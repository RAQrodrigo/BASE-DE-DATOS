/*
 * Cómo insertar un elemento.
 * 
 */

INSERT INTO continent (Name,Area,Porcent_total_mass,Most_populous_city)
VALUES ("Africa",30370000,20.4,608)

SELECT c.Code, c.Name, ct.Name , ct.ID 
FROM country c 
JOIN city ct ON (ct.CountryCode = c.Code)
WHERE c.Name = "Egypt"

/*-------------------------------------- CONSULTAS --------------------------------------------- */

/* Devuelva una lista de los nombres y las regiones a las que pertenece 
 * cada país ordenada alfabéticamente.
 */

SELECT co.Name, co.Region 
FROM country co 
ORDER BY co.Name ASC 

/* Liste el nombre y la población de las 10 ciudades más pobladas del mundo. */

SELECT ci.Name,ci.Population 
FROM city ci
ORDER BY ci.Population DESC 
LIMIT 10

/* Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie. */

SELECT co.Name,co.Region,co.SurfaceArea 
FROM country co
ORDER BY co.SurfaceArea ASC
LIMIT 10

/* Liste todos los países que no tienen independencia (hint: ver que define la independencia de un país en la BD).
 */

SELECT c.Name, c.IndepYear
FROM country c
WHERE c.IndepYear IS NOT NULL 
ORDER BY c.IndepYear ASC

/* Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales. */

SELECT cl.`Language` , cl.Percentage 
FROM countrylanguage cl
WHERE cl.Isofficial = "T"

/* ---------- JOINS ---------- */

/* Lista el nombre de la ciudad, nombre del país, región y forma de gobierno 
 * de las 10 ciudades más pobladas del mundo. */

SELECT ci.Name, c.Name, c.Region, c.GovernmentForm 
FROM country c 
JOIN city ci ON (ci.CountryCode = c.Code)
ORDER BY ci.Population DESC
LIMIT 10

/* Listar los 10 países con menor población del mundo, junto a sus ciudades capitales 
 * (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso 
 * deberá mostrar "NULL").
 */

SELECT c.Name,ci.Name 
FROM country c 
LEFT JOIN city ci ON (c.Capital = ci.ID)

/* Listar el nombre, continente y todos los lenguajes oficiales de cada país. 
 * (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
 */

SELECT c.Name, c.Continent, cl.`Language` 
FROM country c 
JOIN countrylanguage cl ON (cl.Countrycode = c.Code)
WHERE (cl.Isofficial = "T")

/* Listar el nombre del país y nombre de capital, de los 20 países con mayor 
 * superficie del mundo. */

SELECT co.Name, ci.Name 
FROM country co
LEFT JOIN city ci ON (co.Capital = ci.ID)
ORDER BY co.SurfaceArea DESC

/* Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) 
 * y el porcentaje de hablantes del idioma. */

SELECT ci.Name, cl.`Language`, cl.Percentage 
FROM city ci
JOIN country co ON (ci.CountryCode = co.Code)
JOIN countrylanguage cl ON (cl.Countrycode = ci.CountryCode)
WHERE (cl.Isofficial = "T")

/* 
 * Listar los 10 países con mayor población y los 10 países con menor población 
 * (que tengan al menos 100 habitantes) en la misma consulta.
 * */
(
	SELECT co.Name, co.Population
	FROM country co
	WHERE (co.Population >= 100)
	ORDER BY co.Population DESC
	LIMIT 10
)
UNION
(
	SELECT co.Name, co.Population
	FROM country co
	WHERE (co.Population >= 100)
	ORDER BY co.Population ASC 
	LIMIT 10
)
ORDER BY Population DESC;

/* Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés 
 * (hint: no debería haber filas duplicadas). */

