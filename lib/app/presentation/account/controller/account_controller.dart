import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import '../../../domain/entities/user_model.dart';
import '../../home/controller/home_controller.dart'; 

class AccountController extends GetxController {

  // controllers
  HomeController homeController = Get.find();

  // -------------------------------------- //
  // -------------  VARIABLES ------------- //
  // -------------------------------------- //
 

  // state validation accoun
  bool newAccount = false;
  // state loading
  bool stateLoding = true;

  // var : TextFormField formKey
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // controllers
  late final Rx<TextEditingController> _controllerTextEditProvincia = TextEditingController().obs;
  TextEditingController get getControllerTextEditProvincia => _controllerTextEditProvincia.value;
  set setControllerTextEditProvincia(TextEditingController value) => _controllerTextEditProvincia.value = value;

  late final Rx<TextEditingController> controllerTextEditPais = TextEditingController().obs;
  TextEditingController get getControllerTextEditPais => controllerTextEditPais.value;
  set setControllerTextEditPais(TextEditingController value) => controllerTextEditPais.value = value;

  late final Rx<TextEditingController> controllerTextEditTwon = TextEditingController().obs;
  TextEditingController get getControllerTextEditTwon => controllerTextEditTwon.value;
  set setControllerTextEditTwon(TextEditingController value) => controllerTextEditTwon.value = value;

  late final Rx<TextEditingController> controllerTextEditSignoMoneda = TextEditingController().obs;
  TextEditingController get getControllerTextEditSignoMoneda => controllerTextEditSignoMoneda.value;
  set setControllerTextEditSignoMoneda(TextEditingController value) => controllerTextEditSignoMoneda.value = value;

  // values
  final List<Map> coinsList = [
    {'code':'ARS','symbol':'AR\$','description':'Peso Argentino'},
    {'code':'USD','symbol':'US\$','description':'Dólar Estadounidense'}, 
  ];
  final RxList<String> _listCities = [
    'Buenos Aires	',
    'Catamarca',
    'Chaco',
    'Chubut',
    'Córdoba',
    'Corrientes',
    'Entre Ríos',
    'Formosa',
    'Jujuy',
    'La Pampa',
    'La Rioja',
    'Mendoza',
    'Misiones',
    'Neuquén',
    'Río Negro',
    'Salta',
    'San Juan',
    'San Luis',
    'Santa Cruz',
    'Santa Fe',
    'Santiago del Estero',
    'Tucumán',
    'Tierra del Fuego',
  ].obs;
  List<String> get getCities => _listCities;
  final RxList<String> _listountries = ['Argentina '].obs;
  List<String> get getCountries => _listountries;

  // account profile
  final Rx<ProfileAccountModel> _profileAccount =
      ProfileAccountModel(creation: Timestamp.now()).obs;
  ProfileAccountModel get profileAccount => _profileAccount.value;
  set setProfileAccount(ProfileAccountModel user) =>
      _profileAccount.value = user;

  // load save indicator
  final RxBool _savingIndicator = false.obs;
  bool get getSavingIndicator => _savingIndicator.value;
  set setSavingIndicator(bool value) {
    _savingIndicator.value = value;
    update(['load']);
  }

