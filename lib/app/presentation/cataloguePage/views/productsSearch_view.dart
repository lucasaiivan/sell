
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';  
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
          resizeToAvoidBottomInset: true,  // evita que el teclado cubra el contenido
          backgroundColor: controller.getColorFondo,
          appBar: appbar(),
          body: _body(),
          floatingActionButton: Opacity(
                opacity: controller.getproductDoesNotExist ? 0.5 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button : escribir código manual 
                    controller.getWriteCode?Container():FloatingActionButton(onPressed: (){ 
                      controller.setWriteCode =!controller.getWriteCode;
                      controller.textFieldCodeFocusNode.requestFocus();
                      },elevation: 0,backgroundColor: controller.getButtonData.colorButton,child: Icon(Icons.keyboard,color: controller.getButtonData.colorText)),
                    const SizedBox(width: 5.0),
                    // button : buscar producto
                    !controller.getWriteCode?Container():FloatingActionButton(onPressed: () {
                      controller.productSelect.local = true;
                      controller.textEditingController.text == ''? null: controller.searchProductCatalogue(id: controller.textEditingController.value.text);
                    },elevation: 0,backgroundColor: controller.getButtonData.colorButton,child: Icon(Icons.search,color: controller.getButtonData.colorText)),
                    const SizedBox(width: 5.0),
                    // button : escanear código de barra
                    FloatingActionButton(onPressed: controller.scanBarcodeNormal,elevation: 0,backgroundColor: controller.getButtonData.colorButton,child: ImageIconScanWidget(size: 30,color: controller.getButtonData.colorText)),
                  ],
                ),
              )
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

    return SingleChildScrollView( 
      child: Center(
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max, 
          children: [
            const SizedBox(height:50), 
            // view : sugerencias de productos
            controller.getWriteCode||controller.getproductDoesNotExist? Container(): WidgetSuggestionProduct(positionDinamic: true,list: controller.getListProductsSuggestions),
            controller.getWriteCode||controller.getproductDoesNotExist? Container(): const SizedBox(height: 20), 
            // view : image 
            controller.getproductDoesNotExist?Container():
            const Card(
              color: Colors.black12,
              margin: EdgeInsets.all(20.0),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Escanear código de barra',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold )),  
                    Text('Encuentra muchos productos disponibles en nuestra base de datos',style: TextStyle(fontSize: 16),textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            // view : content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [ 
                  // textfield : código de barra
                  textFieldCodeBar(), 
                  const SizedBox(height: 12.0),
                  // button : buscar código
                  controller.getWriteCode||controller.getproductDoesNotExist?Container():
                  Opacity(
                    opacity: controller.getproductDoesNotExist ? 0.5 : 1.0,
                    child: !controller.getStateSearch
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: controller.getproductDoesNotExist?12:0),
                          child: FadeInRight(
                              child: TextButton(
                                onPressed: controller.scanBarcodeNormal,
                                child: const Text('Escanear código'),
                              ),
                            ),
                        )
                        : Container(),
                  ), 
                  // view : texto informativo que el producto aún no existe si no se encuentra en la base de datos y se escribio manualmente el código por el teclado 
                  !(controller.productSelect.local && controller.getproductDoesNotExist)?Container():
                  const Card(
                    color: Colors.black12,
                    margin: EdgeInsets.all(20.0),
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('El código escrito aún no existe',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white )),  
                          Text('Crea el producto en tu catálogo y se te notificará cuando sus datos sean verificado',style: TextStyle(fontSize: 16,color: Colors.white70),textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                  ),
                  // view : texto informativo que el producto aún no existe
                  controller.productSelect.local  ||!controller.getproductDoesNotExist?Container():
                  Card(
                    elevation: 0,
                    color: Colors.black12,
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0.0,bottom: 20.0,left: 12.0,right: 12.0),
                      child: Column(
                        children: [
                          Image.asset('assets/default_image.png',height: 75,width: 75,fit: BoxFit.cover,color: Colors.white38),
                          const Text( 'El producto escaneado aún no existe',textAlign: TextAlign.center, style: TextStyle(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Ayúdanos a registrar nuevos productos para que esta aplicación sea aún más útil para más personsa 🌍 ',textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),  
                  //  button : crear producto
                  controller.getproductDoesNotExist
                      ? FadeInRight(
                          child: button(
                            fontSize: 16,
                            padding: 16,
                            icon: Icon(Icons.add,color: controller.getButtonData.colorText,),
                            onPressed: () {
                              controller.toProductNew(id: controller.textEditingController.text);
                            },
                            text: "Crear producto",
                            colorAccent: controller.getButtonData.colorText,
                            colorButton: controller.getButtonData.colorButton,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ] //your list view content here
          ),
      ),
    );
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

    return ElasticIn(
      curve: Curves.fastLinearToSlowEaseIn,
      child: TextField( 
        readOnly: !controller.productSelect.local &&  controller.getproductDoesNotExist?true:false,
        focusNode: controller.textFieldCodeFocusNode,
        controller: controller.textEditingController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false), 
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[1234567890]'))],
        decoration: InputDecoration(
          fillColor: controller.getColorFondo,
            suffixIcon: controller.textEditingController.value.text == ""?null:IconButton(onPressed: ()=>controller.clean(),icon: Icon(Icons.clear, color: controller.getColorTextField)),
            filled: true,
            hintText: 'ej. 775654001743',
            hintStyle: TextStyle(color: Get.theme.hintColor.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
            border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
            focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(16.0)),borderSide: BorderSide(color: controller.getColorTextField)),
            labelStyle: TextStyle(color: controller.getColorTextField),
            labelText: "Código de barra",
            suffixStyle: TextStyle(color: controller.getColorTextField),
          ),
        style: TextStyle(fontSize: 20.0, color: controller.getColorTextField),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          // convierte el producto en local
          controller.productSelect.local = true;
          //  Se llama cuando el usuario indica que ha terminado de editar el texto en el campo
          controller.searchProductCatalogue( id: controller.textEditingController.value.text);
        },
      ),
    );
  }
  

   
  
}


