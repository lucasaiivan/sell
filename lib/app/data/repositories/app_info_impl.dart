

import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';
import '../providers/firebase_data_provider.dart';

class AppInfoImpl implements AppInfoRepository {
  
  final FirebaseAppInfoProvider firebaseDataProvider;

  AppInfoImpl(this.firebaseDataProvider);
  
  @override
  Future<AppInfo> getAppInfo() { 
    return firebaseDataProvider.getAppInfo();
  }

  

}