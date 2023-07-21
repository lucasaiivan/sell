
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
  List<UserModel> get getUsersList => usersAdminsList;
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
  void editItem({required UserModel user}) {
    if(user.superAdmin){
      Get.snackbar('Super administrador','No se puede editar');
    }else{
      dialogUserAdmin( user: user );
    } 
  }
  void addItem() { 

    dialogUserAdmin(user: UserModel() );
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
  
  // dialog : crear nuevo o editar usuario administrador
  void dialogUserAdmin({required UserModel user}) {
    Widget content = UserAdminAlertDialog(user: user );
    
    // creamos un dialog con GetX
    Get.dialog(
      ClipRRect(
        borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: content,
      ),
    ); 
  }
  
}

// ignore: must_be_immutable
class UserAdminAlertDialog extends StatefulWidget {
  UserModel user = UserModel();
  UserAdminAlertDialog({Key? key,required this.user}) : super(key: key);

  @override
  State<UserAdminAlertDialog> createState() => _UserAdminAlertDialogState();
}

class _UserAdminAlertDialogState extends State<UserAdminAlertDialog> {

  // controllers
  final HomeController homeController = Get.find();
  final MultiUserController controller = Get.find();
  final TextEditingController _textFieldController = TextEditingController();

  // var  
  bool newUser = true;
  bool enableEmailTextField = true; 

  void setAdmin(){
    setState(() { 
      widget.user.admin = true;
      widget.user.personalized = false; 
      widget.user.arqueo = true;
      widget.user.historyArqueo = true;
      widget.user.catalogue = true;
      widget.user.transactions = true; 
      widget.user.multiuser = true;
      widget.user.editAccount = true;
    });
  }
  void setPersonalized(){
    widget.user.admin = false;
    widget.user.personalized = true; 
  }

  @override
  void initState() { 
    super.initState();

    if(widget.user.email.isNotEmpty){
      newUser = false; // no es un nuevo usuario
      _textFieldController.text = widget.user.email; // seteamos el email del usuario
      enableEmailTextField = false; // deshabilitamos el campo de texto
     

    }
  }

  @override
  Widget build(BuildContext context) { 

    return Scaffold(
      appBar: AppBar(
        title: Text( newUser?'Nuevo usuario':'Actualizar usuario',
        textAlign: TextAlign.center),
        automaticallyImplyLeading: false,// desabilitamos el boton de regresar
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.close),
          ),
        ],
        ),

      body: Column(
        children: [
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView( 
                children: [

                  TextField(
                    enabled: enableEmailTextField,
                    controller: _textFieldController,
                    decoration: const InputDecoration(hintText: "Email"),
                    onChanged: (value) {
                      widget.user.email = value;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top:20),
                    child: Opacity(opacity: 0.7,child: Text('Permisos')),
                  ),
                  // view : butones de categorias de permisos 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [ 
                      // button : permiso administrador
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ElevatedButton.icon(
                          style: ButtonStyle(elevation:MaterialStateProperty.all(widget.user.admin? 5: 0)),
                          icon: widget.user.admin? const Icon(Icons.check_circle_rounded) : Container(),
                          onPressed: setAdmin,
                          label: const Text('Administrador'),
                        ),
                      ),
                      // button : permiso personalizados 
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ElevatedButton.icon(
                          style: ButtonStyle(elevation:MaterialStateProperty.all(widget.user.personalized? 5: 0)),
                          icon: widget.user.personalized? const Icon(Icons.check_circle_rounded) : Container(),
                          onPressed: () { 
                            setState(() {
                              widget.user.personalized = !widget.user.personalized;
                              widget.user.admin = false;
                            }); 
                          },
                          label: const Text('Personalizado'),
                        ),
                      ),
                    ],
                  ), 
                  // checkbox : arqueo
                  CheckboxListTile(
                    title:const Text('arqueo de caja'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite crear y cerrar arqueos de caja')),
                    value: widget.user.arqueo, 
                    onChanged: (value){
                      setState(() {
                        widget.user.arqueo=value!; 
                        setPersonalized();
                      });
                    },
                  ),
                  // checkbox : historial de arqueos
                  CheckboxListTile(
                    title:const Text('historial de arqueos'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite ver y eliminar registros de arqueos')),
                    value: widget.user.historyArqueo, 
                    onChanged: (value){
                      setState(() {
                        widget.user.historyArqueo=value!; 
                        setPersonalized();
                      });
                    },
                  ),
                  // checkbox : transacciones
                  CheckboxListTile(
                    title:const Text('Transacciones de ventas'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite ver y eliminar registros de ventas')),
                    value: widget.user.transactions, 
                    onChanged: (value){
                      setState(() {
                        widget.user.transactions=value!; 
                        setPersonalized();
                      });
                    },
                  ),
                  // checkbox : catalogo
                  CheckboxListTile(
                    title:const Text('Catalogo'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite ver y eliminar productos')),
                    value: widget.user.catalogue, 
                    onChanged: (value){
                      setState(() {
                        widget.user.catalogue=value!; 
                        setPersonalized();
                      });
                    },
                  ),
                  // checkbox : multiusuario
                  CheckboxListTile(
                    title:const Text('Multiusuario'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite crear y eliminar usuarios')),
                    value: widget.user.multiuser, 
                    onChanged: (value){
                      setState(() {
                        widget.user.multiuser=value!; 
                        setPersonalized();
                      });
                    },
                  ),
                  // checkbox : editar cuenta
                  CheckboxListTile(
                    title:const Text('Editar cuenta'),
                    subtitle: const Opacity(opacity: 0.5,child: Text('Permite editar la cuenta')),
                    value: widget.user.editAccount, 
                    onChanged: (value){
                      setState(() {
                        widget.user.editAccount=value!; 
                        setPersonalized();
                      });
                    },
                  ),


                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: Get.back,child: const Text('Cancelar')),
              TextButton(
                  onPressed: () { 

                    if(EmailValidator.validate(widget.user.email) ){

                      // verificamos que el email no exista en la lista de usuarios existentes 
                      for (var user in controller.getUsersList) {
                        if(user.email == widget.user.email){
                          Get.snackbar('Email invalido','El email ya existe en la lista de usuarios');
                          return; // detenemos el proceso
                        }
                      }


                      if( widget.user.admin==true || widget.user.personalized==true){ 

                        // set 
                        widget.user.account = homeController.getIdAccountSelected; // seteamos el id de la cuenta

                        // Firebase : ref 
                        var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: widget.user.email).doc( homeController.getIdAccountSelected );
                        var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ).doc(widget.user.email);
                        // Firebase : agrega o actualiza el documento en la coleccion de usuarios en la cuenta
                        refFirestoreAccountsUsersList.set(widget.user.toJson(),SetOptions(merge: true));
                        // Firebase : agrega o actualiza el documento en la coleccion de cuentas administradas del usuario
                        refFirestoreUserAccountsList.set(Map<String, dynamic>.from(widget.user.toJson()),SetOptions(merge: true));

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
                  child: Text( newUser?'Crear usuario':'Actualizar')),
            ],
          ),
        ],
      ), 
    );
  }
}
