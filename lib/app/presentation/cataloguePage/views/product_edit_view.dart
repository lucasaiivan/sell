
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import 'package:search_page/search_page.dart'; 
import 'package:url_launcher/url_launcher.dart';  
import '../../../domain/entities/catalogo_model.dart'; 
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';
import '../controller/product_edit_controller.dart'; 

// ignore: must_be_immutable
class ProductEdit extends StatelessWidget {
  ProductEdit({Key? key}) : super(key: key);

  // controllers  
  final ControllerProductsEdit controller = Get.find();

  // var 
  Color? appBarTextColor = Get.theme.textTheme.bodyMedium!.color;
  final Widget space = const SizedBox(
    height: 16.0,
    width: 16.0, 
  );

  @override
  Widget build(BuildContext context) {

    // get : obtenemos los valores 
    controller.setContext = context;
    controller.colorLoading = Get.theme.primaryColor;
    controller.darkMode = Get.isDarkMode;  
    
    // GetBuilder - refresh all the views
    return GetBuilder<ControllerProductsEdit>(
      id: 'updateAll',
      init: ControllerProductsEdit(),
      initState: (_) {},
      builder: (_) {
        return Material(
          child: AnimatedSwitcher(
          duration: const  Duration(milliseconds: 100),
            child: scaffold(context: context),
          ),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appBar({required BuildContext contextPrincipal}) {
 
    return AppBar(
      elevation: 0.0,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      iconTheme: Theme.of(contextPrincipal).iconTheme.copyWith(color: appBarTextColor),
      title: controller.getLoadingData
          ? Text(controller.getTextAppBar,style: TextStyle(fontSize: 18.0, color: appBarTextColor))
          : Text(controller.getItsInTheCatalogue ? 'Editar' :'Nuevo',style: TextStyle(fontSize: 18.0, color: appBarTextColor)),
      actions: <Widget>[
        // TODO : release : disabled code of button moderator
        // start : contenido para desarrollo (debug) 
        // iconButton : opciones de moderador
        //
        controller.getProduct.local?Container():
        controller.getLoadingData
            ? Container()
            :IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined,color: controller.getProduct.verified? Colors.blue:null),
              onPressed: (){
                Get.bottomSheet(
                  const OptionsModeratorsWidget(),
                );
              },
            ),
        //
        // fin contentido para desarrollo (debug)
        //
        // iconButton : agregar producto a favorito
        controller.getLoadingData
            ? Container()
            :IconButton(
              icon: controller.getFavorite
                  ? const Icon(Icons.star_rounded,color: Colors.orange)
                  : const Icon(Icons.star_outline_rounded),
              onPressed: () { 
                if (!controller.getLoadingData) { 
                  controller.setFavorite = !controller.getFavorite;
                }
                
              },
            ),
        // iconButton : actualizar producto 
        controller.getLoadingData
            ? Container()
            :TextButton.icon(onPressed: () => controller.save(), icon: Icon(controller.getItsInTheCatalogue? Icons.check:Icons.add ), label: Text( controller.getItsInTheCatalogue?'':'Agregar')) ,
      ],
      bottom: controller.getLoadingData? ComponentApp().linearProgressBarApp(color: controller.colorLoading):null,
    );
  }

  Widget scaffold({required BuildContext context}) { 

    // view : form edit product
    return Scaffold(
      appBar: appBar(contextPrincipal: context),
      body: Stack(
        children: [
          ListView(
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // view : notificacion de mensaje
              controller.getMessageNotification==''?Container():Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.new_releases_outlined),
                  const SizedBox(width: 8),
                  Text( controller.getMessageNotification ,style: const TextStyle(fontWeight: FontWeight.w400)),
                ],
              ),
              // view : item de actualizacion de producto desde la base de datos publica
              controller.getProductPublicUpdateStatus?updateProductTile():Container(),
              // view : descripcion del producto
              productDataView(), 
              ComponentApp().divider(thickness: 1),
              productFromView(),
            ],
          ),
          controller.getLoadingData?Container(color: Colors.black12.withOpacity(0.3)):Container()
        ],
      ),
    );
  } 
  // view  : descripcion del producto en una tarjeta con un icono de verificacion,  codigo, descripcion y marca
  Widget productDataView(){

    // var
    final Color textDescriptionStyleColor = Get.isDarkMode?Colors.white.withOpacity(0.8):Colors.black.withOpacity(0.8);
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    bool enableEdit = controller.getLoadingData? false: controller.getEditModerator || controller.getProduct.verified==false;
     
    
    // view : descripcion del producto
    return Padding(
      padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0,bottom: 12.0),
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [   
          // view : texto y imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //  image : imagen del producto
              controller.getProduct.local?Container():
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: controller.loadImage(size:100),
              ),
              Expanded(
                child: Column( 
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // view : codigo del producto
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                
                      children: [ 
                        // icon : verificacion
                        controller.getProduct.verified?const Icon(Icons.verified_rounded,size: 16,color: Colors.blue):const Text('código: ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400)),
                        // spacer si esta verificado
                        controller.getProduct.verified?const SizedBox(width:2):Container(), 
                        // text : codigo
                        controller.getProduct.code != ""?Text(controller.getProduct.code,style: const TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400)):Container(),
                        // text : etiqueta de producto local (en el cátalogo)
                        !controller.getProduct.local?Container():const Opacity(opacity: 0.4,child: Text(' - Cátalogo ',style: TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400))),
                        
                      ],
                    ),
                    const SizedBox(height: 12),
                    // view : marca del producto
                    controller.getProduct.local?Container():Flexible(
                      child: textfielBottomSheetListOptions(  
                        contentPadding: const EdgeInsets.only(bottom: 12,top: 12,left: 12,right: 12),
                        stateEdit: controller.getLoadingData? false: enableEdit,
                        textValue: controller.getMarkSelected.name ,
                        labelText: controller.getMarkSelected.id == ''? 'Seleccionar una marca': 'Marca',
                        onTap: controller.getProduct.verified==false || controller.getEditModerator? controller.showModalSelectMarca : () {},
                        suffix: controller.getMarkSelected.toString().isNotEmpty? ComponentApp().userAvatarCircle(urlImage: controller.getMarkSelected.image,empty: true): null,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // textField  : descripción del producto
          InkWell(
            borderRadius: BorderRadius.circular(2),
            onTap: enableEdit?()=>controller.showDialogDescription():null,
            child: TextField(
              enabled: false,
              minLines: 1,
              maxLines: 5,
              style: TextStyle(height: 2,color: textDescriptionStyleColor),
              keyboardType: TextInputType.multiline,
              onChanged: (value) => controller.setDescription = value,
              autofocus: false, 
              decoration: InputDecoration(   
                border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:boderLineColor),), 
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:!enableEdit?Colors.transparent:boderLineColor)),
                contentPadding: const EdgeInsets.only(bottom: 12,top: 12,left: 12,right: 12),
                filled: enableEdit,
                fillColor: enableEdit?null:Colors.transparent,
                hoverColor: Colors.blue, 
                labelText: "Descripción del producto"),
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\- .³%]')) ],
                textInputAction: TextInputAction.done,
                controller: controller.controllerTextEditDescripcion,
              ),
          ),
        ],
      ),
    );
  }
  //  view : datos para el cátalogo con formulario de edicion
  Widget productFromView(){

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style  
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0,bottom: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[  
          !controller.getAccountAuth? Container():const Text('Personaliza tu producto',style: TextStyle(fontSize: 18.0)),
          space,
          // textfield : seleccionar proveedor
          !controller.getAccountAuth? Container():InkWell(
              borderRadius: BorderRadius.circular(2),
              onTap: SelectProvider.show, 
              child: TextFormField(
                autofocus: false,
                focusNode:null,
                controller: controller.controllerTextEditProvider, 
                style: valueTextStyle,
                enabled: false,
                autovalidateMode: AutovalidateMode.onUserInteraction, 
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fillColor, 
                  labelText: controller.controllerTextEditProvider.text==''?'Seleccionar un proveedor':'Proveedor',
                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                ),   
                // validator: validamos el texto que el usuario
              ),
            ),
          space, 
          // textfield : seleccionar cátegoria
          !controller.getAccountAuth? Container(): InkWell(
              borderRadius: BorderRadius.circular(2),
              onTap: SelectCategory.show, 
              child: TextFormField(
                autofocus: false,
                focusNode:null,
                controller: controller.controllerTextEditCategory, 
                style: valueTextStyle,
                enabled: false,
                autovalidateMode: AutovalidateMode.onUserInteraction, 
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fillColor, 
                  labelText: controller.controllerTextEditCategory.text==''?'Seleccionar una cátegoria':'Cátegoria',
                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                ),   // validamos que el usuario ha modificado el formulario
                // validator: validamos el texto que el usuario ha ingresado.
                validator: (value) {
                  if (controller.controllerTextEditCategory.text=='') { return 'Por favor, seleccione una cátegoria'; }
                  return null;
                },
              ),
            ),
          space,  
          
          !controller.getAccountAuth
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                // view : 
                Row( 
                  children: [
                    // textfield : precio de costo
                    Flexible(
                      flex: 1,
                      child: Form(
                        key: controller.purchasePriceFormKey,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(2),
                          onTap: (){
                            // dialog 
                            controller.showDialogPricePurchase();
                          },
                          child: TextFormField(
                            style: valueTextStyle,
                            autofocus: false, 
                            controller: controller.controllerTextEditPrecioCosto,
                            enabled: false,
                            autovalidateMode: AutovalidateMode.onUserInteraction, 
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [AppMoneyInputFormatter()],
                            decoration: InputDecoration( 
                              filled: true,
                              fillColor: fillColor,
                              labelText: 'Costo',
                              border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                              ),      
                            onChanged: (value) {   
                              controller.updateAll();
                            } ,   
                            // validator: validamos el texto que el usuario ha ingresado.
                            validator: (value) {
                              // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                              return null; 
                            },
                          ),
                        ),
                      ),
                    ), 
                    // text and button : modificar porcentaje de ganancia
                    controller.getPorcentage == '' ? const SizedBox(width:12):TextButton(onPressed: controller.showDialogAddProfitPercentage, child: Text( controller.getPorcentage )), 
                    // precio de venta al público
                    Flexible(
                      flex: 2,
                      child: Form(
                        key: controller.salePriceFormKey, 
                        child: InkWell(
                          borderRadius: BorderRadius.circular(2),
                          onTap: ()=> controller.showDialogPriceSale(),
                          child: TextFormField(
                            style: valueTextStyle,
                            autofocus: false, 
                            controller: controller.controllerTextEditPrecioVenta,
                            enabled: false,
                            autovalidateMode: AutovalidateMode.onUserInteraction, 
                            inputFormatters: [AppMoneyInputFormatter()],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fillColor,
                              labelText: 'Precio de venta al público',
                              border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                            ),   
                            onChanged: (value) { controller.updateAll(); },
                            // validator: validamos el texto que el usuario ha ingresado.
                            validator: (value) {
                              if ( controller.controllerTextEditPrecioVenta.doubleValue == 0.0) { return 'Por favor, escriba un precio de venta'; }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),  
                space,
                //
                // view : control stock
                // 
                AnimatedContainer(
                  width:double.infinity, 
                  duration: const Duration(milliseconds: 500),
                  // dibujar borde solo en la parte superior 
                  decoration: controller.homeController.getIsSubscribedPremium&&controller.getStock?
                  BoxDecoration(border: Border(top: BorderSide(color: boderLineColor,width: 1.0)))
                  : BoxDecoration(border: Border(top: BorderSide(color: boderLineColor,width: 1.0),bottom: BorderSide(color: boderLineColor,width: 1.0),left: BorderSide(color: boderLineColor,width: 1.0),right: BorderSide(color: boderLineColor,width: 1.0))),
                  child: Column(
                  children: [
                    CheckboxListTile( 
                      contentPadding: const EdgeInsets.symmetric(horizontal:12,vertical: 12),
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: controller.homeController.getIsSubscribedPremium?controller.getStock:false,
                      title: const Text('Control de stock'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.getHomeController.getIsSubscribedPremium?Container():LogoPremium(id: 'stock'),
                          const Opacity(opacity: 0.5,child: Text('Controla el inventario de este producto')),
                        ],
                      ), 
                      onChanged: (value) {
                        if(controller.homeController.getIsSubscribedPremium){
                          // esta subscripcion es premium
                          // condition : si el usuario no esta guardando el producto
                          if (!controller.getLoadingData) {
                            controller.setStock = value ?? false;
                          }
                        }else{
                          // no esta subscripcion 
                          controller.homeController.showModalBottomSheetSubcription(id: 'stock');
                        }
                        
                      },
                    ),    
                    // spacer
                    controller.getStock && controller.homeController.getIsSubscribedPremium? space : Container(), 
                    // view : entradas de valores del stock
                    controller.getStock && controller.homeController.getIsSubscribedPremium?Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12,),
                          child: Form(
                            key: controller.quantityStockFormKey,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(2),
                              onTap: ()=> controller.showDialogStock(), 
                              child: TextFormField(
                                style: valueTextStyle,
                                autofocus: false, 
                                controller: controller.controllerTextEditQuantityStock,
                                enabled: false,
                                autovalidateMode: AutovalidateMode.onUserInteraction, 
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: fillColor,
                                  labelText: 'Stock (cantidad disponible)',
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                                ),   
                                onChanged: (value) { controller.updateAll(); },
                                // validator: validamos el texto que el usuario ha ingresado.
                                validator: (value) {
                                  if ( controller.controllerTextEditPrecioVenta.doubleValue == 0.0) { return 'Por favor, escriba un precio de venta'; }
                                  return null;
                                },
                              ),
                            ), 
                          ),
                        ),
                        space,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12,),
                          child: Form( 
                            child: InkWell(
                              borderRadius: BorderRadius.circular(2),
                              onTap: ()=> controller.showDialogStockAlert(),
                              child: TextFormField(
                                style: valueTextStyle,
                                autofocus: false, 
                                controller: controller.controllerTextEditAlertStock,
                                enabled: false,
                                autovalidateMode: AutovalidateMode.onUserInteraction, 
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: fillColor,
                                  labelText: 'Alerta de stock bajo',
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                                ),    
                                // validator: validamos el texto que el usuario ha ingresado.
                                validator: (value) {
                                  if ( controller.controllerTextEditPrecioVenta.doubleValue == 0.0) { return 'Por favor, escriba un precio de venta'; }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ):Container(),
                  ],
                  ),
                ),
          
                // text : marca de tiempo de la ultima actualización del documento
                !controller.getItsInTheCatalogue ? Container() :  Padding(
                  padding: const EdgeInsets.only(top: 50),
                  //child: Text('Actualizado ${}'),
                  child: Opacity(opacity: 0.5,child: Center(child: Text('Actualizado ${Publications.getFechaPublicacion(fechaPublicacion: controller.getProduct.upgrade.toDate(), fechaActual: Timestamp.now().toDate()).toLowerCase()}'))),
                ),
                // button : guardar
                const SizedBox(height:30),  
                //  button : guardar el producto
                ComponentApp().button( 
                  disable:controller.getLoadingData == true   ,
                  onPressed: controller.save,
                  icon: Container(),
                  colorButton: Colors.blue,
                  padding:const EdgeInsets.all(0),
                  colorAccent: Colors.white,
                  text: controller.getItsInTheCatalogue?'Actualizar':'Agregar a mi cátalogo',
                ), 
                // button : elminar el documento
                controller.getLoadingData? Container(): 
                controller.getItsInTheCatalogue? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 12, top: 30, left: 0, right: 0),
                  child: TextButton(onPressed: controller.showDialogDelete,child: Text('Eliminar de mi cátalogo',style: TextStyle(color: Colors.red.shade300),)),
                )
              : Container(), 
              ],
            ), 
            const SizedBox(height: 20.0), 
          //widgetForModerator,
          ]             ,
      ),
    );
  }

  /* WIDGETS COMPONENT */   
  Widget textfielBottomSheetListOptions({required String labelText,String textValue = '',required Function() onTap,bool stateEdit = true,EdgeInsetsGeometry contentPadding = const EdgeInsets.all(12),Widget? suffix}) {

    // value
    final Color textDescriptionStyleColor = Get.isDarkMode?Colors.white.withOpacity(0.7):Colors.black.withOpacity(0.7);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: stateEdit?onTap:null,
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: textValue),
        style: TextStyle(color: textDescriptionStyleColor),
        decoration: InputDecoration( 
          border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:boderLineColor),),
          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:!stateEdit?Colors.transparent:boderLineColor)),
          contentPadding: contentPadding,
          filled: stateEdit,
          fillColor:stateEdit?fillColor:Colors.transparent , 
          labelText: labelText,
          suffix:suffix,
          ),
        
      ),
    );
  }
  Widget updateProductTile() {
    // description : crear un [ListTile] con bordes redondeados,avatar y description y un textbutton 'actualizar' del nuevo producto [controller.getProductPublicUpdate]
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          leading: ImageProductAvatarApp(url: controller.getProductPublicUpdate.image),
          title: Row(
            children: [
              // icon : verificacion
              const Icon(Icons.verified_rounded,size: 16,color: Colors.blue),
              // spacer si esta verificado
              const SizedBox(width:2), 
              // text : codigo
              Text(controller.getProductPublicUpdate.code,style: const TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400)),
            ],
          ),
          subtitle: Text(controller.getProductPublicUpdate.description),
          trailing: TextButton(onPressed: ()  =>  controller.updateProductCatalogue(), child: const Text('Actualizar',style: TextStyle(fontSize: 16))),
          onTap:null,
        ),
      ),
    );
  }
  
}

