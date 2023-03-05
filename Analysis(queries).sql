# Show rental data of customers, names and address
SELECT  c.first_name, c.last_name, a.address, a.district, rental_date , return_date
FROM sakila.rental as r
join customer as c
on r.customer_id = c.customer_id
join address as a
on c.address_id = a.address_id
join city 
on city.city_id = a.city_id
join country 
on country.country_id = city.country_id
order by rental_date desc;

# top cities in number of rentals

SELECT   city.city ,count(r.rental_id) 
FROM sakila.rental as r
left join customer as c
on r.customer_id = c.customer_id
join address as a
on c.address_id = a.address_id
join city 
on city.city_id = a.city_id
group by city.city;

# top contries in number of rentals

SELECT  country.country ,count(r.rental_id) 
FROM sakila.rental as r
left join customer as c
on r.customer_id = c.customer_id
join address as a
on c.address_id = a.address_id
join city 
on city.city_id = a.city_id
join country 
on country.country_id = city.country_id
group by country.country;

# top categories we have
select category.name, count(title) 
from film
join film_category
on film.film_id = film_category.film_id
join category
on category.category_id = film_category.category_id
group by category.name
order by 2 desc;

# top categories rented
select  name, count(rental_id)
from rental
left join inventory
on inventory.inventory_id = rental.inventory_id
join film
on film.film_id = inventory.film_id
join film_category
on film.film_id = film_category.film_id
join category
on category.category_id = film_category.category_id
group by name
order by 2 desc;

# total sales for each year 

select t1.year , sum(t1.amount) as revenue
from(select rental.rental_id, payment.amount , extract(year from rental_date ) as year
from rental
join payment
on rental.rental_id = payment.rental_id) as t1
group by t1.year;


# sales per month on speciefc year
select rental.rental_id, payment.amount , extract(month from rental_date ) as month, extract(year from rental_date ) as year
from rental
join payment
on rental.rental_id = payment.rental_id
where extract(year from rental_date ) = 2005;

# Total revenue per year
select sum(amount) as total_revenue, extract(year from rental_date)as year 
from rental
join payment
on rental.rental_id = payment.rental_id
group by extract(year from rental_date);

# Which store has higher order number in summer months  SHOWING MONTHS
select store.store_id , count(rental_id) as number_of_orders , extract(month from rental_date) as month
from rental 
join inventory
on rental.inventory_id  = inventory.inventory_id
join store 
on store.store_id = inventory.store_id
where extract(month from rental_date) = 6 or extract(month from rental_date) =7 or extract(month from rental_date) =8
group by store.store_id, extract(month from rental_date); 

# Which store has higher order number in summer months NOT SHOWING MONTHS
select store.store_id , count(rental_id) as number_of_orders 
from rental 
join inventory
on rental.inventory_id  = inventory.inventory_id
join store 
on store.store_id = inventory.store_id
where extract(month from rental_date) = 6 or extract(month from rental_date) =7 or extract(month from rental_date) =8
group by store.store_id;

# top 200 movies rented
select  title,count(rental_id),film.film_id
from rental 
join inventory
on rental.inventory_id  = inventory.inventory_id
join film
on film.film_id = inventory.film_id
group by title,film.film_id
order by 2 desc
limit 200;

# Most participated actors in the top 100 movies rented 
# $$$$$$ IMPORTANT MISTAKE WHERE I GROUPED NON UNIQUE COLUMNS 
select first_name, last_name, count(title)
from(select  title,count(rental_id),film.film_id
from rental 
join inventory
on rental.inventory_id  = inventory.inventory_id
join film
on film.film_id = inventory.film_id
group by title,film.film_id
order by 2 desc
limit 200) as t1
join film_actor
on film_actor.film_id = t1.film_id
join actor
on actor.actor_id = film_actor.actor_id
group by first_name, last_name; # there are name with same first name and last name so wrong

# Most participated actors in the top 100 movies rented
# $$$$$$ CORRECT QUERY
select actor.actor_id, first_name, last_name,count(title)
from(select  title,count(rental_id),film.film_id
from rental 
join inventory
on rental.inventory_id  = inventory.inventory_id
join film
on film.film_id = inventory.film_id
group by title,film.film_id
order by 2 desc
limit 200) as t1
join film_actor
on film_actor.film_id = t1.film_id
join actor
on actor.actor_id = film_actor.actor_id
group by actor.actor_id,first_name, last_name;

# Using Case to categorize the price and see how many times each category is requested (How many do we have in each category)
SELECT     case when film.rental_rate  < 1 then "Low Rental Price"
			    when film.rental_rate between 1 and 3 then "Medium Rental Price"
                else "High Rental Price"
                end as Price_category,
                count(payment_id)
