import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/services/database.dart';

class CataloguePageController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

  // catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //catalogueFilter();
  }

  @override
  void onInit() async {
    super.onInit();
    readCatalogueListProductsStream(id: homeController.getAccountProfile.id);
  }

  @override
  void onClose() {}

  // FIREBASE
  void readCatalogueListProductsStream({required String id}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    if (id != '') {
      Database.readProductsCatalogueStream(id: id).listen((value) {
        List<ProductCatalogue> list = [];
        //  get
        for (var element in value.docs) {
          list.add(ProductCatalogue.fromMap(element.data()));
        }
        //  set
        setCatalogueProducts = list;
      }).onError((error) {
        // error
      });
    }
  }

  
}
