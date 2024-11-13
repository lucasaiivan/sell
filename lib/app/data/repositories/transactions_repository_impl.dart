


import 'package:sell/app/domain/entities/cashRegister_model.dart';

import '../../domain/repositories/transactions_repository.dart';
import '../providers/firebase_data_provider.dart';

class TransactionsRepositoryImpl extends TransactionsRepository {

  final FirebaseTransactionProvider firebaseTransactionProvider; 

  TransactionsRepositoryImpl(this.firebaseTransactionProvider);


  @override
  Future<List<CashRegister>> getTransactions(String idAccount) { 
   return firebaseTransactionProvider.getTransactions(idAccount);
  }
  
  @override
  Future<void> setCashRegister(String idAccount, CashRegister cashRegister) {
    return firebaseTransactionProvider.setCashRegister(idAccount, cashRegister);
  }
  
  @override
  Future<void> createFixedDescription(String idAccount, String description) async {
    return firebaseTransactionProvider.createFixedDescription(idAccount, description);
  }
  
  @override
  Future<void> deleteFixedDescription(String idAccount, String idDescription) {
    return firebaseTransactionProvider.deleteFixedDescription(idAccount, idDescription);
  }
  
  @override
  Future<List<Map>> getFixedsDescriptions(String idAccount) {
    return firebaseTransactionProvider.getFixedsDescriptions(idAccount);
  }
  
  @override
  Future<void> addHistoryRecord(String idAccount, CashRegister cashRegister) {
    return firebaseTransactionProvider.addHistoryRecord(idAccount, cashRegister);
  }
  
  @override
  Future<void> deleteCashRegister(String idAccount, String idCashRegister) {
    return firebaseTransactionProvider.deleteCashRegister(idAccount, idCashRegister);
  }
  

}