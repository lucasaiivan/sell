

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../entities/cashRegister_model.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionUseCase {
  
  final TransactionsRepository transactionRepository;  
  GetTransactionUseCase() : transactionRepository = TransactionsRepositoryImpl(FirebaseTransactionProvider());

  Future<List<CashRegister>> getTransactions(String idAccount) {
    return transactionRepository.getTransactions(idAccount);
  }
}