
import 'dart:async'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
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

  // crear nuevo usaurio
  void createNewUser({required UserModel user}) { 

    // set : values
    user.email;
    // Firebase : refencia de la base de datos 
    var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc( homeController.getIdAccountSelected );
    var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ).doc(user.email);
    // Firebase : agrega o actualiza el documento en la coleccion de usuarios en la cuenta
    refFirestoreAccountsUsersList.set(user.toJson());
    // Firebase : agrega o actualiza el documento en la coleccion de cuentas administradas del usuario
    refFirestoreUserAccountsList.set(Map<String, dynamic>.from(user.toJson()));
  }
  void updateUser({required UserModel user}) {
    // Firebase reference: lista de cuenta administradas por el usuario
    var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc( homeController.getIdAccountSelected );
    // Firebase reference: lista de usuarios administradores de la cuenta
    var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ).doc(user.email);
    // Firebase :  actualiza el documento en la coleccion de usuarios en la cuenta
    refFirestoreAccountsUsersList.update(user.toJson());
    // Firebase :  actualiza el documento en la coleccion de cuentas administradas del usuario
    refFirestoreUserAccountsList.update(Map<String, dynamic>.from(user.toJson()));
  }



  // WIDGETS DIALOG
  void editItem({required UserModel user}) {
    dialogUserAdmin( user: user );
  }
  void addItem() { 

    dialogUserAdmin(user: UserModel(creation:Timestamp.now(),lastUpdate:Timestamp.now()) );
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

              // Firebase : referencias de la base de datos
              var refFirestoreUserAccountsList = Database.refFirestoreUserAccountsList(email: user.email).doc( homeController.getIdAccountSelected );
              var refFirestoreAccountsUsersList = Database.refFirestoreAccountsUsersList(idAccount: homeController.getIdAccountSelected ) .doc(user.email);

              // firebase : se elimina el documento de la lista de usuarios administradores de la cuenta
              refFirestoreUserAccountsList.delete();
              // firebase : se elimina el documento de la lista de cuentas administradas por el usuario
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
enum DayOfWeek {monday,tuesday,wednesday,thursday,friday,saturday,sunday}
// ignore: must_be_immutable
class UserAdminAlertDialog extends StatefulWidget {
  UserModel user = UserModel(creation:Timestamp.now(),lastUpdate:Timestamp.now());
  UserAdminAlertDialog({Key? key,required this.user}) : super(key: key);

  @override
  State<UserAdminAlertDialog> createState() => _UserAdminAlertDialogState();
}

class _UserAdminAlertDialogState extends State<UserAdminAlertDialog> {

  // controllers
  final HomeController homeController = Get.find();
  final MultiUserController multiUserController = Get.find();
  final TextEditingController _nameTextFieldController = TextEditingController();
  final TextEditingController _emailTextFieldController = TextEditingController();

  

  // var  
  bool newUser = true;
  bool enableEmailTextField = true; 
  // widgets
  late Widget divider;
  // style  
  late Color textDescriptionStyleColor ;
  late  TextStyle valueTextStyle ; 

  // setters
  Set<DayOfWeek> daysOfWeekFilter = <DayOfWeek>{}.toSet();

  void setAdmin(){
    setState(() { 
      widget.user.admin = true;
      widget.user.personalized = false; 
      // ...
      widget.user.arqueo = true;
      widget.user.historyArqueo = true;
      widget.user.catalogue = true;
      widget.user.transactions = true; 
      widget.user.multiuser = true;
      widget.user.editAccount = true;
    });
  }
  void setPersonalized(){ 
    if(widget.user.arqueo && widget.user.historyArqueo && widget.user.catalogue && widget.user.transactions && widget.user.multiuser && widget.user.editAccount){
      // si todos los permisos estan activados
      widget.user.admin = true;
      widget.user.personalized = false; 
    }else{
      // si algun permiso esta desactivado
      widget.user.admin = false;
      widget.user.personalized = true; 
    }
  }
  String translateDay({required String day}){
    // devuelve el dia de la semana en español
    switch (day) {
      case 'monday':
        return 'Lunes';
      case 'tuesday':
        return 'Martes';
      case 'wednesday':
        return 'Miércoles';
      case 'thursday':
        return 'Jueves';
      case 'friday':
        return 'Viernes';
      case 'saturday':
        return 'Sábado';
      case 'sunday':
        return 'Domingo';
      default:
        return '';
    }
  }
  // void: seteamos los dias de la semana
  void setDaysOfWeek({required List days}){ 
    for (var day in days) {
      switch (day) {
        case 'monday':
          daysOfWeekFilter.add(DayOfWeek.monday);
          break;
        case 'tuesday':
          daysOfWeekFilter.add(DayOfWeek.tuesday);
          break;
        case 'wednesday':
          daysOfWeekFilter.add(DayOfWeek.wednesday);
          break;
        case 'thursday':
          daysOfWeekFilter.add(DayOfWeek.thursday);
          break;
        case 'friday':
          daysOfWeekFilter.add(DayOfWeek.friday);
          break;
        case 'saturday':
          daysOfWeekFilter.add(DayOfWeek.saturday);
          break;
        case 'sunday':
          daysOfWeekFilter.add(DayOfWeek.sunday);
          break;
        default:
      }
    }
  }

  @override
  void initState() { 
    super.initState();

    if(widget.user.email.isNotEmpty){
      newUser = false; // no es un nuevo usuario
      _emailTextFieldController.text = widget.user.email; // seteamos el email del usuario
      _nameTextFieldController.text = widget.user.name; // seteamos el nombre del usuario
      enableEmailTextField = false; // deshabilitamos el campo de texto 
      setDaysOfWeek(days: widget.user.daysOfWeek ); // seteamos los dias de la semana
    }
  }
  

  @override
  Widget build(BuildContext context) { 

    // widgets
    divider = ComponentApp().divider();
    // style  
    textDescriptionStyleColor = Get.isDarkMode?Colors.white:Colors.black ;
    valueTextStyle= TextStyle(height:2,color: textDescriptionStyleColor);  
    // var : true si es su perfil y si es super administrador
    bool editSuperAdmin = widget.user.email == homeController.getProfileAdminUser.email && widget.user.superAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text( newUser?'Nuevo usuario':'Actualizar usuario',
        textAlign: TextAlign.center), 
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.close),
          ),
        ],
        ),

      body: Stack(
        fit:  StackFit.expand,
        children: [
          ListView( 
            physics: const BouncingScrollPhysics(),
            children: [
              // view : datos del usuario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height:20),
                    // textfield : nombre
                    TextField( 
                      style: valueTextStyle,
                      controller: _nameTextFieldController,
                      decoration: const InputDecoration(labelText: "Nombre (opcional))" ),
                      onChanged: (value) {
                        widget.user.name = value;
                      },
                    ),
                    const SizedBox(height:12),
                    // textfield : email
                    TextField( 
                      style: valueTextStyle,
                      enabled: enableEmailTextField,
                      controller: _emailTextFieldController,
                      decoration: InputDecoration(labelText: "Email",filled: enableEmailTextField ),
                      onChanged: (value) {
                        widget.user.email = value;
                      },
                    ),
                    
                  ],
                ),
              ), 
              const SizedBox(height:12),
              // CheckboxListTile : opcipn de inactivar el usuario
              widget.user.superAdmin?Container():CheckboxListTile(  
                enabled: !widget.user.superAdmin,
                title:const Text('Inactivar usuario'),
                subtitle: const Opacity(opacity: 0.5,child: Text('Permite bloquear el usuario')),
                value: widget.user.inactivate, 
                onChanged: (value){ 
                  setState(() {
                    widget.user.inactivate = value!;
                  });
                },
              ),
              widget.user.superAdmin?Container():const Divider(thickness:0.5,height: 0), 
              widget.user.superAdmin?Container():accessView,
              widget.user.superAdmin?Container():const Divider(thickness:0.5,height: 0), 
              permissView, 
              const SizedBox(height: 120),
            ],
          ),
          // elevateButton : crear o actualizar
          //
          // Positioned : para posicionar el boton en la parte inferior de la pantalla
          Positioned(
            bottom: 0,left: 0,right: 0,
            child: Container(   
              // color : gradient de un color y transparent 
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent,Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),Theme.of(context).scaffoldBackgroundColor], begin: Alignment.topCenter,end: Alignment.bottomCenter),),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // button : crear o actualizar
                    ComponentApp().button( 
                      text: newUser?'Crear usuario':'Actualizar',
                      colorButton: homeController.getIsSubscribedPremium || editSuperAdmin ?Colors.blue:Colors.amber,
                      colorAccent: Colors.white,
                      onPressed: (){ 
                        // condition : comprueba si la cuenta tiene una suscripción premium y no es el superusaurio editando su propio perfil
                        if(homeController.getIsSubscribedPremium==false && !editSuperAdmin){
                          // no es premium
                          Get.back();
                          homeController.showModalBottomSheetSubcription(id: 'multiuser');
                          return;
                        }
                        // condition : si es [superAdmin] se le asignan todos los permisos sin restricciones
                        if(widget.user.superAdmin){
                          // si es super administrador le asignamos todos los permisos sin restricciones
                          widget.user.daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
                          widget.user.startTime = {'hour':0, 'minute': 0};
                          widget.user.endTime = {'hour':23, 'minute': 59}; 
                          daysOfWeekFilter = DayOfWeek.values.toSet();
                          // permisos
                          widget.user.arqueo = true;
                          widget.user.historyArqueo = true;
                          widget.user.catalogue = true;
                          widget.user.transactions = true;
                          widget.user.multiuser = true;
                          widget.user.editAccount = true;
                          widget.user.admin = true; 
                        }else{
                          widget.user.daysOfWeek = daysOfWeekFilter.map((day) => day.toString().toLowerCase().replaceAll(' ', '').split('.').last).toList();
                        }
                        // condition : valida el email
                        if(!EmailValidator.validate(widget.user.email) ){ 
                          Get.snackbar('E-mail invalido','Debe proporcionar un correo electrónico válido, asegúrese de que no contenga espacios vacios');
                          return;
                        }
                        // verificamos que el email no exista en la lista de usuarios existentes 
                        if(newUser){
                          for (var user in multiUserController.getUsersList) {
                            if(user.email == widget.user.email){
                              Get.snackbar('Email invalido','El email ya existe en la lista de usuarios');
                              return; // detenemos el proceso
                            }
                          }
                        } 
                        // condition : validar que se haya seleccionado al menos un dia de la semana
                        if(widget.user.daysOfWeek.isEmpty){
                          Get.snackbar('Dias de la semana','Debes seleccionar al menos un dia de la semana');
                          return;
                        }
                        // condition : valida el horario de acceso
                        if(widget.user.getAccessTimeFormat.isNotEmpty ){ 
                          // condition : nos aseguramos que se haya seleccionado un tipo de permiso
                          if( widget.user.admin==true || widget.user.personalized==true){ 

                            // condition : si es un nuevo usuario o se esta actualizando
                            if(newUser){
                              widget.user.account = homeController.getIdAccountSelected; // seteamos el id de la cuenta
                              widget.user.creation = Timestamp.now(); // seteamos la fecha de creacion 
                              widget.user.lastUpdate = Timestamp.now(); // seteamos la fecha de actualizacion 
                              // creamos un nuevo usuario
                              multiUserController.createNewUser(user: widget.user.copyWith());
                            }else{ 
                              widget.user.lastUpdate = Timestamp.now(); // seteamos la fecha de actualizacion 
                              // actualizamos el usuario
                              multiUserController.updateUser(user: widget.user.copyWith());
                            }
                            
                            Get.back();
                          }else{
                            Get.snackbar('Permiso del usuario','Elige qué tipo de permisos tiene este usuario');
                          }
                        }else{
                          Get.snackbar('Horario de acceso invalido','Debes seleccionar un rango de horario de acceso');
                        }
                        }, 
                    ), 
                    // text : fecha de creacion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Opacity(opacity: 0.5,child: Text('Creado ${Publications.getFechaPublicacion(fechaPublicacion: widget.user.creation.toDate(),fechaActual: Timestamp.now().toDate()) }')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ), 
    );
  }

  // WIDGETS VIEWS
  Widget get accessView{
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
          child: Opacity(opacity: 0.7,child: Text('Acceso',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w700))),
        ),
        // view : seleccionar dias de la semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap( 
            alignment: WrapAlignment.start,
            spacing: 3.0,
            children: DayOfWeek.values.map((day) {
              return FilterChip(
                label: Text(translateDay(day:day.toString().split('.').last)),
                selected: daysOfWeekFilter.contains(day),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      daysOfWeekFilter.add(day);
                    } else {
                      daysOfWeekFilter.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        // ListTile : seleccionar rango de horario de acceso
        widget.user.superAdmin?Container():ListTile(
          leading: const Icon(Icons.access_time_rounded),
          title:const Text('Horario de acceso'),
          subtitle: Text((widget.user.startTime.isEmpty && widget.user.endTime.isEmpty )?'Selecciona el rango de horario en el que el usuario puede acceder a la cuenta':'Inicio: ${widget.user.getAccessTimeFormat} '),
          trailing:const Icon(Icons.arrow_right),
          onTap: () async{
            // Primera invocación para seleccionar la hora de inicio
            TimeOfDay? startTime = await showTimePicker( 
              context: context,
              initialTime: TimeOfDay.now(), 
              helpText: 'Selecciona la hora de inicio', 
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );

            // Segunda invocación para seleccionar la hora de finalización
            TimeOfDay? endTime = await showTimePicker(
              // ignore: use_build_context_synchronously
              context: context,  
              initialTime: const TimeOfDay(hour: 0, minute: 0),  
              helpText: 'Hora de finalización',
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true,),
                  child: child!,
                );
              },
            );
            // condition : si se selecciono un rango de horario correcto
            if(startTime!=null && endTime!=null && startTime.hour<endTime.hour){
              setState(() {
                // obtenemos los datos en formato de 24 horas
                widget.user.startTime = {'hour':startTime.hour,'minute':startTime.minute};
                widget.user.endTime = {'hour':endTime.hour,'minute':endTime.minute};
                // message 
                Get.snackbar('Horario de acceso definido exitosamente', 'Inicio: ${widget.user.startTime['hour']}:${widget.user.startTime['minute']} - Fin: ${widget.user.endTime['hour']}:${widget.user.endTime['minute'] } ');
            });
            }else{
              Get.snackbar('Horario de acceso','Debes seleccionar un rango de horario');
            } 
          },
        ), 
      ],
    );
  }
  Widget get permissView{
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
          child: Opacity(opacity: 0.7,child: Text('Permisos',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w700))),
        ),
        // view : butones de categorias de permisos 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ 
              // button : permiso administrador
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton.icon(
                  style: ButtonStyle(elevation:WidgetStateProperty.all(widget.user.admin? 5: 0)),
                  icon: widget.user.admin? const Icon(Icons.check_circle_rounded) : Container(),
                  onPressed: setAdmin,
                  label: Text(widget.user.superAdmin?'Super administrador':'Administrador'),
                ),
              ),
              // button : permiso personalizados 
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton.icon(
                  
                  style: ButtonStyle(elevation:WidgetStateProperty.all(widget.user.personalized? 5: 0)),
                  icon: widget.user.personalized? const Icon(Icons.check_circle_rounded) : Container(),
                  onPressed: widget.user.superAdmin?null: () { 
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
        ), 
        // checkbox : arqueo
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
          title:const Text('Arqueo de caja'),
          subtitle: const Opacity(opacity: 0.5,child: Text('Permite crear y cerrar arqueos de caja')),
          value: widget.user.arqueo, 
          onChanged: (value){
            setState(() { 
              widget.user.arqueo=value!; 
              setPersonalized();
            });
          }, 
        ),
        divider,
        // checkbox : historial de arqueos
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
          title:const Text('Historial de arqueos'),
          subtitle: const Opacity(opacity: 0.5,child: Text('Permite ver y eliminar registros de arqueos')),
          value: widget.user.historyArqueo, 
          onChanged: (value){
            setState(() {
              widget.user.historyArqueo=value!; 
              setPersonalized();
            });
          },
        ),
        divider,
        // checkbox : transacciones
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
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
        divider,
        // checkbox : catalogo
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
          title:const Text('Catálogo'),
          subtitle: const Opacity(opacity: 0.5,child: Text('Permite registrar, editar y eliminar productos')),
          value: widget.user.catalogue, 
          onChanged: (value){
            setState(() {
              widget.user.catalogue=value!; 
              setPersonalized();
            });
          },
        ),
        divider,
        // checkbox : multiusuario
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
          title:const Text('Multiusuario'),
          subtitle: const Opacity(opacity: 0.5,child: Text('Permite crear, modificar y eliminar usuarios')),
          value: widget.user.multiuser, 
          onChanged: (value){
            setState(() {
              widget.user.multiuser=value!; 
              setPersonalized();
            });
          },
        ),
        divider,
        // checkbox : editar cuenta
        CheckboxListTile(
          enabled: !widget.user.superAdmin,
          title:const Text('Editar cuenta'),
          subtitle: const Opacity(opacity: 0.5,child: Text('Permite editar o eliminar datos  de la cuenta')),
          value: widget.user.editAccount, 
          onChanged: (value){
            setState(() {
              widget.user.editAccount=value!; 
              setPersonalized();
            });
          },
        ), 
      ],
    );
  }
}
