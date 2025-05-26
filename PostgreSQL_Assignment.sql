-- Table creation query
-- Rangers table
create table if not exists public.rangers
(
    ranger_id  serial
        primary key,
    name       varchar(100) not null,
    region     varchar(100) not null,
    created_at timestamp default CURRENT_TIMESTAMP
);

alter table public.rangers
    owner to postgres;

-- Sighting Table
create table if not exists public.sightings
(
    sighting_id   serial
        primary key,
    ranger_id     integer      not null
        references public.rangers
            on delete cascade,
    species_id    integer      not null
        references public.species
            on delete cascade,
    location      varchar(200) not null,
    sighting_time timestamp    not null,
    notes         text,
    created_at    timestamp default CURRENT_TIMESTAMP
);

alter table public.sightings
    owner to postgres;

create index if not exists idx_sightings_ranger_id
    on public.sightings (ranger_id);

create index if not exists idx_sightings_species_id
    on public.sightings (species_id);

create index if not exists idx_sightings_time
    on public.sightings (sighting_time);

-- Species Table
create table if not exists public.species
(
    species_id          serial
        primary key,
    common_name         varchar(100) not null,
    scientific_name     varchar(150) not null
        unique,
    discovery_date      date         not null,
    conservation_status varchar(50)  not null
        constraint species_conservation_status_check
            check ((conservation_status)::text = ANY
                   ((ARRAY ['Endangered'::character varying, 'Vulnerable'::character varying, 'Near Threatened'::character varying, 'Least Concern'::character varying, 'Historic'::character varying])::text[])),
    created_at          timestamp default CURRENT_TIMESTAMP
);

alter table public.species
    owner to postgres;

create index if not exists idx_species_status
    on public.species (conservation_status);

-- Sample Data inserting queries
insert into rangers (name, region) values
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

insert into species (common_name, scientific_name, discovery_date, conservation_status) values
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

insert into sightings (species_id, ranger_id, location, sighting_time, notes) values
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);


-- Problem 01:
insert into rangers (name, region) values ('Derek Fox', 'Coastal Plains');

-- Problem 02:
select count(distinct s.species_id) from sightings s;

-- Problem 03:
select * from sightings where location ilike '%Pass%';

-- Problem 04
select r.name as name, count(s.ranger_id) as total_sightings from rangers r
left join sightings s on r.ranger_id = s.ranger_id
group by r.ranger_id,r.name
order by r.name;

-- Problem 05
select sp.common_name
from species sp
left join sightings s on sp.species_id = s.species_id
where s.species_id is null;

-- Problem 06
select sp.common_name, si.sighting_time, r.name from sightings si
left join species sp on si.species_id = sp.species_id
left join rangers r on si.ranger_id = r.ranger_id
order by si.sighting_time desc
limit 2;

-- Problem 07
update species sp set conservation_status = 'Historic'
where extract(year from discovery_date) < 1800;

-- Problem 08
select sighting_id,
       case
          when extract(hour from sighting_time) < 12 then 'Morning'
          when extract(hour from sighting_time) between 12 and 17 then 'Afternoon'
          else 'Evening'
       end as time_of_day
       from sightings
    order by sighting_id;

-- Problem 09
delete from rangers r
where r.ranger_id not in (
    select distinct r.ranger_id
    from sightings si
    where r.ranger_id is not null
    );