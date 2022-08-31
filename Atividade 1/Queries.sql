use sakila;
/*1 Listagem de filmes no inventário*/
SELECT i.inventory_id, f.title, f.description FROM inventory i JOIN film f ON f.film_id = i.film_id ORDER BY i.inventory_id;

/*2 Número de filmes por categoria*/
WITH
  cte1 AS (SELECT film_actor.film_id, count(film_actor.actor_id) AS cast_size 
  FROM film_actor GROUP BY film_actor.film_id),
  cte2 AS (SELECT * FROM film)
SELECT * FROM cte2 JOIN cte1 WHERE cte1.film_id = cte2.film_id;

/*3 Número de filmes de mais de 2h por classificação indicativa*/
SELECT `film`.`rating`, count(`film`.`film_id`) AS `num_films` FROM `film` 
WHERE `film`.`length` > 120 GROUP BY `film`.`rating` 
ORDER BY `num_films` DESC;

/*4 Filmes com 0 copias no inventário */
SELECT `film`.`film_id`, `film`.`title`, count(`inventory`.`film_id`) AS `num_copies` 
FROM `inventory` 
RIGHT JOIN `film` ON `film`.`film_id` = `inventory`.`film_id` GROUP BY `film`.`film_id` 
HAVING `num_copies` = 0;

/*5 Top 10 clientes com maior número de rentals */
SELECT `customer`.`customer_id`, CONCAT(`customer`.`last_name`, ', ', `customer`.`first_name`) 
AS `customer_name`, 
COUNT(`rental`.`rental_id`) as `num_rentals` FROM `customer` LEFT JOIN `rental` 
ON `customer`.`customer_id` = `rental`.`customer_id` 
GROUP BY `customer`.`customer_id` ORDER BY `num_rentals` DESC LIMIT 10;

/*6 Atores que não participaram de documentários */
SELECT DISTINCT `actor`.`actor_id`, CONCAT(`actor`.`last_name`, ', ', `actor`.`first_name`) 
AS `actor_name` 
FROM `actor` WHERE `actor`.`actor_id` NOT IN (SELECT DISTINCT `actor`.`actor_id` FROM `actor`
 INNER JOIN `film_actor` 
ON `actor`.`actor_id` = `film_actor`.`actor_id` INNER JOIN `film_category` ON `film_category`.`film_id` = `film_actor`.`film_id` 
INNER JOIN `category` ON `category`.`category_id` = `film_category`.`category_id`  WHERE `category`.`name` = 'Documentary') ORDER BY `actor_name`;

/*7 Filmes que não são em inglês e que tem uma versão em inglês */
SELECT DISTINCT `film`.`film_id`, `film`.`title` FROM `film` INNER JOIN `language` ON `language`.`language_id` = `film`.`language_id` 
WHERE  `film`.`title` IN (SELECT `film`.`title` FROM `film` INNER JOIN `language` ON `language`.`language_id` = `film`.`language_id` 
WHERE `language`.`name` != "English") AND `language`.`name` = "English";

/*8 Combinação de Atores e Gêneros que nunca ocorreram em nenhum filme */ 
SELECT CONCAT(`actor`.`actor_id`,",", `category`.`category_id`) AS `code_actor_category`, 
CONCAT(`actor`.`last_name`, ', ', `actor`.`first_name`) AS `actor_name`, `category`.`name` 
FROM `actor` CROSS JOIN `category` HAVING `code_actor_category` 
NOT IN (SELECT DISTINCT CONCAT(`actor`.`actor_id`,",", `category`.`category_id`) 
AS `code_actor_category` FROM `actor` INNER JOIN `film_actor` 
ON `actor`.`actor_id` = `film_actor`.`actor_id` INNER JOIN `film_category` 
ON `film_category`.`film_id` = `film_actor`.`film_id` INNER JOIN `category` 
ON `category`.`category_id` = `film_category`.`category_id`);

