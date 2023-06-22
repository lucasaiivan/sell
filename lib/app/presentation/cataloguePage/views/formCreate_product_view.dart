/// Copyright 2022 Logica Booleana Authors

// Dependencias de Flutter
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/presentation/cataloguePage/views/product_edit_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/widgets_utils.dart';
import '../controller/product_edit_controller.dart';


// view : tenemos una tarjeta de información del producto y debajo se muestra un carrusel con campos para agregar información del nuevo producto
// description  : este formulario se encarga de crear un producto nuevo
class FormCreateProductView extends StatefulWidget {
  const FormCreateProductView({Key? key}) : super(key: key);

  @override
  State<FormCreateProductView> createState() => _FormCreateProductViewState();
}

class _FormCreateProductViewState extends State<FormCreateProductView> {


// controllers
  ControllerProductsEdit  controller = Get.find();
 

  
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // set : obtenemos los nuevos valores 
    controller.darkMode = Theme.of(context).brightness == Brightness.dark;
    controller.cardProductDetailColor = controller.darkMode ?controller.formEditing?Colors.blueGrey.withOpacity(0.2):Colors.blueGrey.withOpacity(0.1) : Colors.grey.shade200;

    //  AnnotatedRegion : proporciona un valor a sus widgets hijos
    // SystemUiOverlayStyle : Especifica una preferencia para el estilo de la barra de estado del sistema
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      //  Theme : proporciona datos de tema a sus widgets hijos
      child: Theme(
        data: Theme.of(context).copyWith( 
          // style : estilo del AppBar
          appBarTheme: AppBarTheme(elevation: 0,color: Colors.transparent ,systemOverlayStyle: controller.darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.light,iconTheme: IconThemeData(color: controller.darkMode?Colors.white:Colors.white),titleTextStyle: TextStyle(color: controller.darkMode?Colors.white:Colors.white))),
        // WillPopScope : nos permite controlar el botón de retroceso del dispositivo
        child: WillPopScope(
        onWillPop: () => controller.onBackPressed(context: context),
        //  Scaffold : proporciona una estructura visual básica para la aplicación
          child: Scaffold(
            body: body(context: context),),
        ),
      ),
    );
  } 
  // MAIN WIDGETS
  PreferredSizeWidget get appbar{

    // values
    Color colorAccent = controller.darkMode?Colors.white:Colors.black;

    return AppBar(
      systemOverlayStyle: controller.darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: colorAccent),
      title: Text(controller.getTextAppBar,style: TextStyle(  color: colorAccent,fontSize: 18 )),
    );
  }
  Widget body({required BuildContext context}){

    // values
    Color boderLineColor = Get.theme.textTheme.bodyMedium!.color ?? Colors.black;
    RoundedRectangleBorder shape  = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),side: BorderSide(color:boderLineColor,style: BorderStyle.none),);
    
    // SingleChildScrollView : Un cuadro en el que se puede desplazar un solo widget
    // Este widget es útil cuando tiene un solo cuadro que normalmente será completamente visible, por ejemplo,la aparición del teclado del sistema, pero debe asegurarse de que se pueda desplazar si el contenedor se vuelve demasiado pequeño en un eje (la dirección de desplazamiento )
    return Column(
      children: [
        Flexible(
          flex: 1,fit: FlexFit.tight,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Form : Crea un contenedor para campos de formulario
            child: Column(
              children: [
                appbar,
                controller.getSaveIndicator? ComponentApp().linearProgressBarApp(color: controller.colorLoading):lineProgressIndicator,
                // view : tarjeta animada
                cardFront,
                // chips : chips de información
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Theme(
                    data: ThemeData.light(),
                    child: Wrap(
                      spacing: 5.0, // establece el espacio negativo para compactar horizontalmente  
                      alignment:  WrapAlignment.center,
                      children: [
                        controller.controllerTextEditCategory.text==''?Container():InputChip(shape:shape,checkmarkColor: Colors.red,surfaceTintColor: Colors.green,onPressed: (){controller.carouselController.animateToPage(3, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label: Text(controller.controllerTextEditCategory.text)),
                        controller.controllerTextEditPrecioCosto.numberValue==0.0?Container():InputChip(shape:shape,onPressed: (){controller.carouselController.animateToPage(4, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label: Text(Publications.getFormatoPrecio(monto: controller.controllerTextEditPrecioCosto.numberValue))),
                        controller.getPorcentage==''?Container():InputChip(shape:shape,onPressed: (){controller.carouselController.animateToPage(5, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label: Text( controller.getPorcentage )),
                        controller.controllerTextEditPrecioVenta.numberValue==0.0?Container():InputChip(shape:shape,onPressed: (){controller.carouselController.animateToPage(5, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label: Text(Publications.getFormatoPrecio(monto: controller.controllerTextEditPrecioVenta.numberValue))),
                        controller.getFavorite? InputChip(shape:shape,onPressed: (){controller.carouselController.animateToPage(6, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label:const  Text('Favorito')):Container(),
                        controller.getStock? InputChip(shape:shape,onPressed: (){controller.carouselController.animateToPage(7, duration:const Duration(milliseconds: 500), curve: Curves.ease);},label: const Text('Control de Stock')):Container(),
                      ],
                    ),
                  ),
                ),
                // text and button : modificar porcentaje de ganancia
                controller.getPorcentage == '' || controller.currentSlide != 5 ? Container() : Padding(
                  padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                  child: Row(
                    children: [  
                      TextButton(onPressed: controller.showDialogAddProfitPercentage, child: Text( controller.getPorcentage )),
                      const Spacer(),
                      TextButton(onPressed: controller.showDialogAddProfitPercentage , child: const Text( 'Modificar porcentaje' )),
                    ],
                  ),
                ),
                // formTexts
                controller.getSaveIndicator? Container():textFieldCarrousel(),
              ],
            ),
          ),
        ),
        // buttons : back and next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // button : back
            TextButton(
              onPressed: controller.getSaveIndicator?null:controller.currentSlide==0?null:(){
              controller.previousPage();
              }, 
              child: Text('Anterior',style: TextStyle(color: controller.currentSlide==0?Colors.grey:null),),
            ),
            // button : next o save
            Center(
              child: TextButton( 
                onPressed: controller.getSaveIndicator?null:controller.currentSlide == 8?controller.getUserConsent?controller.save:null :() => controller.next(),
                child: Text( controller.currentSlide == 8  ?'Publicar':'Siguiente')),
            ),
          ],
        )
      ],
    );
  }
  // COMPONENTS WIDGETS
  PreferredSize get lineProgressIndicator{
    return PreferredSize(
  preferredSize: const Size.fromHeight(0.0),
  child: LinearProgressIndicator(
    backgroundColor: Colors.grey.withOpacity(0.5),
    valueColor: const AlwaysStoppedAnimation(Colors.blue),
    minHeight: 2,
    value: controller.getProgressForm,
  ),
);
  }
  Widget textTitleAndDescription({required String title,required String description,bool highlightValue = false}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(opacity: 0.6,child: Text(title,textAlign: TextAlign.start,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w400))),
            const SizedBox(height: 5),
            AnimatedContainer(
              width: double.infinity, 
              padding: const EdgeInsets.symmetric(horizontal:5,vertical:0),
              color: highlightValue?Colors.black12:null,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: Text(description,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w300))),
            
          ],
        ),
      ),
    );
  }

  //  view : carrusel de textFormField
  Widget textFieldCarrousel() {
    // List : lista de widgets con los textFormField y contenido de cada campo del formulario
    List<Widget> listWidgetss = [
      textButtonAddImage,
      descriptionProductCardTextFormField, 
      markProductCardTextFormField,
      categoryCatalogueTextFormField,  
      priceBuyProductCardTextFormField,
      priceSaleProductCardTextFormField,
      favoriteProductCardCheckbox,
      stockProductCardCheckbox,
      consentProductCardCheckbox,
      ];

    return Padding(
      padding: const EdgeInsets.only(top:12),
      child: CarouselSlider.builder(
        carouselController: controller.carouselController,
        options: CarouselOptions(  
          height: 400,
            scrollPhysics: const NeverScrollableScrollPhysics(), 
            onPageChanged: (index, reason) {
              controller.currentSlide = index;
      
              switch(index){
                case 0 : // seleccion de una imagen para el producto
                  FocusScope.of(context).unfocus(); // quita el foco 
                  break;
                case 1 : // descripcion
                  controller.descriptionTextFormFieldfocus.requestFocus(); // pide el foco
                  break;
                case 2 :  // marca 
                  FocusScope.of(context).unfocus(); // quita el foco
                  break; 
                case 3 : // cátegoria
                  FocusScope.of(context).previousFocus(); // quita el foco
                  break; 
                case 4: // precio de compra
                  controller.purchasePriceTextFormFieldfocus.requestFocus();  // pide el foco
                  break;
                case 5: // precio de venta al publico
                  controller.salePriceTextFormFieldfocus.requestFocus();  //  pide el foco
                  break;
                default: 
                FocusScope.of(context).previousFocus(); // quita el foco
                  break;
              }
              // actualiza la vista
              setState(() {});

            },
            viewportFraction: 0.95,
            enableInfiniteScroll:false,
            //autoPlay: listWidgetss.length == 1 ? false : true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            //options: CarouselOptions(enableInfiniteScroll: lista.length == 1 ? false : true,autoPlay: lista.length == 1 ? false : true,aspectRatio: 2.0,enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.scale),
            itemCount: listWidgetss.length,
            itemBuilder: (context, index, realIndex) { 
              // values
              bool focusWidget = controller.currentSlide == index ? true : false; // si el foco esta en el widget actual
              // AnimatedOpacity : anima el cambio de opacidad del widget segun el foco actual
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: focusWidget ? 1.0 : 0.3,
                // widget
                child: listWidgetss[index],
              );
            },
      ),
    );
  } 
  // WIDGET : un boton para cargar una imagen
  Widget get textButtonAddImage{
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => controller.showModalBottomSheetCambiarImagen(),
            child: Text('Cargar foto',style: TextStyle(color: controller.colorButton,fontSize: 18,fontWeight: FontWeight.w400)),
          ),
        ),
        const Spacer(),
      ],
    );
  }
