import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/presentation/splash/controllers/splash_controller.dart';
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
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext buildContext) {

    //  var 
    Color color = Get.theme.brightness == Brightness.dark?Get.theme.scaffoldBackgroundColor:Colors.white;


    return GetBuilder<MultiUserController>(
      init: MultiUserController(),
      initState: (_) {},
      builder: (controller) {

        return Scaffold(
          backgroundColor: color,
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
                color: homeController.getIsSubscribedPremium?homeController.getDarkMode?Colors.white:Colors.black:Colors.amber,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Icon(Icons.add,color:  homeController.getDarkMode?Colors.black:Colors.white,)),
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

    return ListTile(
      contentPadding:  const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
      title: Text(user.email),
      subtitle: Text( user.superAdmin ? 'Super administrador' : user.admin ? 'Administrador':'Estandar'),
      onLongPress: () => controller.deleteItem(user: user),
      onTap: null,
    );
  }

}
