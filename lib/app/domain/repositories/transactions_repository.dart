

import 'package:sell/app/domain/entities/cashRegister_model.dart';

abstract class TransactionsRepository {
   
  Future<void> setCashRegister(String idAccount,CashRegister cashRegister);
  Future<void> deleteCashRegister(String idAccount,String idCashRegister);

  Future<List<CashRegister>> getTransactions(String idAccount); 
  Future<void> addHistoryRecord(String idAccount,CashRegister cashRegister);

  // fixers descriptions
  Future<void> createFixedDescription(String idAccount, String description);
  Future<void> deleteFixedDescription(String idAccount, String idDescription);
  Future<List<Map>> getFixedsDescriptions(String idAccount);
} 