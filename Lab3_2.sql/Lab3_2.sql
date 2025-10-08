


insert into public.author (last_name, first_name) 
values 
	('��������', '������'),
	('��������', '����'),
	('���������', '������'),
	('��������', '����'),
	('��������', '�������')
returning id;

insert into public.publishing_house(name,city)
values 
	('�����-�����', '������'),
	('��������', '������������'),
	('����� �����', '������'),
	('�����', '������')
returning id;

insert into public.book(name, author, code, "publication", year_publication, count_publication)
values 
	('���������� �������', 1, 2, 1, 2019, 4200),
	('����� ���', 2, 1, 1, 2013, 5100),
	('������ ������', 3, 3, 1, 2015, 3700),
	('���������', 4, 4, 1, 2016, 2900),
	('��������� � ������������', 5, 2, 1, 2017, 3100)
returning id;

insert into public.reader(reader_card_number, last_name, first_name, date_birth, gender, data_registration)
values 
	(2001, '������', '����', '1990-05-15', 'M', '2024-03-09' ),
	(2002, '������', '�����', '1988-11-14', 'F', '2024-03-05'),
	(2003, '��������', '�������', '1993-02-08', 'M', '2024-03-16'),
	(2004, '�������', '����', '1992-03-18', 'F', '2024-02-15')
returning reader_card_number;

insert into public.book_instance(id, information_book, state_book, status_book, location_book)
values 
	(6001, 1, 'best', 'available', 'A1-B2-C3'),
    (6002, 1, 'good', 'available', 'A1-B2-C4'),
    (6003, 2, 'old', 'available', 'B3-C1-D2'),
    (6004, 3, 'best', 'available', 'C2-D1-E3'),
    (6005, 4, 'good', 'available', 'D4-E2-F1'),
    (6006, 5, 'old', 'available', 'E3-F4-G2'),
    (6007, 1, 'best', 'available', 'A1-B2-C3')
returning id;	


--1
 insert into public.author(last_name, first_name) 
 values 
 	('������', '���������')
 returning id;

update public.author
set last_name = '�������', first_name = '���' 
where id = 6;

delete from public.author 
where id = 6;


--2 
insert into public.publishing_house (name,city)
values
	('�����', '������')	
returning id;

update public.publishing_house
set name = '���', city = '������'
where id = 5;

delete from publishing_house
where id = 5;



--3
insert into public.book (name, author, code, "publication", year_publication, count_publication)
values 
	  ('������� ������', 3, 1, 1, 2018, 4000)
returning id

update public.book
set 
 	name = '����� � ���',
 	author = 1,
 	code = 1,
 	"publication" = 1,
 	year_publication = 2010,
 	count_publication = 5000
 where id = 6;

delete from public.book
where id = 6;



--4 
insert into public.reader(reader_card_number, last_name, first_name, date_birth, gender, data_registration)
values 
	(2005, '�������', '�����', '1985-08-22', 'F', '2024-01-10')
returning reader_card_number;

update public.reader
set
	last_name = '���������',
	first_name = '�������',
	date_birth = '1990-05-20'
where reader_card_number = 2005;

delete from public.reader
where reader_card_number = 2005;



--5
insert into public.book_instance(id, information_book, state_book, status_book, location_book)
values 
	(6008, 4, 'good', 'available', 'F5-G1-H2')
returning id;	

update into public.book_instance
set
	state_book = 'good',
	status_book = 'reserved',
	location_book = 'A2-B1-C5'
where id = 6008;

delete from public.book_instance
where id = 6008;
	

--6
insert into public.issuance(reader_card_number, book_id, data_time, expected_return_date, date_actual_return)
values 
	(2001, 6001, CURRENT_TIMESTAMP(0), CURRENT_DATE + INTERVAL '16 days', NULL)
returning reader_card_number, book_id;

update public.book_instance
set
	status_book = 'issued'
where id = 6001;



--7
update public.issuance
set date_actual_return = CURRENT_DATE
where reader_card_number = 2001
	and book_id = 6001
	and date_actual_return is null 
	
	
update public.book_instance
set status_book =  'available'
where id = 6001;


insert into public.issuance(reader_card_number, book_id, data_time, expected_return_date, date_actual_return)
values 
	(2001, 6002, CURRENT_TIMESTAMP(0) - INTERVAL '21 days', CURRENT_DATE - INTERVAL '7 days', NULL),
    (2002, 6003, CURRENT_TIMESTAMP(0) - INTERVAL '13 days', CURRENT_DATE + INTERVAL '3 days', NULL),
    (2003, 6004, CURRENT_TIMESTAMP(0) - INTERVAL '25 days', CURRENT_DATE - INTERVAL '12 days', NULL);
	
