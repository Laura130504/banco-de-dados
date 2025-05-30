use uniao;

create table Aluno(
matricula int not null identity(0,1),
nome varchar(30) not null,
primary key (matricula) 
);

INSERT INTO Aluno (nome) VALUES
('Alice Santos'),
('Bruno Lima'),
('Carla Mendes'),
('Diego Rocha'),
('Elaine Costa'),
('Felipe Nunes'),
('Gisele Moraes'),
('Henrique Silva'),
('Isabela Dias'),
('Jo�o Victor');


create table Materia (
id int not null identity(0,1),
nome varchar(30),
primary key (id)
);

INSERT INTO Materia (nome) VALUES
('Matem�tica'),
('Portugu�s'),
('Hist�ria'),
('Geografia'),
('Biologia'),
('F�sica'),
('Qu�mica'),
('Ingl�s'),
('Artes'),
('Educa��o F�sica');



create table Cursa(
matricula int not null,
idMateria int not null,
nota float not null, 
foreign key  (matricula) references Aluno(matricula),
foreign key (idMateria) references Materia(id)
);

INSERT INTO Cursa (matricula, idMateria, nota) VALUES
(0, 0, 8.5),
(1, 1, 7.2),
(2, 2, 6.8),
(3, 3, 9.0),
(4, 4, 5.5),
(5, 5, 7.0),
(6, 6, 6.2),
(7, 7, 8.0),
(8, 8, 9.5),
(9, 9, 7.8);

-- 3.1 apartir do curso informe o nome do aluno matriculado, o nome da disciplina e a nota.

select a.nome as 'ALuno matriculado',
	   m.nome as 'Disciplina',
	   c.nota 
from Cursa c inner join Aluno a on c.matricula = a.matricula
			 inner join Materia m on c.idMateria = m.id;
