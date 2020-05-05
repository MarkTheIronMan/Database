-- 1. �������� ������� �����

ALTER TABLE booking 
ADD CONSTRAINT FK_client FOREIGN KEY (id_client) REFERENCES client(id_client);

ALTER TABLE room
ADD CONSTRAINT fk_room_hotel FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room
ADD CONSTRAINT fk_room_room_category FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_booking FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_room FOREIGN KEY (id_room) REFERENCES room (id_room);

-- 2. ������ ���������� � �������� ��������� �������, ����������� � ������� ��������� ����� �� 1 ������ 2019�.

SELECT 
	c.id_client, c.name, c.phone
FROM client AS c
	JOIN booking AS b ON b.id_client = c.id_client
	JOIN room_in_booking AS rib ON rib.id_booking = b.id_booking
	JOIN room AS r ON rib.id_room = r.id_room
	JOIN hotel AS h ON r.id_hotel = h.id_hotel
WHERE h.name = N'������'
	AND r.id_room_category = (SELECT rc.id_room_category FROM room_category AS rc WHERE rc.name = N'����')
	AND rib.checkin_date <= '2019-04-01'
	AND rib.checkout_date > '2019-04-01';

-- 3.  ���� ������ ��������� ������� ���� �������� �� 22 ������.
SELECT 
	r.id_room, h.name
FROM room AS r
	JOIN hotel AS h ON r.id_hotel = h.id_hotel
WHERE 
	r.id_room NOT IN (
		SELECT 
			rib.id_room
		FROM 
			room_in_booking AS rib
		WHERE 
			rib.checkin_date <= '2019-04-22' AND rib.checkout_date > '2019-04-22'
	) 
ORDER BY h.name, r.id_room;

-- 4.  ���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� �������
SELECT 
	rc.name AS room_cat, COUNT(c.id_client) AS clients_count
FROM 
	room_in_booking AS rib
	JOIN booking AS b ON b.id_booking = rib.id_booking
	JOIN client AS c ON c.id_client = b.id_client
	JOIN room AS r ON rib.id_room = r.id_room
	JOIN hotel AS h ON h.id_hotel = r.id_hotel
	JOIN room_category AS rc ON rc.id_room_category = r.id_room_category
WHERE (h.name = N'������'
	AND rib.checkin_date <= '2019-03-23'
	AND rib.checkout_date > '2019-03-23')
GROUP BY rc.name;

-- 5. ���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������, ��������� � ������ � ��������� ���� ������.
SELECT
	c.name, r.id_room, rib.checkout_date checkout_date
FROM
	room_in_booking rib
	JOIN booking b ON b.id_booking = rib.id_booking
	JOIN client c on c.id_client = b.id_client
	JOIN room r ON r.id_room = rib.id_room
	JOIN hotel h ON h.id_hotel = r.id_hotel
WHERE
	h.name = N'������'
	AND rib.checkout_date >= '2019-04-01'
	AND rib.checkout_date < '2019-05-01'
	AND rib.checkin_date = (SELECT MAX(rib.checkout_date) WHERE rib.id_room = r.id_room)
ORDER BY r.id_room, rib.checkout_date DESC;

-- 6. �������� �� 2 ��� ���� ���������� � ��������� ������� ���� �������� ������ ��������� �������, ������� ���������� 10 ���.

UPDATE 
	room_in_booking
SET
	checkout_date = DATEADD(day, 2, checkout_date)
FROM
	room_in_booking rib
	JOIN room AS r ON r.id_room = rib.id_room
	JOIN hotel AS h ON h.id_hotel = r.id_hotel
	JOIN room_category AS rc ON rc.id_room_category = r.id_room_category
WHERE
	h.name = N'������'
	AND rc.name = N'������'
	AND rib.checkin_date = '2019-05-10';

-- 7. ����� ��� "��������������" �������� ����������. ���������� ���������: �� 
-- ����� ���� ������������ ���� ����� �� ���� ���� ��������� ���, �.�. ������ 
-- ���������� ���������� �������� � ���� �����. ������ � �������
-- room_in_booking � id_room_in_booking = 5 � 2154 �������� �������� 
-- ������������� ���������, ������� ���������� �����. �������������� ������ 
-- ������� ������ ��������� ���������� � ���� ������������� �������.

SELECT
	rib.id_room_in_booking,
	rib.id_booking,
	rib.id_room,
	rib.checkin_date,
	rib.checkout_date,
	rib2.id_room_in_booking,
	rib2.id_booking,
	rib2.id_room,
	rib2.checkin_date,
	rib2.checkout_date
FROM
	room_in_booking rib
	JOIN room_in_booking rib2 ON (
		rib.id_room = rib2.id_room
		AND rib.id_booking <> rib2.id_booking
		AND rib.checkin_date BETWEEN rib2.checkin_date AND rib2.checkout_date
	);

SELECT * FROM client
-- 8. ������� ������������ � ����������.

BEGIN TRANSACTION
DECLARE @namevar varchar(30)
SET @namevar = 'Bill Gates';
INSERT INTO client (name, phone) VALUES (@namevar, '7(800)555-35-35')
INSERT INTO booking (id_client, booking_date) VALUES ((SELECT c.id_client FROM client c WHERE name = @namevar), GETDATE())
INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date) VALUES (
	(SELECT 
		b.id_booking 
	FROM booking b 
	JOIN client c ON b.id_client=c.id_client
	WHERE
		c.name = @namevar), 42, '2020-05-05', '2020-06-06')
IF @@ERROR <> 0
	ROLLBACK
COMMIT;

-- ��������
-- SELECT * FROM client WHERE name = 'Bill Gates'
-- SELECT * FROM booking WHERE id_client = 86
-- SELECT * FROM room_in_booking WHERE id_booking = 2001

-- 9. �������� ����������� ������� ��� ���� ������.

CREATE NONCLUSTERED INDEX [IX_client_name]
ON client (name ASC)

CREATE NONCLUSTERED INDEX [IX_client_phone]
ON client (phone ASC)

CREATE NONCLUSTERED INDEX [IX_booking_id_client]
ON booking (id_client ASC)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_booking]
ON room_in_booking (id_booking ASC)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room]
ON room_in_booking (id_room ASC)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkin_date-checkout_date]
ON room_in_booking (checkin_date ASC, checkout_date ASC)

CREATE NONCLUSTERED INDEX [IX_room_id_hotel-id_room_category]
ON room (id_hotel ASC, id_room_category ASC)

CREATE NONCLUSTERED INDEX [IX_hotel_name]
ON hotel (name ASC)