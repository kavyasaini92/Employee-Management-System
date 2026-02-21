use project;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

describe payroll;
 
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- How many unique employees are currently in the system?
select count(distinct emp_id) as total_employee 
from employee;

-- Which departments have the highest number of employees?
select d.jobdept,count(e.emp_id) as employeecount
from employee e 
join jobdepartment d on e.job_id = d.job_id
group by d.jobdept
order by employeecount desc
limit 1;



-- What is the average salary per department?
select d.jobdept,avg(s.amount) as avgsalary
from salarybonus s
join jobdepartment d on s.job_id = d.job_id
group by d.jobdept;


-- Who are the top 5 highest-paid employees?
SELECT concat(e.FirstName,' ', e.LastName) as full_name, d.JobDept,
       (s.Annual + s.Bonus) AS TotalCompensation
FROM SalaryBonus s
JOIN Employee e ON s.Job_ID = e.Job_ID
JOIN JobDepartment d ON s.Job_ID = d.Job_ID
ORDER BY TotalCompensation DESC
LIMIT 5;

-- Who are the top 5 highest-paid employees?
select concat(e.firstname,' ' ,e.lastname) as fullname, p.total_amount
from employee e 
join payroll p 
on e.emp_id = p.emp_id
order by total_amount desc
limit 5;


-- What is the total salary expenditure across the company?
select sum(Annual + Bonus) as totalsalaryexpenditure
from salarybonus;


-- How many different job roles exist in each department?
SELECT JobDept, COUNT(DISTINCT Name) AS RoleCount
FROM JobDepartment
GROUP BY JobDept
ORDER BY RoleCount DESC;

-- What is the average salary range per department?
SELECT JobDept, AVG((Low + High) / 2) AS AvgSalaryRange
FROM (
    SELECT JobDept,
           CAST(SUBSTRING_INDEX(SalaryRange, ' - ', 1) AS UNSIGNED) AS Low,
           CAST(SUBSTRING_INDEX(SalaryRange, ' - ', -1) AS UNSIGNED) AS High
    FROM JobDepartment
) AS t
GROUP BY JobDept
ORDER BY AvgSalaryRange DESC;


SELECT jobdept,
       ROUND(AVG(
               (CAST(REPLACE(SUBSTRING_INDEX(salaryrange, '-', 1), '$', '') AS UNSIGNED) +
                CAST(REPLACE(SUBSTRING_INDEX(salaryrange, '-', -1), '$', '') AS UNSIGNED)
               ) / 2
           ),2) AS avg_salary_range
FROM JobDepartment
GROUP BY jobdept;


-- Which job roles offer the highest salary?
SELECT d.Name AS JobRole, d.JobDept, (s.Annual + s.Bonus) AS TotalCompensation
FROM SalaryBonus s
JOIN JobDepartment d ON s.Job_ID = d.Job_ID
ORDER BY TotalCompensation DESC
LIMIT 5;


-- Which departments have the highest total salary allocation?

SELECT d.JobDept, SUM(s.Annual + s.Bonus) AS TotalAllocation
FROM SalaryBonus s
JOIN JobDepartment d ON s.Job_ID = d.Job_ID
GROUP BY d.JobDept
ORDER BY TotalAllocation DESC;

-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS EmployeesWithQualifications
FROM Qualification;

-- Which positions require the most qualifications?

SELECT Position, COUNT(QualID) AS QualificationCount
FROM Qualification
GROUP BY Position
ORDER BY QualificationCount DESC;

-- SELECT position,
       -- COUNT(requirements) AS qualification_count
-- FROM qualification
-- GROUP BY position
-- ORDER BY qualification_count DESC
-- LIMIT 1;



-- Which employees have the highest number of qualifications?

SELECT Emp_ID, COUNT(QualID) AS QualificationCount
FROM Qualification
GROUP BY Emp_ID
ORDER BY QualificationCount DESC
limit 5;



-- Which year had the most employees taking leaves?

SELECT YEAR(Date) AS Year, COUNT(*) AS LeaveCount
FROM Leaves
GROUP BY YEAR(Date)
ORDER BY LeaveCount DESC;

-- What is the average number of leave days taken by its employees per department?

SELECT d.JobDept,
COUNT(l.Leave_ID) * 1.0 / COUNT(DISTINCT e.Emp_ID) AS AvgLeavesPerEmployee
FROM Leaves l
JOIN Employee e ON l.Emp_ID = e.Emp_ID
JOIN JobDepartment d ON e.Job_ID = d.Job_ID
GROUP BY d.JobDept;

-- Which employees have taken the most leaves?

SELECT Emp_ID, COUNT(*) AS LeaveCount
FROM Leaves
GROUP BY Emp_ID
ORDER BY LeaveCount DESC;

-- What is the total number of leave days taken company-wide?

SELECT COUNT(*) AS TotalLeaveDays
FROM Leaves;

-- How do leave days correlate with payroll amounts?

SELECT l.Emp_ID,
COUNT(l.Leave_ID) AS LeaveCount,
AVG(p.Total_Amount) AS AvgPayroll
FROM Leaves l
JOIN Payroll p ON l.Emp_ID = p.Emp_ID
GROUP BY l.Emp_ID
limit 5;

-- What is the total monthly payroll processed?

SELECT DATE_FORMAT(Date, '%Y-%m') AS Month,
SUM(Total_Amount) AS TotalPayroll
FROM Payroll
GROUP BY DATE_FORMAT(Date, '%Y-%m');

-- What is the average bonus given per department?

SELECT d.JobDept, AVG(s.Bonus) AS AvgBonus
FROM SalaryBonus s
JOIN JobDepartment d ON s.Job_ID = d.Job_ID
GROUP BY d.JobDept;

-- Which department receives the highest total bonuses?

SELECT d.JobDept, SUM(s.Bonus) AS TotalBonus
FROM SalaryBonus s
JOIN JobDepartment d ON s.Job_ID = d.Job_ID
GROUP BY d.JobDept
ORDER BY TotalBonus DESC
limit 1;

-- What is the average value of total_amount after considering leave deductions?

SELECT AVG(Total_Amount) AS AvgFinalPayroll
FROM Payroll;
