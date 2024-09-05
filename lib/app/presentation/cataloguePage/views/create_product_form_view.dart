import 'package:animate_do/animate_do.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:search_page/search_page.dart'; 
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart'; 
import '../controller/form_create_product_controller.dart';

class ProductNewFormView extends StatelessWidget {
  ProductNewFormView({super.key});

  // controllers
  final ControllerCreateProductForm controller = Get.find();

  // context
  late final BuildContext context;

  @override
  Widget build(BuildContext context) {
    // set : obtenemos los nuevos valores
    context = context;
    controller.darkMode = Theme.of(context).brightness == Brightness.dark;

    //  AnnotatedRegion : proporciona un valor a sus widgets hijos
    // SystemUiOverlayStyle : Especifica una preferencia para el estilo de la barra de estado del sistema
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      //  Theme : proporciona datos de tema a sus widgets hijos
      child: Theme(
        data: Theme.of(context).copyWith(
            // style : estilo del AppBar
            appBarTheme: AppBarTheme(
                elevation: 0,
                color: Colors.transparent,
                systemOverlayStyle: controller.darkMode
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.light,
                iconTheme: IconThemeData(
                    color: controller.darkMode ? Colors.white : Colors.white),
                titleTextStyle: TextStyle(
                    color: controller.darkMode ? Colors.white : Colors.white))),
        // WillPopScope : nos permite controlar el botón de retroceso del dispositivo
        child: PopScope(
          canPop: false, // si se puede retroceder
          onPopInvoked: (_) => controller.onBackPressed(context: context),
          //  Scaffold : proporciona una estructura visual básica para la aplicación
          child: GetBuilder<ControllerCreateProductForm>(
            init: ControllerCreateProductForm(),
            initState: (_) {},
            builder: (_) {
              return Scaffold(
                appBar: appbar,
                body: body(context: context),
              );
            },
          ),
        ),
      ),
    );
  }

  // MAIN WIDGETS
  PreferredSizeWidget get appbar {

    // values
    Color colorAccent = controller.darkMode ? Colors.white : Colors.black;
    bool imageProductExist = controller.getProduct.image != '' ||
        controller.getXFileImage.path != '' && controller.getCurrentSlide != 0;
    String title = controller.getProduct.description != ''
        ? controller.getProduct.description
        : controller.getTextAppBar;
    // widgets
    final Widget dividerCircle = ComponentApp().dividerDot(color: colorAccent); 
    Widget brandText = controller.getProduct.nameMark != '' ? Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dividerCircle,
          Flexible(child: Text(controller.getProduct.nameMark,overflow:TextOverflow.ellipsis,style: const TextStyle(fontSize:12),)),
        ],
      ),
    ):Container();
    Widget proceSaleText = controller.getSalePrice != 0 ? Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dividerCircle,
          Flexible(child: Text(Publications.getFormatoPrecio(value: controller.getSalePrice),overflow:TextOverflow.ellipsis,style: const TextStyle(fontSize:12),)),
        ],
      ),
    ):Container();

    // widgets
    Widget titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // text : titulo o nombre del producto
        Row(
          children: [
            // image : imagen del producto
            imageProductExist ? controller.loadImage(size: 40) : Container(),
            imageProductExist ? const SizedBox(width: 12) : Container(),
            // text : nombre del producto
            SizedBox(width: 200,child: Text(title, style: TextStyle(color: colorAccent,fontSize:18),overflow: TextOverflow.ellipsis)),
          ],
        ), 
        // text : codigo
        Row(
          children: [
            controller.getProduct.code != ''
                ? Opacity(opacity: 0.5,
                  child: Text('${controller.getProduct.code}${controller.getProduct.local?' (Catálogo)':''}',
                      style: TextStyle(color: colorAccent, fontSize: 12)),
                )
                : Container(),
          brandText,
          proceSaleText,
          ],
        ),
      ],
    );
    // si se esta guardando los datos del producto
    if (controller.getDataUploadStatus) {
      titleWidget = Text(controller.getTextAppBar,
          style: TextStyle(color: colorAccent, fontSize: 18));
    }

    return AppBar(
      systemOverlayStyle: controller.darkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: colorAccent),
      title: titleWidget,
      bottom: controller.getDataUploadStatus
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: ComponentApp().linearProgressBarApp(color: controller.colorLoading))
          : PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: lineProgressIndicator),
    );
  }

  Widget body({required BuildContext context}) {
    // si se esta guardando los datos del producto
    if (controller.getDataUploadStatus) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            cardFront,
            AnimatedContainer(
              duration: const Duration(milliseconds: 500), 
              padding: const EdgeInsets.all( 12),
              child: const Text( '¡Gracias por hacer que esta aplicación sea aún más útil para más personas! 🚀',textAlign: TextAlign.center),
            ),
          ],
        ),
      );
    }

    // SingleChildScrollView : Un cuadro en el que se puede desplazar un solo widget
    // Este widget es útil cuando tiene un solo cuadro que normalmente será completamente visible, por ejemplo,la aparición del teclado del sistema, pero debe asegurarse de que se pueda desplazar si el contenedor se vuelve demasiado pequeño en un eje (la dirección de desplazamiento )
    return Column(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              controller.getDataUploadStatus
                  ? Container()
                  : textFieldCarrousel(),
            ],
          ),
        ),
        // buttons : back and next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // button : back
            TextButton(
              onPressed: controller.getDataUploadStatus
                  ? null
                  : controller.getCurrentSlide == 0 || (controller.getProduct.local && controller.getCurrentSlide == 1) 
                      ? null
                      : () {
                          controller.previousPage();
                        },
              child: Text(
                'Anterior',
                style: TextStyle(
                    color: controller.getCurrentSlide == 0 ? Colors.grey : null),
              ),
            ),
            // button : next o save
            Center(
              child: TextButton(
                  onPressed: controller.getDataUploadStatus
                      ? null
                      : controller.getCurrentSlide == 9 ? controller.getUserConsent? controller.save : null: () => controller.next(),
                  child: Text(
                      controller.getCurrentSlide == 9 ? 'Publicar' : 'Siguiente')),
            ),
          ],
        )
      ],
    );
  }

  // COMPONENTS WIDGETS
  PreferredSize get lineProgressIndicator {
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

  Widget textTitleAndDescription(
      {required String title,
      required String description,
      bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(opacity: 0.6,child: Text(title,textAlign: TextAlign.start,style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400))),
            const SizedBox(height: 5),
            AnimatedContainer(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                color: highlightValue ? Colors.black12 : null,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: Text(description,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w300))),
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
      providerProductCardTextFormField,
      priceBuyProductCardTextFormField,
      priceSaleProductCardTextFormField,
      favoriteProductCardCheckbox,
      stockProductCardCheckbox,
      consentProductCardCheckbox,
    ];

    return SizedBox(
      height: 600,
      child: PageView.builder(
        controller: controller.carouselController,
        physics: const NeverScrollableScrollPhysics(), // Desactiva el desplazamiento táctil
        onPageChanged: (index) {
      
          controller.setCurrentSlide = index;
      
          switch (index) {
            case 0: // seleccion de una imagen para el producto
              SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco
              break;
            case 1: // descripcion
              controller.descriptionTextFormFieldfocus.requestFocus(); // pide el foco
              break;
            case 2: // marca
              SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco
              break;
            case 3: // cátegoria
              SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco
              break;
            case 4: // proveedor
              SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco
              break;
            case 5: // precio de compra
              controller.purchasePriceTextFormFieldfocus.requestFocus(); // pide el foco
              break;
            case 6: // precio de venta al publico
              controller.salePriceTextFormFieldfocus .requestFocus(); //  pide el foco
              break;
            default:
              SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco
              break;
          }
          
        },
        itemBuilder: (context, index) {
          // values
          bool focusWidget = controller.getCurrentSlide == index
              ? true
              : false; // si el foco esta en el widget actual
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
  Widget get textButtonAddImage {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => controller.showModalBottomSheetCambiarImagen(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                controller.loadImage(size: 250),
                const SizedBox(height: 20),
                Text('Actualizar foto',
                    style: TextStyle(
                        color: controller.colorButton,
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
                Opacity(
                    opacity: 0.5,
                    child: Text('visibilidad publica',
                        style: TextStyle(
                            color: controller.colorButton,
                            fontSize: 12,
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

// WIDGET : un textFormField para la descripción del producto
  Widget get descriptionProductCardTextFormField {
    // TextFormField : creamos una entrada númerico
    return Column(
      children: [
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //TODO: release : disabled code
            /* Container(
              color: Colors.black.withOpacity(0.01),
              padding: const EdgeInsets.symmetric(horizontal:20,vertical:1),
              margin: const EdgeInsets.symmetric(  vertical:20),
              child: Row(
                children: [ 
                  const Text('Buscar en Google: '), 
                  TextButton(
                      onPressed: () async {
                        String clave = controller.getProduct.code;
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: const Text('El Código')),
                  TextButton(
                      onPressed: () async {
                        String clave = controller.controllerTextEditDescripcion.text;
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: const Text('La Descripción')),
                  
                ],
              ),
            ), */

            // text : texto infomativo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Escriba una descripción del producto',
                style: TextStyle(
                    color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                    fontSize: 18),
              ),
            ),
            // TextFormField : descripción del producto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Form(
                key: controller.descriptionFormKey,
                child: TextFormField(
                  controller: controller.controllerTextEditDescripcion,
                  enabled: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  focusNode: controller.descriptionTextFormFieldfocus,
                  maxLength: 100, // maximo de caracteres
                  minLines: 1,
                  maxLines: 2,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZÀ-ÿ0-9\- .³%]'))
                  ],
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: 'Descripción',
                      helperText: controller.getProduct.local?'':'Visibilidad pública'),
                  onChanged: (value) {
                    controller.formEditing =
                        true; // validamos que el usuario ha modificado el formulario
                    controller.setDescription =
                        value; //  actualizamos el valor de la descripcion del producto
                    controller.update();
                  },
                  // validator: validamos el texto que el usuario ha ingresado.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca la descripción del producto';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  //  WIDGETS: un textfielf para la seleccion de la marca
  Widget get markProductCardTextFormField {

    // style 
    TextStyle textStyle = TextStyle( color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black );
    // widget 
    Widget? circleAvatarBrand = controller.getMarkSelected.toString().isNotEmpty? Padding(
      padding: const EdgeInsets.all(12.0),
      child: ComponentApp().userAvatarCircle(urlImage: controller.getMarkSelected.image,empty: true),
    ): null;

    // TextFormField : creamos una entrada de texto
    return Column(
      children: [
        const Spacer(),
        // text : texto infomativo  
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text.rich(
            TextSpan(
              text: 'Elige una ',
              style: TextStyle(
                  color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                  fontSize: 18),
              children: const <InlineSpan>[
                TextSpan(
                  text: 'marca',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ), 
              ],
            ),
          ),
        ), 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap: controller.showModalSelectMarca,
            child: Form(
              key: controller.markFormKey,
              child: TextFormField(
                style: textStyle,
                autofocus: false,
                focusNode: null,
                controller: controller.controllerTextEditMark,
                enabled: false,
                autovalidateMode: AutovalidateMode.onUserInteraction, 
                keyboardType: TextInputType.name,
                decoration: InputDecoration( 
                  suffixIcon: circleAvatarBrand,
                  border: const UnderlineInputBorder(),  
                  labelText: controller.controllerTextEditMark.text == '' ? 'Seleccionar' : 'Marca',
                  helperText: controller.getProduct.local?'':'Visibilidad pública', 
                  
                ),  
                onChanged: (value) => controller.formEditing = true, // validamos que el usuario ha modificado el formulario
                // validator: validamos el texto que el usuario ha ingresado.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    Get.snackbar('Seleccione un marca', 'Este campo es esencial');
                    return 'Por favor, seleccione una marca';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGETS: un textfielf para la seleccion de la cátegoria del catalogo que se le va a asignar al producto
  Widget get categoryCatalogueTextFormField {
    // style 
    TextStyle textStyle = TextStyle( color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black );
    Color boderLineColor = Get.theme.textTheme.bodyMedium!.color ?? Colors.black;

    return Column(
      children: [
        const Spacer(),
        // text : texto infomativo  
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text.rich(
            TextSpan(
              text: 'Elige una ',
              style: TextStyle(
                  color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                  fontSize: 18),
              children: const <InlineSpan>[
                TextSpan(
                  text: 'categoría',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),  
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap: SelectCategory.show,
            child: TextFormField(
              style: textStyle,
              autofocus: false,
              focusNode: null,
              controller: controller.controllerTextEditCategory,
              enabled: false,
              autovalidateMode: AutovalidateMode.onUserInteraction, 
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: controller.controllerTextEditCategory.text == ''
                    ? 'Seleccionar'
                    : 'Cátegoria (opcional)',
                helperText: 'Visibilidad privada',
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: boderLineColor)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: boderLineColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: boderLineColor),
                ),
              ),
              onChanged: (value) => controller.formEditing =
                  true, // validamos que el usuario ha modificado el formulario
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
  // WIDGET : un textfield para seleccionar el proveedor
  Widget get providerProductCardTextFormField {
    
    // style 
    TextStyle textStyle = TextStyle( color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black );
    Color boderLineColor = Get.theme.textTheme.bodyMedium!.color ?? Colors.black;

    return Column(
      children: [
        const Spacer(),
        // text : texto infomativo con textrich 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text.rich(
            TextSpan(
              text: 'Elige un ',
              style: TextStyle(
                  color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                  fontSize: 18),
              children: const <InlineSpan>[
                TextSpan(
                  text: 'proveedor',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ), 
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap:  SelectProvider.show,
            child: TextFormField(
              style: textStyle,
              autofocus: false,
              focusNode: null,
              controller: controller.controllerTextEditProvider,
              enabled: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: controller.controllerTextEditProvider.text == ''
                    ? 'Seleccionar un proveedor'
                    : 'Proveedor (opcional)',
                helperText: 'Visibilidad privada',
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: boderLineColor)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: boderLineColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: boderLineColor),
                ),
              ),
              onChanged: (value) => controller.formEditing =
                  true, // validamos que el usuario ha modificado el formulario
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGETS: un textfield para el precio de compra del producto
  Widget get priceBuyProductCardTextFormField {
    return Column(
      children: [
        const Spacer(),
        // text : texto infomativo 'Escriba el precio de compra por mayor de una unidad'
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child:Text.rich(
            textAlign:  TextAlign.center,
            TextSpan(
              text: 'Escriba el precio de ',
              style: const  TextStyle( fontSize: 18),
              children: <InlineSpan>[
                const TextSpan(
                  text: 'costo',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' del producto',
                  style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                      fontSize: 18),
                ),
                TextSpan(
                  text: ' (opcional)',
                  style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Form(
            key: controller.purchasePriceFormKey,
            child: TextFormField(
              style: const TextStyle(fontSize: 18),
              focusNode: controller.purchasePriceTextFormFieldfocus,
              controller: controller.controllerTextEditPrecioCosto,
              enabled: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 15,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [AppMoneyInputFormatter()],
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Precio de compra (opcional)',
                  helperText: 'Visibilidad privada (solo tu puedes verlo)'),

              onChanged: (value) {
                if (controller.controllerTextEditPrecioCosto.doubleValue != 0) {
                  controller.setPurchasePrice = controller.controllerTextEditPrecioCosto.doubleValue;
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
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGETS: un textfield para el precio de venta al publico
  Widget get priceSaleProductCardTextFormField {
    return Column(
      children: [
        const Spacer(),
        // text : texto infomativo 'Escriba el precio de venta al publico'
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'Escriba el precio de ',
              style: const TextStyle(fontSize: 18),
              children: <InlineSpan>[
                const TextSpan(
                  text: 'venta',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' al público',
                  style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                      fontSize: 18),
                ), 
              ],
            ),
          ),
        ),
        // textfield : precio de venta al publico
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // text and button : modificar porcentaje de ganancia
              controller.getPorcentage == '' || controller.getCurrentSlide != 6
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Row(
                        children: [
                          TextButton(
                              onPressed: controller.showDialogAddProfitPercentage,
                              child: Text(controller.getPorcentage)),
                          const Spacer(),
                          TextButton(
                              onPressed: controller.showDialogAddProfitPercentage,
                              child: const Text('Modificar porcentaje')),
                        ],
                      ),
                    ),
              Form(
                key: controller.salePriceFormKey,
                child: TextFormField(
                  style: const TextStyle(fontSize: 18), 
                  focusNode: controller.salePriceTextFormFieldfocus,
                  controller: controller.controllerTextEditPrecioVenta,
                  enabled: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  maxLength: 15,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [AppMoneyInputFormatter()],
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Precio de venta',
                      helperText: 'Visibilidad pública (cualquier puede verlo)'),
                  onChanged: (value) {
                    if (controller.controllerTextEditPrecioVenta.doubleValue != 0) {
                      controller.setSalePrice = controller.controllerTextEditPrecioVenta.doubleValue;
                      controller.formEditing = true;
                      controller.update();
                    }
                  },
                  // validator: validamos el texto que el usuario ha ingresado.
                  validator: (value) {
                    if (controller.controllerTextEditPrecioVenta.doubleValue ==
                        0.0) {
                      return 'Por favor, escriba un precio de venta';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  //  WIDGET : checkbox para seleccionar el producto como favorito
  Widget get favoriteProductCardCheckbox {
    return Column(
      children: [
        const Spacer(),
        // view : icono y texto 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              // icon 
              Icon(Icons.star_rounded,
                  color: Colors.yellow[700],
                  size: 40),
              // text : texto infomativo 
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: '¿Quieres agregar este producto a tus ',
                  style: const TextStyle(fontSize: 18),
                  children: <InlineSpan>[
                    const TextSpan(
                      text: 'favoritos',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(
                          color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        
        ),
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabled: controller.getDataUploadStatus ? false : true,
          checkColor: Colors.white,
          activeColor: Colors.amber,
          value: controller.getFavorite,
          shape:  RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(5),
          ), 
          title: Text(controller.getProduct.favorite
              ? 'Quitar de favorito'
              : 'Agregar a favorito'),
          subtitle: const Text('Accede rápidamente a tus productos favoritos'),
          onChanged: (value) {
            if (!controller.getDataUploadStatus) {
              controller.setFavorite = value ?? false;
            }
          },
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGET : control de stock
  Widget get stockProductCardCheckbox {
    // variable para el espacio entre los widgets
    Widget space = const SizedBox(
      height: 12.0,
      width: 12.0,
    );

    return Column(
      children: [
        const Spacer(),
        // view : icono y texto 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              // icon 
              const Icon(Icons.inventory,
                  color: Colors.blue,
                  size: 40),
              // text : texto infomativo 
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: '¿Quieres controlar el ',
                  style: const TextStyle(fontSize: 18),
                  children: <InlineSpan>[
                    const TextSpan(
                      text: 'stock',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' de este producto?',
                      style: TextStyle(
                          color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // view : casilla de verificación y texto
        AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          width: double.infinity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              CheckboxListTile(
                // option premium : solo los usuarios premium pueden crear productos
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabled: true, 
                checkColor: Colors.white,
                activeColor: Colors.blue,
                value: controller.getStock,
                title: Text(controller.getProduct.stock ? 'Quitar control de stock' : 'Agregar control de stock'),
                subtitle: const Text('Controlar el inventario de sus productos'),
              
                shape:  RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: (value) {
                  // si esta subcripto a premium
                  if (!controller.getHomeController.getIsSubscribedPremium) {
                    controller.getHomeController.showModalBottomSheetSubcription(id: 'stock' );
                    return;
                  }
                  // si no esta subcripto a premium y no esta subiendo datos
                  if (!controller.getDataUploadStatus) {
                    controller.setStock = value ?? false;
                  }
                },
              ),
              const SizedBox(height: 12),
              // view :  logo premium : solo los usuarios premium pueden crear productos
              controller.getHomeController.getIsSubscribedPremium?Container():LogoPremium(personalize: true, id: 'stock'),
              controller.getStock ? space : Container(),
              AnimatedContainer(
                width: controller.getStock ? null : 0,
                height: controller.getStock ? null : 0,
                duration: const Duration(milliseconds: 500), 
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Form(
                        key: controller.quantityStockFormKey,
                        child: TextFormField( 
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !controller.getDataUploadStatus,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => controller.setQuantityStock = int.parse(controller.controllerTextEditQuantityStock.text),
                      
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            filled: true, 
                            hoverColor: Colors.blue,
                            disabledBorder: InputBorder.none,
                            labelText: "Stock",
                          ),
                          textInputAction: TextInputAction.done,
                          //style: textStyle,
                          controller: controller.controllerTextEditQuantityStock,
                          // validator: validamos el texto que el usuario ha ingresado.
                          validator: (value) {
                            if(controller.controllerTextEditQuantityStock.text==''){
                              return 'Por favor, escriba una cantidad';
                            }
                            if (int.parse(controller.controllerTextEditQuantityStock.text) ==0) {
                              return 'Por favor, escriba una cantidad';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    space,
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: TextField(
                        enabled: !controller.getDataUploadStatus,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => controller.setAlertStock =
                            int.parse(controller.controllerTextEditAlertStock.text),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                            filled: true,  
                          hoverColor: Colors.blue,
                          disabledBorder: InputBorder.none,
                          labelText: "Alerta de stock (opcional)",
                        ),
                        textInputAction: TextInputAction.done,
                        //style: textStyle,
                        controller: controller.controllerTextEditAlertStock,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGET : concentimiento del usuario para crear el producto
  Widget get consentProductCardCheckbox {

    // style 
    Color cardColor = Get.isDarkMode?Colors.black12:Colors.amber[50]!;

    return Column(
      children: [
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // text : texto infomativo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: '¿Aceptas los ',
                  style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                      fontSize: 18),
                  children: const <InlineSpan>[
                    TextSpan(
                      text: 'términos y condiciones?',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ), 
                  ],
                ),
              ),
            ),
            // CheckboxListTile : consentimiento de usuario para crear un producto
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 12), 
              child: CheckboxListTile(
                tileColor: cardColor, 
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Importante!\nAl crear un producto, entiendo y acepto lo siguiente: los datos básicos (descripción, imagen, marca) serán visibles para todos y podrían ser modificados por otros usuarios hasta que un moderador los verifique. Una vez verificados, no podré cambiar estos datos. El (precio de venta al público) también será visible para todos.',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                value: controller.getUserConsent,
                onChanged: (value) {
                  controller.setUserConsent = value!;
                },
              ),
            ),  
            // text : texto infomativo ' si acepto los terminos y condiciones'
            !controller.getUserConsent?Container():Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Si acepto los ',
                  style: TextStyle(
                      color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black,
                      fontSize: 18),
                  children: const <InlineSpan>[
                    TextSpan(
                      text: 'términos y condiciones',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ', para crear el producto',
                      style: TextStyle( 
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  // WIDGET : una tarjeta para mostrar la imagen del producto, el codigo del producto, la marca, la descripcion
  Widget get cardFront {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //  image : imagen del producto
              controller.loadImage(size: 100),
              // view : codigo,icon de verificaciones, descripcion y marca del producto
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //  text : codigo del producto
                      textTitleAndDescription(
                          title: 'Código del producto',
                          description: controller.getProduct.code,
                          highlightValue: true),
                      //  text : marca del producto
                      textTitleAndDescription(
                          title: 'Marca',
                          description: controller.getMarkSelected.name,
                          highlightValue: true),
                    ],
                  ),
                ),
              )
            ],
          ),
          //  text : marca del producto
          textTitleAndDescription(
              title: 'Descripción del producto',
              description: controller.getDescription,
              highlightValue: true),
        ],
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
          onPressed: disable ? null : onPressed,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
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
  // controllers
  final HomeController homeController = Get.find();
  final ControllerCreateProductForm createProductFormController = Get.find();

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
          IconButton(icon: const Icon(Icons.add),onPressed: (){  
            Get.back();
            showDialogSetCategoria(categoria: Category());
          }),
          // icon : buscar categoria
          IconButton(icon: const Icon(Icons.search),onPressed: (){
            Get.back();
            showSearchCategories();
          }),
        ],
      ),
      body: homeController.getCatalogueCategoryList.isEmpty?const Center(child: Text('Sin cátegorias'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: homeController.getCatalogueCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Category category =homeController.getCatalogueCategoryList[index];
          
          return Column(
            children: <Widget>[
              itemCategory(category: category),
              const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
            ],
          );
        },
      ),
    );

  }

  // WIDGETS COMPONENTS //
  Widget itemCategory({required Category category}){
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      dense: true,
      title: Text(category.name.substring(0, 1).toUpperCase() + category.name.substring(1)),
      onTap: () {
        createProductFormController.setCategory = category;
        homeController.categorySelected(category: category);
        Get.back();
      },
      trailing: popupMenuItemCategoria(categoria: category),
    );
  }
  Widget popupMenuItemCategoria({required Category categoria}) {

    // controllers
    final ControllerCreateProductForm controllerCreateProductForm = Get.find();
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
                                controllerCreateProductForm.controllerTextEditCategory.text = '';
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
  // DIALOG // 
  showDialogSetCategoria({required Category categoria}) async {

    // controllers 
    final ControllerCreateProductForm controllerCreateProductForm = Get.find();
    final HomeController controller = Get.find(); 
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
          title: Text(newProduct ? 'Crear' : "Editar"),
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
                    // save
                    await controller.categoryUpdate(categoria: categoria).whenComplete(() {
                      homeController.getCatalogueCategoryList.add(categoria);
                      controllerCreateProductForm.controllerTextEditCategory.text = categoria.name;
                      Get.back();
                    });
                  }
                })
          ],
        );
      },
    );
  }
  showSearchCategories(){
    // description : muestra la barra de busqueda para buscar las categorias

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    showSearch(
      context: context,
      delegate: SearchPage<Category>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: homeController.getCatalogueCategoryList,
        searchLabel: 'Buscar marca',
        suggestion: const Center(child: Text('ej. agua')),
        failure: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se encontro :('), 
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                Get.back();
                showDialogSetCategoria(categoria: Category());
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Crear categoria'),
            )
          ],
        )),
        filter: (category) => [Utils.normalizeText(category.name),Utils.normalizeText(category.name)],
        builder: (category) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[
          itemCategory(category: category),
          ComponentApp().divider(),
          ]),
      ),
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
  final HomeController homeController = Get.find();
  final ControllerCreateProductForm createProductFormController = Get.find();

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
          // iconButton : agregar nuevo proveedor
          IconButton(icon: const Icon(Icons.add),onPressed: (){Get.back();showDialogSetProvider(provider: Provider());}),
          // iconButton : buscar proveedor
          IconButton(icon: const Icon(Icons.search),onPressed: (){Get.back();showSearchProviders();}), 
        ],
      ),
      body:homeController.getProviderList.isEmpty?const Center(child: Text('Sin proveedores'),): ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: homeController.getProviderList.length,
        itemBuilder: (BuildContext context, int index) {
          //  values
          Provider provider =homeController.getProviderList[index];
          
          return Column(
                  children: <Widget>[
                    itemProvider(provider: provider),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                  ],
                );
        },
      ),
    );

  }
  // WIDGETS COMPONENTS //
  Widget itemProvider({required Provider provider}){
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      dense: true,
      title: Text(provider.name.substring(0, 1).toUpperCase() + provider.name.substring(1)),
      onTap: () {
        createProductFormController.setProvider = provider;
        homeController.providerSelected(provider: provider);
        Get.back();
      },
      trailing: popupMenuItemProvider(provider: provider),
    );
  }
  Widget popupMenuItemProvider({required Provider provider}) {

    // controllers
    final ControllerCreateProductForm controllerCreateProductForm = Get.find(); 
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
                      Expanded(child:Text("¿Desea continuar eliminando esta proveedor?"))
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
                                provider.name = ''; 
                                controllerCreateProductForm.controllerTextEditProvider.text = '';
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
  // DIALOG //
  showSearchProviders(){
    // description : muestra la barra de busqueda para buscar los proveedores

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    showSearch(
      context: context,
      delegate: SearchPage<Provider>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: homeController.getProviderList,
        searchLabel: 'Buscar proveedor',
        suggestion: const Center(child: Text('ej. coca cola')),
        failure: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se encontro :('), 
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                Get.back();
                showDialogSetProvider(provider: Provider());
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Crear proveedor'),
            )
          ],
        )),
        filter: (provider) => [Utils.normalizeText(provider.name) ],
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
    final ControllerCreateProductForm controllerCreateProductForm = Get.find(); 

    // var 
    bool newProvider = false;
    TextEditingController textEditingController = TextEditingController(text: provider.name);

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
            TextButton( child: loadSave == false? Text(newProvider ? 'GUARDAR' : "ACTUALIZAR"): const CircularProgressIndicator(),
                onPressed: () async {
                  if (textEditingController.text != '') { 
                    //  set
                    provider.name = textEditingController.text; 
                    // save
                    await homeController.providerSave(provider: provider).whenComplete(() {
                      //set 
                      controllerCreateProductForm.controllerTextEditProvider.text = provider.name;
                      // add
                      homeController.getProviderList.add(provider);
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

