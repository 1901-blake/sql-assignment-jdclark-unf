/* 2.1 */
-- Select all records from the Employee table.
select * from employee;

-- Select all records from the Employee table where last name is King.
select * from employee where lastname = 'King';

-- Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname = 'Andrew' and reportsto = null;

/* 2.2 */
-- Select all albums in Album table and sort result set in descending order by title.
select * from album order by title desc;

-- Select first name from Customer and sort result set in ascending order by city
select firstname from customer order by city asc;

/* 2.3 */
-- Insert two new records into Genre table
insert into genre values (26, default), (27, default);

-- Insert two new records into Employee table
insert into employee (employeeid, lastname, firstname) values (11, '', ''), (12, '', '');

-- Insert two new records into Customer table
insert into customer (customerid, firstname, lastname, email) values (60, '', '', ''), (61, '', '', '');

/* 2.4 */
-- Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname = 'Robert', lastname = 'Walter' where firstname = 'Aaron' and lastname = 'Mitchell';

-- Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist set name = 'CCR' where name = 'Creedence Clearwater Revival';

/* 2.5 */
-- Select all invoices with a billing address like “T%”
select * from invoice where billingaddress like 'T%';

/* 2.6 */
-- Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;

-- Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate between '2003-06-01' and '2004-03-01';

/* 2.7 */
-- Delete a record in Customer table where the name is Robert Walter
delete from invoiceline where invoiceid in (50, 61, 116, 245, 268, 290, 342); /* constraint */
delete from invoice where customerid = 32; /* constraint */
delete from customer where firstname = 'Robert' and lastname = 'Walter';

/* 3.1 */
-- Create a function that returns the current time.
create or replace function getCurrentTime() returns timestamptz
    as $$
        declare
            currentTime timestamptz; 
        begin
            select now() into currentTime;
            return currentTime;
        end;
    $$ language plpgsql;
select getCurrentTime();

/* 3.2 */
-- Create a function that returns the average total of all invoices
create or replace function avgInvoice() returns numeric
	as $$
        declare
            average numeric;
        begin
            select round(avg(total), 2) from invoice into average;
            return average;
        end;
    $$ language plpgsql;
select avgInvoice();

-- Create a function that returns the most expensive track
create or replace function getCostliestTrack() returns setof varchar
    as $$
        declare
            maxPrice numeric;
        begin
            select max(unitprice) from track into maxPrice;
            return query select name from track where unitprice = maxPrice;
            return;
        end;
    $$ language plpgsql;
select getCostliestTrack();

/* 3.3 */
-- Create a function that returns the average price of invoiceline items in the invoiceline table
create function getAvgPrice() returns table(id int, avgPrice numeric)
    as $$
        begin
            return query select invoiceid, round(avg(unitprice), 2) from invoiceline group by invoiceid  order by invoiceid asc;
            return;
        end;
    $$ language plpgsql;
select getAvgPrice();

/* 3.4 */
-- Create a function that returns all employees who are born after 1968.
create function getEmployee() returns table(fName varchar, lName varchar)
    as $$
        begin
            return query select firstname, lastname from employee where (select extract(year from birthdate)) > 1968;
            return;
        end;
    $$ language plpgsql;
select getEmployee();

/* 4.1 */
-- Create a stored procedure that selects the first and last names of all the employees.
create function getAllNames_proc() returns setof text
    as $$
        begin
            return query select concat(firstname, ' ', lastname) from employee;
            return;
        end;
    $$ language plpgsql;
select * from getAllNames_proc() as employee_name;
 
/* 4.2 */
-- Create a stored procedure that updates the personal information of an employee.
create function updateEmployee_proc(
    e_id integer, e_fname varchar, e_lname varchar, e_title varchar, 
    e_managerid integer, e_birthdate timestamp, e_hiredate timestamp, 
    e_address varchar, e_city varchar, e_state varchar, e_country varchar, 
    e_postalcode varchar, e_phone varchar, e_fax varchar, e_email varchar
) returns void
    as $$
        begin
            update employee set firstname = e_fname, lastname = e_lname, 
                title = e_title, reportsto = e_managerid, birthdate = e_birthdate, 
                hiredate = e_hiredate, address = e_address, city = e_city, state = e_state,
                country = e_country, postalcode = e_postalcode, phone = e_phoneinput, 
                fax = e_fax, email = e_email where employeeid = e_id;
        end;
    $$ language plpgsql;

-- Create a stored procedure that returns the managers of an employee.
create function getManager_proc(in empId integer, out manager text)
    as $$
        declare
            managerId integer;
        begin
            select reportsto from employee where employeeid = empId into managerId;
            select concat(firstname, ' ', lastname) from employee where employeeid = managerId into manager;
        end;
    $$ language plpgsql;
select getManager_proc(2) as "Manager";

/* 4.3 */
-- Create a stored procedure that returns the name and company of a customer.
create function getNameCompany_proc(in custId integer) returns table(firstname, lastname, company)
    as $$
        begin
            return query select firstname, lastname, company from customer where customerid = custId;
            return;
        end;
    $$ language plpgsql;
select getNameCompany_proc(1);

/* 5.0 */
-- Create a transaction that given a invoiceId will delete that invoice 
-- ??

-- Create a transaction nested within a stored procedure that inserts a new record in the Customer table
-- ??

/* 6.1 */
-- Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger afterInsert_trig on employee for each statement;

-- Create an after update trigger on the album table that fires after a row is inserted in the table
create trigger afterUpdate_trig on album for each row;

-- Create an after delete trigger on the customer table that fires after a row is deleted from the table.
create trigger afterUpdate_trig on customer for each row;

/* 7.1 */
-- Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
select firstname, lastname, invoiceid from customer inner join invoice on (customer.customerid = invoice.customerid);

/* 7.2 */
-- Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
select invoice.customerid, firstname, lastname, invoiceid, total from
    customer full join invoice on customer.customerid = invoice.customerid;

/* 7.3 */
-- Create a right join that joins album and artist specifying artist name and title.
select name as artist_name, title as album_title from album right join artist on (artist.artistid = album.artistid)

/* 7.4 */
-- Create a cross join that joins album and artist and sorts by artist name in ascending order.
select * from album cross join artist order by artist.name asc;

/* 7.5 */
-- Perform a self-join on the employee table, joining on the reportsto column.
select e.firstname, e.lastname, m.firstname, m.lastname from employee e 
    join employee m on e.reportsto = m.employeeid;