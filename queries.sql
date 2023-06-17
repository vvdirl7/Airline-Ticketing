-- script file for database creation, population and modification

-- creating database
create database airline_ticketing;

-- creating tables

-- users table
create table if not exists users(
UID int unsigned primary key not null auto_increment,
fname varchar(50) not null default ' ',
lname varchar(50) not null default ' ',
dob date,
phone varchar(20) not null,
email varchar(50),
password varchar(30) not null,
gender ENUM('male', 'female', 'other')
);

-- airlines table
create table if not exists airlines(
  airline_id INT unsigned primary key not null AUTO_INCREMENT,
  airline_name VARCHAR(255) NOT NULL,
  airline_password VARCHAR(255) NOT NULL
);

-- flights table
create table if not exists flights(
flight_id INT unsigned PRIMARY KEY not null AUTO_INCREMENT,
departure_date DATE NOT NULL,
  departure_time TIME NOT NULL,
  f_airline_id int unsigned NOT NULL,
  origin VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  duration INT NOT NULL,
foreign key(f_airline_id)
references airlines(airline_id)
on delete cascade
on update cascade
);

-- booking table (contaisn data about which user booked seats on which flight
create table if not exists booking (
bid int unsigned primary key not null auto_increment,
b_fid int unsigned not null,
b_uid int unsigned not null,
constraint fk_booking_fid FOREIGN KEY(b_fid)
references flights(flight_id) 
on delete restrict
on update cascade,
constraint fk_booking_uid FOREIGN KEY(b_uid)
references users(uid)
on delete restrict
on update cascade
);

-- seats table
create table if not exists seats(
seat_no int unsigned not null,
s_fid int unsigned not null,
s_class enum('first', 'business', 'economy') not null,
s_type enum('window', 'middle', 'aisle') not null,
s_price float not null,
s_bid int unsigned default null,
primary key(seat_no, s_fid),
constraint fk_seats_fid FOREIGN KEY(s_fid)
references flights(flight_id)
on delete cascade
on update cascade,
constraint fk_seats_bid FOREIGN KEY(s_bid)
references booking(bid)
on delete set null
on update cascade
); 

-- booked_seats table (contains data on which user booked which seats on a flight)
create table if not exists booked_seats(
bs_bid int unsigned not null,
bs_sno int unsigned not null,
bs_fid int unsigned not null,
primary key(bs_bid, bs_sno),
constraint fk_bs_bid foreign key(bs_bid)
references booking(bid)
on delete cascade
on update cascade,
constraint fk_bs_seats foreign key(bs_sno, bs_fid)
references seats(seat_no, s_fid)
on delete cascade
on update cascade
);

-- books table (contains data on time of booking)
create table if not exists books(
bo_uid int unsigned not null,
bo_bid int unsigned not null,
bo_time time not null,
primary key(bo_uid, bo_bid),
constraint fk_bo_uid foreign key(bo_uid)
references users(uid),
constraint fk_bo_bid foreign key(bo_bid)
references booking(bid)
);

-- payment table
create table if not exists payment(
pid int unsigned primary key not null auto_increment,
amount float not null,
confirm enum('true') default null,
p_bid int unsigned not null,
constraint fk_p_bid foreign key(p_bid)
references booking(bid)
);

-- has_payment table (contains data on time of payment)
create table if not exists has_payment(
hp_bid int unsigned primary key not null,
hp_pid int unsigned not null,
hp_time time not null,
foreign key(hp_pid)
references payment(pid),
foreign key(hp_bid)
references booking(bid)
);

--cancellation table
create table if not exists cancellation(
cid int unsigned primary key not null auto_increment,
message varchar(255) default ' ',
c_bid int unsigned not null,
c_time time not null,
foreign key(c_bid)
references booking(bid)
);


-- populating users table
INSERT INTO users (fname, lname, dob, phone, email, password, gender) VALUES
('Aarav', 'Gupta', '1995-03-12', '+91 9876543210', 'aaravgupta@gmail.com', 'password1', 'male'),
('Aditi', 'Shah', '1989-06-25', '+91 9876543211', 'aditishah@gmail.com', 'password2', 'female'),
('Anjali', 'Singh', '1990-10-17', '+91 9876543212', 'anjalisingh@gmail.com', 'password3', 'female'),
('Aryan', 'Patel', '1993-11-02', '+91 9876543213', 'aryanpatel@gmail.com', 'password4', 'male'),
('Devanshi', 'Desai', '1996-02-07', '+91 9876543214', 'devanshidesai@gmail.com', 'password5', 'female'),
('Gaurav', 'Mehta', '1987-12-28', '+91 9876543215', 'gauravmehta@gmail.com', 'password6', 'male'),
('Kavya', 'Sharma', '1994-04-11', '+91 9876543216', 'kavyasharma@gmail.com', 'password7', 'female'),
('Manav', 'Shukla', '1991-09-23', '+91 9876543217', 'manavshukla@gmail.com', 'password8', 'male'),
('Neha', 'Joshi', '1988-08-04', '+91 9876543218', 'nehajoshi@gmail.com', 'password9', 'female'),
('Pranav', 'Dave', '1992-05-19', '+91 9876543219', 'pranavdave@gmail.com', 'password10', 'male');

-- populating airlines table
INSERT INTO airlines (airline_name, airline_password) VALUES
('Air India', 'a1b2c3d4e5'),
('IndiGo', 'f6g7h8i9j0'),
('SpiceJet', 'k1l2m3n4o5'),
('Vistara', 'p6q7r8s9t0'),
('GoAir', 'u1v2w3x4y5'),
('AirAsia India', 'z6a7b8c9d0');

-- populating flights table
INSERT INTO flights (departure_date, departure_time, f_airline_id, origin, destination, duration) VALUES
('2023-04-15', '10:00:00', 1, 'Mumbai', 'Delhi', 120),
('2023-04-15', '12:00:00', 2, 'Delhi', 'Mumbai', 120),
('2023-04-15', '15:00:00', 3, 'Mumbai', 'Chennai', 90),
('2023-04-15', '16:00:00', 4, 'Chennai', 'Mumbai', 90),
('2023-04-16', '09:00:00', 5, 'Delhi', 'Kolkata', 120),
('2023-04-16', '11:00:00', 6, 'Kolkata', 'Delhi', 120),
('2023-04-16', '14:00:00', 1, 'Mumbai', 'Bangalore', 120),
('2023-04-16', '16:00:00', 2, 'Bangalore', 'Mumbai', 120),
('2023-04-17', '08:00:00', 3, 'Chennai', 'Kolkata', 120),
('2023-04-17', '10:00:00', 4, 'Kolkata', 'Chennai', 120);

-- populating seats table
INSERT INTO seats (seat_no, s_fid, s_class, s_type, s_price) VALUES
(1, 1, 'first', 'window', 100.00),
(2, 1, 'first', 'aisle', 100.00),
(3, 1, 'first', 'middle', 100.00),
(4, 1, 'business', 'window', 80.00),
(5, 1, 'business', 'aisle', 80.00),
(6, 1, 'business', 'middle', 80.00),
(7, 1, 'economy', 'window', 50.00),
(8, 1, 'economy', 'aisle', 50.00),
(9, 1, 'economy', 'middle', 50.00),
(10, 2, 'first', 'window', 150.00),
(11, 2, 'first', 'aisle', 150.00),
(12, 2, 'first', 'middle', 150.00),
(13, 2, 'business', 'window', 120.00),
(14, 2, 'business', 'aisle', 120.00),
(15, 2, 'business', 'middle', 120.00),
(16, 2, 'economy', 'window', 80.0),
(17, 2, 'economy', 'aisle', 80.0),
(18, 2, 'economy', 'middle', 80.00),
(1, 3, 'first', 'window', 20000.00),
(2, 3, 'first', 'aisle', 20000.00),
(3, 3, 'first', 'middle', 20000.00),
(4, 3, 'business', 'window', 15000.00),
(5, 3, 'business', 'aisle', 15000.00),
(6, 3, 'economy', 'window', 8000.00),
(7, 3, 'economy', 'aisle', 8000.00),
(8, 4, 'first', 'window', 20000.00),
(9, 4, 'first', 'aisle', 20000.00),
(10, 4, 'first', 'middle', 20000.00),
(11, 4, 'business', 'window', 15000.00),
(12, 4, 'business', 'aisle', 15000.00),
(13, 4, 'economy', 'window', 8000.00),
(14, 4, 'economy', 'aisle', 8000.00),
(15, 5, 'first', 'window', 20000.00),
(16, 5, 'first', 'aisle', 20000.00),
(17, 5, 'first', 'middle', 20000.00),
(18, 5, 'business', 'window', 15000.00),
(19, 5, 'business', 'aisle', 15000.00),
(20, 5, 'economy', 'window', 8000.00),
(21, 5, 'economy', 'aisle', 8000.00),
(22, 6, 'first', 'window', 20000.00),
(23, 6, 'first', 'aisle', 20000.00),
(24, 6, 'first', 'middle', 20000.00),
(25, 6, 'business', 'window', 15000.00),
(26, 6, 'business', 'aisle', 15000.00),
(27, 6, 'economy', 'window', 8000.00),
(28, 6, 'economy', 'aisle', 8000.00),
(29, 7, 'first', 'window', 20000.00),
(30, 7, 'first', 'aisle', 20000.00),
(31, 7, 'first', 'middle', 20000.00),
(32, 7, 'business', 'window', 15000.00),
(33, 7, 'business', 'aisle', 15000.00),
(34, 7, 'economy', 'window', 8000.00),
(35, 7, 'economy', 'aisle', 8000.00),
(36, 8, 'first', 'window', 20000.00),
(1, 8, 'first', 'window', 2000.00),
(2, 8, 'first', 'window', 2000.00),
(3, 8, 'business', 'aisle', 1500.00),
(4, 8, 'business', 'aisle', 1500.00),
(5, 8, 'economy', 'middle', 1000.00),
(6, 8, 'economy', 'middle', 1000.00),
(1, 9, 'first', 'window', 2000.00),
(2, 9, 'first', 'window', 2000.00),
(3, 9, 'business', 'aisle', 1500.00),
(4, 9, 'business', 'aisle', 1500.00),
(5, 9, 'economy', 'middle', 1000.00),
(6, 9, 'economy', 'middle', 1000.00),
(1, 10, 'first', 'window', 2000.00),
(2, 10, 'first', 'window', 2000.00),
(3, 10, 'business', 'aisle', 1500.00),
(4, 10, 'business', 'aisle', 1500.00),
(5, 10, 'economy', 'middle', 1000.00),
(6, 10, 'economy', 'middle', 1000.00);


-- All following queries contain dummy data, the queries integrated with the python backend contain placeholders where user inputted data is inserted

-- query to check for correct login info
SELECT * FROM users WHERE uid=5 AND password=password5;

-- query to display all bookings for user id 5
select bk.bo_bid, s.seat_no, s.s_fid from seats s join books bk on s.s_bid=bk.bo_bid where bk.bo_uid=5;

--the following queries are to cancel a certain booking
-- query to select a certain booking for a certain id
select * from books where bo_uid=5 and bo_bid=1;
-- query to set booking id to null for all booked seats in seats table
UPDATE seats SET s_bid = NULL WHERE s_bid = 1;
-- query to delete records for the booking from the table booked_seats
delete from booked_seats where bs_bid=1;
-- query to update cancellation details in the table
insert into cancellation (c_bid, c_time) values (1, 14:30:00);
-- query to find latest cancellation id
select max(cid) from cancellation;
-- query to set cancellation message
update cancellation set message="booking cancelled" where cid=1;

-- query to check for confirmed payment for a booking
select p.confirm from payment p join booking b on p.p_bid=b.bid where p.p_bid=1 and p.confirm="true";

-- the following queries are to book a flight, seats and to pay
-- query to view flights using source and destination
SELECT * FROM flights where origin="Mumbai" and destination="Delhi";
-- the following query checks flights on a particular day
SELECT * FROM flights WHERE departure_date=2023-04-11;
-- this query checks available seats in a particular class on a flight
SELECT * FROM seats WHERE s_fid = 1 AND s_bid IS NULL AND s_class="economy";
-- query checks all available seats in a flight
SELECT * FROM seats WHERE s_fid = 1 AND s_bid IS NULL;
-- finding total price of selected seats
SELECT SUM(s_price) FROM seats WHERE s_fid = 1 AND seat_no IN (10, 11, 12) AND s_bid IS NULL
-- query to display booking id and price of seat selected
select s_bid, s_price from seats where s_fid=1 and seat_no=10;
-- query to insert booking id and user id details into booking table
insert into booking (b_fid, b_uid) values (1, 1);
-- query to insert details of booking into books table
insert into books (bo_uid, bo_bid, bo_time) values (1, 1, 14:30:00);
-- query to insert details into payment table
insert into payment (amount, confirm, p_bid) values (100.0, "true", 1);
-- query to select latest payment id
select max(pid) from payment;
-- query to insert values into has_payment table
insert into has_payment (hp_bid, hp_pid, hp_time) values (1, 1,14:30:00);
-- query to insert values into booked_seats table
insert into booked_seats (bs_bid, bs_sno, bs_fid) values (1, 10, 1);
-- query to update booking id in seats table
update seats set s_bid=1 where s_fid=1 and seat_no=10;

-- handling concurrency