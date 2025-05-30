create database uniao;

use uniao;

create table Proprietario(
nome       varchar(30)   not null unique,
telefone   varchar(20)   not null,
idprop     int			 not null unique identity(1,1)
);

INSERT INTO Proprietario (nome, telefone) VALUES ('Ana Souza', '(14) 98877-6655');
INSERT INTO Proprietario (nome, telefone) VALUES ('Carlos Lima', '(14) 99788-1122');
INSERT INTO Proprietario (nome, telefone) VALUES ('Beatriz Mendes', '(14) 99654-3210');
INSERT INTO Proprietario (nome, telefone) VALUES ('Diego Oliveira', '(14) 99123-4567');
INSERT INTO Proprietario (nome, telefone) VALUES ('Fernanda Silva', '(14) 98987-6543');
INSERT INTO Proprietario (nome, telefone) VALUES ('Gabriel Rocha', '(14) 99876-5432');
INSERT INTO Proprietario (nome, telefone) VALUES ('Helena Costa', '(14) 98765-4321');
INSERT INTO Proprietario (nome, telefone) VALUES ('Igor Martins', '(14) 99456-7890');
INSERT INTO Proprietario (nome, telefone) VALUES ('Juliana Dias', '(14) 99234-5678');
INSERT INTO Proprietario (nome, telefone) VALUES ('Lucas Ferreira', '(14) 99012-3456');



create table Imovel(
quartos int			 not null,
numero  int			 not null,
rua     varchar(30)  not null,
idimo   int			 identity(1,1)
);

INSERT INTO Imovel (quartos, numero, rua) VALUES (2, 101, 'Rua das Flores');
INSERT INTO Imovel (quartos, numero, rua) VALUES (3, 202, 'Avenida Brasil');
INSERT INTO Imovel (quartos, numero, rua) VALUES (1, 55, 'Rua João Paulo');
INSERT INTO Imovel (quartos, numero, rua) VALUES (4, 78, 'Rua das Palmeiras');
INSERT INTO Imovel (quartos, numero, rua) VALUES (2, 12, 'Rua Santo Antônio');
INSERT INTO Imovel (quartos, numero, rua) VALUES (3, 305, 'Avenida Getúlio Vargas');
INSERT INTO Imovel (quartos, numero, rua) VALUES (1, 89, 'Travessa da Paz');
INSERT INTO Imovel (quartos, numero, rua) VALUES (2, 150, 'Rua Dom Pedro');
INSERT INTO Imovel (quartos, numero, rua) VALUES (3, 230, 'Rua Quinze de Novembro');
INSERT INTO Imovel (quartos, numero, rua) VALUES (4, 404, 'Rua das Acácias');


create table Corretor(
nome       varchar(30)   not null unique,
telefone   varchar(20)   not null,
idCor      int			 not null unique identity(1,1),
unidade    int 
);

INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Marcos Pereira', '(14) 98877-1234', 1);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Luciana Tavares', '(14) 98766-2345', 2);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Tiago Santos', '(14) 99655-3456', 1);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Patrícia Ramos', '(14) 99444-4567', 3);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Ricardo Almeida', '(14) 99333-5678', 2);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Vanessa Cruz', '(14) 99222-6789', 1);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Eduardo Martins', '(14) 99111-7890', 3);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Camila Freitas', '(14) 99000-8901', 2);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Julio Andrade', '(14) 98989-9012', 1);
INSERT INTO Corretor (nome, telefone, unidade) VALUES ('Renata Borges', '(14) 98888-0123', 3);


create table Inquilino(
nome       varchar(30)   not null unique,
telefone   varchar(20)   not null,
idInq      int			 not null unique identity(1,1),
CPF        varchar(30)
);


INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Bruna Nascimento', '(14) 98811-2233', '123.456.789-01');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Rafael Teixeira', '(14) 98722-3344', '234.567.890-12');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Juliane Lopes', '(14) 98633-4455', '345.678.901-23');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Fábio Moura', '(14) 98544-5566', '456.789.012-34');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Sandra Carvalho', '(14) 98455-6677', '567.890.123-45');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Daniel Borges', '(14) 98366-7788', '678.901.234-56');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Alessandra Pires', '(14) 98277-8899', '789.012.345-67');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Murilo Costa', '(14) 98188-9900', '890.123.456-78');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Tatiane Vieira', '(14) 98099-0011', '901.234.567-89');
INSERT INTO Inquilino (nome, telefone, CPF) VALUES ('Gustavo Fernandes', '(14) 97900-1122', '012.345.678-90');



create table Aluguel(
idProp  int not null,
idImo	int not null,
idCor	int not null,
idInq	int not null,
valorMensal float not null,
dataContrato date not null  default getdate(),
);


INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (1, 1, 1, 1, 1200.00, '2024-01-10');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (2, 2, 2, 2, 1500.00, '2024-02-15');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (3, 3, 3, 3, 950.00, '2024-03-20');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (4, 4, 4, 4, 1800.00, '2024-04-01');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (5, 5, 5, 5, 1100.00, '2024-04-25');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (6, 6, 6, 6, 1350.00, '2024-05-10');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (7, 7, 7, 7, 1000.00, '2024-06-05');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (8, 8, 8, 8, 1600.00, '2024-07-12');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (9, 9, 9, 9, 1400.00, '2024-08-18');
INSERT INTO Aluguel (idProp, idImo, idCor, idInq, valorMensal, dataContrato) VALUES (10, 10, 10, 10, 1250.00, '2024-09-30');

-- 1.a) Dados do aluguel e o nome do proprietário

select a.valorMensal, a.dataContrato,
	   p.nome as 'Proprietario'

from Aluguel a	inner join Proprietario p on a.idProp = p.idprop
				inner join Imovel i       on a.idImo  = i.idimo
				inner join Corretor c     on a.idCor  = c.idCor
				inner join Inquilino inq  on a.idInq  = inq.idInq;


-- 1.b) Dados do aluguel, dados do proprietário e dados do imóvel

select a.valorMensal, a.dataContrato,
	   p.nome as 'Proprietario',p.telefone 'Tel. do proprietario',
	   CONCAT( i.rua ,', ' , i.numero) as 'Endereço', i.quartos as 'Quant. de quartos'

from Aluguel a	inner join Proprietario p on a.idProp = p.idprop
				inner join Imovel i       on a.idImo  = i.idimo
				inner join Corretor c     on a.idCor  = c.idCor
				inner join Inquilino inq  on a.idInq  = inq.idInq;

-- 1.c)  Dados do aluguel, proprietário, imóvel e dados do corretor

select a.valorMensal, a.dataContrato,
	   p.nome as 'Proprietario',p.telefone 'Tel. do proprietario',
	   CONCAT( i.rua ,', ' , i.numero) as 'Endereço', i.quartos as 'Quant. de quartos',
	   c.nome as 'corretor', c.telefone 'Tel. do corretor', c.unidade as 'Unid. de atuação'
	   
from Aluguel a	inner join Proprietario p on a.idProp = p.idprop
				inner join Imovel i       on a.idImo  = i.idimo
				inner join Corretor c     on a.idCor  = c.idCor
				inner join Inquilino inq  on a.idInq  = inq.idInq;

-- 1.d)  Dados do aluguel, proprietário, imóvel, corretor e dados do inquilino

select a.valorMensal, a.dataContrato,
	   p.nome as 'Proprietario',p.telefone 'Tel. do proprietario',
	   CONCAT( i.rua ,', ' , i.numero) as 'Endereço', i.quartos as 'Quant. de quartos',
	   c.nome as 'corretor', c.telefone 'Tel. do corretor', c.unidade as 'Unid. de atuação',
	   inq.nome as 'Inquilino', inq.telefone as 'Tel. do inquilino', inq.CPF as 'CPF do Inquil.'
	   
from Aluguel a	inner join Proprietario p on a.idProp = p.idprop
				inner join Imovel i       on a.idImo  = i.idimo
				inner join Corretor c     on a.idCor  = c.idCor
				inner join Inquilino inq  on a.idInq  = inq.idInq;

