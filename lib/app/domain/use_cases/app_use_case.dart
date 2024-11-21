//  [ case use ]
//  Este archivo contiene los Casos de Uso de la aplicación

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/app_info_impl.dart';
import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

class GetAppInfo {
  final AppInfoRepository appRepository;

  GetAppInfo() : appRepository = AppInfoImpl(FirebaseAppInfoProvider());


  // future : int : obtener informacion de la aplicacion
  Future<AppInfo> getAppInfo() async { 
    return await appRepository.getAppInfo();
  }
}