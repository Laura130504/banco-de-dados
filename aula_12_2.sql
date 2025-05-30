use uniao;

create table Funcionario(
idFunc int not null identity(1,1),
nome varchar(30) not null unique,
primary key(idFunc)
);

insert into Funcionario (nome) values
('Ana Souza'),
('Carlos Lima'),
('Fernanda Rocha'),
('João Pedro'),
('Marina Silva'),
('Bruno Costa'),
('Juliana Paes'),
('Roberto Nunes'),
('Isabela Moraes'),
('Thiago Martins');


create table Ambulancia(
idAmb int not null identity(1,1),
tipo  varchar(9) not null default 'TRANSPOR'  check(upper(tipo)='TRANSPOR'  or 
													upper(tipo)='SUP.BASIC' or 
												    upper(tipo)='RESGATE'   or 
													upper(tipo)='SUP.AVANC' or 
													upper(tipo)='AERONAVE'  or 
													upper(tipo)='AQUÁTICO')
				
primary key (idAmb)
);

insert into Ambulancia (tipo) values
('TRANSPOR'),
('SUP.BASIC'),
('RESGATE'),
('SUP.AVANC'),
('AERONAVE'),
('AQUÁTICO'),
('SUP.BASIC'),
('TRANSPOR'),
('RESGATE'),
('SUP.AVANC');



create table Equipe(
idEqu int not null identity(1,1),
nomeEquipe varchar(30) not null,
idAmb int not null,
primary key(idEqu),
foreign key (idAmb) references Ambulancia(idAmb)
);

insert into Equipe (nomeEquipe, idAmb) values
('Equipe Alfa', 1),
('Equipe Beta', 2),
('Equipe Gama', 3),
('Equipe Delta', 4),
('Equipe Épsilon', 5),
('Equipe Zeta', 6),
('Equipe Eta', 7),
('Equipe Teta', 8),
('Equipe Iota', 9),
('Equipe Kappa', 10);



create table Coordenadas(
idCoor int not null identity(1,1),
latitute int not null,
longitute int not null,
primary key (idCoor)
);

insert into Coordenadas (latitute, longitute) values
(100, 200),
(101, 201),
(102, 202),
(103, 203),
(104, 204),
(105, 205),
(106, 206),
(107, 207),
(108, 208),
(109, 209);



create table Chamado(
idCham int not null identity(1,1),
idFunc int not null,
idEqu int not null,
idCoor int not null,
solicitante varchar(30),
primary key (idCham),
foreign key (idFunc) references Funcionario(idFunc),
foreign key (idEqu) references Equipe(idEqu),
foreign key (idCoor) references Coordenadas(idCoor)
);


insert into Chamado (idFunc, idEqu, idCoor, solicitante) values
(1, 1, 1, 'Paulo Mendes'),
(2, 2, 2, 'Lucas Braga'),
(3, 3, 3, 'Renata Dias'),
(4, 4, 4, 'Bruno Almeida'),
(5, 5, 5, 'Tatiane Lopes'),
(6, 6, 6, 'Guilherme Pinto'),
(7, 7, 7, 'Carla Ribeiro'),
(8, 8, 8, 'Vinícius Araujo'),
(9, 9, 9, 'Larissa Castro'),
(10, 10, 10, 'Daniela Freitas');



-- 2.1 - Dados do chamado e dados do funcionário
Select c.solicitante,
	   f.nome as 'Funcionario'
from Chamado c inner join Funcionario f on c.idFunc = f.idFunc;


-- 2.2 - - Dados do chamado, funcionário e dados da equipe 
Select c.solicitante,
	   f.nome as 'Funcionario',
	   e.nomeEquipe 'Nome da equipe'
from Chamado c inner join Funcionario f on  c.idFunc = f.idFunc
			   inner join Equipe e      on  c.idEqu = e.idEqu;


-- 2.3 -  Dados do chamado, funcionário, equipe e coordenadas
Select c.solicitante,
	   f.nome as 'Funcionario',
	   e.nomeEquipe 'Nome da equipe',
	   co.latitute 'Latitude do local', co.longitute 'Longitude do local '
from Chamado c inner join Funcionario f on  c.idFunc = f.idFunc
			   inner join Equipe e      on  c.idEqu = e.idEqu
			   inner join Coordenadas co on c.idCoor = co.idCoor;

-- 2.4 -  Dados do chamado, funcionário, coordenadas, equipe e ambulância

Select c.solicitante,
	   f.nome as 'Funcionario',
	   a.tipo 'Tipo da ambulancia',
	   co.latitute 'Latitude do local', co.longitute 'Longitude do local '
from Chamado c inner join Funcionario f on  c.idFunc = f.idFunc
			   inner join Equipe e      on  c.idEqu = e.idEqu
			   inner join Ambulancia a  on  e.idAmb = a.idAmb
			   inner join Coordenadas co on c.idCoor = co.idCoor;