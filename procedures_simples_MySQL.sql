create table ContaCorrente (
    id_conta   int AUTO_INCREMENT,
    id_cliente int, 
    saldo      decimal(10,2),
    primary key (id_conta)
);

create table MovimentoCC (
    id_conta   int, 
    dt_movimen datetime DEFAULT NOW(),
    valor      decimal(10,2),
    operacao   varchar(1) -- S para saque e D para deposito
);

create table clientes(
    id_cliente int AUTO_INCREMENT,  
    nome       varchar(30),
    cpf        varchar(11),
    primary key (id_cliente)
);

--Para fazer verificação de inserção de novos clientes
DELIMITER //
CREATE PROCEDURE pr_inserir_clientes (IN v_nome varchar(30), IN v_cpf varchar(11))
BEGIN
    DECLARE v_id_cliente int;

    if ( v_nome != '' and v_cpf != '') THEN
        insert into clientes(nome, cpf) values (v_nome,v_cpf);

        select id_cliente 
        into v_id_cliente
        from clientes
        where nome = v_nome and cpf = v_cpf;

        insert into ContaCorrente(id_cliente, saldo) values (v_id_cliente, 0.00);
    ELSE 
        SELECT ("nenhum parametro pode ser nulo") as 'Mensagem de erro';
    END IF;
END //
DELIMITER ;

CALL pr_inserir_clientes ('', '12345678910');
CALL pr_inserir_clientes ('Mariana', '');
CALL pr_inserir_clientes ('Mariana', '12345678910');

select * from clientes;
select * from ContaCorrente;


--Para realiazar e gravar as ações do banco 
DELIMITER //
CREATE PROCEDURE pr_acoes (IN v_id_conta int, IN v_acao varchar(1), IN v_valor decimal(10,2))
BEGIN
    declare existe int;

    set existe = 0;

    select count(*)
    into existe
    from ContaCorrente
    where id_conta = v_id_conta;

    if ( existe = 1) THEN
        if (upper(v_acao) = 'D') THEN 
            insert into MovimentoCC(id_conta,valor,operacao) 
            values(v_id_conta, v_valor, 'D'); 
            
            # atualizando o saldo do cliente 
            update ContaCorrente
            set saldo = (saldo +v_valor)
            where id_conta = v_id_conta;

            SELECT "Realizado o Deposito" as 'Mensagem';

        ELSEIF(upper(v_acao) = 'S') THEN 
            insert into MovimentoCC(id_conta,valor,operacao) 
            values(v_id_conta, v_valor, 'S'); 
            
            #atualizando o saldo do cliente 
            update ContaCorrente
            set saldo = (saldo - v_valor)
            where id_conta = v_id_conta;
            
            SELECT "Realizado o Saque" as 'Mensagem';
        ELSE 
            SELECT "Ação não reconhecida" as 'Mensagem de erro';
        END IF;
    ELSE 
        SELECT "Código informado da conta inexiste " as 'Mensagem de erro';
    END IF;
END //
DELIMITER ;

CALL pr_acoes(0, 'D',100.00);
CALL pr_acoes(1, 'S', 100.00);
CALL pr_acoes(1, 'D', 100.00);
CALL pr_acoes(1, 'F', 100.00);


Select * from ContaCorrente;
Select * from MovimentoCC;

--Ver o historico das ações do banco 
DELIMITER //
CREATE PROCEDURE pr_historico_CC (IN v_id_conta int, IN v_data_inicial date, IN v_data_final date)
BEGIN
    declare existe int;

    set existe = 0;

    select  count(*)
    into existe
    from ContaCorrente
    where id_conta = v_id_conta;

    if ( existe = 1) THEN
        if (v_data_inicial < v_data_final) THEN
            select id_conta as 'Numero da conta', 
                   dt_movimen as 'Data da operação',
                   valor,
                   operacao     
            from MovimentoCC
            where dt_movimen >= v_data_inicial and  dt_movimen <= v_data_final and id_conta = v_id_conta;
        ELSE 
            SELECT 'Data inicial maior que final' as 'Mensagem de erro';
        END IF;
    ELSE 
        SELECT "Código informado da conta inexiste " as 'Mensagem de erro';
    END IF;
END //
DELIMITER ;

CALL pr_historico_CC(0, '2026-02-23', '2026-03-29');
CALL pr_historico_CC(1, '2026-03-29', '2026-02-23');
CALL pr_historico_CC(1, '2026-02-23', '2026-03-29');

-- fazer a rentabilidade 
DELIMITER //
CREATE PROCEDURE pr_rentabilidade_default_30 (IN v_saldo decimal(10,2), v_rentabilidade decimal(3,2))
BEGIN

    SET v_rentabilidade = IFNULL(v_rentabilidade, 0.30);

    select (v_saldo * v_rentabilidade) as 'Resultado';
END //
DELIMITER ;

CALL pr_rentabilidade_default_30(1000.00, NULL);
CALL pr_rentabilidade_default_30(1000.00, 0.50);
