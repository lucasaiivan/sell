import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';
import '../controller/catalogue_controller.dart';
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
        child: WillPopScope(
          onWillPop: () => controller.onBackPressed(context: context),
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
    Widget titleWidget = Row(
      children: [
        // image : imagen del producto
        imageProductExist ? controller.loadImage(size: 40) : Container(),
        imageProductExist ? const SizedBox(width: 12) : Container(),
        // text : nombre del producto
        Text(title, style: TextStyle(color: colorAccent, fontSize: 18)),
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
              Center(
                child: controller.getDataUploadStatus
                    ? Container()
                    : textFieldCarrousel(),
              ),
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
                  : controller.getCurrentSlide == 0
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
            Opacity(
                opacity: 0.6,
                child: Text(title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400))),
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

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CarouselSlider.builder(
        carouselController: controller.carouselController,
        options: CarouselOptions(
          height: 420,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index, reason) {

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
          viewportFraction: 0.95,
          enableInfiniteScroll: false, 
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        ),
        //options: CarouselOptions(enableInfiniteScroll: lista.length == 1 ? false : true,autoPlay: lista.length == 1 ? false : true,aspectRatio: 2.0,enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.scale),
        itemCount: listWidgetss.length,
        itemBuilder: (context, index, realIndex) {
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
                controller.loadImage(size: 150),
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
            //TODO: eliminar para desarrrollo
            TextButton(
                onPressed: () async {
                  String clave = controller.controllerTextEditDescripcion.text;
                  Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: const Text('Buscar descripción en Google (moderador)')),
            TextButton(
                onPressed: () async {
                  String clave = controller.getProduct.code;
                  Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: const Text('Buscar en código Google (moderador)')),
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
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Descripción del producto',
                      helperText: 'Visibilidad pública'),
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

    // TextFormField : creamos una entrada de texto
    return Column(
      children: [
        const Spacer(),
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
                  border: const UnderlineInputBorder(),  
                  labelText: controller.controllerTextEditMark.text == '' ? 'Seleccionar marca' : 'Marca',
                  helperText: 'Visibilidad pública',
                ),
                onChanged: (value) => controller.formEditing =
                    true, // validamos que el usuario ha modificado el formulario
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
                    ? 'Seleccionar una cátegoria'
                    : 'Cátegoria',
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
                    : 'Proveedor',
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
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Precio de compra',
                  helperText: 'Visibilidad privada'),

              onChanged: (value) {
                if (controller.controllerTextEditPrecioCosto.numberValue != 0) {
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Precio de venta al público',
                      helperText: 'Visibilidad pública'),
                  onChanged: (value) {
                    if (controller.controllerTextEditPrecioVenta.numberValue != 0) {
                      controller.setSalePrice =
                          controller.controllerTextEditPrecioVenta.numberValue;
                      controller.formEditing = true;
                      controller.update();
                    }
                  },
                  // validator: validamos el texto que el usuario ha ingresado.
                  validator: (value) {
                    if (controller.controllerTextEditPrecioVenta.numberValue ==
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
        CheckboxListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabled: controller.getDataUploadStatus ? false : true,
          checkColor: Colors.white,
          activeColor: Colors.amber,
          value: controller.getFavorite,
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
        AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          width: double.infinity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              CheckboxListTile(
                // option premium : solo los usuarios premium pueden crear productos
                enabled: controller.getHomeController.getIsSubscribedPremium
                    ? true
                    : false,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: controller.getProduct.stock ? 12 : 0, vertical: 12),
                checkColor: Colors.white,
                activeColor: Colors.blue,
                value: controller.getStock,
                title: Text(controller.getProduct.stock
                    ? 'Quitar control de stock'
                    : 'Agregar control de stock'),
                subtitle: const Text('Controlar el inventario de sus productos'),
                onChanged: (value) {
                  if (!controller.getDataUploadStatus) {
                    controller.setStock = value ?? false;
                  }
                },
              ),
              LogoPremium(personalize: true, id: 'stock'),
              controller.getStock ? space : Container(),
              AnimatedContainer(
                width: controller.getStock ? null : 0,
                height: controller.getStock ? null : 0,
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.theme.textTheme.bodyMedium!.color ?? Colors.black12,
                    width: 1,
                  ),
                ),
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
                          onChanged: (value) => controller.setQuantityStock =
                              int.parse(controller.controllerTextEditQuantityStock.text),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
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
                          filled: true,
                          fillColor: Colors.transparent,
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
    return Column(
      children: [
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CheckboxListTile : consentimiento de usuario para crear un producto
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 12),
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.grey),
              ),
              child: CheckboxListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                    'Importante!\nAl crear un producto, entiendo y acepto lo siguiente: los datos básicos (descripción, imagen, marca) serán visibles para todos y podrían ser modificados por otros usuarios hasta que un moderador los verifique. Una vez verificados, no podré cambiar estos datos. El (precio de venta al público) también será visible para todos.',
                    style: TextStyle(fontWeight: FontWeight.w200)),
                value: controller.getUserConsent,
                onChanged: (value) {
                  controller.setUserConsent = value!;
                },
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
  final HomeController welcomeController = Get.find();
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
                        createProductFormController.setCategory = categoria;
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
                        createProductFormController.setProvider = provider;
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

