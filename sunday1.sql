WITH RankedSales AS (
    SELECT 
        e.first_name || ' ' || e.last_name AS seller,
        s.sale_date,
        p.price * s.quantity AS sale_amount,
		EXTRACT(DOW FROM s.sale_date) AS days
    FROM 
        sales s
    JOIN 
        employees e ON e.employee_id = s.sales_person_id
    JOIN 
        products p ON s.product_id = p.product_id
)
SELECT 
    seller, 
    FLOOR(SUM(sale_amount)) AS income,
    case 
    	when days = 0 then 'monday'
    	when days = 1 then 'tuesday'
    	when days = 2 then 'wednesday'
    	when days = 3 then 'thursday'
    	when days = 4 then 'friday'
    	when days = 5 then 'saturday'
    	when days = 6 then 'sunday'
    end as day_of_week
FROM 
    RankedSales s
GROUP BY 
    seller, days
ORDER BY 
    days ASC;