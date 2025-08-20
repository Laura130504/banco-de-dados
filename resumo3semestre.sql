

drop database Revisao;

create database Revisao;

use Revisao;

SELECT name 
FROM sys.tables; -- Lista todas as tabelas do banco 


create table Curso(
id      int unique   identity(1,1), -- unique = somente um valor para o campo id, identity(x, y) = acrecenta um valor automatico crescente para o campo id 
duracao int not null default 1, -- not null = o campo não pode estar nulo, default = da um valor caso o campo não seja preenchido ( obs. vazio ='' é diferente de nulo = )
dataCriacao date  not null, 
primary key (id)
);

insert into Curso values (6,'2025-01-02');

create table Alunos(
nome		varchar(30)		not null,
ra			int				not null  identity(0,1),
mensalidade decimal(6,2)	not null  default 1200.00,
dataInicio  date			not null  default getdate(), -- getdate() = é um afunção que retorna a data do seu dispositivo 
idCurso     int				not null 
primary key (ra),
foreign key (idCurso) references Curso(id) -- chave estrangeira, só pode ser inserido um valor caso o campo idCurso exista na tabela Curso
);

insert into ALunos (nome,mensalidade,dataInicio,idCurso) values ('Laura', 1302.98 , '2024-03-01', 1);

select * from Alunos;



create table Inteiros(
inteiro int , -- bilhao 
grandeInt bigint, -- trilhões
pequenoInt smallint, -- trinta mil
minusculoInt tinyint  -- 250
);

insert into Inteiros values (300.000.000,
							 3.000.000.000.000.000.000,
							 30000,
							 250);
						 

create table Decimais(
decimais decimal(6,2) , -- (x, y), x = quantidade total de digitos, y = quantidade de digitos depois da virgula 
flutuate float ,
numerico numeric(5,1),
);

insert into Decimais values (3000.00,
							 3.00,
							 3000.0
							 );


create table Dineiro(
dinheiro money ,
flooat bit 
);

insert  into dineiro values (12.00,0.00);


create table Tempo (
dia date, 
tempo time,
tempoDia datetime,
tempoPreciso smalldatetime
);

insert into Tempo values ( 
    '15/04/2025',              -- dia (apenas data)
    '14:30:00',                -- tempo (apenas hora)
    '20/05/2025 14:30:00',     -- tempoDia (data e hora completa)
    '10/05/2025 14:30:00'      -- tempoPreciso (data e hora com menor precis�o)
);


select getdate() 'comp', day(dia) 'dia',month(dia) 'm�s', year(dia) 'ano'
from Tempo;


select datediff(dd, dia, tempoDia) 'dias de diferen�a',  
	   datediff(mm, dia, tempoDia) 'm�s de diferen�a',
	   datediff(yy, dia, tempoDia) 'ano de diferen�a'
		from Tempo;


select convert(date, getdate()) 'somente data';
select top 1 dia from tempo;