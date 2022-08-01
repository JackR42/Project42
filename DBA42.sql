create table t42(
  id int primary key,
  description sysname
)
go
insert into t42 values(42, '42')
insert into t42 values(911, '911')
go
create view v42
as 
select * from t42
go
select * from v42
go
