import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:sell/app/presentation/cataloguePage/views/card_create_form.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';
import '../controller/product_edit_controller.dart';

class ProductEdit extends StatelessWidget {
  ProductEdit({Key? key}) : super(key: key);

  // controllers
  final ControllerProductsEdit controller = Get.find();

  // var
  Color cardProductDetailColor = Colors.grey.withOpacity(0.05);
  Color colorLoading = Colors.blue;
  bool darkMode = false;
  final Widget space = const SizedBox(
    height: 12.0,
    width: 12.0,
  );

  @override
  Widget build(BuildContext context) {

    // get : obtenemos los valores
    colorLoading = Get.theme.primaryColor;
    darkMode = Get.isDarkMode;
    cardProductDetailColor = darkMode ? Colors.grey.withOpacity(0.06) : Colors.brown.shade100.withOpacity(0.6);


    // GetBuilder - refresh all the views
    return GetBuilder<ControllerProductsEdit>(
      id: 'updateAll',
      init: ControllerProductsEdit(),
      initState: (_) {},
      builder: (_) {
        return Material(
          child: _.getNewProduct && !_.formComplete? CardCreateForm(): OfflineBuilder(
              child: Container(),
              connectivityBuilder: (
                BuildContext context,
                ConnectivityResult connectivity,
                Widget child,
              ) {
                final connected = connectivity != ConnectivityResult.none;
        
                if (!connected) {
                  Color? colorAccent = Get.theme.textTheme.bodyMedium!.color;
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0.0,
                      backgroundColor: Get.theme.scaffoldBackgroundColor,
                      iconTheme: Theme.of(context)
                          .iconTheme
                          .copyWith(color: colorAccent),
                      title: controller.getSaveIndicator
                          ? Text(controller.getTextAppBar,style: TextStyle(fontSize: 18.0, color: colorAccent))
                          : Text('Espere por favor...',style: TextStyle(fontSize: 18.0, color: colorAccent)),
                    ),
                    body: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Icons.wifi_off_rounded),
                        ),
                        Text('No hay internet'),
                      ],
                    )),
                  );
                }
        
                return scaffold(context: context);
              }),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appBar({required BuildContext contextPrincipal}) {

    // value
    Color? colorText = Get.theme.textTheme.bodyMedium!.color;

    return AppBar(
      elevation: 0.0,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      iconTheme:
          Theme.of(contextPrincipal).iconTheme.copyWith(color: colorText),
      title: controller.getSaveIndicator
          ? Text(controller.getTextAppBar,style: TextStyle(fontSize: 18.0, color: colorText))
          : Text(controller.itsInTheCatalogue ? 'Editar' :'Nuevo',style: TextStyle(fontSize: 18.0, color: colorText)),
      actions: <Widget>[
        controller.getSaveIndicator
            ? Container()
            : controller.itsInTheCatalogue?TextButton.icon(onPressed: () => controller.save(), icon:const Icon( Icons.check ), label:const  Text('Actualizar')):Container(),
      ],
      bottom: controller.getSaveIndicator
          ? ComponentApp.linearProgressBarApp(color: colorLoading)
          : null,
    );
  }

  Widget scaffold({required BuildContext context}) {
    return Scaffold(
      appBar: appBar(contextPrincipal: context),
      body: Stack(
        children: [
          ListView(
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              widgetFormEdit0(),
              widgetFormEdit2(),
            ],
          ),
          controller.getSaveIndicator?Container(color: Colors.black12.withOpacity(0.3)):Container()
        ],
      ),
    );
  }

  Widget widgetsImagen() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.grey.withOpacity(0.05),
      width: double.infinity,
      height: Get.size.height * 0.25,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // button
          controller.getSaveIndicator
              ? Container()
              : controller.getNewProduct || controller.getEditModerator
                  ? IconButton(
                      onPressed: controller.getLoadImageCamera,
                      icon: const Icon(Icons.camera_alt, color: Colors.grey))
                  : Container(),
          //  image
          controller.loadImage(),
          //  button
          controller.getSaveIndicator
              ? Container()
              : controller.getNewProduct || controller.getEditModerator
                  ? IconButton(
                      onPressed: controller.getLoadImageGalery,
                      icon: const Icon(Icons.image, color: Colors.grey))
                  : Container(),
        ],
      ),
    );
  }
  // view  : descripcion del producto en una tarjeta con un icono de verificacion,  codigo, descripcion y marca
  Widget widgetFormEdit0(){
    
    
    // view : descripcion del producto
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(color: cardProductDetailColor,borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //  image : imagen del producto
                controller.loadImage(size:100),
                // view : codigo,icon de verificaciones, descripcion y marca del producto
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          controller.getProduct.code != ""
                              ? Opacity(
                                  opacity: 0.8,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // icon : verificacion del producto
                                      controller.getProduct.verified?const Icon(Icons.verified_rounded,color: Colors.blue, size: 20):const Icon(Icons.qr_code_2_rounded, size: 20),
                                      const SizedBox(width: 5),
                                      // text : codigo del producto
                                      Text(controller.getProduct.code,style: const TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                )
                              : Container(),
                          space,
                          // textfield  : seleccionar una marca
                          textfielButton(
                            contentPadding: const EdgeInsets.only(bottom: 0,top: 0),
                              stateEdit: controller.getSaveIndicator? false: controller.getEditModerator || controller.getNewProduct,
                              textValue: controller.getMarkSelected.name,
                              labelText: controller.getMarkSelected.id == ''? 'Seleccionar una marca': 'Marca',
                              onTap: controller.getNewProduct || controller.getEditModerator? controller.showModalSelectMarca : () {}
                          ),
                          !controller.getAccountAuth ? Container() : space,
                          
                        ],
                      ),
                  ),
                )
              ],
            ),
            // textField  : nombre del producto
            TextField(
              enabled: controller.getSaveIndicator? false: controller.getEditModerator || controller.getNewProduct,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              onChanged: (value) => controller.getProduct.description = value,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 12,top: 12),
                filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                disabledBorder: InputBorder.none,labelText: "Descripción del producto"),
                textInputAction: TextInputAction.done,
                controller: controller.controllerTextEditDescripcion,
              ),
          ],
        ),
      ),
    );
  }
  //  view : descripcion del producto con formulario de edicion
  Widget widgetFormEdit1(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetsImagen(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // text : codigo y verificaciones del producto
                controller.getProduct.code != ""
                    ? Opacity(
                        opacity: 0.8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              controller.getProduct.verified?const Icon(Icons.verified_rounded,color: Colors.blue, size: 20):const Icon(Icons.qr_code_2_rounded, size: 20),
                              const SizedBox(width: 5),
                              Text(controller.getProduct.code,style: const TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                space,
                // textfield  : seleccionar una marca
                textfielButton(
                    stateEdit: controller.getSaveIndicator? false: controller.getEditModerator || controller.getNewProduct,
                    textValue: controller.getMarkSelected.name,
                    labelText: controller.getMarkSelected.id == ''? 'Seleccionar una marca': 'Marca',
                    onTap: controller.getNewProduct || controller.getEditModerator? controller.showModalSelectMarca : () {}
                ),
                !controller.getAccountAuth ? Container() : space,
                // textField  : nombre del producto
                TextField(
                  enabled: controller.getSaveIndicator? false: controller.getEditModerator || controller.getNewProduct,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) => controller.getProduct.description = value,
                  decoration: const InputDecoration(
                      filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                      disabledBorder: InputBorder.none,
                      labelText: "Descripción del producto", 
                    ),
                  textInputAction: TextInputAction.done,
                  controller: controller.controllerTextEditDescripcion,
                ),
              ],
            ),
          ),
      ],
    );
  }
  //  view : datos para el cátalogo con formulario de edicion
  Widget widgetFormEdit2() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          //TODO: eliminar para desarrrollo
          TextButton(
              onPressed: () async {
                String clave = controller.controllerTextEditDescripcion.text;
                Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                await launchUrl(uri,mode: LaunchMode.externalApplication);
              },
              child: const Text('Buscar descripción en Google (moderador)')),
          TextButton(
              onPressed: () async {
                String clave = controller.getProduct.code;
                Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                await launchUrl(uri,mode: LaunchMode.externalApplication);
              },
              child: const Text('Buscar en código Google (moderador)')), 
          space,
          // textfield : seleccionar cátegoria
          !controller.getAccountAuth? Container(): textfielButton(textValue: controller.getCategory.id == ''? '': controller.getCategory.name,labelText: controller.getCategory.id == ''? 'Seleccionar categoría': 'Categoría',onTap: controller.getSaveIndicator? () {}: SelectCategory.show,),
          space,
          // textfield prices
          !controller.getAccountAuth
              ? Container()
              : Column(
                  children: [
                    space,
                    TextField(
                      enabled: !controller.getSaveIndicator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => controller.getProduct.purchasePrice = controller.controllerTextEditPrecioCompra.numberValue,
                      decoration: const InputDecoration(
                        filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                        disabledBorder: InputBorder.none,
                        labelText: "Precio de compra (completa para ver las ganacia)", 
                      ),
                      textInputAction: TextInputAction.next,
                      //style: textStyle,
                      controller: controller.controllerTextEditPrecioCompra,
                    ),
                    space,
                    TextField(
                      enabled: !controller.getSaveIndicator,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => controller.getProduct.salePrice =controller.controllerTextEditPrecioVenta.numberValue,
                      decoration: const InputDecoration(
                        filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                        disabledBorder: InputBorder.none,
                        labelText: "Precio de venta al público", 
                      ),
                      textInputAction: TextInputAction.done,
                      //style: textStyle,
                      controller: controller.controllerTextEditPrecioVenta,
                    ),
                    space,
                    space,
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                      enabled: controller.getSaveIndicator ? false : true,
                      checkColor: Colors.white,
                      activeColor: Colors.amber,
                      value: controller.getProduct.favorite,
                      title: const Text('Favorito'),
                      onChanged: (value) {
                        if (!controller.getSaveIndicator) {
                          controller.setFavorite = value ?? false;
                        }
                      },
                    ),
                    space,
                    // view : control stock
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      color: controller.getProduct.stock?Colors.blue.withOpacity(0.07):Colors.transparent,
                      child: Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: controller.getProduct.stock?12:0,vertical: 12),
                            enabled: controller.getSaveIndicator ? false : true,
                            checkColor: Colors.white,
                            activeColor: Colors.blue,
                            value: controller.getProduct.stock?controller.isSubscribed:false,
                            title: Row(
                              children: [
                                const Text('Control de stock'),
                                const SizedBox(width: 12),
                                LogoPremium(personalize: true),
                              ],
                            ),
                            onChanged: (value) {
                              if (!controller.getSaveIndicator) {
                                controller.setStock = value ?? false;
                              }
                            },
                          ),
                          controller.getProduct.stock && controller.isSubscribed ? space : Container(),
                          controller.getProduct.stock && controller.isSubscribed
                              ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12,),
                                child: TextField(
                                  enabled: !controller.getSaveIndicator,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => controller.getProduct.quantityStock =int.parse(controller.controllerTextEditQuantityStock .text),
                                  decoration: const InputDecoration(
                                    filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                                    disabledBorder: InputBorder.none,
                                    labelText: "Stock", 
                                  ),
                                  textInputAction: TextInputAction.done,
                                  //style: textStyle,
                                  controller: controller.controllerTextEditQuantityStock,
                                ),
                              )
                              : Container(),
                          controller.getProduct.stock && controller.isSubscribed ? space : Container(),
                          controller.getProduct.stock && controller.isSubscribed
                              ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                                child: TextField(
                                  enabled: !controller.getSaveIndicator,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>controller.getProduct.alertStock = int.parse(controller.controllerTextEditAlertStock.text),
                                  decoration: const InputDecoration(
                                    filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                                    disabledBorder: InputBorder.none,
                                    labelText: "Alerta de stock (opcional)", 
                                  ),
                                  textInputAction: TextInputAction.done,
                                  //style: textStyle,
                                  controller: controller.controllerTextEditAlertStock,
                                ),
                              )
                              : Container(),
                        ],
                      ),
                    ),
                    // text : marca de tiempo de la ultima actualización del documento
                    controller.getNewProduct || !controller.itsInTheCatalogue ? Container() :  Padding(
                      padding: const EdgeInsets.only(top: 50),
                      //child: Text('Actualizado ${}'),
                      child: Opacity(opacity: 0.5,child: Center(child: Text('Actualizado ${Publications.getFechaPublicacion(controller.getProduct.upgrade.toDate(), Timestamp.now().toDate()).toLowerCase()}'))),
                    ),
                    // button : guardar
                    const SizedBox(height:50),
                    // CheckboxListTile : consentimiento de usuario para crear un producto
                    !controller.getNewProduct ? Container() :
                    Container(
                      margin:  const EdgeInsets.only(bottom: 20,top: 12),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.grey),
                      ),
                      child: CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Al crear un nuevo producto, entiendo que no seré el dueño ni podré editarlo una vez agregado a la base de datos también entiendo que los precios de venta de los productos serán de carácter publico',style: TextStyle(fontWeight: FontWeight.w300)),
                        value: controller.getUserConsent,
                        onChanged: (value) {
                          controller.setUserConsent = value!;
                        },
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: controller.getUserConsent?null:0,
                      padding: EdgeInsets.all(controller.getUserConsent?30.0:0),
                      child: const Text('¡Gracias por hacer que esta aplicación sea aún más útil para más personas! 🚀'),
                      ),
                    //  button : guardar el producto
                    button(
                      disable:controller.getSaveIndicator == true || (controller.getNewProduct && !controller.getUserConsent)  ,
                      onPressed: controller.save,
                      icon: Container(),
                      colorButton: Colors.blue,
                      padding:const EdgeInsets.all(0),
                      colorAccent: Colors.white,
                      text: controller.itsInTheCatalogue?'Actualizar':'Agregar a mi cátalogo',
                    ),
                  ],
                ),

          // button : elminar el documento
          controller.getSaveIndicator? Container(): 
            controller.itsInTheCatalogue? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 12, top: 20, left: 0, right: 0),
                      child: button(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),colorAccent: Colors.white,colorButton: Colors.red.shade400,icon: const Icon(Icons.delete,color: Colors.white),text: 'Eliminar de mi catálogo', onPressed: controller.showDialogDelete),
                    )
                  : Container(),
            controller.widgetTextButtonAddProduct,
            const SizedBox(height: 20.0),
          
          //TODO: eliminar para desarrrollo
          /* OPCIONES PARA DESARROLLADOR - ELIMINAR ESTE CÓDIGO PARA PRODUCCION */
          const SizedBox(height:50),
          widgetForModerator,
          ]             ,
      ),
    );
  }

  /* WIDGETS COMPONENT */
