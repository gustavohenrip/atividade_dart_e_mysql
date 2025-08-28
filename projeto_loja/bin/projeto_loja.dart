import 'package:mysql_client/mysql_client.dart';

class Cliente {
  int? id;
  String nome;
  String email;

  Cliente({this.id, required this.nome, required this.email});

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, email: $email}';
  }
}

class Pedido {
  int? id;
  String descricao;
  double valor;
  int clienteId;

  Pedido({
    this.id,
    required this.descricao,
    required this.valor,
    required this.clienteId,
  });

  @override
  String toString() {
    return 'Pedido{id: $id, descricao: $descricao, valor: $valor, clienteId: $clienteId}';
  }
}

class DatabaseManager {
  late MySQLConnection conn;

  Future<void> connect() async {
    conn = await MySQLConnection.createConnection(
      host: "127.0.0.1",
      port: 3306,
      userName: "root",
      password: "root",
      databaseName: "loja_dart",
      secure: false,
    );
    await conn.connect();
  }

  Future<void> close() async {
    await conn.close();
  }

  Future<IResultSet> inserirCliente(Cliente cliente) async {
    var result = await conn.execute(
      "INSERT INTO cliente (nome, email) VALUES (:nome, :email)",
      {"nome": cliente.nome, "email": cliente.email},
    );
    return result;
  }

  Future<IResultSet> inserirPedido(Pedido pedido) async {
    var result = await conn.execute(
      "INSERT INTO pedido (descricao, valor, cliente_id) VALUES (:descricao, :valor, :cliente_id)",
      {
        "descricao": pedido.descricao,
        "valor": pedido.valor,
        "cliente_id": pedido.clienteId,
      },
    );
    return result;
  }

  Future<void> listarPedidosComCliente() async {
    var results = await conn.execute(
      "SELECT p.id, p.descricao, p.valor, c.nome as nome_cliente "
      "FROM pedido p "
      "JOIN cliente c ON p.cliente_id = c.id "
      "ORDER BY c.nome",
    );
    print("--- 1. Listagem de Pedidos com Dados do Cliente (JOIN) ---");
    for (final row in results.rows) {
      var rowData = row.assoc();
      print(
        "Pedido ID: ${rowData['id']}, Descrição: ${rowData['descricao']}, Valor: ${rowData['valor']}, Cliente: ${rowData['nome_cliente']}",
      );
    }
  }

  Future<void> resumirPedidosPorCliente() async {
    var results = await conn.execute(
      "SELECT c.nome, COUNT(p.id) as total_pedidos, SUM(p.valor) as total_gasto "
      "FROM cliente c "
      "JOIN pedido p ON c.id = p.cliente_id "
      "GROUP BY c.nome "
      "ORDER BY total_gasto DESC",
    );
    print("\n--- 2. Resumo de Pedidos por Cliente (GROUP BY) ---");
    for (final row in results.rows) {
      var rowData = row.assoc();
      print(
        "Cliente: ${rowData['nome']}, Pedidos: ${rowData['total_pedidos']}, Total Gasto: R\$${rowData['total_gasto']}",
      );
    }
  }
}

Future<void> main() async {
  final dbManager = DatabaseManager();

  try {
    await dbManager.connect();
    print("Conexão com o MySQL estabelecida.");

    await dbManager.inserirCliente(
      Cliente(nome: "Ana Silva", email: "ana.silva@email.com"),
    );
    await dbManager.inserirCliente(
      Cliente(nome: "Bruno Costa", email: "bruno.costa@email.com"),
    );
    await dbManager.inserirCliente(
      Cliente(nome: "Carla Dias", email: "carla.dias@email.com"),
    );
    print("\nClientes inseridos com sucesso.");

    await dbManager.inserirPedido(
      Pedido(descricao: "Notebook Gamer", valor: 7500.00, clienteId: 1),
    );
    await dbManager.inserirPedido(
      Pedido(descricao: "Monitor 4K", valor: 2200.50, clienteId: 1),
    );
    await dbManager.inserirPedido(
      Pedido(descricao: "Mouse sem fio", valor: 150.75, clienteId: 2),
    );
    await dbManager.inserirPedido(
      Pedido(descricao: "Teclado Mecânico", valor: 450.00, clienteId: 3),
    );
    await dbManager.inserirPedido(
      Pedido(descricao: "Webcam HD", valor: 320.00, clienteId: 3),
    );
    print("Pedidos inseridos com sucesso.\n");

    await dbManager.listarPedidosComCliente();
    await dbManager.resumirPedidosPorCliente();
  } catch (e) {
    print("Ocorreu um erro: $e");
  } finally {
    await dbManager.close();
    print("\nConexão com o MySQL fechada.");
  }
}
