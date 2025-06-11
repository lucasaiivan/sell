

import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';
import '../providers/firebase_data_provider.dart'; 

import '../providers/local_data_provider.dart';

class AppInfoImpl implements AppInfoRepository {
  
  final FirebaseAppInfoProvider firebaseDataProvider;
  final LocalAppDataProvider storageLocal;

  AppInfoImpl(this.firebaseDataProvider, this.storageLocal);
  
  @override
  Future<AppInfo> getAppInfo() { 
    return firebaseDataProvider.getAppInfo();
  }
  
  @override
  Future<String> getStorageLocalCashRegisterID() { 
    return storageLocal.getStorageLocalCashRegisterID();
  }
  
  @override
  Future<String> getStorageLocalIdAccount() { 
    return storageLocal.getStorageLocalIdAccount();
  }
  
  @override
  Future setStorageLocalCashRegisterID(String cashRegisterID) {
    return storageLocal.setStorageLocalCashRegisterID(cashRegisterID);
  }
  
  @override
  Future setStorageLocalIdAccount(String idAccount) {
    return storageLocal.setStorageLocalIdAccount(idAccount);
  }
  
  @override
  Future<void> cleanLocalData() {
    return storageLocal.cleanLocalData();
  }
  
  @override
  Future<bool> getStorageLocalCashierMode() {
    return storageLocal.getStorageLocalCashierMode();
  }
  
  @override
  Future<void> setStorageLocalCashierMode(bool cashierMode) { 
    return storageLocal.setStorageLocalCashierMode(cashierMode);
  }
   

  

}