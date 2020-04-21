-- #1 INSERT
INSERT INTO Publisher(name) VALUES ('Drofa');
INSERT INTO Publisher(name) VALUES ('MIF');

INSERT INTO Author (surname, name, date_of_birth, date_of_death)
VALUES ('Scott', 'Walter', '1771-08-15', '1832-09-21');
INSERT INTO Author (surname, name, date_of_birth, date_of_death) 
VALUES ('Alighieri', 'Dante', '1265', '1321');
INSERT INTO Author (surname, name, date_of_birth, date_of_death) 
VALUES ('Shakespeare', 'William', '1564-04-26', '1616-05-03');
INSERT INTO Book (name, id_author, id_publisher, publishing_year)
VALUES ('Divine Comedy', (SELECT id_author FROM Author WHERE surname = 'Alighieri'), (SELECT id_publisher FROM Publisher WHERE name = 'Drofa'), '1995');
INSERT INTO Book (name, id_author, id_publisher, publishing_year)
VALUES ('Hamlet', (SELECT id_author FROM Author WHERE surname = 'Shakespeare'), (SELECT id_publisher FROM Publisher WHERE name = 'Drofa'), '1999');
INSERT INTO Book (name, id_author, id_publisher, publishing_year)
VALUES ('The Talisman', (SELECT id_author FROM Author WHERE surname = 'Scott'), (SELECT id_publisher FROM Publisher WHERE name = 'Drofa'), '2010');
INSERT INTO book_x_order (id_book_in_order, id_order, id_book, book_cost)
VALUES (1, 2, 5, 200);

SET IDENTITY_INSERT Booking ON;
INSERT INTO Booking (id_order, id_customer, date_of_order, total)
VALUES (1, 3, '2020-04-04', 755.5);
INSERT INTO Booking (id_order, id_customer, date_of_order, total)
VALUES (2, 3, '2020-04-05', 400);
INSERT INTO Booking (id_order, id_customer, date_of_order, total)
VALUES (3, 1, '2020-04-05', 200);
SET IDENTITY_INSERT Booking OFF;

SET IDENTITY_INSERT Customer ON;
INSERT INTO Customer (id_customer, customer_type, name, phone_number, sex) VALUES ('1', 'phys', 'John Wayne', '88005553535', 'male');
INSERT INTO Customer (id_customer, customer_type, name, phone_number, sex) VALUES ('2', 'phys', 'John Johnson', '88005553536', 'male');
INSERT INTO Customer (id_customer, customer_type, name, phone_number, sex) VALUES ('3', 'company', 'Jack Johnson', '88005553537', 'none');
SET IDENTITY_INSERT Customer OFF;

--#2 DELETE
DELETE FROM Customer WHERE id_customer = 2;
TRUNCATE TABLE Booking;

--#3 UPDATE
UPDATE Book SET publishing_year = '2001' WHERE id_publisher = 5 AND name = 'Divine Comedy';
UPDATE Customer SET name = 'Mary Johnson', sex = 'female' WHERE id_customer = 1;

--#4 SELECT
SELECT name, phone_number FROM Customer;
SELECT * FROM Customer; 
SELECT * FROM Book WHERE name='Divine Comedy';

--#5 SELECT ORDER BY + TOP (LIMIT)
SELECT TOP 2 * FROM Author ORDER BY name ASC;
SELECT * FROM Author ORDER BY date_of_birth DESC;
SELECT TOP 2 name, surname FROM Author;
SELECT * FROM Author ORDER BY 1;

--#6 DATE
SELECT * FROM Author WHERE date_of_birth = '1771-08-15';
SELECT * FROM Book WHERE YEAR(publishing_year) = 2001;

--#7 SELECT GROUP BY
--min orders from all customers

SELECT id_customer, MIN(total)
FROM Booking
GROUP BY id_customer
HAVING MIN(total) > 50;

--max total from customers by date
SELECT date_of_order AS OrderDate, MAX(total) AS MaxTotal
FROM Booking
GROUP BY date_of_order;

--avg order from all customers
SELECT id_customer AS CUSTOMER_ID, AVG(total) AS Average_total
FROM Booking
GROUP BY id_customer;

--sum profit from all customers > 100
SELECT id_customer, SUM(total) AS SUMMARY
FROM Booking
GROUP BY id_customer
HAVING SUM(total) > 100;

SELECT MONTH(date_of_order) AS MonthNumber, SUM(total) AS AllSales
FROM Booking
GROUP BY date_of_order;

SELECT id_customer, AVG(total) AS Average
FROM Booking
GROUP BY id_customer
HAVING AVG(total) > 150;

--# SELECT JOIN
--get a list of books of target author
SELECT a.name, a.surname, b.name
FROM Author as a
LEFT JOIN Book as b ON a.id_author = b.id_author
WHERE a.name = 'Dante' AND a.surname = 'Alighieri';

--top 2 authors ordered by name
SELECT TOP 2 b.id_author, a.surname, a.name, a.date_of_birth, a.date_of_death
FROM Author as a
RIGHT JOIN Book AS b ON b.id_author = a.id_author
ORDER BY name ASC;

--men who did booking in april 2020
SELECT c.name, b.date_of_order
FROM Customer as c
RIGHT JOIN Booking as b ON c.id_customer = b.id_customer
WHERE c.sex = 'male';

--customers - books publisher's name
SELECT c.name AS CustomerName, p.name AS PublisherName
FROM Customer AS c
LEFT JOIN Booking AS b ON c.id_customer = b.id_customer
LEFT JOIN book_x_order AS bo ON b.id_order = bo.id_order
LEFT JOIN Book AS bk ON bo.id_book = bk.id_book
LEFT JOIN Publisher AS p ON bk.id_publisher = p.id_publisher
WHERE c.id_customer = 3 AND bk.id_book = 5 AND p.id_publisher = 5;

--Authors and their books
SELECT *
FROM Author FULL JOIN Book
ON Author.id_author = Book.id_author;

-- # SUBQUERY
SELECT a.name, a.surname 
FROM Author AS a
WHERE a.name IN (SELECT name FROM Author WHERE date_of_birth < '1600-01-01');

SELECT a.name, a.surname, (SELECT b.name FROM Book AS b
WHERE a.id_author = b.id_author) BookName
FROM Author AS a;



--SUPPORTING QUERIES
SELECT a.name, a.surname
FROM Author AS a


SELECT * FROM Publisher WHERE name = 'Drofa'
SELECT * FROM Author
SELECT * FROM Book
DELETE FROM Publisher WHERE name = 'Drofa'
DELETE FROM Book WHERE name = 'Div'
SELECT * FROM Customer
SELECT * FROM Booking
