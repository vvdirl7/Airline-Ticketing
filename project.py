import mysql.connector
from datetime import datetime
mydb= mysql.connector.connect(
    host="localhost",
    user="root",
    password="sql123",
    database="airline_ticketing"
)

cursor=mydb.cursor()

print("Do you want to 1:login 2: Register:\n")
v1=input()
if v1=='1':
    bkb=False
    if v1=='1':
        userid=input("Enter username: ")
        password=input("Enter password: ")

        query = "SELECT * FROM users WHERE uid=%s AND password=%s"
        cursor.execute(query, (userid, password))
        result = cursor.fetchone()


        if result:
            print("Login successful! Do you want to 1: book tickets 2: view bookings 3: cancel booking 4:Check if booking is confirmed?")
            v2=input()
            if v2=='1':
                bkb=True
            if v2=='2':
                query="select bk.bo_bid, s.seat_no, s.s_fid from seats s join books bk on s.s_bid=bk.bo_bid where bk.bo_uid=%s"
                cursor.execute(query, (userid,))
                bookings=cursor.fetchall()
                for book in bookings:
                    print("Booking ID: ", book[0], "Seat: ", book[1], "Flight: ", book[2])
            if v2=='3':
                 cancelbid=input("Enter Booking ID you want to cancel:")
                 query="select * from books where bo_uid=%s and bo_bid=%s"
                 cursor.execute(query, (userid, cancelbid))
                 resultc=cursor.fetchone()
                 if resultc:
                      try:
                            cursor.execute("START TRANSACTION")
                            

                            cancel_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

                            query="UPDATE seats SET s_bid = NULL WHERE s_bid = %s"
                            cursor.execute(query, (cancelbid,))
                            
                            query="delete from booked_seats where bs_bid=%s"
                            cursor.execute(query, (cancelbid,))

                            
                            query="insert into cancellation (c_bid, c_time) values (%s, %s)"
                            cursor.execute(query, (cancelbid, cancel_time))

                            query="select max(cid) from cancellation"
                            cursor.execute(query)
                            lastcid=cursor.fetchone()[0]
                            cancel_message = f"Booking ID {cancelbid} cancelled at {cancel_time}. Cancellation ID: {lastcid}"
                            print(cancel_message)
                            query="update cancellation set message=%s where cid=%s"
                            cursor.execute(query, (cancel_message, lastcid))

                            mydb.commit()
                      except:
                           mydb.rollback()
            if v2=='4':
                 checkbid=input("Enter booking ID: ")
                 query="select p.confirm from payment p join booking b on p.p_bid=b.bid where p.p_bid=%s and p.confirm=%s"
                 cursor.execute(query, (checkbid, "true"))
                 result=cursor.fetchall()
                 if result:
                      print("Booking confirmed")
                 else:
                      print("Booking pending due to non-payment")                 
            
        else:
                print("Invalid login credentials.")
    if bkb==True:
        print("Start booking:\n\n")
        print("1: Check flights with source and destination\n2: Check flights with date")
        v4=input()
        if v4=='1':
            source=input("Enter source airport (example-Delhi IGI): ")
            destination=input("Enter destination aiport: ")
            query = "SELECT * FROM flights where origin=%s and destination=%s"
            cursor.execute(query, (source, destination))
        if v4=='2':
            date = input("Enter date (YYYY-MM-DD): ")
            query = "SELECT * FROM flights WHERE departure_date=%s"
            values = (date,)
            cursor.execute(query, values)

        print("Available flights: \n\n")
        
        for (flight_id, departure_date, departure_time, f_airline_id, origin, destination, duration) in cursor:
                print(f"Flight ID: {flight_id}\nDeparture Date: {departure_date}\nDeparture Time: {departure_time}\nAirline ID: {f_airline_id}\nOrigin: {origin}\nDestination: {destination}\nDuration: {duration}\n")
        flightid=input("Enter flight ID: ")

        v5=input("Do you have a class preference? y/n:\n")
        if v5=='y':
            v6=input("Enter class (economy, business, first): ")
            query = "SELECT * FROM seats WHERE s_fid = %s AND s_bid IS NULL AND s_class=%s"
            cursor.execute(query, (flightid,v6))
        else:
                query = "SELECT * FROM seats WHERE s_fid = %s AND s_bid IS NULL"
                cursor.execute(query, (flightid,))
        result = cursor.fetchall()
        if result:
                for row in result:
                        print(row)
                print("Enter seat numbers to be booked (separated by commas): ")
                seat_nos_in=input()
                seat_nos=tuple(seat_nos_in.split(','))
                placeholders = ', '.join(['%s'] * len(seat_nos))
                query = f"SELECT SUM(s_price) FROM seats WHERE s_fid = %s AND seat_no IN ({placeholders}) AND s_bid IS NULL"
                cursor.execute(query, (flight_id, *seat_nos))
                total_price = cursor.fetchone()[0]
                print(seat_nos)
                print("Total price is rupees ",total_price,"\n")
                for seat in seat_nos:
                    query="select s_bid, s_price from seats where s_fid=%s and seat_no=%s"
                    cursor.execute(query, (flightid, seat))
                    row = cursor.fetchone()
                    if row:
                        seat_price = row[1]
                        print(seat_price)
                    else:
                        print(f"No seat found for seat number {seat} and flight ID {flightid}")
                v7=input("proceed to payment? (y/n): ")
                if v7=='y':
                     print("Total price to pay: ", total_price)
                     confirmation=input("Type 'confirm' to confirm payment: ")
                     if confirmation=="confirm":
                          now = datetime.now()
                          timestamp = now.strftime('%H:%M:%S')
                          try:
                                cursor.execute("START TRANSACTION")
                                

                                query="insert into booking (b_fid, b_uid) values (%s, %s)"
                                cursor.execute(query, (flightid, userid))
                                query="select max(bid) from booking"
                                cursor.execute(query)
                                lastbid=cursor.fetchone()[0]
                                print("Your booking id is: ", lastbid)

                                query="insert into books (bo_uid, bo_bid, bo_time) values (%s, %s, %s)"
                                cursor.execute(query, (userid, lastbid, timestamp))

                                query="insert into payment (amount, confirm, p_bid) values (%s, %s, %s)"
                                cursor.execute(query, (total_price,"true",lastbid ))
                                query="select max(pid) from payment"
                                cursor.execute(query)
                                lastpid=cursor.fetchone()[0]
                                print("Your payment id is: ", lastpid)

                                query="insert into has_payment (hp_bid, hp_pid, hp_time) values (%s, %s, %s)"
                                cursor.execute(query, (lastbid, lastpid, timestamp))
                                
                                for seat in seat_nos:
                                    query="insert into booked_seats (bs_bid, bs_sno, bs_fid) values (%s, %s, %s)"
                                    cursor.execute(query, (lastbid, seat, flightid))
                                    query="update seats set s_bid=%s where s_fid=%s and seat_no=%s"
                                    cursor.execute(query, (lastbid, flightid, seat))

                                mydb.commit()
                          except:
                               mydb.rollback()


        else:
             print("No seats available")


if v1=='2':
        try:
                cursor.execute("START TRANSACTION")
                #cursor.execute("SELECT * FROM USERS FOR UPDATE")    

                fname = input("Enter first name: ")
                lname = input("Enter last name: ")
                dob = input("Enter date of birth (YYYY-MM-DD): ")
                email = input("Enter email address: ")
                password = input("Enter password: ")
                phone = input("Enter phone number: ")
                gender = input("Enter gender (male/female/other): ")

                query = "INSERT INTO users (fname, lname, dob, email, password, phone, gender) VALUES (%s, %s, %s, %s, %s, %s, %s)"
                values = (fname, lname, dob, email, password, phone, gender)

                cursor.execute(query, values)
                mydb.commit()
                query="select max(uid) from users"
                cursor.execute(query)
                lastuid=cursor.fetchone()[0]
                print("Your user id is: ", lastuid)
                print("User added successfully!")
        except:
             mydb.rollback()




cursor.close()
mydb.close()