  // image update
  final RxBool _imageUpdate = false.obs;
  bool get getImageUpdate => _imageUpdate.value;
  set setImageUpdate(bool value) => _imageUpdate.value = value;
  // load image local
  final ImagePicker _picker = ImagePicker();
  late XFile _xFile = XFile('');
  XFile get getxFile => _xFile;
  set setxFile(XFile value) => _xFile = value;
  void setImageSource({required ImageSource imageSource}) async {
    setxFile = (await _picker.pickImage(source: imageSource,maxWidth: 720.0,maxHeight: 720.0,imageQuality: 55))!;
    setImageUpdate = true;
    update(['image']);
  }
  // -------------------------------------- //
  // ---------------  DIALOG -------------- //
  // -------------------------------------- //
  void dialogDeleteAccount() {

    // var
    String description = 'Se eliminará la cuenta y todos los datos asociados a ella: \n- arqueos\n- ventas\n- catálogo\n- usuarios \nEsta acción no se puede deshacer';

    // AlertDialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Está seguro de eliminar la cuenta?'),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteAccount(); 
              },
              child: const Text('Si, eliminar'),
            ),
          ],
        );
      },
    );

  }
   

  // -------------------------------------- //
  // -------------  FUCTIONS -------------- //
  // -------------------------------------- //

  void verifyAccount( ) { 
    // obtenemos los datos de la cuenta
    setProfileAccount = homeController.getProfileAccountSelected.copyWith();
    // set
    newAccount = profileAccount.id=='';
    setControllerTextEditProvincia =TextEditingController(text: profileAccount.province);
    setControllerTextEditPais =TextEditingController(text: profileAccount.country);
    setControllerTextEditTwon =TextEditingController(text: profileAccount.town);
    setControllerTextEditSignoMoneda =TextEditingController(text: profileAccount.currencySign);
    // actuazamos la vista
    stateLoding = false;
    update(['load']);  
  }

  void saveAccount() async {
    // fuction :  función para guardar los datos de la cuenta
    if ( formKey.currentState!.validate()) { 
      // get : obtenemos los datos de los campos de texto
      profileAccount.province = getControllerTextEditProvincia.text;
      profileAccount.country = getControllerTextEditPais.text;
      profileAccount.town = formatWithInitialsUppercase( getControllerTextEditTwon.text);
      profileAccount.currencySign = getControllerTextEditSignoMoneda.text; 
      setSavingIndicator = true;

      // comprobar existencia de creacion de cuenta
      if (newAccount) {
        //  si es una nueva cuenta se crea un nuevo id obtenido de la id de autenticacion del usuario
        // esto es para que la cuenta sea unica y no se pueda crear mas de una cuenta por usuario autenticado 
        profileAccount.id = homeController.getUserAuth.uid; 
      }
      // si se cargo una nueva imagen procede a guardar la imagen en Storage
      if (getImageUpdate) {
        //  subimos la imagen a firebase storage
        UploadTask uploadTask = Database.referenceStorageAccountImageProfile(id: profileAccount.id).putFile(File(getxFile.path));
        // para obtener la URL de la imagen de firebase storage
        profileAccount.image = await (await uploadTask).ref.getDownloadURL();
      }

      // actualizamos los datos de la cuenta en la memoria en ejecucion de la app
      homeController.setProfileAccountSelected = profileAccount.copyWith(); 

      // si la cuenta no existe, se crea una nueva de lo contrario de actualiza los datos
      newAccount? createAccount(data: profileAccount ): updateAccount(data: profileAccount.toJson());

      //  
      homeController.update();
    }
  }
  String formatWithInitialsUppercase(String value) {
    // Esta función divide el String en palabras, convierte la primera letra de cada palabra a mayúsculas
    return value.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return '';
    }).join(' ');
  }

  updateAccount({required Map<String, dynamic> data}) async {
    // Esto actualiza los datos de la cuenta
    if (data['id'] != '') {
      // db ref
      var documentReferencer = Database.refFirestoreAccount().doc(data['id']);

      // Actualizamos los datos de la cuenta
      documentReferencer.update(Map<String, dynamic>.from(data)).whenComplete(() {
        Get.back();
        print("######################## FIREBASE updateAccount whenComplete");
      }).catchError((e) {
        setSavingIndicator = false;
        Get.snackbar('No se puedo guardar los datos',
            'Puede ser un problema de conexión');
        print("######################## FIREBASE updateAccount catchError: $e");
      });
    }
  }

  void createAccount({required ProfileAccountModel data}) async {
    // Esto guarda un documento con los datos de la cuenta por crear

    // vales
    UserModel user = UserModel(
        account: data.id,
        email: homeController.getUserAuth.email ?? '', 
        superAdmin: true,
        admin: true,
        daysOfWeek: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
        startTime: {'hour':0, 'minute': 0},
        endTime: {'hour':23, 'minute': 59},
        name: data.name,
        arqueo: true,
        catalogue: true, 
        editAccount: true,
        historyArqueo: true,
        multiuser: true,
        personalized: false, 
        transactions: true,
        creation: Timestamp.now(),
        lastUpdate: Timestamp.now(), 
        inactivate: false,
        
      );
    //...
    if (data.id != '') {
      // referencias
      var documentReferencer = Database.refFirestoreAccount().doc(data.id);
      var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc(data.id);
      var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: data.id) .doc(user.email);

      // firestore : crear un documento (cuenta del negocio)
      documentReferencer.set(data.toJson()).whenComplete(() {
        // firestore : crea un documento (referencia) con los datos del usuario en el perfil de la cuenta
        refFirestoreAccountsUsersList.set(user.toJson(),SetOptions(merge: true));
        // firestore : crea un documento (referencia) con los datos de la cuenta en el perfil del usuario
        refFirestoreUserAccountsList.set(user.toJson(),SetOptions(merge: true));
        // actualizamos los datos de la cuenta en la memoria en ejecucion de la app
        homeController.accountChange(idAccount: data.id);
        Get.back();
      }).catchError((e) {
        setSavingIndicator = false;
        Get.snackbar('No se puedo guardar los datos','Puede ser un problema de conexión');
      });
    }else{
      setSavingIndicator = false;
      Get.snackbar('No se puedo guardar los datos','Problema con la indentificación de la cuenta');
    }
  }
  // void : fuction para eliminar la cuenta
  void deleteAccount() {
    // db ref : cuenta
    var documentReferencer = Database.refFirestoreAccount().doc(profileAccount.id);
    // db ref : historial de arqueo
    var refFirestoreHistoryArqueo = Database.refFirestoreRecords(idAccount: profileAccount.id);
    // db ref : historial de transacciones
    var refFirestoreTransactions = Database.refFirestoretransactions(idAccount: profileAccount.id);
    // db ref : catalogo
    var refFirestoreCatalogue = Database.refFirestoreCatalogueProduct(idAccount: profileAccount.id);
    // db ref : usuarios (multiusuario)
    var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: profileAccount.id);
    // db ref :  category (catalogo)
    var refFirestoreCategory = Database.refFirestoreCategory(idAccount: profileAccount.id);
    // db ref :  proveedor (catalogo)
    var refFirestoreProvider = Database.refFirestoreProvider(idAccount: profileAccount.id);
    // db ref :  cajas (arqueo) activas
    var refFirestoreCajas = Database.refFirestoreCashRegisters(idAccount: profileAccount.id);
    // db ref : fixed descriptions (ventas)
    var refFirestoreFixedDescriptions = Database.refFirestoreFixedDescriptions(idAccount: profileAccount.id);
 
    // delete : eliminamos la cuenta
    documentReferencer.delete();
    // delete : eliminamos el historial de arqueo
    refFirestoreHistoryArqueo.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    // delete : eliminamos el historial de transacciones
    refFirestoreTransactions.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    }); 
    // delete : eliminamos los usuarios
    refFirestoreAccountsUsersList.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
        // eliminamos la referencia de la cuenta en el perfil del usuario
        Database.refFirestoreUserAccountsList(email: doc.id).doc(profileAccount.id).delete();
      }
    });
    // delete : eliminamos las categorias
    refFirestoreCategory.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    // delete : eliminamos el catalogo
    refFirestoreCatalogue.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    // delete : eliminamos los proveedores
    refFirestoreProvider.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    // delete : eliminamos las cajas
    refFirestoreCajas.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });
    // delete : eliminamos las descripciones fijas
    refFirestoreFixedDescriptions.get().then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });

    // show alert dialog
    showDialog(
      context: Get.context!,
      barrierDismissible: false, 
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
      onPopInvoked: (_) async => false, // Deshabilita el botón de retroceso
      canPop: false,
      child: const Center(child: CircularProgressIndicator()));
      },
    );

    // sleep : esperamos 5 segundos para direccionar a la pantalla de inicio de selección de cuenta
    Future.delayed(const Duration(seconds: 5), () {
      // eliminamos la cuenta de la memoria en ejecucion de la app
      homeController.accountChange(idAccount: ''); 
    });

  }

  // -------------------------------------- //
  // -------------  OVERRIDE -------------- //
  // -------------------------------------- //
  @override
  void onInit() async { 
    // obtenemos los datos del controlador principal
    verifyAccount();

    super.onInit();
  }

  @override
  void onClose() { 
    super.onClose();
  }

}
