CREATE TABLE flights
(
    flight_id       SERIAL PRIMARY KEY,
    flight_name     VARCHAR(100),
    available_seats INT
);

CREATE TABLE bookings
(
    booking_id    SERIAL PRIMARY KEY,
    flight_id     INT REFERENCES flights (flight_id),
    customer_name VARCHAR(100)
);

-- Dữ liệu mẫu ban đầu
INSERT INTO flights (flight_name, available_seats)
VALUES ('VN123', 3),
       ('VN456', 2);
-- làm
SELECT * FROM flights WHERE flight_name = 'VN123';

BEGIN;
update flights
set available_seats = available_seats -1
where flight_name  = 'VN123';

insert into bookings(booking_id, customer_name)
values (1,'Nguyen Van A');
commit;
end;
select * from flights;
select * from bookings;

begin;
update flights
set available_seats = available_seats -1
where flight_name = 'VN123';

insert into bookings(flight_id, customer_name)
values (4,'Nguyen Van B');
rollback;
end;