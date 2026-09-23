-- =========================================================
--  Feedback Board — รันไฟล์นี้ใน Supabase > SQL Editor ครั้งเดียว
-- =========================================================

-- 1) ตารางเก็บความคิดเห็น
create table if not exists public.feedback (
  id          bigint generated always as identity primary key,
  rating      smallint    not null check (rating between 1 and 5),
  comment     text        not null check (char_length(btrim(comment)) between 1 and 1000),
  name        text        check (name is null or char_length(name) <= 50),
  created_at  timestamptz not null default now()
);

create index if not exists feedback_created_at_idx
  on public.feedback (created_at desc);

-- 2) เปิด Row Level Security (สำคัญมาก)
alter table public.feedback enable row level security;

-- ทุกคนอ่านได้
drop policy if exists "public can read feedback" on public.feedback;
create policy "public can read feedback"
  on public.feedback for select
  to anon, authenticated
  using (true);

-- ทุกคนเขียนได้ (แต่แก้ไข/ลบไม่ได้ เพราะไม่มี policy update/delete)
drop policy if exists "public can insert feedback" on public.feedback;
create policy "public can insert feedback"
  on public.feedback for insert
  to anon, authenticated
  with check (true);

-- 3) ฟังก์ชันคำนวณคะแนนเฉลี่ย + จำนวนทั้งหมด (คำนวณจากข้อมูลจริงทั้งตาราง)
create or replace function public.feedback_stats()
returns table (avg_rating numeric, total bigint)
language sql
stable
security invoker
as $$
  select coalesce(round(avg(rating)::numeric, 2), 0) as avg_rating,
         count(*)                                    as total
  from public.feedback;
$$;

grant execute on function public.feedback_stats() to anon, authenticated;

-- 4) เปิด Realtime ให้การ์ดใหม่เด้งขึ้นเองโดยไม่ต้องรีเฟรช
do $$
begin
  alter publication supabase_realtime add table public.feedback;
exception when duplicate_object then null;
end $$;
