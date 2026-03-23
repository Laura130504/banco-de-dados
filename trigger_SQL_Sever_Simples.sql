	create database lauraLopes;
	use lauraLopes;

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

	insert into produtos(nome_produto,valor,tipo_madeira,estoque) values ('Cadeira-estofada0',500.00,'macieira',3);

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
	foreign key (id_venda)    references vendas(id_venda),
	foreign key (id_vendedor) references vendedores(id_vendedor)
	);

	create table transportadora(
	id_venda int not null,
	id_expedicao int,
	foreign key (id_venda)     references vendas(id_venda),
	foreign key (id_expedicao) references expedicao(id_expedicao)
	);

	--Quem fez a alteração e qual a alteração de vendas
	create table auditoria_vendas(
	id_vendas      int         not null,
	data_insercao  datetime    default GETDATE(),
	realizado_por  varchar(40) default suser_Sname(),
	acao_realizada varchar(30) not null,
	ip_maquina     varchar(48),
	foreign key (id_vendas)    references vendas(id_venda)
	);

	create table aguardando_produto(
	id_cliente      int not null,
	id_produto      int not null,
	qunatid_produto int,
	foreign key (id_cliente)  references clientes(id_cliente),
	foreign key (id_produto)  references produtos(id_produto)
	);

	
	-- Verificar e realizar uma venda
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

			


			--Ajustar valor do estoque 
			update produtos
			set estoque = @estoque_pos_venda
			where id_produto = @id_produto;

			--Dar comissão ao vendedor
			set @valor_comissao = (0.05 * @valor_venda);
			insert into comissao(id_venda, valor_venda, id_vendedor, valor_comissao)
			values (@id_vendas, @valor_venda, @id_vendedor, @valor_comissao);

			--Se o cliente quis entrega  
			if @entrega = 1
			  BEGIN
				declare @endereco_cliente varchar(80),
						@id_expedicao     int;

				--Pegando o endereço do cliente que comprou 
				select @endereco_cliente = endereco
				from clientes 
				where id_cliente = @id_cliente;

				--Separar os produtos para venda
				insert into expedicao(id_vendas,id_produto,nome_produto,quant_produt,data_entrega,local_entrega)
				values (@id_vendas, @id_produto, @nome_produto, @quantid_vendida, @data_venda, @endereco_cliente);

				select @id_expedicao = id_expedicao
				from expedicao
				where id_vendas = @id_vendas;

				--avisar a tranportadora do pedido para ela levar
				insert into transportadora(id_venda,id_expedicao)
				values(@id_vendas,@id_expedicao);

			  END
			else --Vai pegar a compra na loja
			  BEGIN 
			  --Separar o produto para venda
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

		

			insert into auditoria_vendas(id_vendas,acao_realizada,ip_maquina)
			values (@id_vendas,'Sem estoque',@ip_maquina);

			-- ]colocar o cliente na lista de espera para quando chegar mais desse produto 
			insert into aguardando_produto(id_cliente,id_produto,qunatid_produto)
			values (@id_cliente,@id_produto,@quantid_vendida);
		  END

	end;

	select * from clientes;
	select * from produtos;
	select * from vendedores;

	insert into vendas(id_produto,id_vendedor,id_cliente,valor_total,quant_produt,entrega)
	values(0,0,0,1000.00,3,1);

	select * from vendas;
	select * from expedicao;
	select * from comissao;
	select * from transportadora;
	select * from auditoria_vendas;
	select * from aguardando_produto;