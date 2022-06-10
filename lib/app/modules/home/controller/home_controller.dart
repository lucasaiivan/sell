import 'package:get/get.dart';

class HomeController extends GetxController {

  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  @override
  void onClose() {}
}
