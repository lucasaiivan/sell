

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/transactions_repository_impl.dart'; 
import '../entities/ticket_model.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionUseCase {
  
  final TransactionsRepository transactionRepository;  
  GetTransactionUseCase() : transactionRepository = TransactionsRepositoryImpl(FirebaseTransactionProvider());

  // return : list : TicketModel : obtengo las transacciones de la cuenta
  Future<List<TicketModel>> getTransactions(String idAccount) {
    return transactionRepository.getTransactions(idAccount);
  }
  // void : add : TicketModel : agrego una transaccion a la cuenta
  Future<void> addTransaction(String idAccount, TicketModel ticketModel) async {
    transactionRepository.addTransaction(idAccount, ticketModel);
  }
  // void : delete : TicketModel : elimino una transaccion de la cuenta
  Future<void> deleteTransaction(String idAccount, TicketModel ticketModel) async {
    transactionRepository.deleteTransaction(idAccount, ticketModel);
  }
 
  
}