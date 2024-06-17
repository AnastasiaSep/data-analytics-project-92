--общее количество покупателей из таблицы customers
--customers_count.csv Шаг 4
select count(distinct customer_id) as customers_count
from customers;
--top_10_total_income.csv Шаг 5
--Первый отчет о десятке лучших продавцов
select
    (e.first_name || ' ' || e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(p.price * s.quantity)) as income
from
    sales as s
inner join
    employees as e
    on s.sales_person_id = e.employee_id
inner join
    products as p
    on s.product_id = p.product_id
group by
    seller
order by
    income desc
limit 10;
--средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
--lowest_average_income.csv
with a as (
    select
        (e.first_name || ' ' || e.last_name) as seller,
        floor(
            (sum(p.price * s.quantity))
            / count(s.sales_id)
        ) as average_income
    from
        sales as s
    inner join
        employees as e
        on s.sales_person_id = e.employee_id
    inner join
        products as p
        on s.product_id = p.product_id
    group by seller
    order by average_income asc
)

select
    seller,
    average_income
from a
where average_income < (select avg(average_income) from a);
--Третий отчет содержит информацию о выручке по дням недели.
--day_of_the_week_income.csv
with rankedsales as (
    select
        s.sale_date,
        e.first_name || ' ' || e.last_name as seller,
        p.price * s.quantity as sale_amount,
        extract(ISODOW from s.sale_date) as day_of_week,
        to_char(s.sale_date, 'day') as day_of_week_name
    from
        sales as s
    inner join
        employees as e on s.sales_person_id = e.employee_id
    inner join
        products as p on s.product_id = p.product_id
)

select
    seller,
    day_of_week_name,
    floor(sum(sale_amount)) as income
from
    rankedsales
group by
    seller,
    day_of_week_name,
    day_of_week
order by
    day_of_week asc;
--age_groups.csv Шаг 6
--количество покупателей в разных возрастных группах
with t as (
    select
        age,
        customer_id,
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)

select
    age_category,
    count(customer_id) as age_count
from t
group by
    age_category
order by age_category asc;

--customers_by_month.csv
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct c.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from
    sales as s
inner join
    customers as c
    on s.customer_id = c.customer_id
inner join
    products as p
    on s.product_id = p.product_id
group by
    to_char(s.sale_date, 'YYYY-MM')
order by
    selling_month;

--special_offer.csv
--акции
with t as (
    select
        s.customer_id,
        s.sale_date,
        p.price,
        s.sales_person_id,
        row_number()
            over (partition by s.customer_id order by s.sale_date)
        as rn
    from
        sales as s
    inner join
        products as p on s.product_id = p.product_id
)
select
    t.sale_date,
    (c.first_name || ' ' || c.last_name) as customer,
    (e.first_name || ' ' || e.last_name) as seller
from
    t
inner join
    customers as c on t.customer_id = c.customer_id
inner join
    employees as e on t.sales_person_id = e.employee_id
where
    t.price = 0 and t.rn = 1
order by
    t.customer_id asc;
