create database Final;
use Final;

ALTER TABLE `final`.`dim_drug_from_code` 
CHANGE COLUMN `drug_form_code` `drug_form_code` VARCHAR(100) NULL DEFAULT NULL ;
alter table dim_drug_from_code add primary key(drug_form_code);

alter table dim_brands_generic add primary key(drug_brand_generic_code);

alter table dim_member add primary key(member_id);

alter table dim_drug_ndc add primary key(drug_ndc);

alter table fact_drug add primary key(id);

ALTER TABLE `final`.`fact_drug` CHANGE COLUMN `drug_form_code` `drug_form_code` VARCHAR(100) NULL DEFAULT NULL ;

ALTER TABLE fact_drug
ADD FOREIGN Key fact_drug_member_id_fk(member_id)
references dim_member(member_id)
on delete set null
on update set null;

ALTER TABLE fact_drug
ADD FOREIGN key fact_drug_drug_ndc_fk(drug_ndc)
references dim_drug_ndc(drug_ndc)
on delete set null
on update set null;

ALTER TABLE fact_drug
ADD foreign key fact_drug_brands_generic_fk(drug_brand_generic_code)
references dim_brands_generic(drug_brand_generic_code)
on delete set nuLl
on update set null;

ALTER TABLE fact_drug
ADD FOREIGN KEY fact_drug_drug_form_code_fk(drug_form_code)
references dim_drug_from_code(drug_form_code)
on delete set null
on update set null;

-- PART 4

-- Que. 1 
select d.drug_name, count(f.member_id) as num_prescription
from dim_drug_ndc d inner join fact_drug f
on d.drug_ndc = f.drug_ndc
group by drug_name;

-- Que 2.
select case 
	when d.member_age > 65 then '65+'
    when d.member_age < 65 then '<65'
    end as age_category,
    count(distinct d.member_id) as number_of_members,
    sum(f.copay) as sum_copay,
    sum(f.insurance_paid) as sum_insurance_paid,
    count(f.insurance_paid) as num_insurance_paid
    from dim_member d
    inner join fact_drug f
    on d.member_id = f.member_id
    group by age_category;
    
-- Que. 3 
create table precscriptions as 
select d.member_id, d.member_first_name, d.member_last_name, dr.drug_name,
CAST(f.fill_date AS DATE) as fill_date_fixed,
f.insurance_paid
from dim_member d
inner join fact_drug f
on d.member_id = f.member_id
inner join dim_drug_ndc dr
on dr.drug_ndc = f.drug_ndc;

select * from precscriptions;
create table insurance_paid_info as
select member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurance_paid,
row_number() over (partition by member_id order by member_id, fill_date_fixed desc) as fill_number
from precscriptions;

select member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurance_paid
 from insurance_paid_info where fill_number = 1;

-- drop database Final;