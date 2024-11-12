


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

}