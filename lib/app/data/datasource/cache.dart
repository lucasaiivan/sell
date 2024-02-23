
import 'package:flutter_cache/flutter_cache.dart' as cache;
import '../../domain/entities/ticket_model.dart';
  

class TrasactionsCache {  

  // add : guardamos las transacciones
  Future<void> saveTransactions({required List<TicketModel> list}) async { 
    List<Map> listMap = list.map((e) => e.toMap()).toList(); 
    await cache.write('transactions', listMap).whenComplete((){ 
      print('....................... Transacciones guardadas en cache .......................');
    }); 
  }
   Future<List<TicketModel>> loadCacheTransactions() async {
    // obtenemos la consulta del cache y la deserializamos 
    List<dynamic> cacheData = await cache.load('transactions') ; 
    print('.......................  se recupero de cache  /${cacheData.length} .......................'); 
    return cacheData.map((e) => TicketModel.mapRefactoring(e)).toList();  
  } 
  
}