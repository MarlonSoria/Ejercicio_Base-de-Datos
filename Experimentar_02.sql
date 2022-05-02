--RESOLUCION EXPERIMENTAR_02-----

use master
go


use BDArcor
go

--Pregunta si la base de datos "BDArcor" esta creado de ser asi se elimina BDArcor
if DB_ID('BDArcor')is not null
drop database BDArcor
go
--Creacion de la base de datos "BDArcor"
create database BDArcor
go

--usar la base de datos "BDArcor"
use BDArcor
go

--crear los schemas(esquemas):SCHAcad,SCHAdminySCHFinance

create schema SCHAcad
go

create schema SCHAdmin
go

create schema SCHFinance
go

--verificar la creacion de los schemas

select * from sys.schemas

--Creacion de los datos definidos utilizando el comando TYPE


create type UDTIdNum from smallint
go

create type UDTIdCad  from char(8)
go

create type UDTCad from varchar(50)
go

create type UDTTiempo from datetime
go

create type UDTMonto from smallmoney
go

--verificar la creacion de los datos definidos con TYPE

select * from sys.types
go

--Creacion de las tablas, utilizando los tipos de datos creados previamente

--tabla TBDDocente
create table SCHAcad.TBDocente
(
codDoce UDTIdCad not null,
nomDoce UDTCad not null,
apDoce  UDTCad not null,
fnaDoce UDTTiempo not null,
SueDoce UDTMonto not null
constraint PK_codDoce primary key(codDoce)
)
go

--tabla TBOrden
create table SCHAdmin.TBOrden
(
nroOrden UDTIdNum not null,
fecOrden UDTTiempo not null,
fecPago  UDTTiempo not null,
mntOrden UDTMonto  not null,
constraint PK_nroOrden primary key(nroOrden)
)
go
 ---Comprobar la creacion de las tablas desde BDArcor
 select * from sys.tables


 ---Adicionar 03 filegroups(FG1000,FG2000,FG3000),desde la BD Master.
 use master 
 go

 alter database BDArcor
 add filegroup FG1000
 go

 alter database BDArcor
 add filegroup FG2000
 go

 alter database BDArcor
 add filegroup FG3000
 go

--Comrpobando la creacion de los filegropus desde la BDArcor
use BDArcor
 select * from sys.filegroups
 go
 --Modificar BDArcor para adicionar un DataFile en cada filegroup creado,con la ubicacion en Arcor c:/ArcorData con valores predeterminados
 alter database BDArcor
 add file
 (
 name =Data1000,
 filename='C:\ArcorData\Data1000.ndf'
 ) to filegroup FG1000
 go

 alter database BDArcor
 add file
 (
 name =Data2000,
 filename='C:\ArcorData\Data2000.ndf'
 )to filegroup FG2000
 go

 alter database BDArcor
 add file
 (
 name =Data3000,
 filename='C:\ArcorData\Data3000.ndf'
 )to filegroup FG3000
 go

 exec sp_helpdb BDArcor
 go

 --Creacion de funcion de particion utilizando Ramge Left
 use BDArcor
 go

 create partition function FNP_Numeros(int)
 as range left for values (1000,2000)
 go

 --creacion de un esquema de particion usando la funcion de particion anterior
 create partition scheme SP_Numeros
 as partition FNP_Numeros to(FG1000,FG2000,FG3000)
 go

 --creacion de una tabla particionada por el campo NRO_FACT
 create table SCHFinance.TBFactura
 (
 numFact int not null,
 fecFact date not null,
 codPrv char(5) not null,
 monto smallmoney not null
 constraint PK_numFact primary key(numFact)
 )on sp_Numeros(numFact) 
 go

 ---Comprobar la creacion de la tabla aprticionada
 select * from SCHFinance.TBFactura 
 go

 --introducir datos en las tablas
insert into SCHFinance.TBFactura values
(500,'23/06/2021','00001',345),
(100,'24/06/2021','00002',550),
(1400,'21/04/2021','00003',3450),
(2300,'02/06/2021','00004',1245)
go

--Verificar la creacion de los datos dentro de las tablas
select *, $partition.FNP_Numeros(numFact) as [Nº particion]
from SCHFinance.TBFactura
go