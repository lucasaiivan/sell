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
          appBar: appbar(context: context),
          drawer: drawerApp(),
          body: body,
        );
      },
    );
  }

  // WIDGETS MAIN
  PreferredSizeWidget appbar({required BuildContext context}){

    // controllers
    final MultiUserController controller = Get.find();
    final HomeController homeController = Get.find();
 

    return AppBar(
      title: const Text('Multiusuario'),
      actions: [
        // Opcion Premium // 
        // icon : agregar nuevo usuario administrador para la cuenta
        ComponentApp().buttonAppbar(
          context: context,
          padding:  const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
          text: 'Crear',
          iconTrailing: Icons.add, 
          colorAccent: homeController.getIsSubscribedPremium?null:Colors.white,
          colorBackground: homeController.getIsSubscribedPremium?null:Colors.amber,
          onTap: (){
            // condition :  si la cuenta tiene un subcripcion premium
            if(homeController.getIsSubscribedPremium){
              homeController.getUserAnonymous?null:controller.addItem();
            }else{
              homeController.showModalBottomSheetSubcription(id: 'multiuser');
            }
          },
        ), 
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
          leading:  ComponentApp().userAvatarCircle(iconData: user.superAdmin?Icons.security_rounded:user.admin?Icons.admin_panel_settings_outlined:null),
          title: Text(user.name==''?user.email:user.name,maxLines:1,overflow:TextOverflow.clip,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500)),
          subtitle: Opacity(opacity: 0.5,child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // text : email
              user.name==''?Container():Text(user.email),Text( user.superAdmin ? 'Super administrador' : user.admin ? 'Administrador':'Permisos personalizado' ),
              // text : fecha de fecha de actualización 
              Text('Actualizado ${Publications.getFechaPublicacion(fechaActual: user.lastUpdate.toDate(),fechaPublicacion: Timestamp.now().toDate()) }'),
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
