	--drop database laura;
	create database laura;
	use laura;

	--Criando o B.D de uma empresa que vende obejtos e mobilha de madeira 

	create table produtos(
	id_produto   int identity(0,1),
	nome_produto varchar(40) not null,
	valor        decimal(7,2),
	tipo_madeira varchar(40),
	estoque      int,
	obs          varchar(40),
	primary key (id_produto)
	);

	insert into produtos(nome_produto,valor,tipo_madeira,estoque) values ('Cadeira-estofada0',500.00,'macieira',3),
																		 ('prateleira',150.00,'baneneira',9);

	create table clientes(
	id_cliente int identity(0,1),
	nome       varchar(50) not null,
	cpf        varchar(11) UNIQUE not null,
	endereco   varchar(80),
	primary key (id_cliente),
	CONSTRAINT CK_cpf_clientes CHECK (cpf LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
	);

	insert into clientes(nome,cpf,endereco) values ('Laura','12345678910','Rua professor jerson rodrigues');

	create table vendedores(
	id_vendedor  int identity(0,1),
	nome         varchar(50) not null,
	cpf          varchar(11) UNIQUE not null,
	salario_fixo decimal(7,2) DEFAULT  1621.00,
	primary key (id_vendedor),
	CONSTRAINT CK_cpf_funcionarios CHECK (cpf LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
	);

	insert into vendedores(nome,cpf,salario_fixo) values('Mathues Santos','12345678910',1700.00);
	
	create table vendas(
	id_venda       int identity(0,1),
	data_venda     datetime default  GETDATE(),
	valor_total    decimal(7,2),
	id_produto     int,
	quant_produt   int not null, 
	id_vendedor    int,
	id_cliente     int,
	entrega        BIT NOT NULL DEFAULT 0,  --lembrando que 0=false e 1=True 
	status_ve      varchar(15)  default 'Aprovado',
	primary key (id_venda),
	foreign key (id_produto)  references produtos(id_produto),
	foreign key (id_cliente)  references clientes(id_cliente),
	foreign key (id_vendedor) references vendedores(id_vendedor)
	);

	

	--Dados necessários para separar o produtoforeign key
	create table expedicao(
	id_expedicao  int identity(0,1), 
	id_vendas     int,
	id_produto    int,
	nome_produto  varchar(40),
	quant_produt  int,
	data_entrega  datetime,
	local_entrega varchar(40),
	primary key (id_expedicao)
	);

	
	--Comissão dos vendedores para cada venda 
	create table comissao(
	id_venda       int not null,
	valor_venda    decimal(7,2),
	id_vendedor    int not null,
	valor_comissao decimal(7,2),
	foreign key (id_vendedor) references vendedores(id_vendedor)
	);

	create table transportadora(
	id_venda int not null,
	id_expedicao int,
	foreign key (id_expedicao) references expedicao(id_expedicao)
	);
	
	--Quem fez a alteração e qual a alteração de vendas
	create table auditoria_vendas(
	id_vendas      int         not null,
	data_insercao  datetime    default GETDATE(),
	realizado_por  varchar(40) default suser_Sname(),
	acao_realizada varchar(30) not null,
	ip_maquina     varchar(48)
	);

	--Auditoria para quando o estoque estiver baixo
	CREATE TABLE auditoria_estoque_baixo (
     id_auditoria   INT IDENTITY(1,1),
     id_produto     INT,
     quantidade_restante INT,
     data_alerta    DATETIME DEFAULT GETDATE(),
     mensagem       VARCHAR(40),
	 PRIMARY KEY (id_auditoria),
	 foreign key (id_produto)  references produtos(id_produto)
    );

	--Quando alterarem o valor do salario em vendedores ou der comissão, tera registrado o valor do salario --
	CREATE TABLE auditoria_folha_pagamento (
    id_auditoria    INT IDENTITY(1,1) PRIMARY KEY,
    id_vendedor     INT,
    valor_anterior  DECIMAL(7,2),
    valor_atual     DECIMAL(7,2),
    motivo          VARCHAR(50), -- Ex: 'Aumento anual', 'Correção'
    data_modificacao DATETIME DEFAULT GETDATE(),
    realizado_por   VARCHAR(40) DEFAULT SUSER_SNAME()
	);

	insert into auditoria_folha_pagamento(id_vendedor,valor_anterior,valor_atual,motivo)
	values(0,0,1700.00,'Novo funcionario');

	create table aguardando_produto(
	id_cliente      int not null,
	id_produto      int not null,
	qunatid_produto int,
	foreign key (id_cliente)  references clientes(id_cliente),
	foreign key (id_produto)  references produtos(id_produto)
	);

	
	--Garilho de insert 
	go
	create trigger Tg_vendas
	on vendas
	after insert
	as 
	begin

		--Declarando as varavies
		DECLARE	@id_vendas           int,
				@valor_venda         decimal(7,2),
				@data_venda          datetime,
				@id_produto          int,
				@id_vendedor         int,
				@quantid_vendida     int,
				@estoque_antes_venda int,
				@nome_produto        varchar(40),
				@estoque_pos_venda   int,
				@entrega             bit,
				@id_cliente          int,
				@valor_comissao   decimal(6,2),
				@ip_maquina       varchar(48);
	
		--Colocando os valores inseridos agora em vendas
		select @id_vendas       = id_venda,
			   @id_produto     = id_produto,
			   @id_vendedor     = id_vendedor,
			   @valor_venda     = valor_total,
			   @quantid_vendida = quant_produt,
			   @data_venda      = data_venda,
			   @entrega         = entrega,
			   @id_cliente      = id_cliente
			   from inserted;

		--Ip da maquina de quem realizou a inserção da venda
		select @ip_maquina = client_net_address
		from sys.dm_exec_connections
		where session_id = @@SPID; --@@SPID = sessão atual.

		--Quantidade de produtos no estoque
		select @estoque_antes_venda = estoque, @nome_produto = nome_produto
		from produtos 
		where id_produto = @id_produto;

		--Quantidade do estoque após a venda
		set @estoque_pos_venda = (@estoque_antes_venda-@quantid_vendida);

		if @estoque_pos_venda >= 0
		  BEGIN

			declare @valor_anterior_comissao decimal(7,2);
			
			select @valor_anterior_comissao = valor_atual 
			from auditoria_folha_pagamento 
			where id_vendedor = @id_vendedor


			--Ajustar valor do estoque 
			update produtos
			set estoque = @estoque_pos_venda
			where id_produto = @id_produto;

			--Dar comissão ao vendedor
			set @valor_comissao = (0.05 * @valor_venda);
			insert into comissao(id_venda, valor_venda, id_vendedor, valor_comissao)
			values (@id_vendas, @valor_venda, @id_vendedor, @valor_comissao);

			--Registrar a comissão na auditoria
			update auditoria_folha_pagamento
			set  valor_anterior = @valor_anterior_comissao,
			     valor_atual    = ( @valor_anterior_comissao + @valor_comissao),
				 motivo         = 'Ganho comissão'
			where id_vendedor = @id_vendedor;

			--Preencher a tabela expedição 
			if @entrega = 1
			  BEGIN
				declare @endereco_cliente varchar(80),
						@id_expedicao     int;

				--Pegando o endereço do cliente que comprou 
				select @endereco_cliente = endereco
				from clientes 
				where id_cliente = @id_cliente;

				insert into expedicao(id_vendas,id_produto,nome_produto,quant_produt,data_entrega,local_entrega)
				values (@id_vendas, @id_produto, @nome_produto, @quantid_vendida, @data_venda, @endereco_cliente);

				select @id_expedicao = id_expedicao
				from expedicao
				where id_vendas = @id_vendas;

				insert into transportadora(id_venda,id_expedicao)
				values(@id_vendas,@id_expedicao);

			  END
			else 
			  BEGIN
				insert into expedicao(id_vendas,id_produto,nome_produto,quant_produt,data_entrega,local_entrega)
				values (@id_vendas, @id_produto, @nome_produto, @quantid_vendida, @data_venda, 'Pegar na loja');
			  END

			  insert into auditoria_vendas(id_vendas,acao_realizada,ip_maquina)
			  values (@id_vendas,'insert venda produtos',@ip_maquina);

		 END

		ELSE
		  BEGIN
			RAISERROR ('Não há quantidade no estoque suficiente para a venda',1,0);
			ROLLBACK TRANSACTION;

			If @estoque_antes_venda <= 1
			 begin
				insert into auditoria_estoque_baixo(id_produto,quantidade_restante,mensagem)
			    values (@id_produto,@estoque_antes_venda,'Menos de 1 unid');
			 end
			
			insert into auditoria_vendas(id_vendas,acao_realizada,ip_maquina)
			values (@id_vendas,'Sem estoque',@ip_maquina);

			insert into aguardando_produto(id_cliente,id_produto,qunatid_produto)
			values (@id_cliente,@id_produto,@quantid_vendida);
		  END

	end;

	select * from clientes;
	select * from produtos;
	select * from vendedores;

	insert into vendas(id_produto,id_vendedor,id_cliente,valor_total,quant_produt,entrega)
	values(0,0,0,1000.00,0,1);

	select * from vendas;
	select * from expedicao;
	select * from comissao;
	select * from transportadora;
	select * from auditoria_vendas;
	select * from aguardando_produto;
	select * from auditoria_estoque_baixo;
	select * from auditoria_folha_pagamento;

	--drop trigger Tg_vendas_cancelada
	--Trigger com gatilho de delete 
	go
	create trigger Tg_vendas_cancelada
	on vendas
	after delete
	as 
	begin
		declare @id_vendas     int,
				@id_produto    int,
				@id_vendedor   int,
		        @ip_maquina    varchar(48),
				@quant_cancel  int,
				@estoque       int,
				@valor_comiss  decimal(7,2);

		--Valor da comissão que será apagada 
		select @valor_comiss = valor_comissao
		from comissao
		where id_venda = @id_vendas; 

		--Valor da venda apagada
		select @id_vendas    = id_venda,
		       @quant_cancel = quant_produt,
			   @id_produto   = id_produto,
			   @id_vendedor  = id_vendedor
		from deleted;

		--Valor de produtos
		select @estoque = estoque
		from produtos
		where id_produto = @id_produto;


		--Valor do ip da ação 
		select @ip_maquina = client_net_address
		from sys.dm_exec_connections
		where session_id = @@SPID;


		--Gravando ação na tabela atuditoria_vendas
		insert into auditoria_vendas(id_vendas,acao_realizada,ip_maquina)
		values (@id_vendas,'Venda cancel.',@ip_maquina);

		--ajustando a quantidade de produtos no estoque 
		update produtos
		set estoque = (@estoque + @quant_cancel)
		where id_produto = @id_produto;

		--Retirar a comissão do vendedor 
		delete from comissao where id_venda = @id_vendas;
		
		-- E retirar o valor da comissão em seu salario 
		update auditoria_folha_pagamento
		set valor_atual    = valor_atual - @valor_comiss,
			valor_anterior = valor_atual,
			motivo		   = 'venda cancelada'
		where id_vendedor = @id_vendedor;

	end;

	delete from vendas where id_venda = 0;

	select * from auditoria_folha_pagamento; 
	select * from comissao; 
	select * from produtos;
	select * from auditoria_vendas;
	select * from vendas;

	--drop trigger Tg_produto_alterado_vendas
	--Trigger usando update 
    go
	create trigger Tg_produto_alterado_vendas
	on vendas
	after update
	as 
	begin
		
		DECLARE  @quant_produt_antiga int,
				 @quant_produt_nova   int,
				 @id_produto_antigo   int,
				 @id_produto_novo     int,
				 @id_cliente_novo     int,
				 @id_vendas			  int,
				 @entrega_novo        bit,
				 @nome_produto_novo   varchar(40),
				 @data_venda          datetime,
				 @ip_maquina       varchar(48);
		
		--Valores antigos 
		select @quant_produt_antiga      = quant_produt,
			   @id_produto_antigo = id_produto,
			   @id_cliente_novo   = id_cliente
			   from deleted;

		--Valores novos 
		select @id_produto_novo   = id_produto,
			   @entrega_novo      = entrega,
			   @id_cliente_novo   = id_cliente,
			   @quant_produt_nova = quant_produt,
			   @data_venda        = data_venda,
			   @id_vendas         = id_venda
		from inserted;


		--Pegando informações do produto na tabela produtos
		select  @nome_produto_novo = nome_produto
		from produtos 
		where id_produto = @id_produto_novo;

		--Pegando o ip da maquina que fez a alteração 
		select @ip_maquina = client_net_address
		from sys.dm_exec_connections
		where session_id = @@SPID; 

		--ajustar o stoque do produto antigo
		update produtos
		set    estoque = estoque + @quant_produt_antiga
		where  id_produto = @id_produto_antigo;

		--Ajustando o estoque do produto novo 
		update produtos
		set    estoque = estoque - @quant_produt_nova
		where  id_produto = @id_produto_novo;

		--Verificar se o cliente escolheu entrega a domicilio 
			if @entrega_novo = 1
			  BEGIN
				declare @endereco_cliente varchar(80),
						@id_expedicao     int;

				--Pegando o endereço do cliente que comprou 
				select @endereco_cliente = endereco
				from clientes 
				where id_cliente = @id_cliente_novo;

				insert into expedicao(id_vendas,id_produto,nome_produto,quant_produt,data_entrega,local_entrega)
				values (@id_vendas, @id_produto_novo, @nome_produto_novo, @quant_produt_nova, @data_venda, @endereco_cliente);

				select @id_expedicao = id_expedicao
				from expedicao
				where id_vendas = @id_vendas;

				insert into transportadora(id_venda,id_expedicao)
				values(@id_vendas,@id_expedicao);

			  END
			else 
			  BEGIN
				insert into expedicao(id_vendas,id_produto,nome_produto,quant_produt,data_entrega,local_entrega)
				values (@id_vendas, @id_produto_novo, @nome_produto_novo, @quant_produt_nova, @data_venda, 'Pegar na loja');
			  END

			   insert into auditoria_vendas(id_vendas,acao_realizada,ip_maquina)
			  values (@id_vendas,'update na venda',@ip_maquina);
	
		
	end;

	insert into vendas(id_produto,id_vendedor,id_cliente,valor_total,quant_produt,entrega)
	values(0,0,0,1000.00,1,1);

	update vendas
	set   id_produto = 1
	where id_venda  = 2;

	select * from vendas;
	select * from auditoria_vendas;
	select * from expedicao;
	select * from transportadora;
	select * from produtos;
