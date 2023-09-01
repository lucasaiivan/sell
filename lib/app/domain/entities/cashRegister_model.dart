

import 'package:cloud_firestore/cloud_firestore.dart';

class CashRegister {
  String id; // id de la caja
  String description; // descripción de la caja
  DateTime opening; // fecha de apertura
  DateTime closure; // fecha de cierre
  double initialCash; // monto inicial
  int sales; // cantidad de ventas
  double billing; // monto de facturación
  double cashInFlow; // monto de ingresos
  double cashOutFlow; // monto de egresos (numero negativo)
  double expectedBalance; // monto esperado
  double balance; // monto de cierre
  List<dynamic> cashInFlowList; // lista de ingresos de caja
  List<dynamic> cashOutFlowList; // lista de egresos de caja

  CashRegister({
    required this.id,
    required this.description,
    required this.initialCash,
    required this.opening,
    required this.closure,
    required this.sales,
    required this.billing,
    required this.cashInFlow,
    required this.cashOutFlow,
    required this.expectedBalance,
    required this.balance,
    required this.cashInFlowList,
    required this.cashOutFlowList,
  });
 
  // difference : devuelve la diferencia entre el monto esperado y el monto de cierre
  double get getDifference{
    if(balance == 0){ return 0.0;}
    return  balance - getExpectedBalance;
  }
  // balance : devuelve el balance esperado de la caja
  double get getExpectedBalance{
    return (initialCash + cashInFlow+ billing) + cashOutFlow;
  }
  // default values  
  factory CashRegister.initialData(){
    return CashRegister(
      id: '',
      description: '',
      initialCash: 0.0,
      opening: DateTime.now(),
      closure: DateTime.now(),
      sales: 0,
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
        "sales": sales,
        "billing": billing,
        "cashInFlow": cashInFlow,
        "cashOutFlow": cashOutFlow,
        "expectedBalance": expectedBalance,
        "balance": balance,
        "cashInFlowList": cashInFlowList,
        "cashOutFlowList": cashOutFlowList,
      }; 

      
  // fromjson : convierte el json en un objeto
  factory CashRegister.fromMap(Map  data) {
    return CashRegister(
      id: data['id'] ,
      description: data['description'] ,
      initialCash: double.parse(data['initialCash'].toString()),
      opening: data['opening'].toDate(),
      closure: data['closure'].toDate(),
      sales: data['sales'] ?? 0,
      billing: double.parse(data['billing'].toString()),
      cashInFlow: double.parse(data['cashInFlow'].toString()) ,
      cashOutFlow: double.parse(data['cashOutFlow'].toString()),
      expectedBalance:double.parse(data['expectedBalance'].toString()),
      balance: double.parse(data['balance'].toString()),
      cashInFlowList: data['cashInFlowList'] ?? [],
      cashOutFlowList: data['cashOutFlowList'] ?? [],
    );
  }


  fromDocumentSnapshot( {required DocumentSnapshot documentSnapshot}) { 
    id = documentSnapshot.id;
    description = documentSnapshot['description'];
    initialCash = documentSnapshot['initialCash'].toDouble();
    opening = documentSnapshot['opening'].toDate();
    closure = documentSnapshot['closure'].toDate();
    billing = documentSnapshot['billing'].toDouble();
    sales = documentSnapshot['sales'];
    cashInFlow = documentSnapshot['cashInFlow'].toDouble();
    cashOutFlow = documentSnapshot['cashOutFlow'].toDouble();
    expectedBalance = documentSnapshot['expectedBalance'].toDouble();
    balance = documentSnapshot['balance'].toDouble();
    cashInFlowList = documentSnapshot['cashInFlowList'];
    cashOutFlowList = documentSnapshot['cashOutFlowList'];
  }
  // update : actualiza los valores individualmente de la caja 
  CashRegister update({
    String? id,
    String? description,
    double? initialCash,
    DateTime? opening,
    DateTime? closure,
    int? sales,
    double? billing,
    double? cashInFlow,
    double? cashOutFlow,
    double? expectedBalance,
    double? balance,
    List<dynamic>? cashInFlowList,
    List<dynamic>? cashOutFlowList,
  }) {
    return CashRegister(
      id: id ?? this.id,
      description: description ?? this.description,
      initialCash: initialCash ?? this.initialCash,
      opening: opening ?? this.opening,
      closure: closure ?? this.closure,
      sales: sales ?? this.sales,
      billing: billing ?? this.billing,
      cashInFlow: cashInFlow ?? this.cashInFlow,
      cashOutFlow: cashOutFlow ?? this.cashOutFlow,
      expectedBalance: expectedBalance ?? this.expectedBalance,
      balance: balance ?? this.balance,
      cashInFlowList: cashInFlowList ?? this.cashInFlowList,
      cashOutFlowList: cashOutFlowList ?? this.cashOutFlowList,
    );
  }

 
}

// flujo de caja
class CashFlow{ 
  String id = '';
  String userId = '';
  String description = '';
  double amount = 0.0;
  DateTime date = DateTime.now();

  CashFlow({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.date,
  });

  // default values
  factory CashFlow.initialData(){
    return CashFlow(
      id: '',
      userId: '',
      description: '',
      amount: 0.0,
      date: DateTime.now(),
    );
  }
  // tojson : convierte el objeto a json
  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "description": description,
        "amount": amount,
        "date": date,
      };
  // fromjson : convierte el json en un objeto
  factory CashFlow.fromMap(Map<dynamic, dynamic> data) {
    return CashFlow(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date'].toDate(),
    );
  }
  
}