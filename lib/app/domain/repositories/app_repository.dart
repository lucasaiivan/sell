// definimos la interfaz del repositorio de la aplicación

import '../entities/app_info.dart';

abstract class AppInfoRepository {
  // future : int : obtener la version de la aplicacion actual
  Future<AppInfo> getAppInfo();
}