Widget get widgetForModerator{
  // TODO : delete release
  return Theme(
    data: ThemeData.dark(),
    child: Card(
      elevation: 0,
      child: Column(
        children: [
          //  text : title
          Container(width: double.infinity,color: Colors.black12,child: const Center(child: Padding(padding: EdgeInsets.all(12.0),child: Text("OPCIONES PARA MODERADOR")))),const SizedBox(height: 20.0),
          //  content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
                            children: [ 
                              SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                              CheckboxListTile(
                                enabled: controller.getEditModerator ? controller.getSaveIndicator? false: true: false,
                                checkColor: Colors.white,
                                activeColor: Colors.blue,
                                value: controller.getProduct.outstanding,
                                title: const Text('Detacado'),
                                onChanged: (value) {
                                  if (!controller.getSaveIndicator) {
                                    controller.setOutstanding(value: value ?? false);
                                  }
                                },
                              ),
                              SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                              CheckboxListTile(
                                enabled: controller.getEditModerator
                                    ? controller.getSaveIndicator
                                        ? false
                                        : true
                                    : false,
                                checkColor: Colors.white,
                                activeColor: Colors.blue,
                                value: controller.getProduct.verified,
                                title: const Text('Verificado'),
                                onChanged: (value) {
                                  if (controller.getEditModerator) {
                                    if (!controller.getSaveIndicator) {
                                      controller.setCheckVerified(value: value ?? false);
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                              controller.getSaveIndicator
                                  ? Container()
                                  : button(
                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                      icon:const Icon(Icons.security, color: Colors.white),
                                      onPressed: () {
                                        if (controller.getEditModerator) {controller.saveProductPublic();}
                                        controller.setEditModerator = !controller.getEditModerator;
                                      },
                                      colorAccent: Colors.white,
                                      colorButton: controller.getEditModerator? Colors.green: Colors.orange,
                                      text: controller.getEditModerator? controller.getNewProduct?'Crear documento':'Actualizar documento': "Editar documento",
                                    ),
                              const SizedBox(height: 20.0),
                              controller.getSaveIndicator || controller.getNewProduct || !controller.getEditModerator
                                  ? Container()
                                  : button(
                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                      icon:const Icon(Icons.security, color: Colors.white),
                                      onPressed: controller.showDialogDeleteOPTDeveloper,
                                      colorAccent: Colors.white,
                                      colorButton: Colors.red,
                                      text: "Eliminar documento",
                                    ),
                              // text : marca de tiempo de la ultima actualización del documento
                              controller.getNewProduct?Container():Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Opacity(opacity: 0.5,child: Center(child: Text('Creación ${Publications.getFechaPublicacion(controller.getProduct.documentCreation.toDate(), Timestamp.now().toDate()).toLowerCase()}'))),
                              ), 
                              const SizedBox(height: 30.0),
                            ],
                            // fin widget debug
                          ),
          ),
        ],
      ),
    ),
  );
}
  Widget textfielButton({required String labelText,String textValue = '',required Function() onTap,bool stateEdit = true,EdgeInsetsGeometry contentPadding = const EdgeInsets.all(12) }) {

    // value
    Color borderColor = Get.isDarkMode?Colors.white70:Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: stateEdit?onTap:null,
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: textValue),
        decoration: InputDecoration( 
          contentPadding: contentPadding,
          filled: false,
          fillColor:stateEdit?null:Colors.transparent ,
          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: stateEdit?borderColor:Colors.transparent,)),
          labelText: labelText,
          ),
      ),
    );
  }

  Widget button(
      {double width = double.infinity,
      bool disable = false,
      required Widget icon,
      String text = '',
      required dynamic onPressed,
      EdgeInsets padding =
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      Color colorButton = Colors.purple,
      Color colorAccent = Colors.white}) {
    return FadeInRight(
        child: Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: disable?null:onPressed,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.all(16.0),
              backgroundColor: colorButton,
              textStyle: TextStyle(color: colorAccent)),
          icon: icon,
          label: Text(text, style: TextStyle(color: colorAccent)),
        ),
      ),
    ));
  }
}