(
SELECT DISTINCT co.Name, cl.`Language` 
FROM country co
JOIN countrylanguage cl ON (cl.Countrycode = co.Code)
WHERE ((cl.`Language` = "English") AND (cl.Isofficial = "T"))
)
UNION 
(
SELECT DISTINCT co.Name, cl.`Language` 
FROM country co
JOIN countrylanguage cl ON (cl.Countrycode = co.Code)
WHERE ((cl.`Language` = "French") AND (cl.Isofficial = "T") )
)

/* Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población. */

(
	SELECT co.Name, cl.`Language` 
	FROM country co
	RIGHT JOIN countrylanguage cl ON (cl.Countrycode = co.Code)
	WHERE (cl.`Language` = "English")
)
EXCEPT 
(
	SELECT co.Name, cl.`Language` 
	FROM country co
	RIGHT JOIN countrylanguage cl ON (cl.Countrycode = co.Code)
	WHERE (cl.`Language` = "Spanish")
)

/* ---------- CONSULTAS ANIDADAS ---------- */

/* Listar el nombre de la ciudad y el nombre del país de todas las ciudades 
 * que pertenezcan a países con una población menor a 10000 habitantes. */

SELECT ci.Name, co.Name, co.Population 
FROM country co
JOIN city ci ON (co.Code = ci.CountryCode)
WHERE (co.Population < 10000)


/*
 * Listar todas aquellas ciudades cuya población sea mayor que la población 
 * promedio entre todas las ciudades.
 * */

SELECT ci.Name, ci.Population 
FROM city ci
WHERE (ci.Population > 
	(SELECT AVG(ci2.Population) as avg_Pop
	FROM city ci2
	))

/* Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la 
 * población total de algún país de Asia.   */
	
SELECT ci.Name, ci.Population 
FROM city ci
JOIN country co ON (co.Code = ci.CountryCode)
WHERE (ci.Population >= (SELECT MAX(ci2.Population)
	FROM city ci2
	JOIN country co2 ON (co2.Code = ci2.CountryCode)
	WHERE (co2.Continent = "Asia")))
	
SELECT ci.Name
FROM city ci
JOIN country co ON co.Code = ci.CountryCode
WHERE ci.Population >= ANY (
    SELECT SUM(ci2.Population)
    FROM city ci2
    JOIN country co2 ON co2.Code = ci2.CountryCode
    WHERE co2.Continent = "Asia"
    GROUP BY co2.Code
)
AND co.Continent != "Asia";

/* Listar aquellos países junto a sus idiomas no oficiales, 
 * que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.
 */

SELECT co.Name, cl.`Language` 
FROM country co
JOIN countrylanguage cl ON (cl.Countrycode = co.Code)
WHERE (cl.Isofficial = "F" AND cl.Percentage > ALL (
	SELECT cl2.Percentage
	FROM countrylanguage cl2
	WHERE (cl2.Isofficial = "T" AND cl2.Countrycode = co.Code)))

/* Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 
 * y exista (en el país) al menos una ciudad con más de 100000 habitantes. 
 * (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas). */ 

	
	
	
/* ---------- GENERAL ---------- */
/* Acá hay que usar la DB de sakila */
	

/* Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de
Películas. */
	
CREATE TABLE directors (
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    NumeroDePeliculas INT NOT NULL,
    PRIMARY KEY (Nombre, Apellido)
);

/* El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e.
el mayor número de películas filmadas) son también directores de las películas en
las que participaron. Basados en esta información, inserten, utilizando una subquery
los valores correspondientes en la tabla `directors`. */

SELECT act.first_name, COUNT(fa.actor_id) count_actor 
FROM actor act
JOIN film_actor fa ON (fa.actor_id = act.actor_id)
GROUP BY act.first_name 
ORDER BY count_actor DESC

