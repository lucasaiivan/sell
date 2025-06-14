import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sell/app/presentation/account/controller/account_controller.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';



class AccountView extends GetView<AccountController> {
  // VAriables

  final FocusNode focusTextEdiNombre = FocusNode();

  AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return scaffold(buildContext: context);
  }

  Widget scaffold({required BuildContext buildContext}) {
    return GetBuilder<AccountController>(
        id: 'load',
        builder: (_) {
          return Scaffold(
            appBar: appBar(context: buildContext),
            body: body(buildContext: buildContext),
          );
        });
  }
  // ------------ //
  // WIDGET VIEW  //
  // ------------ //
  PreferredSizeWidget appBar({required BuildContext context}) {
    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
      title: Text(controller.newAccount ? 'Perfil de mi negocio' : 'Perfil',
          style: TextStyle(fontSize: 18.0,color: Theme.of(context).textTheme.bodyLarge!.color)),
      actions: <Widget>[ 
        // icon : guardar
        IconButton(
          icon: controller.getSavingIndicator
              ? Container()
              : const Icon(Icons.check_sharp),
          onPressed: controller.saveAccount,
        )
      ],
      bottom: controller.getSavingIndicator ? linearProgressBarApp() : null,
    );
  }

  Widget body({required BuildContext buildContext}) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // container : fondo
        ListView(
          padding: const EdgeInsets.all(12.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Column(
              children: <Widget>[
                const SizedBox(height: 12.0),
                // text : informativo
                controller.newAccount?widgetText(text: 'Dinos un poco de tu negocio\n 👇'): Container(),
                // imagen : avatar del negocio
                widgetsImagen(),
                // button  : actualizart imagen
                controller.getSavingIndicator
                    ? Container()
                    : Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextButton(
                          onPressed: () {
                            if (controller.getSavingIndicator == false) {showModalBottomSheetCambiarImagen();}
                          },
                          child: const Text("actualizar imagen")
                        ),
                    ),
                // TextFuield views
                widgetFormEditText(context: buildContext),
              ],
            ),
          ],
        ),
        // container : fondo cuando se muestra el indicador de progreso
        controller.getSavingIndicator ? Container(color: Colors.black26) : Container()
      ],
    
    );
  }

 
  void showModalBottomSheetCambiarImagen() {
    Widget widget =   Wrap(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.only(top: 12,left: 12,right: 12),
          leading: const Icon(Icons.camera),
          title: const Text('Capturar una imagen'),
          onTap: () {
            Get.back();
            controller.setImageSource(imageSource: ImageSource.camera);
            
          }),
        ListTile(
          contentPadding: const EdgeInsets.only(top: 12,left: 12,right: 12,bottom: 20),
          leading: const Icon(Icons.image),
          title: const Text('Galería de fotos'),
          onTap: () {
            Get.back();
            controller.setImageSource(imageSource: ImageSource.gallery);
          },
        ),
      ],
    );
    // muestre la hoja inferior modal de getx
    Get.bottomSheet( 
      widget,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }

  Widget widgetText({required String text}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
          child: ElasticIn(
        child: Text(text,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )),
    );
  }

  Widget widgetsImagen() {
    // values
    Color colorDefault = Colors.grey.withOpacity(0.2);
    double radius = 45.0;
    // obtener la incial del nombre del negocio si existe el dato
    String initial = controller.profileAccount.name.isNotEmpty ? controller.profileAccount.name[0].toUpperCase() : '';
    // widget
    Widget circleAvatarDefault = CircleAvatar(
      backgroundColor: colorDefault,
      radius: radius,
      child: Opacity(opacity: 0.7,child: Text(initial,style: const TextStyle(fontSize: 30,color: Colors.white))),
    );

    return GetBuilder<AccountController>(
      id: 'image',
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              controller.getImageUpdate == false
                  ? controller.profileAccount.image == ''
                      ? circleAvatarDefault
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: controller.profileAccount.image == '' ? 'default' : controller.profileAccount.image,
                          placeholder: (context, url) => circleAvatarDefault,
                          imageBuilder: (context, image) => CircleAvatar(backgroundImage: image,radius: radius),
                          errorWidget: (context, url, error) => circleAvatarDefault,
                        )
                  : CircleAvatar(
                      radius:radius,
                      backgroundColor: Colors.transparent,
                      backgroundImage: FileImage(File(controller.getxFile.path)),
                    )
            ],
          ),
        );
      },
    );
  }


  Widget widgetFormEditText({required BuildContext context}) {

    // widget
    const Widget divider = Divider(color: Colors.transparent, thickness: 0,height:20);

    // creamos la vista del formulario 
    return Obx(() => Form(
      key: controller.formKey,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[ 
              // textfiel: nombre del negocio
              TextFormField(
                enabled: !controller.getSavingIndicator,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline, 
                onChanged: (value){
                  controller.profileAccount.name = value;  
                },
                decoration: const InputDecoration(filled: true,labelText: "Nombre del Negocio"),
                controller:TextEditingController(text: controller.profileAccount.name),
                textInputAction: TextInputAction.next,
                focusNode: focusTextEdiNombre, 
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el nombre del negocio';
                  }
                  return null;
                },
              ), 
              divider,
              // textfiel: signo de moneda
              InkWell(
                onTap: () => _bottomPickerSelectCurrency(list: controller.coinsList, context: context),
                child: TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Simbolo de moneda",
                    filled: true,
                    prefixIcon: Opacity(opacity: 0.7,child: Icon(Icons.monetization_on_outlined)),
                  ),
                  controller: controller.getControllerTextEditSignoMoneda,
                  onChanged: (value) => controller.profileAccount.currencySign = value,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese el signo de la moneda';
                    }
                    return null;
                  },
                ),
              ),
              divider,
              // text : texto informativo
              controller.newAccount?widgetText(text: '¿Donde se encuentra?\n 🌍'): const Text("Ubicación", style: TextStyle(fontSize: 24.0)),
              divider,
              // textfiel: seleccionar un pais
              InkWell(
                onTap: () => bottomPickerSelectCountries(list: controller.getCountries, context: context),
                child: TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  enabled: false,
                  decoration: const InputDecoration(labelText: "Pais",filled: true,prefixIcon: Opacity(opacity: 0.7,child: Icon(Icons.location_on_outlined))),
                  controller: controller.getControllerTextEditPais,
                  onChanged: (value) => controller.profileAccount.country = value,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor ingrese el pais';
                    }
                    return null;
                  },
                ),
              ),
              divider,
              // textfiel: seleccionar una provincia
              InkWell(
                onTap: () => controller.profileAccount.country == ''
                    ? bottomPickerSelectCountries(list: controller.getCountries, context: context)
                    : bottomPickerSelectCities(list: controller.getCities, context: context),
                child: TextFormField(
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Provincia",
                      filled: true,
                      prefixIcon: Opacity(opacity: 0.7,child: Icon(Icons.business)),
                    ),
                    controller: controller.getControllerTextEditProvincia,
                    onChanged: (value) {
                      controller.profileAccount.province = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor ingrese la provincia';
                      }
                      return null;
                    },
                    ),
              ),
              divider,
              // textfiel: ciudad
              TextField( 
                enabled: !controller.getSavingIndicator,
                onChanged: (value) => controller.profileAccount.town = value,
                decoration: const InputDecoration(
                  labelText: "Ciudad (opcional)",
                  filled: true,
                  prefixIcon: Opacity(opacity: 0.7,child: Icon(Icons.location_searching_rounded)),
                ),
                controller: controller.getControllerTextEditTwon,
              ),
              const Divider(color: Colors.transparent, thickness: 1), 
              // text : marca de tiempo de la ultima actualización del documento
              controller.newAccount?Container():Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Opacity(opacity: 0.5,child: Center(child: Text('Te uniste ${Publications.getFechaPublicacion(fechaPublicacion: controller.profileAccount.creation.toDate(), fechaActual: Timestamp.now().toDate()).toLowerCase()}'))),
              ),
              const SizedBox(height: 50),
              // button : guardar
              controller.newAccount?controller.getSavingIndicator?Container():Center(child: TextButton(onPressed:controller.saveAccount, child: const Text('Guardar'))): Container(),
              // button : eliminar cuenta
              controller.newAccount?Container():Center(
                child: TextButton( 
                  onPressed: controller.dialogDeleteAccount,
                  child: const Text('Eliminar cuenta',style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 20),
              
            ],
          ),
    ));
  }

  void bottomPickerSelectCities(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Seleccione una provincia')),
            body: ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]),
                          onTap: () {
                            controller.getControllerTextEditProvincia.text = list[index];
                            controller.profileAccount.province = list[index];
                            Get.back();
                          },
                        )),
              ),
          );
        });
  }

  void bottomPickerSelectCountries(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Seleccione un pais')),
            body: ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]),
                          onTap: () {
                            controller.profileAccount.country = list[index];
                            controller.getControllerTextEditPais.text =list[index];
                            Get.back();
                            bottomPickerSelectCities(list: controller.getCities, context: context);
                          },
                        )),
              ),
          );
        });
  }

  void _bottomPickerSelectCurrency(
      {required List list, required BuildContext context}) async {
    //  Muestra una hoja inferior de diseño de material modal
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Simbolo monetario')),
            body: ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(
                    list.length,
                    (int index) => ListTile(
                          minVerticalPadding: 12,
                          title: Text(list[index]['code']),
                          subtitle: Text(list[index]['description']),
                          trailing: Text(list[index]['symbol'],style: const  TextStyle(fontSize: 20)),
                          onTap: () {
                            controller.profileAccount.currencySign = list[index]['symbol'];
                            controller.getControllerTextEditSignoMoneda.text =list[index]['symbol'];
                            Get.back();
                          },
                        )),
              ),
          );
        });
  }
}
