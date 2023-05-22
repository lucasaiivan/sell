

class CashRegister {
  String id;
  String description;
  DateTime opening;
  DateTime closure;
  double initialCash;
  double billing;
  double cashInFlow;
  double cashOutFlow;
  double expectedBalance;
  double balance;
  List<Map<String, dynamic>> cashFlowList;
  List<Map<String, dynamic>> cashOutFlowList;

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
    required this.cashFlowList,
    required this.cashOutFlowList,
  });
}