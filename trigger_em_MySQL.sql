create database aula3;

Use aula3;
 
create table contacorrente(
nconta  int           AUTO_INCREMENT,
cliente varchar(30)   not null,
saldo   decimal(10,2) default 0.00,
primary key(nconta)
);
 
create table funcionarios(
nfuncionario int         AUTO_INCREMENT,
nome         varchar(30),
primary key (nfuncionario)
);
 
create table movimentocc(
nconta       int ,
dtmov        date          default CURDATE(),
valor        decimal(10,2),
operacao     varchar(1)    not null,
nfuncionario int,
foreign key (nfuncionario) references funcionarios(nfuncionario)
);
 
create table operacao(
dtoperacao date       default CURDATE(),
operacao   varchar(1) ,
valor      decimal(10,2)
);
 
/*Para controlar todos as ações realizadas nas contas*/
create table auditoria( 
dtoperacao  date default CURDATE(),
funcionario varchar(30),
operacao    varchar(1),
valor       decimal(10,2)
);

/*inserindo contas */
insert into contacorrente(cliente, saldo) values ('Maria',  100.00), 
												 ('João',   200.00), 
												 ('Eduardo',300.00);
/*inserindo funcionarios*/
insert into funcionarios(nome) values ('lopes'), 
									  ('laura'), 
									  ('Joana');

/*CREATE TRIGGER nome_do_trigger
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON nome_da_tabela
FOR EACH ROW
BEGIN
    -- Instruções SQL que serão executadas
END;
*/

/*Para verificar se o movimentação financeira que querem realizar é valida*/
DELIMITER //
create trigger mov_financ_deposito 
BEFORE insert 
on movimentocc
for each ROW
BEGIN
    /*Declarar as variaveis - lembrando que em MySQL tem que ter um declare para cada tipo */
    DECLARE operacao              varchar(1);
	DECLARE	conta, validar, nfunc int;
	DECLARE valor                 decimal(10,2);
			
    
    /*Pegando os valores inseridos*/
	set operacao = upper(NEW.operacao), 
	    conta =    NEW.nconta, 
		valor =    NEW.valor,
		nfunc =    NEW.nfuncionario;
    
    /*Verificando se o numero da conta fornecido existe */
    SELECT count(*)
	INTO validar
	FROM contacorrente
	WHERE nconta = conta;

    /*Realizando deposito quando a conta é existente */
	if operacao = 'D' and validar = 1 then
		update contacorrente set saldo = (saldo + valor) where nconta = conta;
		insert into operacao(operacao, valor) values ('D', valor);
		insert into auditoria(funcionario, operacao, valor) values (nfunc, operacao, valor);	
	else
		if operacao != 'D' and validar = 1 then
		    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operação diferente de Deposito!';
		end if;		
		if operacao = 'D' and validar != 1 then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conta invalida!';
        end if;
    end if;
end;
//
/*se der erro apague o comentario encima do primeiro if*/

/*Testando inserção de dados*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (1,'2026-02-26', 100.00, 'D', 1);/*dados corretos*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (4,'2026-02-20', 112.00, 'D', 1); /*Conta invalida*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (2,'2026-02-21', 190.00, 'M', 1);/*Operação diferente de Deposito*/



DELIMITER //
create trigger mov_financei_saque 
after insert 
on movimentocc
for each ROW
BEGIN
 /*Declarar as variaveis*/
    DECLARE operacao                    varchar(1);
	DECLARE	conta, validar, nfunc       int;
	DECLARE valor_saque, valor_atual    decimal(10,2);
			
    
    /*Pegando os valores inseridos*/
	set operacao =    upper(NEW.operacao), 
	    conta =          NEW.nconta, 
		valor_saque =    NEW.valor,
		nfunc =          NEW.nfuncionario;
    
    /*Verificando se o numero da conta fornecido existe */
    SELECT count(*)
	INTO validar
	FROM contacorrente
	WHERE nconta = conta;

    SELECT saldo
	INTO valor_atual
	FROM contacorrente
	WHERE nconta = conta;
    
   
	if operacao = 'S' and validar = 1 and (valor_atual - valor_saque ) >= 0 then
		update contacorrente set saldo = (saldo - valor_saque) where nconta = conta;
		insert into operacao(operacao, valor) values ('S', valor_saque);
		insert into auditoria(funcionario, operacao, valor) values (nfunc, operacao, valor_saque);	
	else
		if operacao != 'S' and validar = 1 and (valor_atual - valor_saque ) >= 0 then
		    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operação diferente de Saque!';
		    		
		elseif operacao = 'S' and validar != 1 and (valor_atual - valor_saque ) >= 0 then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conta invalida!';
            
        elseif operacao = 'S' and validar = 1 and (valor_atual - valor_saque ) < 0 then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não tem valor suficiente na conta para retirar essa quantia!';

        else 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro desconhecido!';
        end if;
    end if;
end;
//

insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (1,'2026-03-26', 100.00,'S',  1);/*dados corretos*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (6,'2026-03-20', 50.00, 'S',  1); /*Conta invalida*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (2,'2026-03-21', 90.00, 'G',  1);/*Operação diferente de Saque*/
insert into movimentocc(nconta, dtmov, valor, operacao, nfuncionario) values (1,'2026-03-20', 150.00, 'S', 1);/*Valor maior que o saldo*/



DELIMITER //
create trigger delete_movimentacao_S_D
after delete 
on movimentocc
for each ROW
BEGIN
    /*Declarar as variaveis*/
    DECLARE operacao               varchar(1);
	DECLARE	conta, validar, nfunc  int;
	DECLARE valor                  decimal(10,2);
			
    
    /*Pegando os valores deletados*/
	set operacao = upper(OLD.operacao), 
	    conta =       OLD.nconta, 
		valor =       OLD.valor,
		nfunc =       OLD.nfuncionario;
    
    /*Verificando se era Saque */
    IF operacao = 'S' then 
        /*Ajustando valor na conta, gravando na auditoria e na operacao*/
        update contacorrente set saldo = (saldo + valor) where nconta = conta;
        insert into auditoria(funcionario, operacao, valor) values (nfunc, operacao, valor);
        insert into operacao(operacao, valor) values ('E', valor); /*operação E = Estorno*/
    
    ELSEIF operacao = 'D' then 
         /*Ajustando valor na conta, gravando na auditoria e na operacao*/
        update contacorrente set saldo = (saldo - valor) where nconta = conta;
        insert into auditoria(funcionario, operacao, valor) values (nfunc, operacao, valor);
        insert into operacao(operacao, valor) values ('E', valor); /*operação E = Estorno*/

    ELSE 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não foi possível excluir esse dado!';
    end if;
END;
//


