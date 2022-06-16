import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/user_model.dart';
import 'package:sell/app/services/database.dart';

class HomeController extends GetxController {
  //  authentication account profile
  late User _userAccountAuth;
  User get getUserAccountAuth => _userAccountAuth;
  set setUserAccountAuth(User user) => _userAccountAuth = user;

  // profile user
  ProfileAccountModel _accountProfile =
      ProfileAccountModel(creation: Timestamp.now());
  ProfileAccountModel get getAccountProfile => _accountProfile;
  set setAccountProfile(ProfileAccountModel value) => _accountProfile = value;

  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  @override
  void onInit() async {
    super.onInit();

    // obtenemos por parametro los datos de la cuenta de atentificación
    Map map = Get.arguments as Map;

    // verificamos y obtenemos los datos pasados por parametro
    setUserAccountAuth = map['currentUser'];
    readAccountsData(idAccount: getUserAccountAuth.uid);
    /* map.containsKey('idAccount')
        ? readAccountsData(idAccount: Get.arguments['idAccount'])
        : readAccountsData(idAccount: '');
  } */
  }

  @override
  void onClose() {}

  // QUERIES DB
  void readAccountsData({required String idAccount}) {
    //default values
    setAccountProfile = ProfileAccountModel(creation: Timestamp.now());

    // obtenemos los datos de la cuenta
    if (idAccount != '') {
      Database.readProfileAccountModelFuture(idAccount).then((value) {
        //get
        if (value.exists) {
          setAccountProfile =
              ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          //  agregamos los datos del perfil de la cuenta en la lista para mostrar al usuario
          /* if (profileAccount.id != '') {
            //addManagedAccount(profileData: profileAccount);
          } */
        }
      }).catchError((error) {
        print('######################## readManagedAccountsData: ' +
            error.toString());
      });
    }
  }
}
