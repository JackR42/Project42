-- Idempotent
if (OBJECT_ID('s42.f42') IS NOT NULL) drop function [s42].[f42]
if (OBJECT_ID('s42.p42') IS NOT NULL) drop procedure [s42].[p42]
if (OBJECT_ID('s42.v42') IS NOT NULL) drop view [s42].[v42]
if (OBJECT_ID('s42.t42') IS NOT NULL) drop table [s42].[t42]
if (SCHEMA_ID('s42') IS NOT NULL) drop schema [s42]
go

create schema s42
go
create table s42.t42(
	ID integer primary key
	, Description sysname
)
go
insert into s42.t42 values(1, '42')
insert into s42.t42 values(2, '911')
go
create view s42.v42
as
select * from s42.t42
go
create function s42.f42()
RETURNS TABLE
as
RETURN
	select * from s42.v42
GO
create or alter procedure s42.p42
as
select * from s42.f42()
go
exec s42.p42
go
