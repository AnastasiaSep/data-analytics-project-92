select 
	(e.first_name || ' ' || e.last_name) AS seller, 
	FLOOR((SUM(p.price * s.quantity))/ 
	COUNT(s.sales_id)) AS average_income 
from 
    sales s 
join 
    employees e ON e.employee_id = s.sales_person_id
join 
    products p ON s.product_id = p.product_id
group by seller
order by average_income asc;
-- floor ~!

--продавцах, чья средняя выручка за сделку меньше средней выручки за сделку 
--по всем продавцам. Таблица отсортирована по выручке по возрастанию.
--
--seller — имя и фамилия продавца
--average_income — средняя выручка продавца за сделку с округлением до целого