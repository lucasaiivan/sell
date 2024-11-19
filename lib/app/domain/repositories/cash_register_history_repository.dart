

import '../entities/cashRegister_model.dart';

abstract class CashRegisterHistoryRepository {
  
   
  // fixers descriptions
  Future<void> createFixedDescription(String idAccount, String description);
  Future<void> deleteFixedDescription(String idAccount, String idDescription);
  Future<List<Map>> getFixedsDescriptions(String idAccount);

  // return : list : CashRegister : obtengo los registros de arqueo de caja
  Future<List<CashRegister>> getCashRegisterActive(String idAccount);
  Future<List<CashRegister>> getCashRegisterHistory(String idAccount); 
  Stream<List<CashRegister>> getCashRegisterHistoryStream(String idAccount);

  // void : add : obtengo los registros de arqueo de caja
  Future<void> addCashRegisterHistory(String idAccount, CashRegister cashRegister);
  // void : delete : elimina un registro de arqueo de caja
  Future<void> deleteCashRegisterHistory(String idAccount, CashRegister cashRegister);

  // void : create/update : actualiza la caja registradora activas
  Future<void> createUpdateCashRegister(String idAccount, CashRegister cashRegister);
  // delete : elimina la caja registradora activa
  Future<void> deleteCashRegister(String idAccount, String idCashRegister);

  
  
}