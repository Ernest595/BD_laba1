CREATE DATABASE t01_library;

create table public.author (
id serial primary key,
last_name varchar not null,
first_name varchar not null
);

create table public.publishing_house (
id serial primary key,
name varchar not null,
city varchar not null
);

create table public.book (
id serial primary key,
name varchar not null,
author INT references  public.author(id),
code INT references  public.publishing_house(id),
publication INT not null,
year_publication INT not null,
count_publication INT not null
);

create table public.reader (
reader_card_number int primary key,
last_name varchar not null,
first_name varchar not null,
date_birth date not null,
gender char(1) not null,
data_registration date not null 
);

create type enumeration_state as enum ('best','good','normal','old', 'lost');
create type enumeration_status as enum ('available','issued','booked');



create table public.book_instance (
id INT primary key,
information_book INT references public.book(id),
state_book enumeration_state not null default 'best',
status_book enumeration_status not null default 'available',
location_book varchar not null
);

create table public.issuance (
reader_card_number INT references public.reader(reader_card_number),
book_id INT references public.book_instance(id),
data_time TIMESTAMP(0) not null default current_TIMESTAMP(0),
expected_return_date date not null,
date_actual_return DATE null 
);

create table public.booking (
id serial primary key,
reader_card INT references public.reader(reader_card_number),
id_book INTEGER references public.book(id),
min_level enumeration_state not null default 'normal',
data_time TIMESTAMP(2) not null default current_TIMESTAMP(0)
);


