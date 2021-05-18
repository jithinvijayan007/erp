CREATE VIEW sales_details_view AS SELECT val.*, STRING_AGG(CASE WHEN fin.vchr_name IS NOT NULL AND fin_name != 'BAJAJ ONLINE' THEN fin.vchr_name ELSE fin_name END,'') as financier, JSONB_BUILD_OBJECT('FINANCE',ROUND(SUM(CASE WHEN pd.int_fop = 0 THEN pd.dbl_finance_amt ELSE 0 END)::NUMERIC,2), 'CASH',ROUND(SUM(CASE WHEN pd.int_fop = 1 THEN pd.dbl_receved_amt ELSE 0 END)::NUMERIC,2), 'DEBIT CARD',ROUND(SUM(CASE WHEN pd.int_fop = 2 THEN pd.dbl_receved_amt ELSE 0 END)::NUMERIC,2), 'CREDIT CARD',ROUND(SUM(CASE WHEN pd.int_fop = 3 THEN pd.dbl_receved_amt ELSE 0 END)::NUMERIC,2), 'RECEIPT',ROUND(SUM(CASE WHEN pd.int_fop = 4 THEN pd.dbl_receved_amt ELSE 0 END)::NUMERIC,2), 'BHARATH QR',ROUND(SUM(CASE WHEN pd.int_fop = 7 THEN pd.dbl_receved_amt ELSE 0 END)::NUMERIC,2)) FROM (SELECT sm.pk_bint_id as pk_bint_id, sm.dat_created::DATE AS date, sm.dat_created::Time as time, sm.vchr_invoice_num AS invoice_number, au.first_name || ' ' || au.last_name as staff, b.vchr_name AS branch, UPPER(scustd.vchr_name) as customer_name, scustd.int_mobile as customer_mobile, custd.vchr_gst_no as gst_number, l.vchr_name as customer_location, pd.vchr_name AS product_name, brd.vchr_name AS brand_name, ig.vchr_item_group AS item_group, it.vchr_item_code AS item_code, it.vchr_name AS item_name, ROUND((((sd.dbl_selling_price) / ('1.' || sd.dbl_tax_percentage)::NUMERIC))::NUMERIC,2) AS taxable_value, ROUND((sd.dbl_selling_price - (sd.dbl_selling_price / ('1.' || sd.dbl_tax_percentage)::NUMERIC))::NUMERIC, 2) AS tax, sd.dbl_dealer_price AS dp, sd.dbl_cost_price AS cost_price, sd.dbl_mop AS mop, CASE WHEN sd.dbl_selling_price < 0 THEN (-1*sd.int_qty) ELSE sd.int_qty END AS qty, sd.dbl_selling_price - sd.dbl_dealer_price - sd.dbl_indirect_discount AS profit_on_dp, ROUND((ROUND(((sd.dbl_selling_price) / ('1.' || sd.dbl_tax_percentage)::NUMERIC)::NUMERIC,2) - sd.dbl_cost_price)::NUMERIC,2) AS profit_on_costprice, CASE WHEN sm.int_sale_type = 1 THEN 'BAJAJ ONLINE' WHEN sm.int_sale_type = 2 THEN 'AMAZON' WHEN sm.int_sale_type = 3 THEN 'FLIPKART' WHEN sm.int_sale_type = 4 THEN 'E-COMMERCE' ELSE CASE WHEN pi.json_data::jsonb->>'vchr_finance_name' IS NOT NULL THEN pi.json_data::jsonb->>'vchr_finance_name' ELSE '' END END as fin_name, CASE WHEN pi.json_updated_data is not null then pi.json_updated_data::jsonb->>'dbl_balance_amt'||'.00' ELSE '0.00' END as approved_credit, CASE WHEN pi.json_data is not null then pi.json_data::jsonb->>'vchr_finance_schema' ELSE '' END as emi, CASE WHEN scustd.int_cust_type = 1 THEN 'Corporate Customer' WHEN scustd.int_cust_type = 2 THEN 'Credit Customer' WHEN scustd.int_cust_type = 3 THEN 'Sez Customer' WHEN scustd.int_cust_type = 4 THEN 'Cash Customer' ELSE 'Cash Customer' END as customer_type, (sd.dbl_selling_price)::NUMERIC AS selling_price, CASE WHEN sd.int_sales_status = 0 THEN 'RETURN' WHEN sd.int_sales_status = 1 THEN 'SALE' WHEN sd.int_sales_status = 2 THEN 'SMART CHOICE' WHEN sd.int_sales_status = 3 THEN 'SERVICE' WHEN sd.int_sales_status = 4 THEN 'JIO' ELSE 'SALES' END as exchange, ROUND(sm.dbl_discount::NUMERIC,2) as discount, ROUND((CASE WHEN sd.dbl_indirect_discount is not null THEN sd.dbl_indirect_discount ELSE 0 END)::NUMERIC,2) as indirect_discount, ROUND((Sd.dbl_buyback)::NUMERIC,2)  as buyback, sm.jsn_addition  as addition, sm.jsn_deduction  as deduction, pi.json_data::jsonb->'vchr_fin_ordr_num' as delivery_order_num FROM sales_details sd JOIN sales_master sm ON sd.fk_master_id = sm.pk_bint_id JOIN branch b ON b.pk_bint_id = sm.fk_branch_id JOIN item it ON it.pk_bint_id = sd.fk_item_id JOIN item_group ig ON ig.pk_bint_id = it.fk_item_group_id JOIN products pd ON pd.pk_bint_id = it.fk_product_id JOIN brands brd ON brd.pk_bint_id = it.fk_brand_id JOIN sales_customer_details scustd ON scustd.pk_bint_id = sm.fk_customer_id JOIN customer_details custd ON custd.pk_bint_id =  scustd.fk_customer_id JOIN partial_invoice pi ON pi.fk_invoice_id = sm.pk_bint_id JOIN auth_user au on au.id = sm.fk_staff_id JOIN location l on l.pk_bint_id = custd.fk_location_id GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35 ORDER BY sm.vchr_invoice_num) as val LEFT JOIN payment_details pd ON val.pk_bint_id = pd.fk_sales_master_id LEFT JOIN (select vchr_name,vchr_code from financiers where bln_active = 't') AS fin ON fin.vchr_code = pd.vchr_name GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35;