-- EduSite Pro starter database
create extension if not exists "uuid-ossp";

create type public.user_role as enum ('super_admin','owner','student');

create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 email text,
 phone text,
 role public.user_role default 'owner',
 is_active boolean default true,
 created_at timestamptz default now()
);

create table public.schools (
 id uuid primary key default uuid_generate_v4(),
 owner_id uuid references public.profiles(id) on delete cascade,
 school_name text not null,
 slug text unique not null,
 principal_name text,
 email text,
 phone text,
 address text,
 about_school text,
 logo_url text,
 banner_url text,
 status text default 'pending',
 is_public boolean default false,
 created_at timestamptz default now()
);

create table public.team_members (
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 name text not null,
 designation text,
 description text,
 photo_url text,
 created_at timestamptz default now()
);

create table public.forms (
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 title text not null,
 slug text not null,
 description text,
 is_active boolean default true,
 created_at timestamptz default now()
);

create table public.form_fields (
 id uuid primary key default uuid_generate_v4(),
 form_id uuid references public.forms(id) on delete cascade,
 label text not null,
 field_name text not null,
 field_type text default 'text',
 options jsonb default '[]'::jsonb,
 is_required boolean default false,
 display_order integer default 0
);

create table public.form_submissions (
 id uuid primary key default uuid_generate_v4(),
 form_id uuid references public.forms(id) on delete cascade,
 submission_data jsonb default '{}'::jsonb,
 submitted_at timestamptz default now()
);

create table public.news (
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 title text not null,
 description text,
 image_url text,
 is_published boolean default true,
 created_at timestamptz default now()
);

create table public.notices (
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 title text not null,
 description text,
 file_url text,
 is_published boolean default true,
 created_at timestamptz default now()
);

insert into storage.buckets(id,name,public) values
('school-logos','school-logos',true),
('team-photos','team-photos',true),
('gallery','gallery',true)
on conflict do nothing;

-- Enable RLS before production deployment and add owner/admin policies.
