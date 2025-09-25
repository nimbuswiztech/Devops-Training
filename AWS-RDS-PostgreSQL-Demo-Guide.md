# AWS RDS PostgreSQL Complete Demo Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Creating RDS PostgreSQL Instance](#step-1-creating-rds-postgresql-instance)
3. [Step 2: Configuring Security Groups](#step-2-configuring-security-groups)
4. [Step 3: Finding Connection Information](#step-3-finding-connection-information)
5. [Step 4: Connecting Using psql (Command Line)](#step-4-connecting-using-psql-command-line)
6. [Step 5: Connecting Using pgAdmin (GUI)](#step-5-connecting-using-pgadmin-gui)
7. [Step 6: Creating Sample Database and Tables](#step-6-creating-sample-database-and-tables)
8. [Step 7: Adding Sample Data](#step-7-adding-sample-data)
9. [Step 8: Running Sample Queries](#step-8-running-sample-queries)
10. [Troubleshooting Common Issues](#troubleshooting-common-issues)
11. [Best Practices](#best-practices)
12. [Cost Optimization Tips](#cost-optimization-tips)
13. [Cleanup Process](#cleanup-process)

## Prerequisites

Before starting, ensure you have:
- An active AWS account with appropriate permissions
- AWS CLI installed (optional)
- PostgreSQL client tools installed:
  - **psql command line tool**: Download from [PostgreSQL official website](https://www.postgresql.org/download/)
  - **pgAdmin 4**: Download from [pgAdmin official website](https://www.pgadmin.org/download/)
- Basic understanding of SQL and PostgreSQL

## Step 1: Creating RDS PostgreSQL Instance

### 1.1 Access AWS RDS Console
1. Log into your AWS Management Console
2. In the search bar, type "RDS" and select **Amazon RDS**
3. Click on **Create database** button

### 1.2 Database Creation Method
- Select **Standard Create** (provides more configuration options)
- **Standard Create** allows full control over all settings

### 1.3 Engine Selection
1. **Engine Type**: Select **PostgreSQL**
2. **Version**: Choose the latest stable version (recommended) or specific version as needed
   - Latest version provides newest features and security patches
   - For production, consider using a well-tested version

### 1.4 Templates Selection
Choose based on your use case:
- **Production**: For production workloads (includes Multi-AZ, Provisioned IOPS)
- **Dev/Test**: For development and testing environments
- **Free Tier**: For learning and small projects (if eligible)

*For this demo, select **Free Tier** if available, otherwise choose **Dev/Test***

### 1.5 Settings Configuration
1. **DB Instance Identifier**: Enter a unique name (e.g., `postgres-demo-db`)
2. **Master Username**: Keep default `postgres` or choose custom name
3. **Master Password**: 
   - Either use **Auto generate a password** or
   - Create a strong password (minimum 8 characters)
   - **Important**: Note down the credentials securely

### 1.6 Instance Configuration
1. **DB Instance Class**: 
   - For Free Tier: `db.t3.micro` (1 vCPU, 1 GB RAM)
   - For Dev/Test: Choose based on expected workload
2. **Storage Type**: 
   - **General Purpose SSD (gp2)**: Balanced performance
   - **Provisioned IOPS SSD (io1)**: High I/O performance
3. **Allocated Storage**: Start with 20 GB (minimum)
4. **Storage Autoscaling**: Enable if you expect data growth

### 1.7 Availability & Durability
- **Multi-AZ Deployment**: 
  - **Yes**: High availability (additional cost)
  - **No**: Single AZ deployment (for demo/dev)

### 1.8 Connectivity Settings
1. **Virtual Private Cloud (VPC)**: Select default VPC
2. **Subnet Group**: Use default
3. **Public Access**: **YES** (required for external connections)
   - ⚠️ **Security Note**: Only enable for demos/development
4. **VPC Security Groups**: Create new or use existing
5. **Availability Zone**: Choose preferred or leave default
6. **Database Port**: **5432** (PostgreSQL default)

### 1.9 Database Authentication
- **Password Authentication**: Standard option
- **IAM Database Authentication**: For advanced security (optional)

### 1.10 Additional Configuration
1. **Initial Database Name**: `sampledb` (optional but recommended)
2. **DB Parameter Group**: Default
3. **Backup**:
   - **Backup Retention Period**: 7 days (default)
   - **Backup Window**: Preferred maintenance time
4. **Monitoring**: Enable Enhanced Monitoring (optional)
5. **Log Exports**: Enable PostgreSQL log (optional)
6. **Maintenance**: 
   - **Auto Minor Version Upgrade**: Disable for production stability
   - **Maintenance Window**: Choose low-traffic hours

### 1.11 Encryption
- **Enable Encryption**: Recommended for sensitive data
- **AWS KMS Key**: Default AWS managed key

### 1.12 Create Database
1. Review all settings in **Summary** section
2. Click **Create Database**
3. Creation process takes 10-20 minutes
4. Status will change from **Creating** to **Available**

## Step 2: Configuring Security Groups

### 2.1 Understanding Security Groups
Security groups act as virtual firewalls controlling inbound/outbound traffic to your RDS instance.

### 2.2 Configure Inbound Rules
1. Go to **EC2 Console** → **Security Groups**
2. Find your RDS security group (usually named `rds-launch-wizard-X`)
3. Click **Edit Inbound Rules**

### 2.3 Add PostgreSQL Rule
1. Click **Add Rule**
2. **Type**: Select **PostgreSQL** (automatically sets port 5432)
3. **Protocol**: TCP (automatic)
4. **Port Range**: 5432 (automatic)
5. **Source**: Choose based on security requirements:
   - **My IP**: Your current IP address (most secure)
   - **Anywhere (0.0.0.0/0)**: Allow from any IP (least secure, demo only)
   - **Custom**: Specific IP range or security group

### 2.4 Save Rules
1. Click **Save Rules**
2. Changes take effect immediately

**⚠️ Security Warning**: Using 0.0.0.0/0 allows global access. Only use for demos/development.

## Step 3: Finding Connection Information

### 3.1 Get Database Endpoint
1. Go to **RDS Console** → **Databases**
2. Click on your database instance name
3. In **Connectivity & Security** tab, copy:
   - **Endpoint**: hostname for connections
   - **Port**: typically 5432
   - **Database Name**: from Configuration tab

### 3.2 Example Connection Details
```
Endpoint: postgres-demo-db.c6c8mwvfdgv0.us-west-2.rds.amazonaws.com
Port: 5432
Username: postgres
Database: sampledb (or postgres if no initial DB created)
```

## Step 4: Connecting Using psql (Command Line)

### 4.1 Install psql
**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql-client
```

**CentOS/RHEL:**
```bash
sudo yum install postgresql
```

**macOS:**
```bash
brew install postgresql
```

**Windows:** Download from PostgreSQL official website

### 4.2 Basic Connection Command
```bash
psql --host=<RDS_ENDPOINT> --port=5432 --username=<USERNAME> --dbname=<DATABASE_NAME>
```

### 4.3 Example Connection
```bash
psql --host=postgres-demo-db.c6c8mwvfdgv0.us-west-2.rds.amazonaws.com --port=5432 --username=postgres --dbname=postgres
```

### 4.4 Connection with Password Prompt
```bash
psql --host=postgres-demo-db.c6c8mwvfdgv0.us-west-2.rds.amazonaws.com --port=5432 --username=postgres --password --dbname=postgres
```

### 4.5 Connection String Format (Alternative)
```bash
psql "postgresql://postgres:PASSWORD@postgres-demo-db.c6c8mwvfdgv0.us-west-2.rds.amazonaws.com:5432/postgres"
```

### 4.6 Verify Connection
Once connected, you should see:
```
postgres=> 
```

Test with simple command:
```sql
SELECT version();
```

## Step 5: Connecting Using pgAdmin (GUI)

### 5.1 Install pgAdmin 4
Download from [pgAdmin official website](https://www.pgadmin.org/download/) for your operating system.

### 5.2 Launch pgAdmin
1. Open pgAdmin 4
2. Set master password if prompted (first time only)

### 5.3 Add New Server Connection
1. Right-click **Servers** in left panel
2. Select **Create** → **Server**

### 5.4 General Tab Configuration
1. **Name**: Enter descriptive name (e.g., "AWS RDS PostgreSQL Demo")

### 5.5 Connection Tab Configuration
1. **Host name/address**: Paste RDS endpoint
2. **Port**: 5432
3. **Maintenance database**: postgres (or your database name)
4. **Username**: postgres (or your master username)
5. **Password**: Enter your master password
6. **Save password**: Check if desired

### 5.6 Advanced Tab (Optional)
1. **DB restriction**: Leave empty to show all databases
2. **Connection timeout**: 10 seconds (default)

### 5.7 SSL Tab (Optional)
1. **SSL mode**: Prefer (recommended for security)

### 5.8 Save Connection
1. Click **Save**
2. Connection should appear in server list
3. Expand to view databases

### 5.9 Open Query Tool
1. Right-click on database name
2. Select **Query Tool** to run SQL commands

## Step 6: Creating Sample Database and Tables

### 6.1 Create New Database (Optional)
```sql
CREATE DATABASE company_db;
```

Connect to the new database:
```sql
\c company_db;
```

### 6.2 Create Sample Tables

#### Employee Table
```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(100),
    salary DECIMAL(10, 2),
    department_id INTEGER,
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Department Table
```sql
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget DECIMAL(15, 2),
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Project Table
```sql
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    status VARCHAR(20) DEFAULT 'Planning',
    department_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Employee-Project Assignment Table
```sql
CREATE TABLE project_assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    assigned_date DATE NOT NULL,
    role VARCHAR(50),
    hours_per_week INTEGER,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
```

### 6.3 Add Foreign Key Constraints
```sql
-- Add foreign key for department in employees table
ALTER TABLE employees 
ADD CONSTRAINT fk_emp_department 
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Add foreign key for manager in employees table
ALTER TABLE employees 
ADD CONSTRAINT fk_emp_manager 
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Add foreign key for projects
ALTER TABLE projects 
ADD CONSTRAINT fk_proj_department 
FOREIGN KEY (department_id) REFERENCES departments(department_id);
```

### 6.4 Create Indexes for Performance
```sql
-- Index on email for quick lookups
CREATE INDEX idx_employees_email ON employees(email);

-- Index on department_id
CREATE INDEX idx_employees_department ON employees(department_id);

-- Index on hire_date for date range queries
CREATE INDEX idx_employees_hire_date ON employees(hire_date);

-- Index on project status
CREATE INDEX idx_projects_status ON projects(status);
```

## Step 7: Adding Sample Data

### 7.1 Insert Department Data
```sql
INSERT INTO departments (department_name, location, budget, manager_id) VALUES
('Engineering', 'San Francisco', 2500000.00, NULL),
('Marketing', 'New York', 800000.00, NULL),
('Sales', 'Chicago', 1200000.00, NULL),
('Human Resources', 'Austin', 500000.00, NULL),
('Finance', 'Boston', 600000.00, NULL),
('IT Support', 'Seattle', 400000.00, NULL);
```

### 7.2 Insert Employee Data
```sql
INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, salary, department_id, manager_id) VALUES
-- Engineering Team
('John', 'Smith', 'john.smith@company.com', '555-0101', '2022-01-15', 'Senior Software Engineer', 95000.00, 1, NULL),
('Emily', 'Johnson', 'emily.johnson@company.com', '555-0102', '2022-03-20', 'Frontend Developer', 75000.00, 1, 1),
('Michael', 'Brown', 'michael.brown@company.com', '555-0103', '2021-11-10', 'Backend Developer', 80000.00, 1, 1),
('Sarah', 'Davis', 'sarah.davis@company.com', '555-0104', '2023-02-28', 'DevOps Engineer', 85000.00, 1, 1),
('David', 'Wilson', 'david.wilson@company.com', '555-0105', '2022-08-05', 'Database Administrator', 88000.00, 1, 1),

-- Marketing Team
('Lisa', 'Anderson', 'lisa.anderson@company.com', '555-0201', '2022-04-12', 'Marketing Manager', 78000.00, 2, NULL),
('Chris', 'Taylor', 'chris.taylor@company.com', '555-0202', '2022-09-18', 'Content Specialist', 55000.00, 2, 6),
('Amanda', 'Garcia', 'amanda.garcia@company.com', '555-0203', '2023-01-22', 'Social Media Manager', 58000.00, 2, 6),

-- Sales Team
('Robert', 'Martinez', 'robert.martinez@company.com', '555-0301', '2021-12-08', 'Sales Director', 92000.00, 3, NULL),
('Jennifer', 'Lopez', 'jennifer.lopez@company.com', '555-0302', '2022-06-14', 'Sales Representative', 65000.00, 3, 9),
('Kevin', 'Clark', 'kevin.clark@company.com', '555-0303', '2022-10-25', 'Account Manager', 70000.00, 3, 9),

-- HR Team
('Michelle', 'Rodriguez', 'michelle.rodriguez@company.com', '555-0401', '2021-08-30', 'HR Director', 85000.00, 4, NULL),
('Daniel', 'Lewis', 'daniel.lewis@company.com', '555-0402', '2023-03-15', 'HR Specialist', 52000.00, 4, 12),

-- Finance Team
('Jessica', 'Walker', 'jessica.walker@company.com', '555-0501', '2021-10-20', 'Finance Manager', 82000.00, 5, NULL),
('Thomas', 'Hall', 'thomas.hall@company.com', '555-0502', '2022-12-07', 'Financial Analyst', 60000.00, 5, 14);
```

### 7.3 Update Manager References
```sql
-- Update department managers
UPDATE departments SET manager_id = 1 WHERE department_name = 'Engineering';
UPDATE departments SET manager_id = 6 WHERE department_name = 'Marketing';
UPDATE departments SET manager_id = 9 WHERE department_name = 'Sales';
UPDATE departments SET manager_id = 12 WHERE department_name = 'Human Resources';
UPDATE departments SET manager_id = 14 WHERE department_name = 'Finance';
```

### 7.4 Insert Project Data
```sql
INSERT INTO projects (project_name, description, start_date, end_date, budget, status, department_id) VALUES
('Website Redesign', 'Complete overhaul of company website with modern UI/UX', '2023-01-01', '2023-06-30', 150000.00, 'In Progress', 1),
('Mobile App Development', 'Native mobile application for iOS and Android', '2023-03-01', '2023-12-31', 300000.00, 'In Progress', 1),
('Database Migration', 'Migration from legacy database to cloud-based solution', '2023-02-15', '2023-08-15', 80000.00, 'Planning', 1),
('Marketing Campaign Q2', 'Digital marketing campaign for Q2 product launch', '2023-04-01', '2023-06-30', 50000.00, 'Active', 2),
('Sales Training Program', 'Comprehensive training program for new sales techniques', '2023-01-15', '2023-04-15', 25000.00, 'Completed', 3),
('HR System Upgrade', 'Upgrade to new HRMS system', '2023-05-01', '2023-09-30', 45000.00, 'Planning', 4);
```

### 7.5 Insert Project Assignments
```sql
INSERT INTO project_assignments (employee_id, project_id, assigned_date, role, hours_per_week) VALUES
-- Website Redesign assignments
(1, 1, '2023-01-01', 'Project Lead', 40),
(2, 1, '2023-01-01', 'Frontend Developer', 35),
(3, 1, '2023-01-15', 'Backend Developer', 30),

-- Mobile App Development assignments
(1, 2, '2023-03-01', 'Technical Lead', 20),
(2, 2, '2023-03-01', 'UI Developer', 40),
(3, 2, '2023-03-01', 'API Developer', 40),
(4, 2, '2023-03-01', 'DevOps Support', 15),

-- Database Migration assignments
(5, 3, '2023-02-15', 'Database Lead', 40),
(4, 3, '2023-02-15', 'Infrastructure Support', 25),

-- Marketing Campaign assignments
(6, 4, '2023-04-01', 'Campaign Manager', 40),
(7, 4, '2023-04-01', 'Content Creator', 35),
(8, 4, '2023-04-01', 'Social Media Lead', 30),

-- Sales Training assignments
(9, 5, '2023-01-15', 'Program Director', 25),
(10, 5, '2023-01-15', 'Trainer', 20),

-- HR System Upgrade assignments
(12, 6, '2023-05-01', 'Project Manager', 35),
(13, 6, '2023-05-01', 'System Analyst', 30);
```

## Step 8: Running Sample Queries

### 8.1 Basic Select Queries

#### View All Employees
```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    job_title,
    salary
FROM employees
ORDER BY last_name;
```

#### View All Departments
```sql
SELECT 
    department_id,
    department_name,
    location,
    budget
FROM departments
ORDER BY department_name;
```

### 8.2 Join Queries

#### Employees with Department Information
```sql
SELECT 
    e.first_name,
    e.last_name,
    e.job_title,
    e.salary,
    d.department_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, e.last_name;
```

#### Employees with Their Managers
```sql
SELECT 
    emp.first_name AS employee_first_name,
    emp.last_name AS employee_last_name,
    emp.job_title,
    mgr.first_name AS manager_first_name,
    mgr.last_name AS manager_last_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.last_name;
```

### 8.3 Aggregate Queries

#### Average Salary by Department
```sql
SELECT 
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    ROUND(AVG(e.salary), 2) as average_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;
```

#### Project Status Summary
```sql
SELECT 
    status,
    COUNT(*) as project_count,
    SUM(budget) as total_budget
FROM projects
GROUP BY status
ORDER BY project_count DESC;
```

### 8.4 Complex Queries

#### Employee Project Workload
```sql
SELECT 
    e.first_name,
    e.last_name,
    e.job_title,
    COUNT(pa.project_id) as project_count,
    SUM(pa.hours_per_week) as total_hours_per_week
FROM employees e
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title
ORDER BY total_hours_per_week DESC NULLS LAST;
```

#### Department Budget Utilization
```sql
SELECT 
    d.department_name,
    d.budget as department_budget,
    COALESCE(SUM(p.budget), 0) as project_budget_allocated,
    d.budget - COALESCE(SUM(p.budget), 0) as remaining_budget,
    ROUND((COALESCE(SUM(p.budget), 0) / d.budget) * 100, 2) as utilization_percentage
FROM departments d
LEFT JOIN projects p ON d.department_id = p.department_id
GROUP BY d.department_id, d.department_name, d.budget
ORDER BY utilization_percentage DESC;
```

### 8.5 Date and Time Queries

#### Employees Hired in Last Year
```sql
SELECT 
    first_name,
    last_name,
    hire_date,
    job_title,
    AGE(CURRENT_DATE, hire_date) as tenure
FROM employees
WHERE hire_date >= CURRENT_DATE - INTERVAL '1 year'
ORDER BY hire_date DESC;
```

#### Current Active Projects
```sql
SELECT 
    project_name,
    start_date,
    end_date,
    status,
    CASE 
        WHEN end_date < CURRENT_DATE THEN 'Overdue'
        WHEN start_date > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END as timeline_status
FROM projects
WHERE status IN ('In Progress', 'Active')
ORDER BY end_date;
```

### 8.6 Update and Delete Operations

#### Update Employee Salary
```sql
-- Give a 10% raise to all employees in Engineering
UPDATE employees 
SET salary = salary * 1.10
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Engineering');
```

#### Update Project Status
```sql
-- Mark completed projects
UPDATE projects 
SET status = 'Completed' 
WHERE end_date < CURRENT_DATE AND status != 'Completed';
```

## Step 9: Creating a Northwind Sample Database (Alternative)

### 9.1 Create Northwind Database
```sql
CREATE DATABASE northwind;
\c northwind;
```

### 9.2 Northwind Tables (Simplified Version)
```sql
-- Categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(25) NOT NULL,
    description TEXT
);

-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    address VARCHAR(50),
    city VARCHAR(20),
    postal_code VARCHAR(10),
    country VARCHAR(15)
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id),
    unit_price DECIMAL(10,2),
    units_in_stock INTEGER
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    required_date DATE,
    shipped_date DATE,
    freight DECIMAL(10,2)
);

-- Order Details table
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    unit_price DECIMAL(10,2),
    quantity INTEGER,
    discount DECIMAL(3,2) DEFAULT 0
);
```

### 9.3 Insert Northwind Sample Data
```sql
-- Insert categories
INSERT INTO categories (category_name, description) VALUES
('Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
('Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings'),
('Dairy Products', 'Cheeses'),
('Grains/Cereals', 'Breads, crackers, pasta, and cereal'),
('Meat/Poultry', 'Prepared meats'),
('Produce', 'Dried fruit and bean curd'),
('Seafood', 'Seaweed and fish');

-- Insert customers
INSERT INTO customers (customer_name, contact_name, address, city, postal_code, country) VALUES
('Alfreds Futterkiste', 'Maria Anders', 'Obere Str. 57', 'Berlin', '12209', 'Germany'),
('Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Avda. de la Constitución 2222', 'México D.F.', '05021', 'Mexico'),
('Antonio Moreno Taquería', 'Antonio Moreno', 'Mataderos 2312', 'México D.F.', '05023', 'Mexico'),
('Around the Horn', 'Thomas Hardy', '120 Hanover Sq.', 'London', 'WA1 1DP', 'UK'),
('Berglunds snabbköp', 'Christina Berglund', 'Berguvsvägen 8', 'Luleå', 'S-958 22', 'Sweden');

-- Insert products
INSERT INTO products (product_name, category_id, unit_price, units_in_stock) VALUES
('Chais', 1, 18.00, 39),
('Chang', 1, 19.00, 17),
('Aniseed Syrup', 2, 10.00, 13),
('Chef Anton''s Cajun Seasoning', 2, 22.00, 53),
('Chef Anton''s Gumbo Mix', 2, 21.35, 0),
('Grandma''s Boysenberry Spread', 2, 25.00, 120),
('Uncle Bob''s Organic Dried Pears', 7, 30.00, 15),
('Northwoods Cranberry Sauce', 2, 40.00, 6),
('Mishi Kobe Niku', 6, 97.00, 29),
('Ikura', 8, 31.00, 31);
```

## Troubleshooting Common Issues

### Issue 1: Connection Timeout
**Symptoms:**
```
psql: error: could not connect to server: Connection timed out
```

**Solutions:**
1. **Check Security Groups:**
   - Verify inbound rule allows port 5432
   - Confirm source IP is correct
   - Test with 0.0.0.0/0 temporarily

2. **Verify Public Access:**
   - Ensure RDS instance has Public Access = Yes
   - Check VPC route table configuration

3. **Check Endpoint:**
   - Use correct RDS endpoint (not localhost)
   - Verify region matches

### Issue 2: Connection Refused
**Symptoms:**
```
psql: error: could not connect to server: Connection refused
```

**Solutions:**
1. **Database Status:** Ensure RDS status is "Available"
2. **Port Configuration:** Confirm port 5432 is configured
3. **Network ACLs:** Check VPC Network ACLs allow traffic

### Issue 3: Authentication Failed
**Symptoms:**
```
psql: error: FATAL: password authentication failed for user "postgres"
```

**Solutions:**
1. **Password Verification:** Double-check master password
2. **Username Verification:** Confirm master username
3. **Reset Password:** Use AWS Console to modify DB instance

### Issue 4: Database Does Not Exist
**Symptoms:**
```
psql: error: FATAL: database "mydb" does not exist
```

**Solutions:**
1. **Use Default Database:** Connect to `postgres` database first
2. **Create Database:** Run `CREATE DATABASE mydb;`
3. **Check Database List:** Use `\l` in psql to list databases

### Issue 5: SSL Connection Issues
**Symptoms:**
```
psql: error: FATAL: no pg_hba.conf entry for host
```

**Solutions:**
1. **Enable SSL:** Add `sslmode=require` to connection string
2. **Download Certificate:** Get RDS SSL certificate
3. **Use SSL Parameters:**
   ```bash
   psql "sslmode=require host=... port=5432 dbname=... user=..."
   ```

### Debugging Tips

#### Test Network Connectivity
```bash
# Test if port is open
telnet your-rds-endpoint.amazonaws.com 5432

# Test with nmap (if available)
nmap -p 5432 your-rds-endpoint.amazonaws.com
```

#### Enable Connection Logging
1. Go to RDS Console → Parameter Groups
2. Create custom parameter group
3. Set `log_connections = 1`
4. Apply to RDS instance

#### Check RDS Logs
1. RDS Console → Databases → Your Instance
2. Go to "Logs & events" tab
3. View PostgreSQL logs for connection attempts

## Best Practices

### Security Best Practices
1. **Restrict Security Groups:** Only allow necessary IPs/ranges
2. **Use SSL/TLS:** Always encrypt connections in production
3. **Strong Passwords:** Use complex passwords or IAM authentication
4. **Regular Updates:** Keep PostgreSQL version updated
5. **Private Subnets:** Use private subnets for production databases

### Performance Best Practices
1. **Appropriate Instance Size:** Choose instance class based on workload
2. **Storage Type:** Use Provisioned IOPS for high I/O applications
3. **Connection Pooling:** Implement connection pooling in applications
4. **Query Optimization:** Use EXPLAIN ANALYZE to optimize queries
5. **Indexing Strategy:** Create appropriate indexes for frequent queries

### Backup Best Practices
1. **Automated Backups:** Enable with appropriate retention period
2. **Manual Snapshots:** Create before major changes
3. **Cross-Region Backup:** For disaster recovery
4. **Test Restores:** Regularly test backup restoration process

### Monitoring Best Practices
1. **CloudWatch Metrics:** Monitor CPU, memory, I/O, connections
2. **Enhanced Monitoring:** Enable for detailed OS-level metrics
3. **Performance Insights:** Enable for query-level performance data
4. **Alerting:** Set up CloudWatch alarms for key metrics

## Cost Optimization Tips

### Instance Management
1. **Right-sizing:** Regular review and adjust instance classes
2. **Reserved Instances:** Use for predictable workloads
3. **Stop/Start:** Stop development instances when not in use
4. **Multi-AZ:** Only enable for production workloads

### Storage Optimization
1. **Storage Auto Scaling:** Prevent over-provisioning
2. **gp2 vs gp3:** Evaluate gp3 for better price/performance
3. **Unused Space:** Regular cleanup of unused data
4. **Backup Retention:** Optimize backup retention periods

### Feature Management
1. **Enhanced Monitoring:** Disable if not actively used
2. **Performance Insights:** Free tier available, paid features optional
3. **Encryption:** Evaluate necessity for development environments

## Cleanup Process

### 1. Delete Sample Data (Optional)
```sql
-- Connect to your database
\c company_db;

-- Drop tables in correct order (foreign keys)
DROP TABLE IF EXISTS project_assignments;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Drop the database
\c postgres;
DROP DATABASE IF EXISTS company_db;
```

### 2. Delete RDS Instance
1. Go to RDS Console → Databases
2. Select your instance
3. Click **Actions** → **Delete**
4. **Important Options:**
   - **Create final snapshot**: Yes (recommended)
   - **Delete automated backups**: Choose based on needs
5. Type "delete me" to confirm
6. Click **Delete DB Instance**

### 3. Clean Up Security Groups (Optional)
1. Go to EC2 Console → Security Groups
2. Find RDS-related security groups
3. Delete if no longer needed
4. **Note:** Cannot delete if still referenced by other resources

### 4. Remove Parameter Groups (Optional)
1. Go to RDS Console → Parameter Groups
2. Select custom parameter groups
3. Delete if no longer needed

## Additional Resources

### Documentation Links
- [AWS RDS PostgreSQL User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)

### SQL Practice Resources
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com/)
- [W3Schools PostgreSQL](https://www.w3schools.com/postgresql/)
- [SQL Bolt Interactive Tutorial](https://sqlbolt.com/)

### Sample Databases
- [PostgreSQL Sample Database](https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/)
- [Northwind Database](https://github.com/pthom/northwind_psql)
- [Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/) (adapted versions available)

## Conclusion

This comprehensive guide covers everything needed to create, configure, connect to, and work with an AWS RDS PostgreSQL instance. From initial setup through advanced querying and troubleshooting, you now have the knowledge to effectively use PostgreSQL on AWS RDS.

Remember to always follow security best practices, optimize for cost and performance, and regularly monitor your database instances. As you become more comfortable with RDS, explore advanced features like read replicas, Multi-AZ deployments, and Performance Insights for production workloads.

Happy learning and building with AWS RDS PostgreSQL!

---
**Created for DevOps Demo Purposes**  
*Last Updated: September 2025*