from payment
join rental
on payment.rental_id = rental.rental_id
join inventory
on rental.inventory_id  = inventory.inventory_id
join film
on film.film_id = inventory.film_id
group by 1
order by 2 desc;


# see if rental price is fixed for the same film 
select * #title , count(distinct(amount))
from payment
join rental
on payment.rental_id = rental.rental_id
join inventory
on rental.inventory_id  = inventory.inventory_id
join film
on film.film_id = inventory.film_id
#group by 1
where title = "ACADEMY DINOSAUR";
#### Answer is no as rental price changes based on the duration customer wants to rent ####



# Cleaning (Create dummy valriable for special featuers from film table)
select memberfirst as firstt,
					case when t1.mid = t1.memberfirst then "null"			   ## Adjusting rows to have only one unique value in each column and null if repeated
						 else t1.mid end as middle,
                         
					case when t1.last_name = t1.mid then "null"
                         else t1.last_name end as lasttt,
                         
					case when t1.last_name = t1.after_mid then "null"
                         else t1.after_mid end as after_midd
from(SELECT                                                                            ## using sybstring_index to split columns 
																					   ## but still need to be adjusted 
    SUBSTRING_INDEX(film.special_features, ',', 1) AS memberfirst,
    SUBSTRING_INDEX(SUBSTRING_INDEX(film.special_features, ',', 2),',',-1) AS mid,
    SUBSTRING_INDEX(film.special_features, ',', -1) AS last_name,
    SUBSTRING_INDEX(SUBSTRING_INDEX(film.special_features, ',', -2),',',1) AS after_mid
from film) as t1;


# See how many file we have in each special feature type
select *
from film 
where special_features like "%Deleted Scenes%";



# Another approach to see how many films we have in each special feature type
select sum(case when t2.firstt = "Deleted Scenes" then 1
			when t2.middle = "Deleted Scenes" then 1
            when t2.lasttt = "Deleted Scenes" then 1
            when t2.after_midd = "Deleted Scenes" then 1
            else 0 end) as Count_Deleted_Scenes_films
from (select memberfirst as firstt,
					case when t1.mid = t1.memberfirst then "null"			   ## Adjusting rows to have only one unique value in each column and null if repeated
						 else t1.mid end as middle,
                         
					case when t1.last_name = t1.mid then "null"
                         else t1.last_name end as lasttt,
                         
					case when t1.last_name = t1.after_mid then "null"
                         else t1.after_mid end as after_midd
from(SELECT                                                                            ## using sybstring_index to split columns 
																					   ## but still need to be adjusted 
    SUBSTRING_INDEX(film.special_features, ',', 1) AS memberfirst,
    SUBSTRING_INDEX(SUBSTRING_INDEX(film.special_features, ',', 2),',',-1) AS mid,
    SUBSTRING_INDEX(film.special_features, ',', -1) AS last_name,
    SUBSTRING_INDEX(SUBSTRING_INDEX(film.special_features, ',', -2),',',1) AS after_mid
from film) as t1)t2;



SELECT s.store_id, f.rating, COUNT(f.rating) AS total_number_of_films
FROM store s
JOIN inventory i ON s.store_id = i.store_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1,2;

# Rank movies based on the revenue they got 
select title , sum(rental_rate)
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1
ORDER BY 2 DESC;

/* Most Spending Customer so that we can send him/her rewards or debate points*/
select r.customer_id, first_name, last_name , sum(amount) 
from payment p
join rental r on r.rental_id = p.rental_id
join customer on customer.customer_id = r.customer_id 
group by 1,2,3
order by 4 desc;

/* For each movie, when was the first time and last time it was rented out? */
select title , max(rental_date), min(rental_date)
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1;

/* How many distint Renters per month*/
select  extract(month from rental_date) ,count(distinct(customer_id))
from rental
where extract(year from rental_date) = 2005
group by 1;


/* films that have not been rented in the last 3 months*/
select film_id , title
from film 
where film.film_id NOT IN (select f.film_id
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
where extract(year from r.rental_date) = 2005 and (extract(month from r.rental_date) = 8 or extract(month from r.rental_date) = 7 or extract(month from r.rental_date) = 6)
order by r.rental_date desc);



/*Users who have rented movies at least 3 times*/
select customer.customer_id,first_name,last_name , count(*)
from rental
join customer on customer.customer_id = rental.customer_id
group by 1,2,3
having count(*) >= 3;

/* Reward Users : who has rented at least 30 times*/
select customer.customer_id,first_name,last_name,Phone , count(*)
from rental
join customer on customer.customer_id = rental.customer_id
join address on address.address_id = customer.address_id
group by 1,2,3,4
having count(*) >= 30;