// WIDGET : un textFormField para la descripción del producto
  Widget get descriptionProductCardTextFormField{
    // TextFormField : creamos una entrada númerico
    return Column(
      children: [
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
              child: const Text('Buscar en código Google (moderador)')
          ),
        // TextFormField : descripción del producto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: Form(
            key: controller.descriptionFormKey,
            child: TextFormField( 
              controller: controller.controllerTextEditDescripcion,
              enabled: true ,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              focusNode: controller.descriptionTextFormFieldfocus,
              maxLength: 100, // maximo de caracteres
              minLines: 1,
              maxLines:2, 
              inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\- .³%]')) ],
              decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Descripción del producto'),
              onChanged: (value) {
                controller.formEditing = true; // validamos que el usuario ha modificado el formulario
                controller.setDescription=value;  //  actualizamos el valor de la descripcion del producto
                setState((){});
              },
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if (value == null || value.isEmpty) { return 'Por favor, introduzca la descripción del producto'; }
                return null;
              },
            ),
          ),
        ),

      ],
    );
  }
  //  WIDGETS: un textfielf para la seleccion de la marca
  Widget get markProductCardTextFormField{
    // TextFormField : creamos una entrada de texto
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: GestureDetector(
            onTap: controller.showModalSelectMarca,
            child: Form(
              key: controller.markFormKey, 
              child: TextFormField( 
                autofocus: false,
                focusNode: null,
                controller: controller.controllerTextEditMark,
                enabled: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: 20, 
                keyboardType: TextInputType.name,
                decoration: InputDecoration(border: const UnderlineInputBorder(),
                labelText: controller.controllerTextEditMark.text=='' ? 'Seleccionar marca' : 'Marca',
                ),  
                onChanged: (value) => controller.formEditing = true, // validamos que el usuario ha modificado el formulario
                // validator: validamos el texto que el usuario ha ingresado. 
                validator: (value) {
                  if ( value == null || value.isEmpty) { 
                    Get.snackbar('Seleccione un marca', 'Este campo es esencial');
                    return 'Por favor, seleccione una marca'; 
                    }
                  return null;
                },   
              ),
            ),
          ),
        );
  } 
  // WIDGETS: un textfielf para la seleccion de la cátegoria del catalogo que se le va a asignar al producto
  Widget get categoryCatalogueTextFormField{

    // var 
    Color boderLineColor = Get.theme.textTheme.bodyMedium!.color ?? Colors.black;

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: GestureDetector(
            onTap: SelectCategory.show,
            child: TextFormField(
              autofocus: false,
              focusNode:null,
              controller: controller.controllerTextEditCategory,
              enabled: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 20, 
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: controller.controllerTextEditCategory.text==''?'Seleccionar una cátegoria':'Cátegoria',
                  border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor),),
                ),  
              onChanged: (value) => controller.formEditing = true, // validamos que el usuario ha modificado el formulario 
            ),
          ),
        );
  } 
  // WIDGETS: un textfielf para el precio de compra del producto
  Widget get priceBuyProductCardTextFormField{
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
      child: Form(
        key: controller.purchasePriceFormKey,
        child: TextFormField(
          style: const TextStyle(fontSize: 18),
          autofocus: true,
          focusNode:controller.purchasePriceTextFormFieldfocus,
          controller: controller.controllerTextEditPrecioCosto,
          enabled: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: 15, 
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Precio de compra'),   
          onChanged: (value){
            if( controller.controllerTextEditPrecioCosto.numberValue != 0){
              controller.setPurchasePrice = controller.controllerTextEditPrecioCosto.numberValue;
              controller.formEditing = true;
            }
             
          },
          // validator: validamos el texto que el usuario ha ingresado.
          validator: (value) {
            // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
            return null;
          },
        ),
      ),
    );
  } 
  // WIDGETS: un textfielf para el precio de venta al publico
  Widget get priceSaleProductCardTextFormField{
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: Form(
            key: controller.salePriceFormKey,
            child: TextFormField(
              style: const TextStyle(fontSize: 18),
              autofocus: true,
              focusNode:controller.salePriceTextFormFieldfocus,
              controller: controller.controllerTextEditPrecioVenta,
              enabled: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 15, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Precio de venta al público'),  
              onChanged: (value){
                if( controller.controllerTextEditPrecioVenta.numberValue != 0){
                  controller.setSalePrice = controller.controllerTextEditPrecioVenta.numberValue;
                  controller.formEditing = true;
                  setState(() {
                    
                  });
                }
              },
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if ( controller.controllerTextEditPrecioVenta.numberValue == 0.0) { return 'Por favor, escriba un precio de venta'; }
                return null;
              },
            ),
          ),
        );
  }
  //
  //  WIDGET : checkbox para seleccionar el producto como favorito
  //
  Widget get favoriteProductCardCheckbox{

    return Column(
      children: [
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal:12, vertical: 12),
          enabled: controller.getSaveIndicator ? false : true,
          checkColor: Colors.white,
          activeColor: Colors.amber,
          value: controller.getFavorite,
          title: Text(controller.getProduct.favorite?'Quitar de favorito':'Agregar a favorito'),subtitle: const Text('Accede rápidamente a tus productos favoritos'),
          onChanged: (value) {
            if (!controller.getSaveIndicator) { controller.setFavorite = value ?? false; }
          },
        ),
        const Spacer(),
      ],
    );
  }
  //
  // WIDGET : control de stock
  //
  Widget get stockProductCardCheckbox{

    // variable para el espacio entre los widgets
    Widget space = const SizedBox(height: 12.0, width: 12.0,);

    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal:20, vertical: 0),
      width: double.infinity,
      duration: const Duration(milliseconds: 500),
      child: Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: controller.getProduct.stock?12:0,vertical: 12),
          enabled: controller.getSaveIndicator ? false : true,
          checkColor: Colors.white,
          activeColor: Colors.blue,
          value: controller.getStock,
          title: Text(controller.getProduct.stock?'Quitar control de stock':'Agregar control de stock'),
          subtitle: const Text('Controlar el inventario de sus productos'),
          onChanged: (value) {
            if (!controller.getSaveIndicator) {
              controller.setStock = value ?? false;
            }
          },
        ),
        LogoPremium(personalize: true),
        controller.getStock  ? space : Container(), 
        AnimatedContainer(
          width: controller.getStock?null:0,
          height: controller.getStock?null:0,
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(border: Border.all(color: Get.theme.textTheme.bodyMedium!.color?? Colors.black12,width: 1,),),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12,),
                child: Form(
                  key: controller.quantityStockFormKey,
                  child: TextFormField(
                    enabled: !controller.getSaveIndicator,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.setQuantityStock =int.parse(controller.controllerTextEditQuantityStock .text),
                    decoration: const InputDecoration(
                      filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                      disabledBorder: InputBorder.none,
                      labelText: "Stock", 
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
                      enabled: !controller.getSaveIndicator,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>controller.setAlertStock = int.parse(controller.controllerTextEditAlertStock.text),
                      decoration: const InputDecoration(
                        filled: true,fillColor: Colors.transparent,hoverColor: Colors.blue,
                        disabledBorder: InputBorder.none,
                        labelText: "Alerta de stock (opcional)", 
                      ),
                      textInputAction: TextInputAction.done,
                      //style: textStyle,
                      controller: controller.controllerTextEditAlertStock,
                    ),
                  ) ,
            ],
          ),
        ),
      ],
      ),
      );
  }
  // WIDGET : concentimiento del usuario para crear el producto
  Widget get consentProductCardCheckbox{
    return ListView(
      children: [ 
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
            title: const Text('Entiendo que no seré el propietario de los datos públicos asociados con el producto, ni podré editarlos después de la verificación. Además, los precios de venta serán públicos',style: TextStyle(fontWeight: FontWeight.w300)),
            value: controller.getUserConsent,
            onChanged: (value) { 
              setState(() {
                controller.setUserConsent = value!;
               });
            },
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: controller.getUserConsent?null:0,
          padding: EdgeInsets.all(controller.getUserConsent?12.0:0),
          child: const Text('¡Gracias por hacer que esta aplicación sea aún más útil para más personas! 🚀'),
          ),
          ProductEdit().widgetForModerator,
      ],
    );
  }
  //
  // WIDGET : una tarjeta para mostrar la imagen del producto, el codigo del producto, la marca, la descripcion
  //
  Widget get cardFront{ 
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(color: controller.cardProductDetailColor,
        borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
                      crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,mainAxisSize: MainAxisSize.max,
                        children: [
                          //  text : codigo del producto
                          textTitleAndDescription(title: 'Código del producto',description: controller.getProduct.code,highlightValue: true),
                          //  text : marca del producto
                          textTitleAndDescription(title: 'Marca',description: controller.getMarkSelected.name,highlightValue: true),
                        ],
                      ),
                  ),
                )
              ],
            ),
            //  text : marca del producto
            textTitleAndDescription(title: 'Descripción del producto',description: controller.getDescription,highlightValue: true),
          ], 
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

  //  button  : icono y texto
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
