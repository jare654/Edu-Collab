// Supabase Edge Function: send-group-invite
// Sends group invite email when a lecturer adds a member.
// Requires RESEND_API_KEY env var (recommended).

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

type Payload = {
  group_id: string;
  email: string;
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

  const { group_id, email } = payload ?? {};
  if (!group_id || !email) {
    return new Response("Missing required fields", { status: 400, headers: corsHeaders });
  }

  const subject = "You’ve been added to a group in EduCollab";
  const html = `
    <div style="background:#0B1420;padding:32px 16px;">
      <div style="max-width:560px;margin:0 auto;background:#131C29;border-radius:16px;border:1px solid #2C3543;padding:24px;color:#DAE3F5;font-family:Inter,Arial,sans-serif;">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
          <div style="height:40px;width:40px;border-radius:12px;background:#36D1DC;display:flex;align-items:center;justify-content:center;color:#0B1420;font-weight:700;">EC</div>
          <div>
            <div style="font-size:12px;letter-spacing:1px;color:#B2C5FF;text-transform:uppercase;">EduCollab</div>
            <div style="font-size:18px;font-weight:700;">Group Invitation</div>
          </div>
        </div>
        <h2 style="margin:0 0 8px 0;font-size:22px;">You’ve been added to a group</h2>
        <div style="margin-bottom:12px;color:#BBC9CA;">
          Your lecturer added you to a group in EduCollab.
        </div>
        <a href="https://educollab.app" style="display:inline-block;background:#5EEDF9;color:#0B1420;text-decoration:none;padding:10px 18px;border-radius:999px;font-weight:700;">
          Open EduCollab
        </a>
        <div style="margin-top:16px;font-size:12px;color:#859394;">
          Group ID: ${group_id}
        </div>
      </div>
    </div>
  `;

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
      to: [email],
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

  console.log("Invite sent", { group_id, email });
  return new Response(JSON.stringify({ ok: true }), {
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
});
