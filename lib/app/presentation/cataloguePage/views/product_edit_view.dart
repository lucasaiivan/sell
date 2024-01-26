
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import 'package:sell/app/presentation/cataloguePage/controller/catalogue_controller.dart';
import 'package:url_launcher/url_launcher.dart';  
import '../../../domain/entities/catalogo_model.dart'; 
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';
import '../controller/product_edit_controller.dart'; 

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

    Widget noEdit = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings,size: 50),
                SizedBox(height: 16.0),
                Text('No eres administrador de esta cuenta',style: TextStyle(fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        ), 
        TextButton.icon(onPressed: Get.back, icon: const Icon(Icons.close_rounded), label: const Text('Cerrar')),
      ],
    ); 
    
    // GetBuilder - refresh all the views
    return GetBuilder<ControllerProductsEdit>(
      id: 'updateAll',
      init: ControllerProductsEdit(),
      initState: (_) {},
      builder: (_) {
        return Material(
          child: AnimatedSwitcher(
          duration: const  Duration(milliseconds: 100),
            child: controller.homeController.getInternetConnection ? scaffold(context: context) : Scaffold(
                      appBar: AppBar(
                        elevation: 0.0,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        iconTheme: Theme.of(context)
                            .iconTheme
                            .copyWith(color: appBarTextColor),
                        title: Text(controller.getTextAppBar,style: TextStyle(  color: appBarTextColor,fontSize: 18 )),
                      ),
                      body: const Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.wifi_off_rounded),
                          ),
                          Text('No hay internet'),
                        ],
                      )),
                    ),
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
      iconTheme:
          Theme.of(contextPrincipal).iconTheme.copyWith(color: appBarTextColor),
      title: controller.getDataUploadStatus
          ? Text(controller.getTextAppBar,style: TextStyle(fontSize: 18.0, color: appBarTextColor))
          : Text(controller.getItsInTheCatalogue ? 'Editar' :'Nuevo producto',style: TextStyle(fontSize: 18.0, color: appBarTextColor)),
      actions: <Widget>[
        // TODO : delete release
        // 
        // start : contenido para desarrollo (debug) 
        // iconButton : opciones de moderador
        //
        controller.getDataUploadStatus
            ? Container()
            :IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: (){
                Get.bottomSheet(
                  const OptionsModeratorsWidget(),
                );
              },
            ), 
        //
        // fin contentido para desarrollo (debug)
        //
        // iconButton : actualizar producto 
        controller.getDataUploadStatus
            ? Container()
            :TextButton.icon(onPressed: () => controller.save(), icon:const Icon( Icons.check ), label: Text( controller.getItsInTheCatalogue?'Actualizar':'Agregar')) ,
      ],
      bottom: controller.getDataUploadStatus? ComponentApp().linearProgressBarApp(color: controller.colorLoading):null,
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
              productDataView(), 
              ComponentApp().divider(),
              productFromView(),
            ],
          ),
          controller.getDataUploadStatus?Container(color: Colors.black12.withOpacity(0.3)):Container()
        ],
      ),
    );
  } 
  // view  : descripcion del producto en una tarjeta con un icono de verificacion,  codigo, descripcion y marca
  Widget productDataView(){

    // var
    final Color textDescriptionStyleColor = Get.isDarkMode?Colors.white.withOpacity(0.8):Colors.black.withOpacity(0.8);
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    bool enableEdit = controller.getDataUploadStatus? false: controller.getEditModerator || controller.getProduct.verified==false;
     
    
    // view : descripcion del producto
    return Padding(
      padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 12.0,bottom: 12.0),
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [  
          // view : codigo del producto
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,

            children: [ 
              // icon : verificacion
              controller.getProduct.verified?const Icon(Icons.verified_rounded,size: 16,color: Colors.blue):Container(),
              // spacer si esta verificado
              controller.getProduct.verified?const SizedBox(width:2):Container(), 
              // text : codigo
              controller.getProduct.code != ""?Text(controller.getProduct.code,style: const TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400)):Container(),
              // barra separadora 
              const Opacity(opacity: 0.4,child: Text(' | ',style: TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400))) ,
              // text : cantidad de comercios que tienen el producto
              Opacity(opacity: 0.4,child: Text('${Publications.getFormatAmount(value: controller.getProduct.followers)} ${controller.getProduct.followers == 1 ? 'comercio' : 'comercios'}')),
            ],
          ),
          const SizedBox(height: 12),
          // view : texto y imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //  image : imagen del producto
              controller.loadImage(size:100),
              // view : codigo,icon de verificaciones, descripcion y marca del producto
              Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: textfielBottomSheetListOptions(
                      contentPadding: const EdgeInsets.only(bottom: 12,top: 12,left: 12,right: 12),
                      stateEdit: controller.getDataUploadStatus? false: controller.getEditModerator || controller.getProduct.verified==false,
                      textValue: controller.getMarkSelected.name ,
                      labelText: controller.getMarkSelected.id == ''? 'Seleccionar una marca': 'Marca',
                      onTap: controller.getProduct.verified==false || controller.getEditModerator? controller.showModalSelectMarca : () {}
                                  ),
                  ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // textField  : descripción del producto
          TextField(
            enabled: enableEdit,
            minLines: 1,
            maxLines: 5,
            style: TextStyle(height: 2,color: textDescriptionStyleColor),
            keyboardType: TextInputType.multiline,
            onChanged: (value) => controller.setDescription = value,
            // desabilitar autofocus
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
          !controller.getAccountAuth? Container(): GestureDetector(
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
          !controller.getAccountAuth? Container(): GestureDetector(
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
                // textfield : precio de costo
                Form(
                  key: controller.purchasePriceFormKey,
                  child: TextFormField(
                    style: valueTextStyle,
                    autofocus: false,
                    focusNode:controller.purchasePriceTextFormFieldfocus,
                    controller: controller.controllerTextEditPrecioCosto,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration( 
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Precio de costo',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      ),    
                    onChanged: (value) {  
                    } ,  
                    onEditingComplete: (){
                      controller.updateAll();
                      FocusScope.of(controller.getContext).previousFocus();
                    },
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                      return null; 
                    },
                  ),
                ),
                controller.getPorcentage == '' ? Container():space,
                // text and button : modificar porcentaje de ganancia
                controller.getPorcentage == '' ? Container():Row(
                  children: [
                    TextButton(onPressed: controller.showDialogAddProfitPercentage, child: Text( controller.getPorcentage )),
                    const Spacer(),
                    TextButton(onPressed: controller.showDialogAddProfitPercentage , child: const Text( 'Modificar porcentaje' )),
                  ],
                ),
                space,
                // precio de venta al público
                Form(
                  key: controller.salePriceFormKey,
                  // TODO : RangeError TextFormField : cuando el usuario mantiene presionado el boton de borrar > 'RangeError : Invalid value: only valid value is 0: -1'
                  child: TextFormField(
                    style: valueTextStyle,
                    autofocus: false,
                    focusNode:controller.salePriceTextFormFieldfocus,
                    controller: controller.controllerTextEditPrecioVenta,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Precio de venta al público',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                    ),  
                    onChanged: (value) { },
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      if ( controller.controllerTextEditPrecioVenta.numberValue == 0.0) { return 'Por favor, escriba un precio de venta'; }
                      return null;
                    },
                  ),
                ), 
                space,
                // view : control de stock
                AnimatedContainer(
                  width:double.infinity, 
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(border: Border.all(color: controller.getFavorite?Colors.amber :boderLineColor,width: 0.5,),),
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal:12, vertical: 12),
                    enabled: controller.getDataUploadStatus ? false : true,
                    checkColor: Colors.white,
                    activeColor: Colors.amber,
                    value: controller.getFavorite,
                    tileColor: controller.getFavorite?Colors.amber.withOpacity(0.1):null,
                    title: Text(controller.getFavorite?'Quitar de favorito':'Agregar a favorito'),
                    subtitle: controller.getFavorite?null: const Opacity(opacity: 0.5,child: Text('Accede rápidamente a tus productos favoritos')),
                    onChanged: (value) {
                      if (!controller.getDataUploadStatus) { controller.setFavorite = value ?? false; }
                    },
                  ),
                ),
                space,
                //
                // view : control stock
                // 
                AnimatedContainer(
                  width:double.infinity, 
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(color: controller.getStock?Colors.grey.withOpacity(0.05):null,border: Border.all(color: controller.getStock?Colors.grey:boderLineColor,width: 0.5,),),
                  child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal:12,vertical: 12),
                      //enabled: controller.getHomeController.getIsSubscribedPremium?controller.getSaveIndicator ? false : true:false,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: controller.homeController.getIsSubscribedPremium?controller.getStock:false,
                      title: Text(controller.getHomeController.getIsSubscribedPremium?controller.getStock?'Quitar control de stock':'Agregar control de stock':'Control de stock'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.getHomeController.getIsSubscribedPremium?Container():LogoPremium(personalize: true,id: 'stock'),
                          controller.getStock?Container():const Opacity(opacity: 0.5,child: Text('Controla el inventario de este producto')),
                        ],
                      ), 
                      onChanged: (value) {
                        if(controller.homeController.getIsSubscribedPremium){
                          // esta subscripcion es premium
                          // condition : si el usuario no esta guardando el producto
                          if (!controller.getDataUploadStatus) {
                            controller.setStock = value ?? false;
                          }
                        }else{
                          // no esta subscripcion 
                          controller.homeController.showModalBottomSheetSubcription(id: 'stock');
                        }
                        
                      },
                    ),  
                    ComponentApp().divider(),
                    controller.getStock && controller.homeController.getIsSubscribedPremium? space : Container(), 
                    controller.getStock && controller.homeController.getIsSubscribedPremium?Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0,bottom: 12),
                          child: Opacity(opacity: 0.5,child: Text('Controla el inventario de este producto')),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12,),
                          child: Form(
                            key: controller.quantityStockFormKey,
                            child: TextFormField(
                              style: valueTextStyle,
                              enabled: !controller.getDataUploadStatus,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => controller.setQuantityStock =int.parse(controller.controllerTextEditQuantityStock .text),
                              decoration: InputDecoration(
                                filled: true,fillColor: fillColor,hoverColor: Colors.blue,
                                disabledBorder: InputBorder.none,
                                labelText: "Stock", 
                                border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                              ),
                              textInputAction: TextInputAction.done,
                              //style: textStyle,
                              controller: controller.controllerTextEditQuantityStock,
                              // validator: validamos el texto que el usuario ha ingresado.
                              validator: (value) {
                                if ( int.parse(controller.controllerTextEditQuantityStock.text )== 0) { return 'Por favor, escriba una cantidad'; }
                                return null;
                              },
                            ),
                          ),
                        ),
                        space,
                        Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                              child: TextField(
                                style: valueTextStyle,
                                enabled: !controller.getDataUploadStatus,
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>controller.setAlertStock = int.parse(controller.controllerTextEditAlertStock.text),
                                decoration: InputDecoration(
                                  filled: true,fillColor: fillColor,hoverColor: Colors.blue,
                                  disabledBorder: InputBorder.none,
                                  labelText: "Alerta de stock (opcional)", 
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                                ),
                                textInputAction: TextInputAction.done,
                                //style: textStyle,
                                controller: controller.controllerTextEditAlertStock,
                              ),
                            ) ,
                      ],
                    ):Container(),
                  ],
                  ),
                ),

                // text : marca de tiempo de la ultima actualización del documento
                !controller.getItsInTheCatalogue ? Container() :  Padding(
                  padding: const EdgeInsets.only(top: 50),
                  //child: Text('Actualizado ${}'),
                  child: Opacity(opacity: 0.5,child: Center(child: Text('Actualizado ${Publications.getFechaPublicacion(fechaActual: controller.getProduct.upgrade.toDate(), fechaPublicacion: Timestamp.now().toDate()).toLowerCase()}'))),
                ),
                // button : guardar
                const SizedBox(height:30),  
                //  button : guardar el producto
                ComponentApp().button( 
                  disable:controller.getDataUploadStatus == true   ,
                  onPressed: controller.save,
                  icon: Container(),
                  colorButton: Colors.blue,
                  padding:const EdgeInsets.all(0),
                  colorAccent: Colors.white,
                  text: controller.getItsInTheCatalogue?'Actualizar':'Agregar a mi cátalogo',
                ), 
                // button : elminar el documento
                controller.getDataUploadStatus? Container(): 
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
  Widget get widgetForModerator{
  // TODO : delete release
  return TextButton(
    onPressed: (){
      Get.bottomSheet(
        const OptionsModeratorsWidget(),
      );
    },
    child: const Text('opciones para moderadores',style: TextStyle(color: Colors.blue),textAlign: TextAlign.center,),
  );
}
  Widget textfielBottomSheetListOptions({required String labelText,String textValue = '',required Function() onTap,bool stateEdit = true,EdgeInsetsGeometry contentPadding = const EdgeInsets.all(12) }) {

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
          IconButton(icon: const Icon(Icons.add),onPressed: () => showDialogSetProvider(provider: Provider())),
        ],
      ),
      body:welcomeController.getProviderList.isEmpty?const Center(child: Text('Sin proveedores'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: welcomeController.getProviderList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Provider provider =welcomeController.getProviderList[index];
          
          return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      dense: true,
                      title: Text(provider.name.substring(0, 1).toUpperCase() + provider.name.substring(1)),
                      onTap: () {
                        controllerProductsEdit.setProvider = provider;
                        Get.back();
                      },
                      trailing: popupMenuItemProvider(provider: provider),
                    ),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                  ],
                );
        },
      ),
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
                          controller.categoryDelete(idCategory: provider.id).then((value) {
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

  showDialogSetProvider({required Provider provider}) async {

    // controllers 
    final CataloguePageController cataloguePageController = Get.find(); 

    // var
    bool loadSave = false;
    bool newProvider = false;
    TextEditingController textEditingController = TextEditingController(text: provider.name);

    if (provider.id == '') {
      newProvider = true;
      provider =  Provider();
      provider.id =  DateTime.now().millisecondsSinceEpoch.toString();
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
            TextButton( child: loadSave == false? Text(newProvider ? 'GUARDAR' : "ACTUALIZAR"): const CircularProgressIndicator(),
                onPressed: () async {
                  if (textEditingController.text != '') {
                    // set
                    provider.name = textEditingController.text;
                    setState(() => loadSave = true);
                    // save
                    await cataloguePageController.providerSave(provider: provider).whenComplete(() {
                      welcomeController.getProviderList.add(provider);
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
        title: const Text('Opciones para moderador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(  
          children: [  
            // textButton : buscar en google
            TextButton(
                onPressed: () async {
                  String clave = controller.controllerTextEditDescripcion.text;
                  Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                },
                child: const Text('Buscar por la descripción en Google' )),
            // textButton : buscar en google
            TextButton(
                onPressed: () async {
                  String clave = controller.getProduct.code;
                  Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                },
                child: const Text('Buscar por el código Google')), 
            const Divider(), 
            Row(
              children: [
                // textButtons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // button : incrementar seguidores
                    TextButton(
                        onPressed: !controller.getEditModerator?null: (){
                          setState(() {
                            controller.increaseFollowersProductPublic();
                          });
                        },
                        child: const Text('Incrementar'),
                    ),
                    // button : decrementar seguidores
                    TextButton(
                        onPressed: !controller.getEditModerator?null: (){
                          setState(() {
                            controller.descreaseFollowersProductPublic();
                          });
                        }, 
                        child: Text('Decrementar',style:TextStyle(color: !controller.getEditModerator?null:Colors.red)),
                    ),
                  ],
                ),
              const Spacer(),
                // text : cantidad de comercios que tienen el producto
              Opacity(opacity: 0.4,child: Text('${Publications.getFormatAmount(value: controller.getProduct.followers)} ${controller.getProduct.followers == 1 ? 'comercio' : 'comercios'}')),
              ],
            ),
            const Divider(),
            CheckboxListTile(
              enabled: controller.getEditModerator ? controller.getDataUploadStatus? false: true: false,
              checkColor: Colors.white,
              activeColor: Colors.blue,
              value: controller.getProduct.outstanding,
              title: const Text('Detacado'),
              onChanged: (value) {
                if (!controller.getDataUploadStatus) {
                  
                  setState(() {
                    controller.setOutstanding(value: value ?? false);
                  });
                }
              },
            ), 
            const Divider(),
            CheckboxListTile(
              enabled: controller.getEditModerator
                  ? controller.getDataUploadStatus
                      ? false
                      : true
                  : false,
              checkColor: Colors.white,
              activeColor: Colors.blue,
              value: controller.getProduct.verified,
              title: const Text('Verificado'),
              onChanged: (value) {
                if (controller.getEditModerator) {
                  if (!controller.getDataUploadStatus) {
                    setState(() {
                      controller.setCheckVerified(value: value ?? false);
                    });
                  }
                }
              },
            ),
            controller.getEditModerator ? Container() :SizedBox(height: !controller.getDataUploadStatus ? 12.0 : 0.0),
            controller.getEditModerator
                ? Container()
                : button(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    icon:const Icon(Icons.security, color: Colors.white),
                    onPressed: () { 
                      setState(() {
                        controller.setEditModerator = !controller.getEditModerator;
                      });
                    },
                    colorAccent: Colors.white,
                    colorButton:  Colors.orange,
                    text:  "Editar documento",
                  ), 
            // button : actualizar documento
            controller.getDataUploadStatus ||  !controller.getEditModerator
                ? Container()
                : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: button(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      icon:const Icon(Icons.security, color: Colors.white),
                      onPressed: controller.setProductPublicFirestoreAndBack,
                      colorAccent: Colors.white,
                      colorButton: Colors.green.shade400,
                      text: "Actualizar documento",
                    ),
                ),
            // button : eliminar documento
            controller.getDataUploadStatus || !controller.getEditModerator
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
            Opacity(opacity: 0.5,child: Center(child: Text('Creación ${Publications.getFechaPublicacion( fechaActual: controller.getProduct.documentCreation.toDate(),fechaPublicacion:  Timestamp.now().toDate()).toLowerCase()}'))), 
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
