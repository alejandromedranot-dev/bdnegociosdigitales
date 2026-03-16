
-- CONCAT 
SELECT
    FirstName, 
    LastName, 
    CONCAT(FirstName, ' ', lastname) AS FULLNAME
FROM Employees;

-- UPPERCASE
SELECT
    FirstName, 
    LastName, 
    CONCAT(FirstName, ' ', lastname) AS FULLNAME, 
    UPPER(FirstName) AS UPPER_CASE, 
    LOWER(LastName) AS LOWER_CASE 
FROM Employees;

-- TRIM 

SELECT
    FirstName
FROM Employees
WHERE FirstName != TRIM(FirstName);

SELECT
    FirstName, 
    LEN(FirstName) AS len_name,
    LEN(TRIM(FirstName)) AS len_trim_name, 
    LEN(FirstName) - LEN(TRIM(FirstName)) AS flag
FROM Employees
WHERE  LEN(FirstName) != LEN(TRIM(FirstName));

-- REPLACE 




