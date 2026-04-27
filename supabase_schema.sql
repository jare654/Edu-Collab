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
