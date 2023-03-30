 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import 'package:sell/app/data/datasource/database_cloud.dart';
import 'package:sell/app/core/utils/dynamicTheme_lb.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';

class ButtonData {
  Color colorButton = Colors.purple;
  Color colorText = Colors.white; 
  ButtonData({required Color colorButton, required Color colorText}) {
    this.colorButton = colorButton;
    this.colorText = colorText;
  }
}

class ControllerProductsSearch extends GetxController {
  // controllers
  late HomeController homeController;

  @override
  void onInit() {

    // obtenemos los datos del controlador principal
    homeController = Get.find();
    // llamado inmediatamente después de que se asigna memoria al widget - ej. fetchApi();
    _codeBarParameter = Get.arguments['id'] ?? '';
    if (_codeBarParameter != '') {
      getTextEditingController.text = _codeBarParameter;
      queryProduct(id: _codeBarParameter);
    }
    queryProductSuggestion();

    super.onInit();
  }

  @override
  void onReady() {
    // llamado después de que el widget se representa en la pantalla - ej. showIntroDialog();
    super.onReady();
  }

  @override
  void onClose() {
    ThemeService.switchThemeDefault();
    super.onClose();
  }

  // product
  ProductCatalogue productSelect = ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());

  // list excel to json
   List<ProductCatalogue> productsToExelList = [];
  static List<Map<String, dynamic>> listExcelToJson = [];
  void filterListExcelToJson({required List<Map<String, dynamic>> value}) async{

    for (var element in value) {
      // set values
      ProductCatalogue productCatalogue = ProductCatalogue(creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
        productCatalogue.id = element['Código'];
        productCatalogue.code = element['Código'];
        productCatalogue.description = element['Producto'];
        productCatalogue.purchasePrice = double.tryParse(element['P. Costo'].toString().replaceAll('\$', '').replaceAll(',', '.')) ??0.0;
        productCatalogue.salePrice = double.tryParse(element['P. Venta'].toString().replaceAll('\$', '').replaceAll(',', '.')) ??0.0;
      if(productCatalogue.id==''){break;}
      Database.readProductPublicFuture(id: productCatalogue.id).then((value) {
        if(value.exists){
          // no se hace nada
        }else{
          productsToExelList.add(productCatalogue);
          update(['updateAll']);
        }
      });
    }
    //listExcelToJson = value;
  }
  List<Map<String, dynamic>> get getListExcelToJson => listExcelToJson;

  // write code
  bool _writeCode = false;
  set setWriteCode(bool value){
    _writeCode = value;
    update(['updateAll']);
  }
  get getWriteCode => _writeCode;

  // result text
  String _codeBarParameter = "";

  // Color de fondo
  Color _colorFondo = Get.theme.scaffoldBackgroundColor;
  set setColorFondo(Color color) => _colorFondo = color;
  Color get getColorFondo => _colorFondo;

  // Color de icono y texto de appbar y textfield
  Color? _colorTextField = Get.theme.textTheme.bodyLarge!.color;
  set setColorTextField(Color color) => _colorTextField = color;
  get getColorTextField => _colorTextField;

  // TextEditingController
  TextEditingController textEditingController =  TextEditingController(text: '');
  set setTextEditingController(TextEditingController editingController) => textEditingController = editingController;
  TextEditingController get getTextEditingController => textEditingController;
  

  // color component textfield
  ButtonData _buttonData =
      ButtonData(colorButton: Get.theme.primaryColor, colorText: Colors.white);
  setButtonData({required Color colorButton, required Color colorText}) =>
      _buttonData = ButtonData(colorButton: colorButton, colorText: colorText);
  ButtonData get getButtonData => _buttonData;

  // state search : estado de la busqueda
  bool _stateSearch = false;
  set setStateSearch(bool state) => _stateSearch = state;
  get getStateSearch => _stateSearch;

  // state result
  bool _productDoesNotExist = false;
  set setproductDoesNotExist(bool state) {
    if (state) {
      ThemeService.switchThemeColor(color: Colors.red);
      setColorFondo = Colors.red;
      setColorTextField = Colors.white;
      setButtonData(colorButton: Colors.white, colorText: Colors.black);
      _productDoesNotExist = state;
    } else {
      ThemeService.switchThemeDefault();
      _productDoesNotExist = false;
    }
  }

  // list productos sujeridos
  static List<Product> _listProductsSuggestion = [];
  set setListProductsSuggestions(List<Product> list) => _listProductsSuggestion = list;
  List<Product> get getListProductsSuggestions => _listProductsSuggestion;

  get getproductDoesNotExist => _productDoesNotExist;

  // FUCTIONS
  void queryProduct({required String id}) {
    if (id != '' && id != '-1') {
      // set
      setStateSearch = true;
      update(['updateAll']);
      // query
      Database.readProductPublicFuture(id: id).then((value) {
        Product product = Product.fromMap(value.data() as Map);
        toProductView(porduct: product.convertProductCatalogue());
      }).onError((error, stackTrace) {
        setproductDoesNotExist = true;
        setStateSearch = false;
        update(['updateAll']);
      }).catchError((error) {
        setproductDoesNotExist = true;
        setStateSearch = false;
        update(['updateAll']);
      });
    }else{
      clean(); 
    }
  }

  void updateAll() => update(['updateAll']);
  bool verifyIsNumber({required dynamic value}) {
    //  Verificamos que el dato ingresado por el usuario sea un número válido
    try {
      int.parse(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  void clean() {
    setStateSearch = false;
    textEditingController.clear();
    setproductDoesNotExist = false;
    setButtonData(colorButton: Get.theme.colorScheme.primary, colorText: Colors.white);
    setColorFondo = Get.theme.scaffoldBackgroundColor;
    setColorTextField = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    update(['updateAll']);
  }

  void queryProductSuggestion() {
    if (getListProductsSuggestions.isEmpty) {
      Database.readProductsFuture(limit: 6).then((value) {

        // values 
        List<Product> newList = [];
        for (var element in value.docs) {newList.add(Product.fromMap(element.data()));}
        // set
        setListProductsSuggestions = newList;
        // actualizamos la vista
        update(['updateAll']);
      });
    }
  }

  void toProductView({required ProductCatalogue porduct}) {
    Get.back();
     // TODO :  comrpobar si el producto esta en el cátalogo
     // ...
    Get.toNamed(Routes.EDITPRODUCT, arguments: {'product': porduct.copyWith()});
  }

  void toProductNew({required String id}) {
    //values default
    clean();
    //set
    productSelect.id = id;
    productSelect.code = id;
    // navega hacia una nueva vista para crear un nuevo producto
    Get.toNamed(Routes.EDITPRODUCT,arguments: {'new': true, 'product': productSelect});
  }
}





