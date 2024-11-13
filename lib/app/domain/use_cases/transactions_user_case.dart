

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../entities/cashRegister_model.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionUseCase {
  
  final TransactionsRepository transactionRepository;  
  GetTransactionUseCase() : transactionRepository = TransactionsRepositoryImpl(FirebaseTransactionProvider());

  // future : obtengo las transacciones de la cuenta
  Future<List<CashRegister>> getTransactions(String idAccount) {
    return transactionRepository.getTransactions(idAccount);
  }
  // void : actualiza la caja registradora activa
  Future<void> updateCashRegister(String idAccount,CashRegister cashRegister) {
    return transactionRepository.setCashRegister(idAccount, cashRegister);
  }
  // void : elimina la caja registradora activa
  Future<void> deleteCashRegister(String idAccount,String idCashRegister) {
    return transactionRepository.deleteCashRegister(idAccount, idCashRegister);
  }
  // void : agrega al historial de arqueo de caja
  Future<void> addHistoryRecord(String idAccount,CashRegister cashRegister) {
    return transactionRepository.addHistoryRecord(idAccount, cashRegister);
  }
  // void : crea una descripción fija (fixers)
  Future<void> createFixedDescription(String idAccount, String description) {
    return transactionRepository.createFixedDescription(idAccount, description);
  }
  // void : elimina una descripción fija (fixers)
  Future<void> deleteFixedDescription(String idAccount, String idDescription) {
    return transactionRepository.deleteFixedDescription(idAccount, idDescription);
  }
  // Future : obtiene las descripciones fijadas (fixers)
  Future<List<Map>> getFixedsDescriptions(String idAccount) {
    return transactionRepository.getFixedsDescriptions(idAccount);
  }
}