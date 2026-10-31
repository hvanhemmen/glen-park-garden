-- Glen Park Garden Dashboard: run this once in Supabase > SQL Editor > New query > Run.

-- 1. The plant table
create table if not exists public.glen_park_plants (
  id            text primary key default gen_random_uuid()::text,
  name          text not null check (char_length(name) between 1 and 80),
  spot          text not null default '' check (char_length(spot) <= 120),
  water_every   int  not null default 3 check (water_every between 1 and 60),
  every_rain    int  check (every_rain between 1 and 90),
  outdoor       boolean not null default true,
  kind          text not null default 'leafy' check (kind in ('leafy','flower','succulent','veg')),
  notes         text not null default '' check (char_length(notes) <= 500),
  added         date default current_date,
  history       date[] not null default '{}' check (cardinality(history) <= 120),
  last_watered  date,
  snooze_until  date,
  updated_at    timestamptz not null default now()
);

-- 2. Security: anyone with the page can read and edit plants in this one table, nothing else.
-- Give the public (anon) role access to this table only. Needed when "Automatically expose new tables" is off.
grant usage on schema public to anon;
grant select, insert, update, delete on public.glen_park_plants to anon;
alter table public.glen_park_plants enable row level security;
drop policy if exists "garden read"   on public.glen_park_plants;
drop policy if exists "garden insert" on public.glen_park_plants;
drop policy if exists "garden update" on public.glen_park_plants;
drop policy if exists "garden delete" on public.glen_park_plants;
create policy "garden read"   on public.glen_park_plants for select to anon using (true);
create policy "garden insert" on public.glen_park_plants for insert to anon with check (true);
create policy "garden update" on public.glen_park_plants for update to anon using (true) with check (true);
create policy "garden delete" on public.glen_park_plants for delete to anon using (true);

-- 3. Live updates between devices
alter publication supabase_realtime add table public.glen_park_plants;

-- 4. Suzy's plants so far (bought Oct 31, 2026)
insert into public.glen_park_plants (id, name, water_every, every_rain, outdoor, kind, notes, added) values
 ('yarrow','Yarrow',4,10,true,'flower','California native. Tough and drought tolerant once settled; flat flower heads feed lots of tiny native bees and hoverflies.','2026-10-31'),
 ('seaside-daisy','Seaside daisy',4,10,true,'flower','SF coastal native with lavender daisies most of the year. Snip spent flowers to keep it blooming.','2026-10-31'),
 ('coffeeberry','Coffeeberry',6,14,true,'leafy','California native shrub. Tiny flowers feed bees, and the berries feed birds. Low water once established.','2026-10-31'),
 ('manzanita','Manzanita',7,21,true,'leafy','California native. Hates wet feet: use a fast-draining mix, never leave it in a saucer, and let it dry out between waterings. Winter flowers feed hummingbirds and bumble bees.','2026-10-31'),
 ('arugula','Arugula',2,4,true,'veg','Cool-season green, great for SF winters. Pick outer leaves often.','2026-10-31'),
 ('chives','Chives',2,5,true,'veg','Perennial herb. Snip leaves down to 2 inches and it regrows; bees love the purple flowers in spring.','2026-10-31'),
 ('carrots','Carrots',2,4,true,'veg','Need a deep pot (10+ inches). Keep the soil evenly moist so roots grow straight and don''t split.','2026-10-31')
on conflict (id) do nothing;
