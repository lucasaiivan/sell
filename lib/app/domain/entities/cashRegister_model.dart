

class CashRegister {
  String id; // id de la caja
  String description; // descripción de la caja
  DateTime opening; // fecha de apertura
  DateTime closure; // fecha de cierre
  double initialCash; // monto inicial
  double billing; // monto de facturación
  double cashInFlow; // monto de ingresos
  double cashOutFlow; // monto de egresos
  double expectedBalance; // monto esperado
  double balance; // monto actual
  List<Map<String, dynamic>> cashInFlowList; // lista de ingresos de caja
  List<Map<String, dynamic>> cashOutFlowList; // lista de egresos de caja

  CashRegister({
    required this.id,
    required this.description,
    required this.initialCash,
    required this.opening,
    required this.closure,
    required this.billing,
    required this.cashInFlow,
    required this.cashOutFlow,
    required this.expectedBalance,
    required this.balance,
    required this.cashInFlowList,
    required this.cashOutFlowList,
  });
 
  // balance : devuelve el balance actual de la caja
  double get getBalance{
    return (initialCash + cashInFlow) - cashOutFlow;
  }
  // default values  
  factory CashRegister.initialData(){
    return CashRegister(
      id: '',
      description: '',
      initialCash: 0.0,
      opening: DateTime.now(),
      closure: DateTime.now(),
      billing: 0.0,
      cashInFlow: 0.0,
      cashOutFlow: 0.0,
      expectedBalance: 0.0,
      balance: 0.0,
      cashInFlowList: [],
      cashOutFlowList: [],
    );
  }
  // tojson : convierte el objeto a json
  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "initialCash": initialCash,
        "opening": opening,
        "closure": closure,
        "billing": billing,
        "cashInFlow": cashInFlow,
        "cashOutFlow": cashOutFlow,
        "expectedBalance": expectedBalance,
        "balance": balance,
        "cashInFlowList": cashInFlowList,
        "cashOutFlowList": cashOutFlowList,
      };
  // fromjson : convierte el json en un objeto
  factory CashRegister.fromMap(Map<dynamic, dynamic> data) {
    return CashRegister(
      id: data['id'] ?? '',
      description: data['description'] ?? '',
      initialCash: (data['initialCash'] ?? 0).toDouble(),
      opening: data['opening'].toDate(),
      closure: data['closure'].toDate(),
      billing: (data['billing'] ?? 0).toDouble(),
      cashInFlow: (data['cashInFlow'] ?? 0).toDouble(),
      cashOutFlow: (data['cashOutFlow'] ?? 0).toDouble(),
      expectedBalance: (data['expectedBalance'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      cashInFlowList: data['cashInFlowList'] ?? [],
      cashOutFlowList: data['cashOutFlowList'] ?? [],
    );
  }
}

// flujo de caja
class CashFlow{ 
  String id = '';
  String description = '';
  double amount = 0.0;
  DateTime date = DateTime.now();

  CashFlow({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  // default values
  factory CashFlow.initialData(){
    return CashFlow(
      id: '',
      description: '',
      amount: 0.0,
      date: DateTime.now(),
    );
  }
  // tojson : convierte el objeto a json
  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "amount": amount,
        "date": date,
      };
  // fromjson : convierte el json en un objeto
  factory CashFlow.fromMap(Map<dynamic, dynamic> data) {
    return CashFlow(
      id: data['id'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date'].toDate(),
    );
  }
  
}