INSERT INTO directors (Nombre, Apellido, NumeroDePeliculas)
SELECT act.first_name, act.last_name, COUNT(fa.actor_id) AS count_actor
FROM actor act
JOIN film_actor fa ON fa.actor_id = act.actor_id
JOIN film_director fd ON fd.director_id = act.actor_id AND fd.film_id = fa.film_id
GROUP BY act.first_name, act.last_name
ORDER BY count_actor DESC
LIMIT 5; /* ---> ACA SE VE QUE PODEMOS HACER UN INSERT DE LA SALIDA DE UNA QUERY*/


/* Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a
si el cliente es "premium" o no. Por defecto ningún cliente será premium.  */

ALTER TABLE customer
ADD COLUMN premium_customer CHAR(1) DEFAULT 'F' NOT NULL;

/* Modifique la tabla customer. Marque con 'T' en la columna premium_customer de
los 10 clientes con mayor dinero gastado en la plataforma. */

UPDATE customers
SET premium_customer = 'T'
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    ORDER BY total_spent DESC
    LIMIT 10
);

/* Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings
de las películas existentes (Hint: rating se refiere en este caso a la clasificación
según edad: G, PG, R, etc). */

SELECT rating, COUNT(*) AS cantidad_peliculas
FROM films
GROUP BY rating
ORDER BY cantidad_peliculas DESC;

/* ¿Cuáles fueron la primera y última fecha donde hubo pagos? */

SELECT 
    MIN(payment_date) AS primera_fecha,
    MAX(payment_date) AS ultima_fecha
FROM payment;

/* Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el
nombre del mes de una fecha). */

SELECT 
    MONTH(payment_date) AS mes,
    AVG(amount) AS promedio_pagos
FROM payment
GROUP BY MONTH(payment_date)
ORDER BY mes;

/* Modifique la table `inventory_id` agregando una columna `stock` que sea un número
entero y representa la cantidad de copias de una misma película que tiene
determinada tienda. El número por defecto debería ser 5 copias. */

ALTER TABLE inventory
ADD COLUMN stock INT DEFAULT 5 NOT NULL;



/* Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la
tabla rental, haga un update en la tabla `inventory` restando una copia al stock de la
película rentada (Hint: revisar que el rental no tiene información directa sobre la
tienda, sino sobre el cliente, que está asociado a una tienda en particular). */

DELIMITER $$

CREATE TRIGGER update_stock
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock = stock - 1
    WHERE inventory_id = NEW.inventory_id
    AND stock > 0;
END$$

DELIMITER ;

/* EJEMPLO DE TRIGGER*/

DELIMITER $$

CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON table_name
FOR EACH ROW
BEGIN
    -- Lógica del trigger
    -- Ejemplo: UPDATE otra_tabla SET campo = valor WHERE condicion;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_stock
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock = stock - 1
    WHERE inventory_id = NEW.inventory_id
    AND stock > 0;
END$$

DELIMITER ;


/* Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un
registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya
tardado más de 3 días (comparación con rental_date). El valor de la multa será el
número de días de retraso multiplicado por 1.5. */

DELIMITER $$

CREATE PROCEDURE check_date_and_fine()
BEGIN
    -- Variable para almacenar los días de retraso
    DECLARE days_late INT;
    DECLARE fine_amount DECIMAL(10, 2);

    -- Insertar en la tabla fines los registros con retraso
    INSERT INTO fines (rental_id, fine_amount, fine_date)
    SELECT 
        r.rental_id, 
        (DATEDIFF(r.return_date, r.rental_date) - 3) * 1.5 AS fine_amount,
        NOW() AS fine_date
    FROM rental r
    WHERE r.return_date > DATE_ADD(r.rental_date, INTERVAL 3 DAY);
END$$

DELIMITER ;

/*Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a
la tabla `rental`.*/

CREATE ROLE employee;
GRANT INSERT, UPDATE, DELETE ON sakila.rental TO employee;

/*14. Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que
tenga todos los privilegios sobre la BD `sakila`.*/

REVOKE DELETE ON sakila.rental FROM employee;

/*15. Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro
de `administrator`. */

CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON sakila.* TO administrator;