update public.book_instance
set status_book = 'issued'
where id in (6002,6003,6004);


--8
CREATE OR REPLACE view public.issued_books_view AS
SELECT 
	r.last_name AS reader_last_name,
    r.first_name AS reader_first_name,
    a.last_name AS author_last_name,
    a.first_name AS author_first_name,
	b.name as book_title,
	bi.state_book as book_condition,
	i.data_time as issue_date
FROM public.issuance i
INNER JOIN public.reader r ON i.reader_card_number = r.reader_card_number
INNER JOIN public.book_instance bi ON i.book_id = bi.id
INNER JOIN public.book b ON bi.information_book = b.id
INNER JOIN public.author a ON b.author = a.id
WHERE i.date_actual_return IS NULL;

SELECT * FROM public.issued_books_view;



--9
CREATE OR REPLACE VIEW public.overdue_books_view AS
SELECT 
	r.last_name AS reader_last_name,
    r.first_name AS reader_first_name,
    a.last_name AS author_last_name,
    a.first_name AS author_first_name,
	b.name as book_title,
	(CURRENT_DATE - i.expected_return_date) AS overdue_days
FROM public.issuance i
INNER JOIN public.reader r ON i.reader_card_number = r.reader_card_number
INNER JOIN public.book_instance bi ON i.book_id = bi.id
INNER JOIN public.book b ON bi.information_book = b.id
INNER JOIN public.author a ON b.author = a.id
WHERE i.date_actual_return IS null
	 AND i.expected_return_date < CURRENT_DATE;


SELECT * FROM public.overdue_books_view;



--10
WITH overdue_check AS (
    SELECT COUNT(*) as overdue_count 
    FROM public.issuance i
    JOIN public.reader r ON i.reader_card_number = r.reader_card_number
    WHERE r.reader_card_number = 2004
      AND i.date_actual_return IS NULL 
      AND i.expected_return_date < CURRENT_DATE
)
insert into public.issuance(reader_card_number, book_id, data_time, expected_return_date, date_actual_return)
select 
	2004 as reader_card_number,
    6005 as book_id,
    CURRENT_TIMESTAMP(0) as data_time,
    CURRENT_DATE + INTERVAL '14 days' as expected_return_date,
    NULL as date_actual_return
FROM overdue_check
WHERE overdue_count = 0; 

UPDATE public.book_instance
SET status_book = 'issued'
WHERE id = 6005
AND EXISTS (
    SELECT 1 FROM public.issuance 
    WHERE reader_card_number = 2004
    AND book_id = 5005 
    AND date_actual_return IS NULL
);



--11
insert into public.booking(reader_card, id_book, min_level, data_time)
select  2001, 1, 'best', CURRENT_TIMESTAMP(0)
WHERE EXISTS (
    SELECT 1 FROM public.book_instance 
    WHERE information_book = 1 
    AND state_book >= 'best' 
    AND status_book = 'available'
);

update public.book_instance    
set status_book  = 'reserved' 
where information_book = 1
and state_book >= 'best'
and status_book  = 'available';
);



--12 
delete from  public.booking 
where reader_card = 2001 AND id_book = 1;

update public.book_instance 
set status_book = 'available' 
where information_book = 1
and status_book  = 'reserved';



--13
WITH 
overdue_check AS (
    SELECT COUNT(*) as overdue_count 
    FROM public.issuance i
    JOIN public.reader r ON i.reader_card_number = r.reader_card_number
    WHERE r.reader_card_number = 2004
      AND i.date_actual_return IS NULL 
      AND i.expected_return_date < CURRENT_DATE
),

booking_check AS (
    SELECT COUNT(*) as active_booking_count
    FROM public.booking b
    JOIN public.book_instance bi ON b.id_book = bi.information_book 
    WHERE bi.id = 6007
      AND b.reader_card != 2004
      AND b.data_time >= CURRENT_TIMESTAMP - INTERVAL '5 days'
)
insert into public.issuance(reader_card_number, book_id, data_time, expected_return_date, date_actual_return)
select 
	2004 as reader_card_number,
    6007 as book_id,
	CURRENT_TIMESTAMP(0) as data_time,
    CURRENT_DATE + INTERVAL '14 days' as expected_return_date,
    NULL as date_actual_return
