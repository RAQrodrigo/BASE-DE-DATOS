-- Cree una tabla de `directors` con las columnas: 

-- 		Nombre, Apellido, Número de Películas.

CREATE TABLE directors (

Nombre varchar(50),

Apellido varchar(50),

NumPeliculas int

);


/* 2

 * El top 5 de actrices y actores de la tabla `actors` que tienen la mayor 

 * experiencia (i.e. el mayor número de películas filmadas) son también 

 * directores de las películas en las que participaron. Basados en esta información, 

 * inserten, utilizando una subquery los valores correspondientes en la tabla 

 * `directors`.

 */

-- Primero selecciono los actores que tambien son directores

INSERT INTO directors VALUES 

(SELECT act.first_name, act.last_name, COUNT(fa.film_id) AS num_film

FROM actor act

JOIN film_actor fa ON (act.actor_id = fa.actor_id)

GROUP BY act.first_name , act.last_name 

ORDER BY num_film  DESC

LIMIT 5;)


INSERT INTO directors (Nombre, Apellido, NumPeliculas)

SELECT act.first_name, act.last_name, COUNT(fa.film_id) AS num_film

FROM actor act

JOIN film_actor fa ON act.actor_id = fa.actor_id

GROUP BY act.first_name, act.last_name

ORDER BY num_film DESC

LIMIT 5;


/* 3

 * Agregue una columna `premium_customer` que tendrá un valor 'T' 

 * o 'F' de acuerdo a si el cliente es "premium" o no. Por defecto ningún 

 * cliente será premium.

 */


ALTER TABLE customer 

ADD premium_customer VARCHAR(1) DEFAULT 'T'


UPDATE customer 

SET premium_customer = 'F';


SELECT * FROM customer c 


/* 4

 * Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` 

 * de los 10 clientes con mayor dinero gastado en la plataforma.

 */


SELECT cus.first_name,cus.last_name, SUM(pay.amount) AS total_pay

FROM customer cus

JOIN payment pay ON (pay.customer_id = cus.customer_id)

GROUP BY cus.first_name, cus.last_name 

ORDER BY total_pay DESC 

LIMIT 10;	


UPDATE customer

JOIN (

    SELECT cus.customer_id

    FROM customer cus

    JOIN payment pay ON pay.customer_id = cus.customer_id

    GROUP BY cus.customer_id

    ORDER BY SUM(pay.amount) DESC

    LIMIT 10

) AS top_customers ON customer.customer_id = top_customers.customer_id

SET premium_customer = 'T';


/* 5

 * Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings 

 * de las películas existentes (Hint: rating se refiere en este caso a la clasificación 

 * según edad: G, PG, R, etc).

 * */


SELECT film.rating, COUNT(*) AS num_film

FROM film 

GROUP BY film.rating 

ORDER BY num_film DESC


SELECT film.rating, COUNT(*) AS num_film

FROM film

GROUP BY film.rating

ORDER BY COUNT(*) DESC;


/* 6

 * ¿Cuáles fueron la primera y última fecha donde hubo pagos?

 */


SELECT MAX(payment.payment_date) AS first, MIN(payment_date) AS last

FROM payment


/* 7

 * Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el 

 * nombre del mes de una fecha).

 */


SELECT EXTRACT(MONTH FROM payment.payment_date) AS mes, AVG(payment.amount) as avgpay

FROM payment

GROUP BY mes;


-- Hay que usar MONTHNAME para que me de lo que hay que usar -- MOUNTNAME(payment.payment_date).


/* 8

 * Listar los 10 distritos que tuvieron 

 * mayor cantidad de alquileres (con la cantidad total de alquileres).

 * */


SELECT addr.district, COUNT(ren.rental_id) AS total_alquileres

FROM address addr

JOIN customer cust ON (cust.address_id = addr.address_id)

JOIN rental ren ON (cust.customer_id = ren.customer_id)

GROUP BY addr.district 

ORDER BY total_alquileres DESC 

LIMIT 10;


/* 9

 * Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero 

 * y representa la cantidad de copias de una misma película que tiene determinada tienda. 

 * El número por defecto debería ser 5 copias.

 * */


ALTER TABLE inventory 

ADD stock INTEGER DEFAULT 5


/* 10

 * Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla 

 * rental, haga un update en la tabla `inventory` restando una copia al stock de la película 

 * rentada (Hint: revisar que el rental no tiene información directa sobre la tienda, 

 * sino sobre el cliente, que está asociado a una tienda en particular).

 * */


CREATE TRIGGER update_stock AFTER INSERT ON rental 

FOR EACH ROW

	UPDATE inventory

	SET inventory.stock = inventory.stock - 1

	WHERE (inventory.inventory_id = NEW.inventory_id)
	
	
/* 11
 * Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es 
 * una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.
 */

CREATE TABLE fines (
 rental_id INTEGER,
 amount DECIMAL(10,2),
 FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

ALTER TABLE fines
ADD PRIMARY KEY (rental_id);

/* 12 
 * Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un
 * registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya
 * tardado más de 3 días (comparación con rental_date). El valor de la multa será el
 * número de días de retraso multiplicado por 1.5.
 */



CREATE PROCEDURE check_date_and_fine()
  INSERT INTO fines (rental_id, amount)
  SELECT rent.rental_id, (TIMESTAMPDIFF(DAY, rent.rental_date, rent.return_date) - 3) * 1.5
  FROM rental rent
  WHERE TIMESTAMPDIFF(DAY, rent.rental_date, rent.return_date) > 3;


CALL check_date_and_fine();
SELECT * FROM fines

-- TIMESTAMPDIFF es una función en MySQL que devuelve la diferencia entre dos valores de tipo TIMESTAMP, o cualquier tipo de dato que pueda ser tratado como una fecha/hora. La diferencia se calcula en términos de la unidad de tiempo que especifiques, como segundos, minutos, horas, días, etc.

/* 13
 * Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a 
 * la tabla `rental`.
 */

CREATE ROLE employee
GRANT INSERT, DROP, UPDATE on rental TO employee

/* 14
 * Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que
 * tenga todos los privilegios sobre la BD `sakila`.
 */

REVOKE DROP ON rental from employee

/* 15
 * Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro 
 * de `administrator`
 */
CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON sakila.* TO administrator;
-- Lo de .* indica que estoy asignando permisos a toda las tablas de la base de datos.
CREATE ROLE empleado_1, empleado_2
GRANT employee TO empleado_1
GRANT administrator to empleado_2
	
