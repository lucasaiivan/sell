

import 'package:sell/app/domain/entities/cashRegister_model.dart';

abstract class TransactionsRepository {
  // get : obtener las transacciones de la cuenta
  Future<List<CashRegister>> getTransactions(String idAccount); 
 
} 