/// Copyright 2022 Logica Booleana Authors

// Dependencias de Flutter
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/cataloguePage/views/product_edit_view.dart';
import '../../../core/utils/widgets_utils.dart';
import '../controller/product_edit_controller.dart';


// view : tenemos una tarjeta de información del producto y debajo se muestra un carrusel con campos para agregar información del nuevo producto
// description  : este formulario se encarga de crear un producto nuevo
class CardCreateForm extends StatefulWidget {
  const CardCreateForm({Key? key}) : super(key: key);

  @override
  State<CardCreateForm> createState() => _CardCreateFormState();
}

class _CardCreateFormState extends State<CardCreateForm> {


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
    controller.cardProductDetailColor = controller.darkMode ?controller.formEditing?Colors.blueGrey.withOpacity(0.2):Colors.blueGrey.withOpacity(0.1) : controller.formEditing?Colors.brown.shade100.withOpacity(0.6):Colors.brown.shade100.withOpacity(0.2);

    // SystemUiOverlayStyle : Especifica una preferencia para el estilo de la barra de estado del sistema
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      // Theme : definismos estilos
      child: Theme(
        data: Theme.of(context).copyWith( 
          // style : estilo del AppBar
          appBarTheme: AppBarTheme(elevation: 0,color: Colors.transparent ,systemOverlayStyle: controller.darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.light,iconTheme: IconThemeData(color: controller.darkMode?Colors.white:Colors.white),titleTextStyle: TextStyle(color: controller.darkMode?Colors.white:Colors.white))),
        child: Scaffold(body: body(context: context)),
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
      title: Text('Nuevo Producto',style:TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: colorAccent)),
      
    );
  }
  Widget body({required BuildContext context}){
    
    
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
            child: Form(
              key: controller.formKey, // identifique de forma única el widget de formulario
              child: Column(
                children: [
                  appbar,
                  // view : progress indicator
                  LinearProgressIndicator(backgroundColor: Colors.grey.withOpacity(0.5),valueColor: const AlwaysStoppedAnimation(Colors.blue),minHeight: 2,value: controller.getProgressForm),
                  // view : tarjeta animada
                  cardFront,
                  // formTexts
                  textFieldCarrousel(),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // button : back
             TextButton(
              onPressed: controller.currentSlide==0?null:(){
              controller.previousPage();
            }, child: Text('Anterior',style: TextStyle(color: controller.currentSlide==0?Colors.grey:null),)),
            // button : next o save
            Center(
              child: TextButton( 
                onPressed: controller.currentSlide == 8?controller.controllerTextEditDescripcion.text!=''&&controller.controllerTextEditMark.text!='' && controller.getUserConsent ? controller.saveProductNewForm :null :() => controller.next(),
                child: Text( controller.currentSlide == 8  ?'Finalizar':'Siguiente')),
            ),
          ],
        )
      ],
    );
  }
  // COMPONENTS WIDGETS
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
              color: highlightValue?Colors.grey.withOpacity(0.15):null,
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
    // var
    List<Widget> listWidgetss = [
      textButtonAddImage,
      descriptionProductCardTextFormField(), 
      markProductCardTextFormField,
      categoryCatalogueTextFormField,  
      priceBuyProductCardTextFormField,
      priceSaleProductCardTextFormField,
      favoriteProductCardCheckbox,
      stockProductCardCheckbox,
      consentProductCardCheckbox,
      ];

    return SizedBox( 
      width: double.infinity,
      child: CarouselSlider.builder(
        carouselController: controller.carouselController,
        options: CarouselOptions(  
          height: 400,
            scrollPhysics: const NeverScrollableScrollPhysics(), 
            onPageChanged: (index, reason) {
              controller.currentSlide = index;

              switch(index){
                case 0 : // seleccion de una imagen para el producto
                  //...
                  break;
                case 1 : // descripcion del producto
                  controller.descriptionTextFormFieldfocus.requestFocus();
                  break;
                case 2 :  // marca del producto
                  FocusScope.of(context).unfocus();
                  break; 
                case 3 : // categoria del producto
                  FocusScope.of(context).unfocus();
                  break; 
                case 4: // precio de compra
                  controller.purchasePriceTextFormFieldfocus.requestFocus();
                  break;
                case 5: // precio de venta
                  controller.salePriceTextFormFieldfocus.requestFocus();
                  break;
                default: 
                  break;
              }
              setState(() {});
            },viewportFraction: 0.95,
            enableInfiniteScroll:false,
            //autoPlay: listWidgetss.length == 1 ? false : true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            //options: CarouselOptions(enableInfiniteScroll: lista.length == 1 ? false : true,autoPlay: lista.length == 1 ? false : true,aspectRatio: 2.0,enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.scale),
            itemCount: listWidgetss.length,
            itemBuilder: (context, index, realIndex) {
              //return cardPublicidad(context: context, item: lista[index]);
              // values
              bool focusWidget = controller.currentSlide == index ? true : false;
              // AnimatedOpacity : Versión animada de Opacity que cambia automáticamente la opacidad del niño durante un período determinado cada vez que cambia la opacidad dada
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
  Widget get textButtonAddImage{
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: () => controller.showModalBottomSheetCambiarImagen(),
        child: const Text('Actualizar imagen',style: TextStyle(color: Colors.blue)),
      ),
    );
  }
// WIDGET : un textFormField para la descripción del producto
  Widget descriptionProductCardTextFormField({bool enabled = true}){
    // TextFormField : creamos una entrada númerico
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: TextFormField( 
            controller: controller.controllerTextEditDescripcion,
            enabled: enabled ,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            focusNode: controller.descriptionTextFormFieldfocus,
            maxLength: 50,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\- .]'))
            ],
            decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Descripción del producto'),
            onChanged: (value) {
              controller.formEditing = true;
              controller.getProduct.description=value; 
              setState((){});
            },
            // validator: validamos el texto que el usuario ha ingresado.
            validator: (value) {
              if (value == null || value.isEmpty) { return 'Por favor, introduzca la descripción del producto'; }
              return null;
            },
          ),
        );
  }
  //  WIDGETS: un textfielf para la seleccion de la marca
  Widget get markProductCardTextFormField{
    // TextFormField : creamos una entrada de texto
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: GestureDetector(
            onTap: controller.showModalSelectMarca,
            child: TextFormField( 
              autofocus: false,
              focusNode: null,
              controller: controller.controllerTextEditMark,
              enabled: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 20, 
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Marca'),  
              onChanged: (value) => controller.formEditing = true,
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if (value == null || value.isEmpty) { return 'Por favor, seleccione una marca'; }
                return null;
              },
            ),
          ),
        );
  } 
  // WIDGETS: un textfielf para la seleccion de la categoria del catalogo que se le va a asignar al producto
  Widget get categoryCatalogueTextFormField{
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
              decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Cátegoria'),  
              onChanged: (value) => controller.formEditing = true,
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if (value == null || value.isEmpty) { return 'Por favor, seleccione una cátegoria'; }
                return null;
              },
            ),
          ),
        );
  } 
  // WIDGETS: un textfielf para el precio de compra del producto
  Widget get priceBuyProductCardTextFormField{
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: TextFormField(
            autofocus: true,
            focusNode:controller.salePriceTextFormFieldfocus,
            controller: controller.controllerTextEditPrecioCompra,
            enabled: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: 20, 
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Precio de compra'),  
            onChanged: (value){
              controller.getProduct.purchasePrice = controller.controllerTextEditPrecioCompra.numberValue;
              controller.formEditing = true;
            },
            // validator: validamos el texto que el usuario ha ingresado.
            validator: (value) {
              // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
              return null;
            },
          ),
        );
  } 
  // WIDGETS: un textfielf para el precio de venta al publico
  Widget get priceSaleProductCardTextFormField{
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: TextFormField(
            autofocus: true,
            focusNode:controller.salePriceTextFormFieldfocus,
            controller: controller.controllerTextEditPrecioVenta,
            enabled: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: 20, 
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Precio de venta al públuco'),  
            onChanged: (value){
              controller.getProduct.salePrice = controller.controllerTextEditPrecioVenta.numberValue;
              controller.formEditing = true;
            },
            // validator: validamos el texto que el usuario ha ingresado.
            validator: (value) {
              // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de venta'; }
              return null;
            },
          ),
        );
  }
  //  WIDGET : checkbox para seleccionar el producto como favorito
  Widget get favoriteProductCardCheckbox{
    return CheckboxListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal:12, vertical: 12),
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
    );
  }
  // WIDGET : control de stock
  Widget get stockProductCardCheckbox{

    // variable para el espacio entre los widgets
    Widget space = const SizedBox(height: 12.0, width: 12.0,);

    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal:20, vertical: 0),
      width: double.infinity,
                      duration: const Duration(milliseconds: 500),
                      //color: controller.getProduct.stock?Colors.blue.withOpacity(0.07):Colors.transparent,
                      child: Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: controller.getProduct.stock?12:0,vertical: 12),
                            enabled: controller.getSaveIndicator ? false : true,
                            checkColor: Colors.white,
                            activeColor: Colors.blue,
                            value: controller.getProduct.stock?controller.isSubscribed:false,
                            title: Column(
                              children: [
                                const Text('Control de stock'),
                                const SizedBox(height: 5),
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
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            color: controller.getProduct.stock?Colors.blue.withOpacity(0.05):Colors.transparent,
                            child: Column(
                              children: [
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
                        ],
                      ),
                    );
  }
  // WIDGET : concentimiento del usuario para crear el producto
  Widget get consentProductCardCheckbox{
    return Column(
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
          padding: EdgeInsets.all(controller.getUserConsent?12.0:0),
          child: const Text('¡Gracias por hacer que esta aplicación sea aún más útil para más personas! 🚀'),
          ),
      ],
    );
  }
  // WIDGET : una tarjeta para mostrar la imagen del producto, el codigo del producto, la marca, la descripcion
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
                          textTitleAndDescription(title: 'Código del producto',description: controller.getProduct.code,highlightValue: false),
                          //  text : marca del producto
                          textTitleAndDescription(title: 'Marca',description: controller.getProduct.nameMark,highlightValue: true),
                        ],
                      ),
                  ),
                )
              ],
            ),
            //  text : marca del producto
            textTitleAndDescription(title: 'Descripción del producto',description: controller.getProduct.description,highlightValue: true),
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