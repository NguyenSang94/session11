create table accounts(
    acc_id serial primary key ,
    owner_name varchar(100),
    balance numeric(10,2)
);
insert into accounts(owner_name, balance)
values ('A', 500.00 ),
       ('B', 300.00);

begin;
 update accounts
 set balance = balance - 100.00
 where owner_name = 'A';

 update accounts
 set balance = balance + 100.00
 where owner_name = 'B';
commit;
end;

begin;
insert into accounts(acc_id, owner_name)
values (222, 'A');
rollback;
end;
select * from accounts;
