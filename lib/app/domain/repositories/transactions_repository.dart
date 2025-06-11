 
import '../entities/ticket_model.dart';

abstract class TransactionsRepository {
    

  Future<List<TicketModel>> getTransactions(String idAccount);  
  Future<void> addTransaction(String idAccount,TicketModel ticketModel);
  Future<void> deleteTransaction(String idAccount,TicketModel ticketModel);

  
} 