// category
class SelectCategory extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SelectCategory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectCategoryState createState() => _SelectCategoryState();

  static void show() {
    Widget widget = SelectCategory();
    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      widget,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
}

class _SelectCategoryState extends State<SelectCategory> {
  _SelectCategoryState();

  // Variables
  final Category categoriaSelected = Category();
  bool crearCategoria = false, loadSave = false;
  final HomeController welcomeController = Get.find();
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  @override
  void initState() {
    crearCategoria = false;
    loadSave = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categoría'),
        actions: [
          IconButton(icon: const Icon(Icons.add),onPressed: () => showDialogSetCategoria(categoria: Category())),
        ],
      ),
      body:welcomeController.getCatalogueCategoryList.isEmpty?const Center(child: Text('Sin cátegorias'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: welcomeController.getCatalogueCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Category categoria =welcomeController.getCatalogueCategoryList[index];
          
          return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      dense: true,
                      title: Text(categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1)),
                      onTap: () {
                        controllerProductsEdit.setCategory = categoria;
                        Get.back();
                      },
                      trailing: popupMenuItemCategoria(categoria: categoria),
                    ),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                  ],
                );
        },
      ),
    );

  }

  Widget popupMenuItemCategoria({required Category categoria}) {
    final HomeController controller = Get.find();

    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
        const PopupMenuItem<String>(value: 'eliminar', child: Text('Eliminar')),
      ],
      onSelected: (value) async {
        switch (value) {
          case "editar":
            showDialogSetCategoria(categoria: categoria);
            break;
          case "eliminar":
            await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Row(
                    children: const <Widget>[
                      Expanded(child:Text("¿Desea continuar eliminando esta categoría?"))
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    TextButton(
                        child: loadSave == false? const Text("ELIMINAR"): const CircularProgressIndicator(),
                        onPressed: () async {
                          controller.categoryDelete(idCategory: categoria.id).then((value) {
                              setState(() {
                                Get.back();
                              });
                            });
                        })
                  ],
                );
              },
            );
            break;
        }
      },
    );
  }

  showDialogSetCategoria({required Category categoria}) async {
    final HomeController controller = Get.find();
    bool loadSave = false;
    bool newProduct = false;
    TextEditingController textEditingController =
        TextEditingController(text: categoria.name);

    if (categoria.id == '') {
      newProduct = true;
      categoria =  Category();
      categoria.id =  DateTime.now().millisecondsSinceEpoch.toString();
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        return  AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content:  Row(
            children: <Widget>[
              Expanded(
                child:  TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: const InputDecoration( labelText: 'Categoria', hintText: 'Ej. golosinas'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Get.back();
                }),
            TextButton( child: loadSave == false? Text(newProduct ? 'GUARDAR' : "ACTUALIZAR"): const CircularProgressIndicator(),
                onPressed: () async {
                  if (textEditingController.text != '') {
                    // set
                    categoria.name = textEditingController.text;
                    setState(() => loadSave = true);
                    // save
                    await controller.categoryUpdate(categoria: categoria).whenComplete(() {
                      welcomeController.getCatalogueCategoryList.add(categoria);
                      setState(() {Get.back();});
                    }).catchError((error, stackTrace) =>setState(() => loadSave = false));
                  }
                })
          ],
        );
      },
    );
  }
}