/*9 Filmes por total de vendas já recebido por toda a empresa */
SELECT `film`.`film_id`, `film`.`title`, SUM(`payment`.`amount`) AS `total_revenue`  
FROM `payment` RIGHT JOIN `rental` ON `payment`.`rental_id` = `rental`.`rental_id` 
RIGHT JOIN `inventory` ON `rental`.`inventory_id` = `inventory`.`inventory_id` 
RIGHT JOIN `film` ON `inventory`.`film_id` = `film`.`film_id` GROUP BY `film`.`film_id` 
ORDER BY `total_revenue` DESC;

/*10 Clientes ordenados por ultimo emprestimo*/
SELECT CONCAT(`customer`.`last_name`, ', ', `customer`.`first_name`) 
AS name, email, last_update FROM customer ORDER BY last_update;
/*11 Número de clientes não ativos */
SELECT COUNT(*) AS `num_non_active_custumers` FROM `customer` 
WHERE `customer`.`active` != 1;

/*12 Número de Clientes por Cidade*/
SELECT `city`.`city_id`, `city`.`city`, COUNT(`customer`.`customer_id`) AS `num_customer` 
FROM `customer` RIGHT JOIN `address` ON `address`.`address_id` = `customer`.`address_id` 
RIGHT JOIN `city` ON `city`.`city_id` = `address`.`city_id` GROUP BY `city`.`city_id` 
ORDER BY `num_customer` DESC;

/*13 País com maior número de clientes */
SELECT `country`.*, COUNT(`customer`.`customer_id`) AS `num_customer` FROM `customer` 
RIGHT JOIN `address` ON `address`.`address_id` = `customer`.`address_id` RIGHT JOIN `city` 
ON `city`.`city_id` = `address`.`city_id` RIGHT JOIN `country` 
ON `country`.`country_id` = `city`.`country_id` GROUP BY `country`.`country_id` 
ORDER BY `num_customer` DESC LIMIT 1;

/*14 Calculando número de clientes USANDO a VIEW customer_list */
SELECT `customer_list`.`country`, COUNT(`customer_list`.`ID`) AS `qtd_customer` 
FROM `customer_list` GROUP BY `customer_list`.`country` ORDER BY `qtd_customer` DESC;

/*15 Dia mais lucrativo da empresa */
SELECT `payment_date`, SUM(`payment`.`amount`) as `total_revenue` FROM `payment` 
GROUP BY `payment_date` ORDER BY `total_revenue` DESC;

/*16 Média de preço dos filmes por categoria USANDO a VIEW film_list */
SELECT `film_list`.`category`, AVG(`film_list`.`price`) AS `avg_price` FROM `film_list` 
GROUP BY `film_list`.`category` ORDER BY `avg_price` DESC;

/*17 Média de duração dos filmes por classificação indicativa USANDO a VIEW film_list */
SELECT `film_list`.`rating`, AVG(`film_list`.`length`) AS `avg_duration` FROM `film_list` 
GROUP BY `film_list`.`rating` ORDER BY `avg_duration` DESC;

/*18 Média de preço dos filmes por categoria e classificação indicativa USANDO a VIEW film_list */
SELECT `film_list`.`rating`, `film_list`.`category`, AVG(`film_list`.`price`) AS `avg_price` 
FROM `film_list` GROUP BY `film_list`.`category`,`film_list`.`rating` ORDER BY `avg_price` 
DESC;

/*19 Todos os nomes de clientes, atores e empregados*/ 
SELECT CONCAT(`customer`.`last_name`, ', ', `customer`.`first_name`) AS `name` FROM `customer` 
UNION 
SELECT CONCAT(`actor`.`last_name`, ', ', `actor`.`first_name`) AS `name` FROM `actor`
UNION
SELECT CONCAT(`staff`.`last_name`, ', ', `staff`.`first_name`) AS `name` FROM `staff`;


/*20 Busca por algum cliente que tem nome de ator USANDO CTE */ 
WITH 
	`cte1` AS (SELECT CONCAT(`actor`.`last_name`, ', ', `actor`.`first_name`) AS `actor_name` 
    FROM `actor`),
    `cte2` AS (SELECT CONCAT(`customer`.`last_name`, ', ', `customer`.`first_name`) 
    AS `customer_name` FROM `customer`)
