// Supabase Edge Function: send-assignment-email
// Sends assignment notification emails to a list of recipients.
// Requires RESEND_API_KEY env var (recommended).

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

type Payload = {
  assignment_id: string;
  title: string;
  course_id: string;
  description?: string;
  due_date: string;
  assigned_emails: string[];
  is_group?: boolean;
};

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") ?? "no-reply@educollab.app";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  let payload: Payload;
  try {
    payload = await req.json();
  } catch (_) {
    return new Response("Invalid JSON", { status: 400, headers: corsHeaders });
  }

  const {
    assignment_id,
    title,
    course_id,
    description,
    due_date,
    assigned_emails,
    is_group,
  } = payload ?? {};

  if (!assignment_id || !title || !course_id || !due_date || !assigned_emails?.length) {
    return new Response("Missing required fields", { status: 400, headers: corsHeaders });
  }

  const typeLabel = is_group ? "Group" : "Individual";
  const subject = `${typeLabel} Assignment: ${title}`;
  const html = `
    <div style="background:#0B1420;padding:32px 16px;">
      <div style="max-width:560px;margin:0 auto;background:#131C29;border-radius:16px;border:1px solid #2C3543;padding:24px;color:#DAE3F5;font-family:Inter,Arial,sans-serif;">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
          <div style="height:40px;width:40px;border-radius:12px;background:#36D1DC;display:flex;align-items:center;justify-content:center;color:#0B1420;font-weight:700;">EC</div>
          <div>
            <div style="font-size:12px;letter-spacing:1px;color:#B2C5FF;text-transform:uppercase;">EduCollab</div>
            <div style="font-size:18px;font-weight:700;">New ${typeLabel} Assignment</div>
          </div>
        </div>
        <h2 style="margin:0 0 8px 0;font-size:22px;">${title}</h2>
        <div style="margin-bottom:12px;color:#BBC9CA;">
          <div><strong>Course:</strong> ${course_id}</div>
          <div><strong>Due:</strong> ${new Date(due_date).toUTCString()}</div>
          <div><strong>Type:</strong> ${typeLabel}</div>
        </div>
        ${
          description
            ? `<div style="background:#17202D;border-radius:12px;padding:12px;margin-bottom:16px;color:#BBC9CA;">
                 <strong style="color:#DAE3F5;">Details:</strong> ${description}
               </div>`
            : ""
        }
        <a href="https://educollab.app" style="display:inline-block;background:#5EEDF9;color:#0B1420;text-decoration:none;padding:10px 18px;border-radius:999px;font-weight:700;">
          Open EduCollab
        </a>
        <div style="margin-top:16px;font-size:12px;color:#859394;">
          You’re receiving this because a lecturer assigned you coursework in EduCollab.
        </div>
      </div>
    </div>
  `;

  // If RESEND_API_KEY is not set, log and return success so the app flow continues.
  if (!RESEND_API_KEY) {
    console.log("RESEND_API_KEY missing; skipping email send", payload);
    return new Response(JSON.stringify({ ok: true, skipped: true }), {
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const sendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: assigned_emails,
      subject,
      html,
    }),
  });

  if (!sendRes.ok) {
    const errText = await sendRes.text();
    let friendly = errText;
    try {
      const parsed = JSON.parse(errText);
      const message = parsed?.message?.toString() ?? errText;
      if (message.includes("You can only send testing emails")) {
        friendly =
          "Resend restricts test emails. Verify a domain in Resend or send only to your own verified email address.";
      } else {
        friendly = message;
      }
    } catch (_) {
      if (errText.includes("You can only send testing emails")) {
        friendly =
          "Resend restricts test emails. Verify a domain in Resend or send only to your own verified email address.";
      }
    }
    console.error("Email send failed", errText);
    return new Response(JSON.stringify({ ok: false, error: friendly }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  console.log("Email sent", { assignment_id, count: assigned_emails.length });
  return new Response(JSON.stringify({ ok: true }), {
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
});