// select mark
class WidgetSelectMark extends StatefulWidget {
  const WidgetSelectMark({Key? key}) : super(key: key);

  @override
  _WidgetSelectMarkState createState() => _WidgetSelectMarkState();
}

class _WidgetSelectMarkState extends State<WidgetSelectMark> {
  //  controllers
  ControllerProductsEdit controllerProductsEdit = Get.find();
  //  var
  List<Mark> list = [];

  @override
  void initState() {
    loadMarks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widgetView();
  }

  Widget widgetView() {
    return Column(
      children: [
        widgetAdd(),
        Expanded(
          child: list.isEmpty
              ? widgetAnimLoad()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Mark marcaSelect = list[index];
                    if (index == 0) {
                      return Column(
                        children: [
                          getWidgetOptionOther(),
                          const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                          controllerProductsEdit.getUltimateSelectionMark.id =='' ||controllerProductsEdit.getUltimateSelectionMark.id =='other'? Container(): listTile(marcaSelect: controllerProductsEdit.getUltimateSelectionMark),
                          const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                          listTile(marcaSelect: marcaSelect),
                          const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                        ],
                      );
                    }
                    return Column(
                      children: <Widget>[
                        listTile(marcaSelect: marcaSelect),
                        const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // WIDGETS
  Widget widgetAnimLoad() {
    return Center(
        child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(child: SizedBox(width: double.infinity, height: 50))),
        ),
      ],
    ));
  }

  Widget getWidgetOptionOther() {
    //values
    late Widget widget;
    // recorre la la de marcas para buscar la informaciób de opción 'other'
    if (controllerProductsEdit.getMarks.isEmpty) {
      widget = Container();
    } else {
      for (var element in controllerProductsEdit.getMarks) {
        if (element.id == 'other') {
          widget = listTile(
            marcaSelect: element,
          );
        }
      }
    }
    return widget;
  }

  // WIDGETS COMPONENT
  Widget widgetAdd() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 12),
          child: Row(
            children: [
              const Expanded(child: Text('Marcas', style: TextStyle(fontSize: 18))),
              // TODO : delete icon 'add new mark for release'
              IconButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => CreateMark(mark: Mark(upgrade: Timestamp.now(),creation: Timestamp.now())));
                  },
                  icon: const Icon(Icons.add)),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Get.back();
                  showSearch(
                    context: context,
                    delegate: SearchPage<Mark>(
                      items: list,
                      searchLabel: 'Buscar marca',
                      suggestion: const Center(
                        child: Text('ej. Miller'),
                      ),
                      failure: const Center(
                        child: Text('No se encontro :('),
                      ),
                      filter: (product) => [
                        product.name,
                        product.description,
                      ],
                      builder: (mark) => Column(
                        children: <Widget>[
                          listTile(marcaSelect: mark),
                          const Divider(endIndent: 12.0, indent: 12.0, height: 0),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget listTile({required Mark marcaSelect, bool icon = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      trailing: !icon ? null : AvatarApp(url: marcaSelect.image,size: 50,description:marcaSelect.name),
      dense: true,
      title: Text(marcaSelect.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18.0, color: Get.theme.textTheme.bodyText1!.color)),
      subtitle: marcaSelect.description == ''
          ? null
          : Text(marcaSelect.description, overflow: TextOverflow.ellipsis),
      onTap: () {
        controllerProductsEdit.setUltimateSelectionMark = marcaSelect;
        controllerProductsEdit.setMarkSelected = marcaSelect;
        Get.back();
      },
      onLongPress: () {
        // TODO : delete fuction
        Get.to(() => CreateMark(mark: marcaSelect));
      },
    );
  }

  // functions
  loadMarks() async {
    if (controllerProductsEdit.getMarks.isEmpty) {
      await Database.readListMarksFuture().then((value) {
        setState(() {
          for (var element in value.docs) {
            Mark mark = Mark.fromMap(element.data());
            mark.id = element.id;
            list.add(mark);
          }
          controllerProductsEdit.setMarks = list;
        });
      });
    } else {
      // datos ya descargados
      list = controllerProductsEdit.getMarks;
      setState(() => list = controllerProductsEdit.getMarks);
    }
  }
}

// TODO : delete release

class CreateMark extends StatefulWidget {
  late final Mark mark;
  CreateMark({required this.mark, Key? key}) : super(key: key);

  @override
  _CreateMarkState createState() => _CreateMarkState();
}

class _CreateMarkState extends State<CreateMark> {
  // others controllers
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  //var
  var uuid = const Uuid();
  bool newMark = false;
  String title = 'Crear nueva marca';
  bool load = false;
  TextStyle textStyle = const TextStyle(fontSize: 24.0);
  final ImagePicker _picker = ImagePicker();
  XFile xFile = XFile('');

  @override
  void initState() {
    newMark = widget.mark.id == '';
    title = newMark ? 'Crear nueva marca' : 'Editar';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  PreferredSizeWidget appbar() {
    Color? colorAccent = Get.theme.textTheme.bodyText1!.color;

    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text(
        title,
        style: TextStyle(color: colorAccent),
      ),
      centerTitle: true,
      iconTheme: Get.theme.iconTheme.copyWith(color: colorAccent),
      actions: [
        newMark
            ? Container()
            : IconButton(onPressed: delete, icon: const Icon(Icons.delete)),
        load
            ? Container()
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: save,
              ),
      ],
      bottom: load ? ComponentApp.linearProgressBarApp() : null,
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              xFile.path != ''
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(xFile.path)),
                      radius: 76,
                    )
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.mark.image,
                      placeholder: (context, url) => CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 75.0,
                      ),
                      imageBuilder: (context, image) => CircleAvatar(
                        backgroundImage: image,
                        radius: 75.0,
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 75.0,
                      ),
                    ),
              load
                  ? Container()
                  : TextButton(
                      onPressed: getLoadImageMark,
                      child: const Text("Cambiar imagen")),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.name),
            onChanged: (value) => widget.mark.name = value,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Descripción (opcional)"),
            style: textStyle,
          ),
        ),
      ],
    );
  }

  //  MARK CREATE
  void getLoadImageMark() {
    _picker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
        .then((value) {
      setState(() => xFile = value!);
    });
  }

  void delete() async {
    setState(() {
      load = true;
      title = 'Eliminando...';
    });

    if (widget.mark.id != '') {
      // delele archive storage
      await Database.referenceStorageProductPublic(id: widget.mark.id)
          .delete()
          .catchError((_) => null);
      // delete document firestore
      await Database.refFirestoreMark()
          .doc(widget.mark.id)
          .delete()
          .then((value) {
        // eliminar el objeto de la lista manualmente para evitar hacer una consulta innecesaria
        controllerProductsEdit.getMarks.remove(widget.mark);
        Get.back();
      });
    }
  }

  void save() async {
    setState(() {
      load = true;
      title = newMark ? 'Guardando...' : 'Actualizando...';
    });

    // set values
    widget.mark.verified = true;
    if (widget.mark.id == '') {
      widget.mark.id = uuid.v1();
      if (widget.mark.id == '') {
        widget.mark.id = DateTime.now().millisecondsSinceEpoch.toString();
      }
    }
    if (widget.mark.name != '') {
      // image save
      // Si el "path" es distinto '' procede a guardar la imagen en la base de dato de almacenamiento
      if (xFile.path != '') {
        Reference ref =
            Database.referenceStorageProductPublic(id: widget.mark.id);
        // referencia de la imagen
        UploadTask uploadTask = ref.putFile(File(xFile.path));
        // cargamos la imagen a storage
        await uploadTask;
        // obtenemos la url de la imagen guardada
        await ref
            .getDownloadURL()
            .then((value) async {
              // set
              widget.mark.image = value;
              // mark save
              await Database.refFirestoreMark()
                  .doc(widget.mark.id)
                  .set(widget.mark.toJson())
                  .whenComplete(() {
                controllerProductsEdit.setUltimateSelectionMark = widget.mark;
                controllerProductsEdit.setMarkSelected = widget.mark;
                // agregar el obj manualmente para evitar consulta a la db  innecesaria
                controllerProductsEdit.getMarks.add(widget.mark);
                Get.back();
              });
            })
            .onError((error, stackTrace) {})
            .catchError((_) {});
      } else {
        // mark save
        await Database.refFirestoreMark()
            .doc(widget.mark.id)
            .set(widget.mark.toJson())
            .whenComplete(() {
          controllerProductsEdit.setUltimateSelectionMark = widget.mark;
          controllerProductsEdit.setMarkSelected = widget.mark;
          // agregar el obj manualmente para evitar consulta a la db  innecesaria
          controllerProductsEdit.getMarks.add(widget.mark);
          Get.back();
        });
      }
    } else {
      Get.snackbar('', 'Debes escribir un nombre de la marca');
    }
  }
}