-- EDU SITE PRO V2 - RUN THIS IN A NEW/EMPTY PROJECT
create extension if not exists "uuid-ossp";

create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 email text,
 role text default 'owner',
 created_at timestamptz default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.profiles(id,full_name,email,role)
 values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''),new.email,'owner')
 on conflict(id) do nothing;
 return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.schools(
 id uuid primary key default uuid_generate_v4(),
 owner_id uuid references public.profiles(id) on delete cascade,
 school_name text not null,
 slug text unique not null,
 principal_name text,
 phone text,email text,address text,about_school text,
 is_public boolean default false,
 status text default 'pending',
 created_at timestamptz default now()
);

create table if not exists public.team_members(
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 name text not null, designation text, description text, photo_url text,
 created_at timestamptz default now()
);

create table if not exists public.forms(
 id uuid primary key default uuid_generate_v4(),
 school_id uuid references public.schools(id) on delete cascade,
 title text not null, slug text not null, description text,
 is_active boolean default true, created_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.schools enable row level security;
alter table public.team_members enable row level security;
alter table public.forms enable row level security;

create policy "profiles own read" on public.profiles for select to authenticated using(auth.uid()=id);

create policy "school public or owner read" on public.schools for select using(is_public=true or owner_id=auth.uid());
create policy "school owner insert" on public.schools for insert to authenticated with check(owner_id=auth.uid());
create policy "school owner update" on public.schools for update to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());

create policy "team public or owner read" on public.team_members for select using(
 exists(select 1 from public.schools s where s.id=school_id and (s.is_public=true or s.owner_id=auth.uid()))
);
create policy "team owner insert" on public.team_members for insert to authenticated with check(
 exists(select 1 from public.schools s where s.id=school_id and s.owner_id=auth.uid())
);
create policy "team owner delete" on public.team_members for delete to authenticated using(
 exists(select 1 from public.schools s where s.id=school_id and s.owner_id=auth.uid())
);

create policy "forms public or owner read" on public.forms for select using(
 is_active=true or exists(select 1 from public.schools s where s.id=school_id and s.owner_id=auth.uid())
);
create policy "forms owner insert" on public.forms for insert to authenticated with check(
 exists(select 1 from public.schools s where s.id=school_id and s.owner_id=auth.uid())
);
create policy "forms owner delete" on public.forms for delete to authenticated using(
 exists(select 1 from public.schools s where s.id=school_id and s.owner_id=auth.uid())
);
