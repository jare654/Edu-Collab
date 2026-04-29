-- Core schema for Academic Collab (aligns with app models)

-- Assignments
create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  course_id text not null,
  description text,
  due_date timestamptz,
  is_completed boolean not null default false,
  attachment_url text,
  assigned_emails text[] not null default '{}'::text[],
  is_group boolean not null default false,
  created_at timestamptz not null default now()
);

-- Ensure columns exist (safe for existing tables)
alter table public.assignments add column if not exists description text;
alter table public.assignments add column if not exists due_date timestamptz;
alter table public.assignments add column if not exists is_completed boolean default false;
alter table public.assignments add column if not exists attachment_url text;
alter table public.assignments add column if not exists assigned_emails text[] default '{}'::text[];
alter table public.assignments add column if not exists is_group boolean default false;

create index if not exists assignments_assigned_emails_gin
  on public.assignments using gin (assigned_emails);
create index if not exists assignments_due_date_idx
  on public.assignments (due_date);

-- Submissions
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments(id) on delete cascade,
  student_id uuid not null,
  submission_url text,
  submitted_at timestamptz not null default now(),
  grade text,
  feedback text
);

alter table public.submissions add column if not exists submission_url text;
alter table public.submissions add column if not exists submitted_at timestamptz;
alter table public.submissions add column if not exists grade text;
alter table public.submissions add column if not exists feedback text;

create index if not exists submissions_assignment_idx
  on public.submissions (assignment_id);
create index if not exists submissions_student_idx
  on public.submissions (student_id);

-- Groups
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  course_code text,
  description text,
  created_by uuid,
  created_at timestamptz not null default now()
);

alter table public.groups add column if not exists course_code text;
alter table public.groups add column if not exists description text;
alter table public.groups add column if not exists created_by uuid;

create index if not exists groups_course_code_idx
  on public.groups (course_code);

-- Group Members
create table if not exists public.group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now()
);

alter table public.group_members add column if not exists email text;
alter table public.group_members add column if not exists created_at timestamptz;

create index if not exists group_members_group_idx
  on public.group_members (group_id);
create index if not exists group_members_email_idx
  on public.group_members (email);

-- Notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  recipient_email text,
  title text,
  body text,
  created_at timestamptz not null default now(),
  read boolean not null default false
);

alter table public.notifications add column if not exists user_id uuid;
alter table public.notifications add column if not exists recipient_email text;
alter table public.notifications add column if not exists title text;
alter table public.notifications add column if not exists body text;
alter table public.notifications add column if not exists read boolean default false;

create index if not exists notifications_user_idx
  on public.notifications (user_id);
create index if not exists notifications_email_idx
  on public.notifications (recipient_email);

-- Enable RLS
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.groups enable row level security;
alter table public.notifications enable row level security;

-- Assignments: lecturers manage, students read
create policy "Assignments readable by authenticated"
on public.assignments for select
to authenticated
using (auth.role() = 'authenticated');

create policy "Assignments managed by lecturers"
on public.assignments for all
to authenticated
using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer')
with check ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer');

-- Submissions: students submit their own, lecturers read all
create policy "Submissions readable by lecturers"
on public.submissions for select
to authenticated
using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer');

create policy "Submissions readable by owner"
on public.submissions for select
to authenticated
using (student_id = auth.uid());

create policy "Submissions insert by owner"
on public.submissions for insert
to authenticated
with check (student_id = auth.uid());

-- Groups: authenticated users can read (tighten with membership when available)
create policy "Groups readable by authenticated"
on public.groups for select
to authenticated
using (auth.role() = 'authenticated');

-- Groups: lecturers manage groups
create policy "Groups managed by lecturers"
on public.groups for all
to authenticated
using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer')
with check ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer');

-- Group members table (if present)
create policy "Group members readable by authenticated"
on public.group_members for select
to authenticated
using (auth.role() = 'authenticated');

create policy "Group members managed by lecturers"
on public.group_members for all
to authenticated
using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer')
with check ((auth.jwt() -> 'user_metadata' ->> 'role') = 'lecturer');

-- Notifications: authenticated users can read
create policy "Notifications readable by authenticated"
on public.notifications for select
to authenticated
using (
  auth.role() = 'authenticated'
  and (
    recipient_email is null
    or lower(recipient_email) = lower(auth.jwt() ->> 'email')
  )
);

create policy "Notifications insert by authenticated"
on public.notifications for insert
to authenticated
with check (
  auth.role() = 'authenticated'
);

-- Storage policies (bucket: assignments)
alter table storage.objects enable row level security;

create policy "Assignments bucket public read"
on storage.objects for select
to public
using (bucket_id = 'assignments');

create policy "Assignments bucket authenticated write"
on storage.objects for insert
to authenticated
with check (bucket_id = 'assignments' and auth.role() = 'authenticated');

-- Storage policies (bucket: avatars)
create policy "Avatars bucket public read"
on storage.objects for select
to public
using (bucket_id = 'avatars');

create policy "Avatars bucket authenticated write"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Avatars bucket authenticated update"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Avatars bucket authenticated delete"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Meetings: sessions + attendance
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  group_id text not null,
  room_name text not null,
  created_by uuid,
  start_time timestamptz not null default now(),
  end_time timestamptz
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.sessions(id) on delete cascade,
  user_id uuid not null,
  role text,
  join_time timestamptz not null default now(),
  leave_time timestamptz
);

alter table public.sessions enable row level security;
alter table public.attendance enable row level security;

create policy "Sessions readable by authenticated"
on public.sessions for select
to authenticated
using (auth.role() = 'authenticated');

create policy "Sessions insert by authenticated"
on public.sessions for insert
to authenticated
with check (auth.role() = 'authenticated');

create policy "Attendance readable by authenticated"
on public.attendance for select
to authenticated
using (auth.role() = 'authenticated');

create policy "Attendance insert by authenticated"
on public.attendance for insert
to authenticated
with check (auth.role() = 'authenticated');

create policy "Attendance update by authenticated"
on public.attendance for update
to authenticated
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');