FROM overdue_check, booking_check
WHERE overdue_check.overdue_count = 0 
  AND booking_check.active_booking_count = 0;

UPDATE public.book_instance
SET status_book = 'issued'
WHERE id = 6007
AND EXISTS (
    SELECT 1 FROM public.issuance 
    WHERE reader_card_number = 2004
    AND book_id = 6007
    AND date_actual_return IS NULL
);



--14
CREATE OR REPLACE FUNCTION get_book_locations(
    p_book_id INTEGER DEFAULT NULL,
    p_book_name VARCHAR DEFAULT NULL  
)
RETURNS TABLE (
    book_id INTEGER,
    book_name VARCHAR,                
    author_last_name VARCHAR,           
    author_first_name VARCHAR,        
    publishing_house VARCHAR,         
    publication_year INTEGER,
    instance_id INTEGER,
    book_state book_state_type,               
    book_status book_status_type,              
    book_location VARCHAR,
    state_priority INTEGER
) AS $$
begin
	
	IF p_book_id IS NULL AND p_book_name IS NULL THEN
        RAISE EXCEPTION '���������� ������� ID ��� �������� �����';
    END IF;
	
	  RETURN QUERY
    SELECT 
        b.id AS book_id,
        b.book_name,
        a.last_name AS author_last_name,
    	a.first_name AS author_first_name,
        ph.house_name AS publishing_house,
        b.publication_year,
        bi.id AS instance_id,
        bi.book_state,
        bi.book_status,
        bi.book_location,
        CASE 
            WHEN bi.book_state = 'best' 	THEN 1
            WHEN bi.book_state = 'good' 	THEN 2
            WHEN bi.book_state = 'normal' 	THEN 3
            WHEN bi.book_state = 'old' 		THEN 4
            ELSE 5
        END AS state_priority
     FROM public.book b
    INNER JOIN public.author a ON b.author = a.id
    INNER JOIN public.publishing_house ph ON b.house = ph.id
    INNER JOIN public.book_instance bi ON b.id = bi.book_info
    WHERE 
        (p_book_id IS NOT NULL AND b.id = p_book_id) OR
        (p_book_name IS NOT NULL AND b.book_name ILIKE '%' || p_book_name || '%')
    ORDER BY 
        state_priority ASC,
        bi.id ASC;
	  
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM get_book_locations(p_book_id := 1);

	SELECT * FROM get_book_locations(p_book_name := '����� � ���');


--15
CREATE OR REPLACE VIEW public.available_books_view AS
SELECT 
    b.id AS book_id,
    b.book_name,
    a.last_name AS author_last_name,
    a.first_name AS author_first_name,
    ph.house_name AS publishing_house,
    b.publication_year,
    bi.book_state,
    COUNT(bi.id) AS available_copies_count
FROM public.book b
INNER JOIN public.author a ON b.author = a.id
INNER JOIN public.publishing_house ph ON b.house = ph.id
INNER JOIN public.book_instance bi ON b.id = bi.book_info
WHERE bi.book_status = 'available'
GROUP BY 
    b.id, b.book_name, a.last_name, a.first_name, 
    ph.house_name, b.publication_year, bi.book_state
ORDER BY 
    b.book_name,
    CASE 
        WHEN bi.book_state = 'best' 	THEN 1
        WHEN bi.book_state = 'good' 	THEN 2
        WHEN bi.book_state = 'normal' 	THEN 3
        WHEN bi.book_state = 'old' 		THEN 4
        ELSE 5
    END;

SELECT * FROM public.available_books_view;	
	
--16
CREATE OR REPLACE VIEW public.overdue_one_year_books_view AS
SELECT 
    r.reader_card,
    r.last_name AS reader_last_name,
    r.first_name AS reader_first_name,
    b.book_name,
    a.last_name AS author_last_name,
    a.first_name AS author_first_name,
    i.issue_datetime,
    i.expected_return_date,
    (CURRENT_DATE - i.issue_datetime::date) AS days_since_issue
FROM public.issuance i
INNER JOIN public.reader r ON i.reader_card = r.reader_card
INNER JOIN public.book_instance bi ON i.book_instance_id = bi.id
INNER JOIN public.book b ON bi.book_info = b.id
INNER JOIN public.author a ON b.author = a.id
WHERE i.actual_return_date IS NULL 
  AND i.issue_datetime < CURRENT_DATE - INTERVAL '2 year'
ORDER BY i.issue_datetime ASC;

SELECT * FROM public.overdue_one_year_books_view;