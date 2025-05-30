--Aula 11 
use fib2025;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';



create  table Produtos (
   id           int            identity(1,1) unique,
   nome         varchar(20)    not null,
   preco        float          not null,
   fabricacao   datetime       not null ,
   entrada      date		   default getdate(),
   validade     date		   --check(validade > getdate()) 
   primary key (id)
);



SET LANGUAGE Portuguese;

INSERT INTO Produtos (nome, preco, fabricacao, validade) VALUES
('Notebook',      3500.00, '01/12/2024 08:00:00', '01/12/2025'),
('Smartphone',    2100.50, '15/01/2025 09:30:00', '15/01/2026'),
('Mouse',           75.90, '01/03/2025 14:00:00', '01/03/2026'),
('Teclado',        150.00, '10/02/2025 10:00:00', '10/02/2026'),
('Monitor',        980.00, '20/11/2024 13:20:00', '20/11/2025'),
('HD Externo',     400.00, '05/01/2025 12:00:00', '05/01/2026'),
('Pen Drive',       45.00, '01/04/2025 11:00:00', '01/04/2026'),
('Webcam',         199.99, '20/02/2025 16:00:00', '20/02/2026'),
('Impressora',     850.00, '15/03/2025 09:45:00', '15/03/2026'),
('Caixa de Som',   120.00, '25/03/2025 10:30:00', '25/03/2026');

 insert into Produtos values ('robo',   120.00, '25/03/2025 10:30:00', '25/03/2023','25/03/2024');
 insert into Produtos values ('porta rerato',   19920.00, '22/05/2025 10:30:00', '25/05/2023','25/05/2025');
 insert into Produtos values ('Biscoito',   190.00, '22/05/2019 10:30:00', '25/05/2019','25/05/2019');
 insert into Produtos values ('apontador',   10.00, '22/06/2025 10:30:00', '25/05/2019','25/05/2019');
 insert into Produtos values ('urso de chocolate',   10.00, '22/06/2025 10:30:00', '25/05/2025','25/05/2025');

 -- 3 - Verificar se existem produtos com o data de validade vencida
 select *
 from Produtos
 where validade <= getdate();


 --  4 - Verificar que produtos foram fabricados nos meses de março e abril 
 select nome
 from Produtos
 where month(fabricacao) = 4 or  month(fabricacao) = 5;


 --  5 - Verificar produtos com a data de fabricação do ano de 2019
  select nome
 from Produtos
 where year(fabricacao) = 2019;


 --  6 - Calcular a data de validade dos produtos 90 dias depois de fabricados
 select nome, fabricacao, convert(date,(fabricacao + 90)) as 'Validade após 90 dias' 
 from Produtos;


--  7 - Calcular a data de validade dos produtos 6 meses depois de fabricados
 select nome, convert(date,fabricacao) 'fabricacao' , convert(date,(fabricacao + 180)) as 'Validade =/- após 6 meses' 
 from Produtos;

 --ou

 select nome, convert(date,fabricacao) 'fabricacao' , convert(date,(dateadd(month,6,fabricacao))) as  'Validade  após 6 meses' 
 from Produtos;


 -- 8 - Calcular há quantos dias um produto entrou no estoque 
 
 select nome, 
		entrada  , 
		datediff(day,entrada,getdate()) as  'tempo no estoque' 
 from Produtos;


--  9 - Mostrar o preço de todos os produtos com data de validade superior a abril de 2018
select * 
from Produtos
where validade >= '2018-05-30';  


-- 10 - Mostrar os produtos fabricamos entre os dias 12 de março e 22 de abril
select * 
from Produtos
where (day(fabricacao) >= '12' and day(fabricacao) >= '22') and (month(fabricacao) >= '4' and month(fabricacao) >= '5');


-- 11 - Mostrar o produto mais antigo no estoque – data de entrada

select top 3 nome, entrada, validade 
from Produtos 
order by entrada;

-- 12 - Mostrar o produto mais novo – data de fabricação

select top 3 nome, fabricacao 
from Produtos 
order by fabricacao desc;


-- 13 - Informe o total de produtos com validade vencida 
 
 select count(*) as 'Produtos vencidos'
 from Produtos
 where validade <= getdate();


--  14 - Informe o valor total dos produtos com validade vencida
 select  sum(preco) as 'valor perdido'
 from Produtos
 where validade <= getdate();


 -- 15 - Quais foram os produtos fabricados nesse ano?
 select count(nome) as 'Produtos'
 from Produtos
 where year(fabricacao) = '2025'


 --  16 - Quais foram os produtos que entraram no estoque esse ano

 select count(nome) as 'Produtos'
 from Produtos
 where year(entrada) = '2025';


 --  17 - Qual a média de preço dos produtos com validade vencida

 
 select cast(avg(preco) as decimal(9,2)) as 'preco medio perdido '
 from Produtos
 where validade <= getdate();