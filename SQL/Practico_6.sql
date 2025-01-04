/* 1
 * Devuelva la oficina con mayor número de empleados.
 */
SELECT off.officeCode, COUNT(emp.employeeNumber) AS num_emp
FROM offices off
JOIN employees emp ON (off.officeCode = emp.officeCode)
GROUP BY off.officeCode 
ORDER BY num_emp DESC 
LIMIT 1;

/* 2
 * ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor 
 * cantidad de productos?
 */
 
-- Hay que sumar todas las ordenes de todos los clientes de todos los empleados

SELECT emp.employeeNumber , COUNT(ord.orderNumber)
FROM employees emp
JOIN customers cust ON (emp.employeeNumber = cust.salesRepEmployeeNumber)
JOIN orders ord ON (ord.customerNumber = cust.customerNumber)
GROUP BY emp.employeeNumber 

-- Despues sacar el promedio
SELECT officeCode, AVG(order_count) 
FROM (SELECT emp., COUNT(ord.orderNumber) AS order_count
	FROM employees emp
	JOIN employees emp ON (off.officeCode = emp.officeCode)
	JOIN customers cust ON (emp.employeeNumber = cust.salesRepEmployeeNumber)
	JOIN orders ord ON (ord.customerNumber = cust.customerNumber)
	GROUP BY off.officeCode) AS order_for_off
GROUP BY officeCode


-- Primero contabilizamos numero de ordenes por cliente
SELECT cust.salesRepEmployeeNumber AS employee, COUNT(ord.orderNumber)
FROM customers cust
JOIN orders ord ON (cust.customerNumber = ord.customerNumber)
GROUP BY employee

SELECT emp.officeCode, AVG(count_emp.ord_number)
FROM employees emp
JOIN (	SELECT cust.salesRepEmployeeNumber AS employee, COUNT(ord.orderNumber) AS ord_number
		FROM customers cust
		JOIN orders ord ON (cust.customerNumber = ord.customerNumber)
		GROUP BY employee) AS count_emp
	ON (count_emp.employee = emp.employeeNumber)
GROUP BY emp.officeCode 

SELECT emp.officeCode, SUM(count_emp.ord_number) AS sum_ord_number
FROM employees emp
JOIN (	SELECT cust.salesRepEmployeeNumber AS employee, COUNT(ord.orderNumber) AS ord_number
		FROM customers cust
		JOIN orders ord ON (cust.customerNumber = ord.customerNumber)
		GROUP BY employee) AS count_emp
	ON (count_emp.employee = emp.employeeNumber)
GROUP BY emp.officeCode 
ORDER BY sum_ord_number DESC 
LIMIT 1;

/* 3
 * Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.
 */

SELECT 	MAX(data_for_month.amount_for_month) as Max_amounth,
		MIN(data_for_month.amount_for_month) as Min_amounth,
		AVG(data_for_month.amount_for_month) as Avg_amounth	
FROM 	(SELECT EXTRACT(YEAR FROM pay.paymentDate) AS año, 
		EXTRACT(MONTH FROM pay.paymentDate) AS mes, SUM(pay.amount) AS amount_for_month
		FROM payments pay 
		GROUP BY año,mes
		) AS data_for_month

/* 4
 * Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de
 * un cliente con un valor pasado por parámetro.
 */
DELIMITER //
CREATE PROCEDURE Update_Credit (IN new_limit INT,IN customer_id INT) 
BEGIN
	UPDATE customers	
	SET cust.creditLimit = new_limit
	WHERE customerNumber = customer_id
END 
DELIMITER;

/* 5
 * Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más 
 * dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, 
 * la ciudad y el total gastado por ese cliente en la plataforma.
 */

CREATE VIEW premium_customers as 
	SELECT cust.customerNumber , cust.city, SUM(pay.amount) AS total_amount
	FROM customers cust
	JOIN payments pay ON (cust.customerNumber = pay.customerNumber)
	GROUP BY cust.customerNumber, cust.city
	ORDER BY total_amount DESC; 

/* 6
 * Cree una función "employee of the month" que tome un mes y un año y devuelve el 
 * empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de 
 * órdenes en ese mes.
 */

DELIMITER //
CREATE FUNCTION employee_of_the_month(month INT,year INT)
	RETURNS VARCHAR(100)
	DETERMINISTIC
BEGIN
	DECLARE name_lastName VARCHAR(100);
		SELECT CONCAT(e.firstName,' ', e.lastName) INTO name_lastName
		FROM employees e
		JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
		JOIN orders od ON c.customerNumber = od.customerNumber
		WHERE MONTH(od.orderDate) = month AND YEAR(od.orderDate) = year
		GROUP BY e.employeeNumber	
		ORDER BY COUNT(od.orderNumber) DESC
		LIMIT 1;
	RETURN name_lastName;	
END
DELIMITER ;

SELECT employee_of_the_month(1,2003)

/* 7
 * Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno 
 * con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`
 * */

CREATE TABLE ProductRefillment (
    refillmentID INT NOT NULL AUTO_INCREMENT, 
    productCode VARCHAR(15) NOT NULL,
    orderDate DATETIME NOT NULL,
    quantity INT NOT NULL,
    
    PRIMARY KEY (refillmentID),
    FOREIGN KEY (productCode) REFERENCES products(productCode)
);

SHOW COLUMNS FROM products LIKE 'productCode';

/* 8
 * Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados 
 * en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de 
 * productos pedidos (`quantityOrdered`) y compare con la cantidad en stock 
 * (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product
 * Refillment" por 10 nuevos productos.
 */

CREATE TRIGGER Restock_Product AFTER INSERT ON orderdetails 
FOR EACH ROW
	 INSERT INTO product_Refillment (productCode, orderDate, quantity)
	SELECT *
	FROM orderdetails ordd
	JOIN products prod ON (ordd.productCode = prod.productCode)
	WHERE -- DEBERIA COMPARAR 
	
DELIMITER //
CREATE TRIGGER restoc_product AFTER INSERT ON (orderdetails) 
FOR EACH ROW
BEGIN
	DECLARE quantity_ordered INT
DECLARE quantity_in_stock INT
DECLARE product_number INT


SELECT quantityOrdered INTO  quantity_ordered, productCode INTO product_number
FROM orderdetails
WHERE quantityOrdered = NEW.quantityOrdered AND  productCode = NEW. productCode


SELECT quantityInStock INTO quantity_in_stock
FROM products
WHERE quantityInStock = NEW.quantityInStock


if (quantity_ordered > quantity_in_stock OR 10 > quantity_in_stock )
	then INSERT INTO productrefillment (productCode,quantity) 
VALUES (product_number,10)  
end if


END//
DELIMITER ;

