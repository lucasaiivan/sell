
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:flutter_offline/flutter_offline.dart';

import '../../../domain/entities/catalogo_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../../core/utils/widgets_utils.dart';
import '../controller/productsSearch_controller.dart';

class ProductsSearch extends GetView<ControllerProductsSearch> {
  // ignore: prefer_const_constructors_in_immutables
  ProductsSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerProductsSearch>(
      id: 'updateAll',
      init: ControllerProductsSearch(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: controller.getColorFondo,
          appBar: appbar(),
          body: _body(),
        );
      },
    );
  }

  /* WIDGETS */
  PreferredSizeWidget appbar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: controller.getColorFondo,
      title: Text(
        controller.getproductDoesNotExist ? "Sin resultados" : "Buscar",
        style: TextStyle(color: controller.getColorTextField),
      ),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: controller.getColorTextField),
          onPressed: () => Get.back()),
      bottom: controller.getStateSearch
          ? linearProgressBarApp(color: Get.theme.primaryColor)
          : null,
    );
  }

  Widget _body() {
    return OfflineBuilder(
        child: Container(),
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final connected = connectivity != ConnectivityResult.none;

          if (!connected) {
            return const Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.wifi_off_rounded),
                ),
                Text('No hay internet'),
              ],
            ));
          }
          return Center(
            child: ListView(
                padding:const EdgeInsets.all(0.0),
                shrinkWrap: true,
                children: [
                  // view : sugerencias de productos
                  controller.getproductDoesNotExist? Container(): WidgetSuggestionProduct(list: controller.getListProductsSuggestions),
                  // view : content
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        controller.getWriteCode||controller.getproductDoesNotExist?textFieldCodeBar():Container(), 
                        // textButton : escribir código
                        controller.getWriteCode?Container():TextButton(onPressed: (){ controller.setWriteCode =!controller.getWriteCode;}, child: Text('Escribir código',style: TextStyle(color: controller.getproductDoesNotExist?Colors.white:Colors.blue) ,)),
                        const SizedBox(height: 12.0),
                        Opacity(
                          opacity: controller.getproductDoesNotExist ? 0.5 : 1.0,
                          child: Column(
                            children: [
                              // button : buscar código
                              controller.getStateSearch == false && controller.getWriteCode
                                  ? Padding(
                                    padding: EdgeInsets.symmetric(horizontal: controller.getproductDoesNotExist?12:0),
                                    child: FadeInRight(
                                        child: button(
                                          icon: Icon(Icons.search, color: controller.getButtonData.colorText),
                                          onPressed: () =>controller.textEditingController.text == ''? null: controller.queryProduct(id: controller.textEditingController.value.text),
                                          text: "Buscar",
                                          colorAccent:controller.getButtonData.colorText,
                                          colorButton: controller.getButtonData.colorButton,
                                        ),
                                      ),
                                  )
                                  : Container(),
                              const SizedBox(height: 12.0),
                              // button : escanear codigo de barra
                              !controller.getStateSearch
                                  ? Padding(
                                    padding: EdgeInsets.symmetric(horizontal: controller.getproductDoesNotExist?12:0),
                                    child: FadeInRight(
                                        child: button(
                                          icon: const ImageIconScanWidget(size: 30,),
                                          onPressed: scanBarcodeNormal,
                                          text: "Escanear código",
                                          colorAccent:controller.getButtonData.colorText,
                                          colorButton:controller.getButtonData.colorButton,
                                        ),
                                      ),
                                  )
                                  : Container(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // text : el producto no existe
                        controller.getproductDoesNotExist
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 30),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                      style: TextStyle(color: Colors.white,fontSize: 18),
                                      children: <TextSpan>[
                                        TextSpan(text: 'El producto aún no existe\n', style: TextStyle(fontSize: 24)),
                                        TextSpan(text: 'Ayúdenos a registrar nuevos productos para que esta aplicación sea aún más útil para más personsa 🌍 ', style: TextStyle(color: Colors.white70)),
                                      ],
                                  ),
                                ),
                                
                                /*  Text(
                                  "El producto aún no existe 🙁, ayúdenos a registrar nuevos productos para que esta aplicación sea aún más útil para la comunidad",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: controller.getColorTextField),
                                ), */
                              )
                            : Container(),
                            //  button : crear producto
                        controller.getproductDoesNotExist
                            ? FadeInRight(
                                child: button(
                                  fontSize: 16,
                                  padding: 16,
                                  icon: Icon(Icons.add,color: controller.getButtonData.colorText,),
                                  onPressed: () {
                                    controller.toProductNew(
                                        id: controller
                                            .textEditingController.text);
                                  },
                                  text: "Crear producto",
                                  colorAccent:
                                      controller.getButtonData.colorText,
                                  colorButton:
                                      controller.getButtonData.colorButton,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ] //your list view content here
                ),
          );
        });
  }

  /* WIDGETS COMPONENT */ 
  Widget button(
      {required Widget icon,
      required String text,
      required dynamic onPressed,
      double fontSize = 0.0,
      double padding = 12,
      Color colorButton = Colors.purple,
      Color colorAccent = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: colorButton,
            padding: EdgeInsets.all(
              padding),
            textStyle: TextStyle(
                color: colorAccent,
                fontSize: fontSize == 0.0 ? null : fontSize)),
        icon: icon,
        label: Text(text,
            style: TextStyle(
                color: colorAccent, fontSize: fontSize == 0 ? null : fontSize)),
      ),
    );
  }

  Widget textFieldCodeBar() {

    return TextField(
              controller: controller.textEditingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[1234567890]'))],
              decoration: InputDecoration(
                fillColor: controller.getColorFondo,
                  suffixIcon: controller.textEditingController.value.text == ""?null:IconButton(onPressed: ()=>controller.clean(),icon: Icon(Icons.clear, color: controller.getColorTextField)),
                  filled: true,
                  hintText: 'ej. 77565440001743',
                  hintStyle: TextStyle(color: Get.theme.hintColor.withOpacity(0.3)),
                  enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
                  border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
                  focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
                  labelStyle: TextStyle(color: controller.getColorTextField),
                  labelText: "Escribe el código de barra",
                  suffixStyle: TextStyle(color: controller.getColorTextField),
                ),
              style: TextStyle(fontSize: 20.0, color: controller.getColorTextField),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                //  Se llama cuando el usuario indica que ha terminado de editar el texto en el campo
                controller.queryProduct( id: controller.textEditingController.value.text);
              },
            );
  }
  

  Widget widgetSuggestions({required List<Product> list}) {
    if (list.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("sugerencias para ti"),
        ),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: InkWell(
                onTap: () => controller.toProductView(porduct: list[0].convertProductCatalogue()),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FadeInRight(
                    child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Get.theme.primaryColor,
                        child: CircleAvatar(
                            radius: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: CachedNetworkImage(
                                  imageUrl: list[0].image, fit: BoxFit.cover),
                            ))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: InkWell(
                onTap: () => controller.toProductView(
                    porduct: list[1].convertProductCatalogue()),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FadeInRight(
                    child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Get.theme.primaryColor,
                        child: CircleAvatar(
                            radius: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: CachedNetworkImage(
                                  imageUrl: list[1].image, fit: BoxFit.cover),
                            ))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: InkWell(
                onTap: () => controller.toProductView(
                    porduct: list[2].convertProductCatalogue()),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FadeInRight(
                    child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Get.theme.primaryColor,
                        child: CircleAvatar(
                            radius: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: CachedNetworkImage(
                                  imageUrl: list[2].image, fit: BoxFit.cover),
                            ))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 120),
              child: InkWell(
                onTap: () => controller.toProductView(
                    porduct: list[3].convertProductCatalogue()),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FadeInRight(
                    child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Get.theme.primaryColor,
                        child: CircleAvatar(
                            radius: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: CachedNetworkImage(
                                  imageUrl: list[3].image, fit: BoxFit.cover),
                            ))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /* FUNCTIONS */
  Future<void> scanBarcodeNormal() async {
    // Escanner Code - Abre en pantalla completa la camara para escanear
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      late String barcodeScanRes; 
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode( "#ff6666", "Cancel", true, ScanMode.BARCODE);
      controller.textEditingController.text = barcodeScanRes;
      controller.queryProduct(id: barcodeScanRes);
    } on PlatformException {
      Get.snackbar('scanBarcode', 'Failed to get platform version');
    }
  }
}
