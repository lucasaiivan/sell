 
import '../../domain/entities/ticket_model.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../providers/firebase_data_provider.dart';

class TransactionsRepositoryImpl extends TransactionsRepository {
 
  final FirebaseTransactionProvider firebaseTransactionProvider; 
  TransactionsRepositoryImpl(this.firebaseTransactionProvider);

  // return : list : TicketModel
  @override
  Future<List<TicketModel>> getTransactions(String idAccount) { 
   return firebaseTransactionProvider.getTransactions(idAccount);
  }
  // void : add : TicketModel
  @override
  Future<void> addTransaction(String idAccount,TicketModel ticketModel) async {
    firebaseTransactionProvider.addTransaction(idAccount,ticketModel);
  }
  // void : delete : TicketModel
  @override
  Future<void> deleteTransaction(String idAccount,TicketModel ticketModel) async {
    firebaseTransactionProvider.deleteTransaction(idAccount,ticketModel);
  }

  
  

}