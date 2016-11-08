use TDDD37;
-- 1
select * from jbemployee;
-- 2
select name from jbdept order by name ASC;
-- 3
select * from jbparts where qoh = 0;
-- 4
select * from jbemployee where salary between 9000 and 10000;
-- 5 (?)
select * from jbemployee order by startyear;
-- 6
select * from jbemployee where name like "%son";
-- 7
select * from jbitem item where exists (select id from jbsupplier where id = item.supplier and name = "Fisher-Price");
-- 8
select * from jbitem where supplier=89;
-- 9
select name from jbcity city where (select count(*) from jbsupplier where city.id = city) > 0;
-- 10 (?)
select * from jbparts part where exists (select * from jbparts where name like "%card reader" and weight < part.weight);
-- 11
select joinpart.* from jbparts part
right join jbparts joinpart on joinpart.weight > part.weight
where part.name like "%card reader%";
-- 12
select avg(weight) from jbparts where color = "black";
-- 13
select avg(weight) from jbparts jp
left join jbsupply js on js.part = jp.id
left join jbsupplier jss on jss.id = js.supplier
group by jss.name;
-- 14.0
DROP TABLE IF EXISTS reitem CASCADE;
CREATE TABLE reitem(
    id INT,
    name VARCHAR(20),
    dept INT NOT NULL,
    price INT,
    qoh INT UNSIGNED,
    supplier INT NOT NULL,
	CONSTRAINT pk_item PRIMARY KEY(id)
) ENGINE=InnoDB;
-- 14.1
insert into reitem
select * from jbitem where price < (select avg(price) from jbitem);
select * from reitem;
-- 15
create VIEW item_lessthen_avg as
select * from jbitem where price < (select avg(price) from jbitem);
select * from item_lessthen_avg;
-- 16
-- Table is static and contains the actually data
-- A view is a sql select query combined with the table(s) and is therefor dynamic
-- 17
drop view if exists customer_debit;
create view customer_debit as
select item.name,sale.debit,item.price*sale.quantity as total_cost from jbsale sale,jbitem item
where item.id = sale.item;
select * from customer_debit;
-- 18, inner join since we are interested in the sales of items that exists and
-- can be counted for. 
drop view if exists customer_debit;
create view customer_debit as
select item.name,sale.debit,item.price*sale.quantity as total_cost from jbsale sale
inner join jbitem item on item.id = sale.item;
select * from customer_debit;
-- 19a/b The following dependencies are in the data
-- The suppliers of los angeles has supplied items
-- These items are sold to customer
-- First we need to remove the jbsale tuples,
-- Then remove the items
-- Then remoe the sale
delete sale from jbsale sale
left join jbitem item on sale.item = item.id
left join jbsupplier supp on item.supplier = supp.id
left join jbcity city on city.id = supp.city
where city.name = "Los Angeles";

delete item from jbitem item
left join jbsupplier supp on item.supplier = supp.id
left join jbcity city on city.id = supp.city
where city.name = "Los Angeles";

delete jbsupplier from jbsupplier
left join jbcity jcity on jcity.id = jbsupplier.city
where jcity.name = "Los Angeles";
-- 20
drop view if exists jbsale_supply;
CREATE VIEW jbsale_supply(supplier, item, quantity) AS
SELECT jbsupplier.name, jbitem.name, IFNULL(jbsale.quantity,0)
FROM jbsupplier, jbitem
left join jbsale on jbsale.item = jbitem.id
WHERE jbsupplier.id = jbitem.supplier;
SELECT * from jbsale_supply;
SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
GROUP BY supplier;


