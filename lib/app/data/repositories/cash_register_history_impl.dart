 
import 'package:sell/app/domain/entities/cashRegister_model.dart';

import '../../domain/repositories/cash_register_history_repository.dart';
import '../providers/firebase_data_provider.dart';

class CashRegisterHistory extends CashRegisterHistoryRepository {

  final FirebaseHistoryCashRegisterProvider firebaseTransactionProvider; 
  CashRegisterHistory(this.firebaseTransactionProvider);


  @override
  Future<List<CashRegister>> getCashRegisterActive(String idAccount) { 
    return firebaseTransactionProvider.getCashRegistersActive(idAccount);
  }

  @override
  Stream<List<CashRegister>> getCashRegisterHistoryStream(String idAccount) { 
    return firebaseTransactionProvider.getHistoryCashRegistersStream(idAccount);
  } 

  @override
  Future<List<CashRegister>> getCashRegisterHistory(String idAccount) { 
    return firebaseTransactionProvider.getHistoryCashRegisters(idAccount);
  }

  @override
  Future<void> addCashRegisterHistory(String idAccount, CashRegister cashRegister) {
    return firebaseTransactionProvider.addHistoryCashRegister(idAccount, cashRegister);
  }

  @override
  Future<void> createFixedDescription(String idAccount, String description) {
    return firebaseTransactionProvider.createFixedDescription(idAccount, description);
  }

  @override
  Future<void> createUpdateCashRegister(String idAccount, CashRegister cashRegister) {
    return firebaseTransactionProvider.setCashRegister(idAccount, cashRegister);
  }

  @override
  Future<void> deleteCashRegister(String idAccount, String idCashRegister) {
    return firebaseTransactionProvider.deleteCashRegister(idAccount, idCashRegister);
  }

  @override
  Future<void> deleteCashRegisterHistory(String idAccount, CashRegister cashRegister) {
    return firebaseTransactionProvider.deleteHistoryCashRegister(idAccount, cashRegister);
  }

  @override
  Future<void> deleteFixedDescription(String idAccount, String idDescription) { 
    return firebaseTransactionProvider.deleteFixedDescription(idAccount, idDescription);
  }
 

  @override
  Future<List<Map>> getFixedsDescriptions(String idAccount) { 
    return firebaseTransactionProvider.getFixedsDescriptions(idAccount);
  }
  
   
  
}