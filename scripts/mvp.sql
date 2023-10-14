--- 1. 
   -- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    
	SELECT npi, nppes_provider_first_name,nppes_provider_last_org_name, SUM(total_claim_count) AS claim_count_sum
	FROM prescriber
	INNER JOIN prescription
	USING (npi)
	GROUP BY npi,nppes_provider_first_name,nppes_provider_last_org_name
	ORDER BY claim_count_sum DESC
	LIMIT 5;
	
	
   -- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

	SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS claim_count_sum
	FROM prescriber
	INNER JOIN prescription
	USING (npi)
	GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
	ORDER BY claim_count_sum DESC
	LIMIT 5;

--- 2. 
  --  a. Which specialty had the most total number of claims (totaled over all drugs)?

   SELECT specialty_description , SUM(total_claim_count) AS sum_claim_count
   FROM prescriber
   INNER JOIN prescription
   USING (npi)
   GROUP BY specialty_description
   ORDER BY sum_claim_count DESC
   LIMIT 10;

   -- b. Which specialty had the most total number of claims for opioids?
   
   SELECT specialty_description , SUM(total_claim_count) AS sum_claim_count
   FROM prescriber as p1
   INNER JOIN prescription as p2
   USING (npi)
   INNER JOIN drug
   USING (drug_name)
   WHERE opioid_drug_flag='Y'
   GROUP BY specialty_description
   ORDER BY sum_claim_count DESC
   LIMIT 10;


 --  c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
  
 --  d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--- 3. 

  -- a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, CAST (total_drug_cost AS money)
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY generic_name, total_drug_cost
ORDER BY total_drug_cost DESC
LIMIT 5;

-- "PIRFENIDONE", "$2,829,174.30"

  --  b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, CAST(ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS money) AS daily_cost
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC
LIMIT 1;

-- "C1 ESTERASE INHIBITOR", "$3,495.22"

--- 4. 
  --  a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' 
	END AS drug_type
FROM drug;

   -- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type,
CAST(SUM(p.total_drug_cost) AS money) AS total_spent
FROM drug AS d
LEFT JOIN prescription AS p
USING(drug_name)
GROUP BY drug_type
ORDER BY total_spent DESC;

-- Opiods have more money spent on them.


--- 5. 
  --  a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT(cbsa), cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%';

---  10


  -- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT
	c.cbsaname,
	SUM(p.population) AS total_population
	FROM cbsa AS c
	INNER JOIN population AS p
		USING(fipscounty)
	GROUP BY c.cbsaname
	ORDER BY total_population DESC;

--- Nashville-Davidson--Murfreesboro--Franklin, TN as the largest, Morristown, TN is the smallest.


  -- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT c1.cbsaname, f1.county, SUM(p1.population) AS total_population
FROM cbsa AS c1
	FULL JOIN population AS p1
	USING (fipscounty)
	FULL JOIN fips_county AS f1
	USING (fipscounty)
WHERE c1.cbsa IS NULL 
	AND population IS NOT NULL
GROUP BY c1.cbsaname, f1.county
ORDER BY SUM(p1.population) DESC;

--- "SEVIER", "TN", 95523

--- 6. 
  
  -- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
	CASE 
	WHERE d.opio
FROM prescription
WHERE total_claim_count > 3000;

--- 9

  --  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT
p.drug_name,
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'not opioid'
	END AS drug_type,
p.total_claim_count
FROM prescription AS p
FULL JOIN drug AS d
USING(drug_name)
WHERE total_claim_count > 3000;

-- OXYCODONE HCL and HYDROCODONE-ACETAMINOPHEN are opioids


   -- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT
p2.nppes_provider_last_org_name, 
p2.nppes_provider_first_name, 
p1.drug_name,
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'not opioid'
	END AS drug_type,
p1.total_claim_count
FROM prescription AS p1
FULL JOIN drug AS d
USING(drug_name)
FULL JOIN prescriber AS p2
USING(npi)
WHERE total_claim_count > 3000;



--- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

 --  a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT p.npi, d.drug_name, specialty_description, nppes_provider_city,
    CASE
    WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
    ELSE 'not opioid'
    END AS drug_type
FROM prescription
FULL JOIN drug AS d ON prescription.drug_name = d.drug_name
FULL JOIN prescriber AS p ON prescription.npi = p.npi
WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city ILIKE 'Nashville'
    AND (CASE
            WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
            ELSE 'not opioid'
        END) ILIKE 'opioid';
	

  --  b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi, d.drug_name, specialty_description, nppes_provider_city, p1.total_claim_count,
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
        ELSE 'not opioid'
    END AS drug_type
FROM prescription AS p1
FULL JOIN drug AS d ON p1.drug_name = d.drug_name
FULL JOIN prescriber AS p ON p1.npi = p.npi
WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city ILIKE 'Nashville'
    AND (CASE
            WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
            ELSE 'not opioid'
        END) ILIKE 'opioid'
GROUP BY p.npi, d.drug_name, specialty_description, nppes_provider_city, p1.total_claim_count, d.opioid_drug_flag;


   -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
   
SELECT p.npi, d.drug_name, specialty_description, nppes_provider_city, COALESCE(p1.total_claim_count, 0) AS total_claim_count,
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
        ELSE 'not opioid'
    END AS drug_type
FROM prescription AS p1
FULL JOIN drug AS d ON p1.drug_name = d.drug_name
FULL JOIN prescriber AS p ON p1.npi = p.npi
WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city ILIKE 'Nashville'
    AND (CASE
            WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
            ELSE 'not opioid'
        END) ILIKE 'opioid'
GROUP BY p.npi, d.drug_name, specialty_description, nppes_provider_city, p1.total_claim_count, d.opioid_drug_flag;


-- Sorry I know 7 is wrong but this was an attempt :'/

-------------------
-- Seans code
-- EXPERIMENTAL! DANGER WILL ROBINSON
SELECT 
    prescriber.npi,
    drug.drug_name as drug_name,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description,
	nppes_provider_city,
    COALESCE(SUM(prescription.total_claim_count), 0) as total_claims
FROM 
    prescriber
LEFT JOIN 
    prescription
    USING (npi)
LEFT JOIN 
    drug
    USING (drug_name)
WHERE 
    prescriber.specialty_description iLIKE '%Pain Management%'
    AND prescriber.nppes_provider_city iLIKE '%Nashville%'
GROUP BY 
    prescriber.npi,
    drug.drug_name,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description,
	nppes_provider_city
ORDER BY 
    prescriber.npi,
	nppes_provider_last_org_name,
    drug.drug_name;
   