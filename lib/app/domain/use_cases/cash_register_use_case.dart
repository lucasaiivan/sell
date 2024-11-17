

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/cash_register_history_impl.dart';
import '../entities/cashRegister_model.dart';
import '../repositories/cash_register_history_repository.dart';

class CashRegisterUseCase {
  
  final CashRegisterHistoryRepository cashRegisterHistoryRepository;  
  CashRegisterUseCase() : cashRegisterHistoryRepository = CashRegisterHistory(FirebaseHistoryCashRegisterProvider());


  // return : list : CashRegister : obtengo los registros de arqueo de caja
  Future<List<CashRegister>> getCashRegisterHistory(String idAccount) {
    return cashRegisterHistoryRepository.getCashRegisterHistory(idAccount);
  }
  // void : add : obtengo los registros de arqueo de caja 
  Future<void> addCashRegisterHistory(String idAccount, CashRegister cashRegister) {
    return cashRegisterHistoryRepository.addCashRegisterHistory(idAccount, cashRegister);
  }
  // void : delete : elimina un registro de arqueo de caja
  Future<void> deleteCashRegisterHistory(String idAccount, CashRegister cashRegister) {
    return cashRegisterHistoryRepository.deleteCashRegisterHistory(idAccount, cashRegister);
  }

  // void : create/update : actualiza la caja registradora activas
  Future<void> createUpdateCashRegister(String idAccount, CashRegister cashRegister) {
    return cashRegisterHistoryRepository.createUpdateCashRegister(idAccount, cashRegister);
  }
  // delete : elimina la caja registradora activa
  Future<void> deleteCashRegister(String idAccount, String idCashRegister) {
    return cashRegisterHistoryRepository.deleteCashRegister(idAccount, idCashRegister);
  }

  // fixers descriptions
  Future<void> createFixedDescription(String idAccount, String description) {
    return cashRegisterHistoryRepository.createFixedDescription(idAccount, description);
  }
  Future<void> deleteFixedDescription(String idAccount, String idDescription) {
    return cashRegisterHistoryRepository.deleteFixedDescription(idAccount, idDescription);
  }
  Future<List<Map>> getFixedsDescriptions(String idAccount) {
    return cashRegisterHistoryRepository.getFixedsDescriptions(idAccount);
  }
  

}