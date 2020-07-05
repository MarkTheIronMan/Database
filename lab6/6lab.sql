--1. Добавить внешние ключи
USE [6lab]

ALTER TABLE [dealer]
ADD CONSTRAINT FK_dealer_company
FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE [order]
ADD CONSTRAINT FK_order_production
FOREIGN KEY (id_production) REFERENCES production(id_production);

ALTER TABLE [order]
ADD CONSTRAINT FK_order_dealer
FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);

ALTER TABLE [order]
ADD CONSTRAINT FK_order_pharmacy
FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);

ALTER TABLE [production]
ADD CONSTRAINT FK_production_company
FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE [production]
ADD CONSTRAINT FK_production_medicine
FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);

--2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов.

SELECT p.name, o.date, o.quantity
FROM [order] o
JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy
JOIN production prod ON prod.id_production = o.id_production
WHERE prod.id_company = (SELECT c.id_company FROM company c WHERE c.name = N'Аргус')
AND prod.id_medicine = (SELECT m.id_medicine FROM medicine m WHERE m.name = N'Кордерон');

--3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.

SELECT m.name
FROM medicine m
JOIN production pr ON pr.id_medicine = m.id_medicine
WHERE pr.id_company = (SELECT c.id_company FROM company c WHERE c.name = N'Фарма')
AND pr.id_production IN (SELECT o.id_production FROM [order] o WHERE o.date < CONVERT(DATE, '2019-01-25'))
GROUP BY m.name;

--4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.

SELECT c.name, MIN(pr.rating) min_rate, MAX(pr.rating) max_rate
FROM production pr
JOIN company c ON c.id_company = pr.id_company
WHERE pr.id_company IN (
	SELECT pr.id_company 
	FROM production pr 
	JOIN [order] o ON o.id_production = pr.id_production 
	GROUP BY pr.id_company 
	HAVING COUNT(*) >= 120) 
GROUP BY c.name;

--5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL.

SELECT DISTINCT p.name Pharmacy, d.name Dealer, c.name Company
FROM company c
INNER JOIN dealer d ON c.id_company = d.id_company
INNER JOIN [order] o ON d.id_dealer = o.id_dealer
LEFT JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy WHERE c.name = 'AstraZeneca'

--6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.

UPDATE production
SET price = p.price * 0.8
FROM production p
JOIN medicine m ON m.id_medicine = p.id_medicine
WHERE p.price > 3000 AND m.cure_duration <= 7;

--7. Добавить необходимые индексы.

CREATE INDEX [IX_medicine_name] ON medicine (name ASC)

CREATE INDEX [IX_company_name] ON company (name ASC)

CREATE INDEX [IX_pharmacy_name] ON pharmacy (name ASC)

CREATE INDEX [IX_order_date] ON [order] (date ASC)

CREATE INDEX [IX_production_id_company] ON production (id_company ASC)

CREATE INDEX [IX_order_id_production-id_dealer-id_pharmacy] ON [order] (id_production ASC, id_dealer ASC, id_pharmacy ASC)

