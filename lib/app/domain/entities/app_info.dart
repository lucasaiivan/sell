

import 'package:cloud_firestore/cloud_firestore.dart';

class AppInfo {
  final int versionApp ;
  final String urlPlayStore; 

  AppInfo({
    required this.versionApp,
    required this.urlPlayStore,
  });
 
 
  AppInfo.fromDocumentSnapshot(DocumentSnapshot data) :
    versionApp = data['versionApp'],
    urlPlayStore = data['urlPlayStore'];
}