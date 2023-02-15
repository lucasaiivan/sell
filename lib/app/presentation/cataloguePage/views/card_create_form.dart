/// Copyright 2022 Logica Booleana Authors

// Dependencias de Flutter
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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

  // var
  Color cardProductDetailColor = Colors.grey.withOpacity(0.2);
  Color colorLoading = Colors.blue;
  bool darkMode = false;
  // var : estilo
  Color colorPrimary = Colors.grey;
  Color colorSecundary = Colors.grey;
 

  
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
    darkMode = Theme.of(context).brightness == Brightness.dark;

    // SystemUiOverlayStyle : Especifica una preferencia para el estilo de la barra de estado del sistema
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      // Theme : definismos estilos
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: colorPrimary, 
          // style : estilo del button
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(colorSecundary),shadowColor: MaterialStateProperty.all(colorSecundary))),
          // style : estilo del AppBar
          appBarTheme: AppBarTheme(elevation: 0,color: Colors.transparent ,systemOverlayStyle: darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.light,iconTheme: IconThemeData(color: darkMode?Colors.white:Colors.white),titleTextStyle: TextStyle(color: darkMode?Colors.white:Colors.white))),
        child: Scaffold(body: body(context: context)),
      ),
    );
  } 
  // MAIN WIDGETS
  PreferredSizeWidget get appbar{

    // values
    Color colorAccent = darkMode?Colors.white:Colors.black;

    return AppBar(
      systemOverlayStyle: darkMode?SystemUiOverlayStyle.light:SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: colorAccent),
      title: Text('Nuevo Producto',style:TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: colorAccent)),
      
    );
  }
  Widget body({required BuildContext context}){
    
    
    // SingleChildScrollView : Un cuadro en el que se puede desplazar un solo widget
    // Este widget es útil cuando tiene un solo cuadro que normalmente será completamente visible, por ejemplo,la aparición del teclado del sistema, pero debe asegurarse de que se pueda desplazar si el contenedor se vuelve demasiado pequeño en un eje (la dirección de desplazamiento )
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Form : Crea un contenedor para campos de formulario
            child: Form(
              key: controller.formKey, // identifique de forma única el widget de formulario
              child: Column(
                children: [
                  Column(
                    children: [
                      appbar,
                      // view : progress indicator
                      LinearProgressIndicator(backgroundColor: Colors.grey.withOpacity(0.5),valueColor: const AlwaysStoppedAnimation(Colors.blue),minHeight: 2,value: controller.getProgressForm),
                      // view : tarjeta animada
                      Padding(padding: const EdgeInsets.all(20.0),child: cardFront),
                      // formTexts
                      textFieldCarrousel(),
                    ],
                  ),
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
                onPressed: controller.currentSlide == 2?controller.controllerTextEditDescripcion.text!=''&&controller.controllerTextEditMark.text!=''?controller.saveProductNewForm:null :() => controller.next(),
                child: Text( controller.currentSlide == 2  ?'Finalizar':'Siguiente')),
            ),
          ],
        )
      ],
    );
  }
  // COMPONENTS WIDGETS
  Widget textTitleAndDescription({required String title,required String description}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(title,textAlign: TextAlign.start,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            AnimatedContainer(
              color: description.isEmpty?Colors.transparent:Colors.grey.withOpacity(0.2),
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
      ];

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CarouselSlider.builder(
        carouselController: controller.carouselController,
        options: CarouselOptions(  
            scrollPhysics: const NeverScrollableScrollPhysics(), 
            onPageChanged: (index, reason) {
              controller.currentSlide = index;
              switch(index){
                case 0 :
                  //...
                  break;
                case 1 :
                  controller.descriptionTextFormFieldfocus.requestFocus();
                  break;
                case 2 :
                  FocusScope.of(context).unfocus();
                  break; 
                default: 
                  break;
              }
              setState(() {});
            },
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
        child: const Text('Agregar imagen',style: TextStyle(color: Colors.blue)),
      ),
    );
  }
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
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9- ]')),
            ],
            decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Descripción del producto'),
            onChanged: (value) {
              controller.getProduct.description=value;
              colorPrimary = value==''?Colors.grey: Colors.deepPurple;
              colorSecundary = value==''?Colors.grey:Colors.purple;
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
  Widget get markProductCardTextFormField{
    // TextFormField : creamos una entrada de texto
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: GestureDetector(
            onTap: controller.showModalSelectMarca,
            child: TextFormField( 
              autofocus: false,focusNode: null,
              controller: controller.controllerTextEditMark,
              enabled: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 20, 
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(border: UnderlineInputBorder(),labelText: 'Marca'),  
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if (value == null || value.isEmpty) { return 'Por favor, seleccione una marca'; }
                return null;
              },
            ),
          ),
        );
  } 
  
  Widget get cardFront{ 


    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(color: cardProductDetailColor,
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
                          controller.getProduct.code != ""
                              ? Opacity(
                                  opacity: 0.8,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // icon : verificacion del producto
                                      controller.getProduct.verified?const Icon(Icons.verified_rounded,color: Colors.blue, size: 20): ImageBarWidget(size: 24),
                                      const SizedBox(width: 2),
                                      // text : codigo del producto
                                      Text(controller.getProduct.code,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                )
                              : Container(),
                          //  text : marca del producto
                          textTitleAndDescription(title: 'Marca',description: controller.getProduct.nameMark),
                        ],
                      ),
                  ),
                )
              ],
            ),
            //  text : marca del producto
            textTitleAndDescription(title: 'Descripción del producto',description: controller.getProduct.description),
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