// class : vista para seleccionar categoria de producto y eliminar o editar las categorias
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
        title: const Text('Categorías'),
        actions: [
          // icon : agregar nueva categoria
          IconButton(icon: const Icon(Icons.add),onPressed: (){Get.back();showDialogSetCategoria(categoria: Category());}),
          // icon : buscar categoria
          IconButton(icon: const Icon(Icons.search),onPressed: () {Get.back();showSearchCategory();}),
          
        ],
      ),
      body: welcomeController.getCatalogueCategoryList.isEmpty?const Center(child: Text('Sin cátegorias'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: welcomeController.getCatalogueCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Category categoria =welcomeController.getCatalogueCategoryList[index];
          
          return Column(
            children: <Widget>[
              itemCategory(category: categoria),
              const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
            ],
          );
        },
      ),
    );

  }

  // WIDGETS COMPONENT
  Widget itemCategory({required Category category}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      dense: true,
      title: Text(category.name.substring(0, 1).toUpperCase() + category.name.substring(1)),
      onTap: () {
        controllerProductsEdit.setCategory = category;
        welcomeController.categorySelected(category:category);

        Get.back();
      },
      trailing: popupMenuItemCategoria(categoria: category),
    );
  }

  Widget popupMenuItemCategoria({required Category categoria}) {
    // controllers 
    final HomeController controller = Get.find();
    final ControllerProductsEdit controllerProductsEdit = Get.find();
    
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
                  content: const Row(
                    children: <Widget>[
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
                                controllerProductsEdit.controllerTextEditCategory.text = '';
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
  // DIALOG
  showSearchCategory(){
    // description : muestra la barra de busqueda para buscar la categoria del producto

    // controllers
    final HomeController welcomeController = Get.find();

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    showSearch(
      context: context,
      delegate: SearchPage<Category>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: welcomeController.getCatalogueCategoryList,
        searchLabel: 'Buscar cátegoria',
        suggestion: const Center(child: Text('ej. gaseosa')),
        failure: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se encontro :('), 
            const SizedBox(height:20),
            // button : crear nueva categoria
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                showDialogSetCategoria(categoria: Category());
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear nueva categoría'),
            ),
          ],
        )),
        filter: (category) => [Utils.normalizeText(category.name)],
        builder: (category) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[
          itemCategory(category: category),
          ComponentApp().divider(),
          ]),
      ),
    );
  }
  showDialogSetCategoria({required Category categoria}) async {
    // controllers
    final HomeController homeController = Get.find();
    final ControllerProductsEdit controllerProductsEdit = Get.find();
    TextEditingController textEditingController = TextEditingController(text: categoria.name);
    // var 
    bool newProduct = false;

    if (categoria.id == '') {
      newProduct = true;
      categoria =  Category();
      categoria.id =  DateTime.now().millisecondsSinceEpoch.toString();
    }

    await showDialog<String>(
      context: Get.context!,
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
            TextButton( child: Text(newProduct ? 'GUARDAR' : "ACTUALIZAR") ,
                onPressed: () async {
                  if (textEditingController.text != '') {

                    // set
                    categoria.name = textEditingController.text; 
                     
                    // save
                    await homeController.categoryUpdate(categoria: categoria).whenComplete(() {
                      // set 
                      controllerProductsEdit.controllerTextEditCategory.text = categoria.name;
                      // add
                      welcomeController.getCatalogueCategoryList.add(categoria);
                      Get.back();
                    });
                  }
                })
          ],
        );
      },
    );
  }

}
// class : vista para seleccionar el proveedor del producto y eliminar o editar los proveedores
class SelectProvider extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SelectProvider({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectProviderState createState() => _SelectProviderState();

  static void show() {
    Widget widget = SelectProvider();
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
class _SelectProviderState extends State<SelectProvider> {
  _SelectProviderState();

  // Variables
  final Provider providerSelected = Provider();
  bool createProvider = false, loadSave = false;
  final HomeController welcomeController = Get.find();
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  @override
  void initState() {
    createProvider = false;
    loadSave = false;
    super.initState();
  } 

  @override
  Widget build(BuildContext buildContext) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedor'),
        actions: [
          // icon : buscar proveedor
          IconButton(icon: const Icon(Icons.add),onPressed: (){Get.back();showDialogSetProvider(provider: Provider());}),
          // icon : buscar proveedor
          IconButton(icon: const Icon(Icons.search),onPressed: () {Get.back();showSearchProvider();}),
          
        ],
      ),
      body: welcomeController.getProviderList.isEmpty?const Center(child: Text('Sin proveedores'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: welcomeController.getProviderList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Provider provider = welcomeController.getProviderList[index] ;
          
          return Column(
            children: <Widget>[
              itemProvider(provider: provider),
              const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.2),
            ],
          );
        },
      ),
    );

  }

  // WIIDGETS COMPONENT
  Widget itemProvider({required Provider provider}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      dense: true,
      title: provider.name==''?null: Text(provider.name.substring(0, 1).toUpperCase() + provider.name.substring(1)),
      onTap: () {
        controllerProductsEdit.setProvider = provider;
        welcomeController.providerSelected(provider: provider);
        Get.back();
      },
      trailing: popupMenuItemProvider(provider: provider),
    );
  }

  Widget popupMenuItemProvider({required Provider provider}) {
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
            showDialogSetProvider(provider: provider);
            break;
          case "eliminar":
            await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(16.0),
                  content: const Row(
                    children: <Widget>[
                      Expanded(child:Text("¿Desea continuar eliminando este proveedor?"))
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
                          controller.providerDelete(idProvider: provider.id).then((value) {
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
  // DIALOG
  showSearchProvider(){
    // description : muestra la barra de busqueda para buscar la categoria del producto

    // controllers
    final HomeController welcomeController = Get.find();

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    showSearch(
      context: context,
      delegate: SearchPage<Provider>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: welcomeController.getProviderList,
        searchLabel: 'Buscar proveedor',
        suggestion: const Center(child: Text('ej. Mayorista')),
        failure: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // text 
            const Text('No se encontro :('), 
            const SizedBox(height: 20),
            // textButton : agregar proveedor
            TextButton(onPressed: (){Get.back();showDialogSetProvider(provider: Provider());}, child: const Text('Agregar proveedor')),
          ],
        )),
        filter: (provider) => [Utils.normalizeText(provider.name)],
        builder: (provider) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[
          itemProvider(provider: provider),
          ComponentApp().divider(),
          ]),
      ),
    );
  }
  showDialogSetProvider({required Provider provider}) async {

    // controllers 
    final HomeController homeController = Get.find(); 
    final ControllerProductsEdit controllerProductsEdit = Get.find();
    TextEditingController textEditingController = TextEditingController(text: provider.name);

    // var  
    bool newProvider = false;

    if (provider.id == '') {
      newProvider = true;
      provider =  Provider();
      provider.id =  DateTime.now().millisecondsSinceEpoch.toString();
    }

    await showDialog<String>(
      context: Get.context!,
      builder: (context) {
        return  AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content:  Row(
            children: <Widget>[
              Expanded(
                child:  TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: const InputDecoration( labelText: 'Proveedor', hintText: 'Ej. proveedor bebidas'),
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
            TextButton( child: Text(newProvider ? 'GUARDAR' : "ACTUALIZAR") ,
                onPressed: () async {
                  if (textEditingController.text != '') {
                    // set
                    provider.name = textEditingController.text;   
                    // save
                    await homeController.providerSave(provider: provider).whenComplete(() {
                      welcomeController.getProviderList.add(provider);
                      controllerProductsEdit.controllerTextEditProvider.text = provider.name;
                      Get.back();
                    }).catchError((error, stackTrace) =>setState(() => loadSave = false));
                  }
                })
          ],
        );
      },
    );
  }
}

