import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/presentation/splash/controllers/splash_controller.dart';
import '../../../core/utils/fuctions.dart';
import '../../../domain/entities/user_model.dart';
import '../../../core/utils/widgets_utils.dart';
import '../controllers/multiuser_controller.dart';

class MultiUser extends GetView<SplashController> {
  // ignore: prefer_const_constructors_in_immutables
  MultiUser({super.key});

  @override
  // ignore: prefer_const_constructors
  Widget build(BuildContext context) => LoadingInitView();
}

class LoadingInitView extends StatelessWidget {
  const LoadingInitView({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context) { 

    return GetBuilder<MultiUserController>(
      init: MultiUserController(),
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(MultiUserController());
      },
      builder: (controller) {

        return Scaffold( 
          appBar: appbar,
          drawer: drawerApp(),
          body: body,
        );
      },
    );
  }

  // WIDGETS MAIN
  PreferredSizeWidget get appbar{

    // controllers
    final MultiUserController controller = Get.find();
    final HomeController homeController = Get.find();

    // var
    final bool darkTheme = Get.isDarkMode;

    // style 
    Color iconColor =  homeController.getIsSubscribedPremium==false?Colors.amber: darkTheme?Colors.white:Colors.black;
    Color textColor = darkTheme == false || homeController.getIsSubscribedPremium==false?Colors.white:Colors.black;
   

    return AppBar(
      title: const Text('Multiusuario'),
      actions: [
        // Opcion Premium // 
        // icon : agregar nuevo usuario administrador para la cuenta
        IconButton(
          onPressed: (){
            // condition :  si la cuenta tiene un subcripcion premium
            if(homeController.getIsSubscribedPremium){
              homeController.getUserAnonymous?null:controller.addItem();
            }else{
              homeController.showModalBottomSheetSubcription(id: 'multiuser');
            }
          },  
          icon:  Opacity(
            opacity: homeController.getUserAnonymous?0.1:1,
            child: Material(
                color:iconColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8),
                  child: Row(
                    children: [
                      Text('Crear',style:TextStyle(color: textColor,fontWeight: FontWeight.w700)),
                      Icon(Icons.add,color:textColor),
                    ],
                  ),
                )),
          )),
      ],
    );
  }
  Widget get body{

    // controllers
    final MultiUserController controller = Get.find();

    if(controller.homeController.getFirebaseAuth.currentUser!.isAnonymous){ return const Center(child: Text('Debes iniciar sesión para para ver esta sección'));}
    if(controller.getUsersList.isEmpty ){ return const  Center(child: CircularProgressIndicator());}

    return ListView.builder(
      itemCount: controller.getUsersList.length,
      itemBuilder: (context, index) => listTile( user: controller.getUsersList[index] ),
    );
  }

  // WIDGETS COMPONENTS
  Widget listTile ({required UserModel user}){

    // controllers 
    final MultiUserController controller = Get.find();  

    return Column(
      children: [
        ListTile( 
          contentPadding:  const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
          leading:  ComponentApp().userAvatarCircle(),
          title: Text(user.name==''?user.email:user.name,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500)),
          subtitle: Opacity(opacity: 0.5,child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // text : email
              user.name==''?Container():Text(user.email),Text( user.superAdmin ? 'Super administrador' : user.admin ? 'Administrador':'Permisos personalizado' ),
              // text : fecha de fecha de actualización 
              Text('Actualizado ${Publications.getFechaPublicacion(fechaActual: user.creation.toDate(),fechaPublicacion: Timestamp.now().toDate()) }'),
            ],
          )),
          onLongPress: () => controller.deleteItem(user: user),
          onTap: () => controller.editItem(user: user.copyWith()),
          trailing: user.superAdmin?null:IconButton(onPressed: () => controller.deleteItem(user: user),icon: const Icon(Icons.close)),
        ),
        ComponentApp().divider(),
      ],
    );
  }

}