SELECT * FROM `cte1` JOIN `cte2` WHERE `cte2`.`customer_name` = `cte1`.`actor_name`;

/*21 Média de dias emprestados num aluguel para cada categoria de filme */
SELECT `category`.`category_id`, `category`.`name` AS `category_name`, 
AVG(`film`.`rental_duration`) AS `avg_rental_duration` FROM `film` 
RIGHT JOIN `film_category` ON `film_category`.`film_id` = `film`.`film_id` 
RIGHT JOIN `category` ON `category`.`category_id` = `film_category`.`category_id` 
GROUP BY `category`.`category_id` ORDER BY `avg_rental_duration` DESC;

/*22 Filmes com o maior valor de custo caso perdido (replacement_cost) */ 
SELECT * FROM `film` WHERE `film`.`replacement_cost` = (SELECT MAX(`film`.`replacement_cost`) 
FROM `film`);

/*23 Filmes com o maior duração*/ 
SELECT * FROM `film` WHERE `film`.`length` = (SELECT MAX(`film`.`length`) FROM `film`);

/*24 Empregados ordenados pelo valor gerado em vendas*/
SELECT `staff`.`staff_id`, CONCAT(`staff`.`first_name`, " ",`staff`.`last_name`) 
AS `staff_name`, SUM(`payment`.`amount`) AS `total_received`  FROM `payment` 
INNER JOIN `staff` ON `staff`.`staff_id` = `payment`.`staff_id` GROUP BY `staff`.`staff_id` 
ORDER BY `total_received` DESC;

/*25 Empregados ordenados pelo total de emprestimos já devolvidos */
SELECT `staff`.`staff_id`, CONCAT(`staff`.`first_name`, " ",`staff`.`last_name`) 
AS `staff_name`, SUM(`rental`.`rental_id`) AS `total_rents`  FROM `rental` 
INNER JOIN `staff` ON `staff`.`staff_id` = `rental`.`staff_id` WHERE `rental`.`return_date` 
IS NOT NULL GROUP BY `staff`.`staff_id` ORDER BY `total_rents` DESC;

/*26 Número de filmes por linguagem */
SELECT `language`.`language_id`, `language`.`name`, COUNT(`film_id`) AS `num_films` 
FROM `language` INNER JOIN `film` ON  `film`.`language_id` =  `language`.`language_id` 
GROUP BY `language`.`language_id` ORDER BY `num_films` DESC;

/*27 Filmes com títulos que citam países da base de dados*/ 
SELECT `film_text`.* FROM `film_text`, `country` WHERE `film_text`.`title` 
LIKE CONCAT("%",`country`.`country`,"%");

/*28 Filmes com títulos que citam nomes de pessoas na base de dados*/ 
SELECT DISTINCT `film_text`.* FROM `film_text`, (SELECT `customer`.`first_name` FROM `customer` 
UNION 
SELECT `actor`.`first_name` FROM `actor`
UNION
SELECT `staff`.`first_name` FROM `staff`) AS `all_names` WHERE `film_text`.`title` 
LIKE CONCAT("%",`all_names`.`first_name`,"%");

/*29 Número de filmes por categoria*/
SELECT `category`.`category_id`, `category`.`name`, count(`film_category`.`film_id`) 
AS `num_films` FROM `film_category` INNER JOIN `category` 
ON `film_category`.`category_id` = `category`.`category_id` GROUP BY `category`.`category_id`;

/*30 Filmes cujo título contém um dos nomes de um dos atores  */ 
SELECT `film`.*, CONCAT(`actor`.`last_name`, ', ', `actor`.`first_name`) AS `name` 
FROM `film` INNER JOIN `film_actor` ON `film_actor`.`film_id` = `film`.`film_id` 
INNER JOIN `actor` ON `actor`.`actor_id` = `film_actor`.`actor_id` WHERE `film`.`title` 
LIKE CONCAT("%",`actor`.`last_name`,"%") OR `film`.`title` 
LIKE CONCAT("%",`actor`.`first_name`,"%");

ALTER TABLE actor ADD actor_full_name varchar(100) AFTER last_name;