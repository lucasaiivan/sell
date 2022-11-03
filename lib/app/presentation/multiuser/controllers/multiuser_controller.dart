
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/user_model.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../home/controller/home_controller.dart';

// Controlador: administrador de usuarios
// proveedores: HomeController
// manejador de estados: GetX

class MultiUserController extends GetxController {

  // controllers
  final HomeController homeController = Get.find();
  late final Timer _periodicTimer;


  // usuarios que administran la cuenta
  final RxList<UserModel> usersAdminsList = <UserModel>[].obs;
  List<UserModel> get getUsersList => usersAdminsList.value;
  set setUsersList( List<UserModel> value) => usersAdminsList.value= value;

  @override
  void onInit() {
    super.onInit();

    _periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setUsersList = homeController.getAdminsUsersList;
        update();
      },
    );
  }

  @override
  void onClose() { 
    _periodicTimer.cancel();
  }



  // WIDGETS DIALOG
  void addItem() { 

    Get.dialog(AddAlertDialog());
  }
  void deleteItem({required UserModel user}) {
    Widget widget = AlertDialog(
      title: const Text('¿Seguro que quieres eliminar este usuario?',textAlign: TextAlign.center),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        TextButton(onPressed: Get.back,child: const Text('Cancelar')),
        TextButton(
            onPressed: () {

              // Firebase : ref 
              var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc( homeController.getIdAccountSelected );
              var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ) .doc(user.email);

              // Firebase : delete
              refFirestoreUserAccountsList.delete();
              refFirestoreAccountsUsersList.delete();

              Get.back();
            },
            child: const Text('si, eliminar')),
      ]),
    );

    if(user.superAdmin){
      Get.snackbar('Super administrador','No se puede elmininar');
    }else{
      Get.dialog(widget);
    }
  }
  
}

class AddAlertDialog extends StatefulWidget {
  AddAlertDialog({Key? key}) : super(key: key);

  @override
  State<AddAlertDialog> createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends State<AddAlertDialog> {

  // controllers
  final HomeController homeController = Get.find();
  final MultiUserController controller = Get.find();
  final TextEditingController _textFieldController = TextEditingController();

  // var
  bool? admin = false;
  bool? standar = false;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text('Nuevo usuario',textAlign: TextAlign.center),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Email"),
          ),
          const Padding(
            padding: EdgeInsets.only(top:40),
            child: Text('Permisos del usuario'),
          ),
          CheckboxListTile(title:const Text('Administrador'),value: admin, onChanged: (value){setState(() {
            admin=value;
            if(admin==true){standar=false;}
          });}),
          CheckboxListTile(title:const Text('Estandar'),value: standar, onChanged: (value){setState(() {
            standar=value;
            if(standar==true){admin=false;}
          });}),
        ],
      ),

      actions: [
        TextButton(onPressed: Get.back,child: const Text('Cancelar')),
        TextButton(
            onPressed: () {

              if(EmailValidator.validate(_textFieldController.text) ){
                if( admin==true || standar==true){

                  // create user 
                  UserModel user = UserModel(email: _textFieldController.text , admin: admin==true);

                  // Firebase : ref 
                  var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc( homeController.getIdAccountSelected );
                  var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ) .doc(user.email);
                  // Firebase : set doc
                  refFirestoreAccountsUsersList.set(user.toJson(),SetOptions(merge: true));
                  refFirestoreUserAccountsList.set(Map<String, dynamic>.from({'id': homeController.getIdAccountSelected ,'superAdmin':user.admin}),SetOptions(merge: true));

                  Get.back();
                }else{
                  Get.snackbar('Permiso del usuario','Elige qué tipo de permisos tiene este usuario');
                }
              }else{
                Get.snackbar('E-mail invalido','Debe proporcionar un correo electrónico válido, asegúrese de que no contenga espacios vacios');
              }

              // Firebase : delete
              //Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected).doc(user.email).delete();
              //Get.back();
            },
            child: const Text('Crear usuario')),
      ],
    );
  }
}