// class : vista de opciones para moderador
class OptionsModeratorsWidget extends StatefulWidget {
  const OptionsModeratorsWidget({super.key});

  @override
  State<OptionsModeratorsWidget> createState() => _OptionsModeratorsWidgetState();
}
class _OptionsModeratorsWidgetState extends State<OptionsModeratorsWidget> {

  // controllers
  final ControllerProductsEdit controller = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [ 
            Icon(Icons.security_sharp),
            SizedBox(width:5),
            Text('Moderador'),
          ],
        ),
        actions: [
          
          // iconButton : editar opciones
          controller.getEditModerator?Container():IconButton(
            onPressed: (){
              setState(() {
                controller.getProduct.reviewed = true; 
                controller.setEditModerator = !controller.getEditModerator;
              });
            }, 
            icon: const Icon(Icons.edit_outlined),
          ),
          // button : actualizar documento
          controller.getLoadingData ||  !controller.getEditModerator
              ? Container() : Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.check,color: Colors.blue,),
                ),
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(   
          children: [  
            // view :botones de busqueda en google
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    // text 
                    const Text('Buscar en google:'),
                    const Spacer(),
                    // button : textButton : buscar en google
                    TextButton(
                        onPressed: !controller.getEditModerator?null: () async {
                          String clave = controller.controllerTextEditDescripcion.text;
                          Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                          await launchUrl(uri,mode: LaunchMode.externalApplication);
                        },
                        child: const Text('Descripción' )),
                    // textButton : buscar en google
                    TextButton(
                      onPressed: !controller.getEditModerator?null: () async {
                        String clave = controller.getProduct.code;
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                        await launchUrl(uri,mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Código' ),
                    ),
                  ],
                ),
              // view : apps utiles
              Row(
                children: [
                  // text 
                  const Text('Apps de edición de imagen'),
                  const Spacer(),
                  // textButton : direccionamiento a la play store
                  TextButton.icon( 
                    onPressed: !controller.getEditModerator?null: () async{
                      // values
                      Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.camerasideas.instashot&pcampaignid=web_share');
                      //  redireccionara para la tienda de aplicaciones
                      await launchUrl(uri,mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.photo_size_select_large_sharp),
                    label: const Text('InstaShot'),
                  
                  ),
                ],
              ),
              ],
            ),  
            const Divider(),
            // view : verificacion de verificado
            CheckboxListTile(
              enabled: controller.getEditModerator ? controller.getLoadingData ? false : true : false,
              checkColor: Colors.white,
              activeColor: Colors.blue,
              value: controller.getProduct.verified,
              title: const Text('Verificado'),
              subtitle: const Text('Se verifica que el producto es real'), 
              secondary: const Icon(Icons.verified_outlined),
              onChanged: (value) {
                if (controller.getEditModerator) {
                  if (!controller.getLoadingData) {
                    setState(() {
                      controller.setCheckVerified(value: value ?? false);
                      if (value??false) {
                        controller.getProduct.reviewed = true;
                      }
                    });
                  }
                }
              },
            ), 
            const Divider(),
            CheckboxListTile(
              enabled: controller.getEditModerator ? controller.getLoadingData? false: true: false,
              checkColor: Colors.white,
              activeColor: Colors.blue,
              value: controller.getProduct.outstanding,
              title: const Text('Detacado'),
              subtitle: const Text('Se visualiza en productos sugeridos'),
              secondary: const Icon(Icons.star_border_purple500_outlined),
              onChanged: (value) {
                if (!controller.getLoadingData) {
                  
                  setState(() {
                    controller.setOutstanding(value: value ?? false);
                  });
                }
              },
            ),  
            const Divider(), 
            // view : cantidad de comercios que tienen el producto
            Padding(
              padding: const EdgeInsets.only(left: 12,right: 12),
              child: Row(
                children: [
                  // text : cantidad de comercios que tienen el producto
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comercios '),
                        Opacity(opacity: 0.4,child: Text('Negocios que siguen este producto',overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  ), 
                  // textButtons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // button : decrementar seguidores
                      TextButton(
                          onPressed: !controller.getEditModerator?null: ()=> setState(()=>controller.descreaseFollowersProductPublic()), 
                          child:  const Icon(Icons.indeterminate_check_box ),
                      ),
                      Opacity(opacity:!controller.getEditModerator?0.3:1,child: Text(Publications.getFormatAmount(value: controller.getProduct.followers))),
                      // button : incrementar seguidores
                      TextButton(
                          onPressed: !controller.getEditModerator? null : ()=> setState( ()=> controller.increaseFollowersProductPublic() ),
                          child: const Icon(Icons.add_box_rounded),
                      ),
                      
                    ],
                  ),
                
                ],
              ),
            ),
            const SizedBox(height:50),
            // button : eliminar documento
            controller.getLoadingData || !controller.getEditModerator
                ? Container()
                : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: button(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      icon:const Icon(Icons.security, color: Colors.white),
                      onPressed: controller.showDialogDeleteOPTDeveloper,
                      colorAccent: Colors.white,
                      colorButton: Colors.red,
                      text: "Eliminar documento",
                    ),
                ),
            // text : marca de tiempo de la ultima actualización del documento
            Opacity(opacity: 0.5,child: Center(child: Text('Creación ${Publications.getFechaPublicacion( fechaPublicacion: controller.getProduct.documentCreation.toDate(),fechaActual:  Timestamp.now().toDate()).toLowerCase()}'))), 
            const SizedBox(height: 30.0),
          ],
          // fin widget debug
        ),
      ),
    ); 
  
  }
  Widget button( {double width = double.infinity,
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
