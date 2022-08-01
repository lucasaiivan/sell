// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/modules/sellPage/controller/sell_controller.dart';
import 'package:sell/app/modules/splash/controllers/splash_controller.dart';
import 'package:sell/app/utils/dynamicTheme_lb.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../modules/cataloguePage/controller/catalogue_controller.dart';
import '../routes/app_pages.dart';

class WidgetButtonListTile extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  WidgetButtonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return buttonListTileCrearCuenta();
  }

  Widget buttonListTileCrearCuenta() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      leading: const Icon(Icons.add),
      dense: true,
      title: const Text("Crear mi perfil", style: TextStyle(fontSize: 16.0)),
      onTap: () {
        Get.back();
        Get.toNamed(Routes.ACCOUNT);
      },
    );
  }

  Widget buttonListTileItemCuenta({required ProfileAccountModel perfilNegocio}) {

    if (perfilNegocio.id == '') { return Container(); }
    
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding:const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: perfilNegocio.image != '' || perfilNegocio.image.isNotEmpty
                ? CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 200),
                    fit: BoxFit.cover,
                    imageUrl: perfilNegocio.image.contains('https://')? perfilNegocio.image : "https://${perfilNegocio.image}",
                    placeholder: (context, url) => CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 24.0,
                      child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle( fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                    ),
                    imageBuilder: (context, image) => CircleAvatar(backgroundImage: image,radius: 24.0),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 24.0,
                      child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle(fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.black26,
                    radius: 24.0,
                    child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle(fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                  ),
          ),
          dense: true,
          title: Text(perfilNegocio.name),
          trailing: Radio(
            activeColor: Colors.blue,
            value: controller.isSelected(id: perfilNegocio.id) ? 0 : 1,
            groupValue: 0,
            onChanged: (val) {
              controller.accountChange(idAccount: perfilNegocio.id);
            },
          ),
          onTap: () {
            controller.accountChange(idAccount: perfilNegocio.id);
          },
        ),
      ],
    );
  }
}

PreferredSize linearProgressBarApp({Color color = Colors.purple}) {
  return PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: LinearProgressIndicator(
          minHeight: 6.0,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color)));
}

class ProductoItem extends StatefulWidget {
  final ProductCatalogue producto;

  const ProductoItem({super.key, required this.producto});

  @override
  State<ProductoItem> createState() => _ProductoItemState();
}

class _ProductoItemState extends State<ProductoItem> {
  // controllers
  SalesController salesController = Get.find<SalesController>();
  @override
  Widget build(BuildContext context) {
    //  values
    final String alertStockText = widget.producto.stock ? (widget.producto.quantityStock >=0 ? widget.producto.quantityStock<=widget.producto.alertStock?'Stock bajo':'' : 'Sin stock'): '';

    // aparición animada
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // image and description  to product
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              alertStockText == ''
                  ? Container()
                  : Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(alertStockText,style: const TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold)),
                      )),
                    ),
              Expanded(child: contentImage()),
              contentInfo(),
            ],
          ),
          // selected
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: MouseCursor.uncontrolled,
                onTap: () => salesController.selectedItem(id: widget.producto.id),
                onLongPress: () {},
              ),
            ),
          ),
          // color selected
          widget.producto.select ?Positioned.fill(child: Container(color: Colors.black26,)):Container(),
          // button delete
          widget.producto.select
              ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        salesController.removeProduct = widget.producto.id;
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ))))
              : Container(),
          // value quantity
          widget.producto.quantity > 1 || widget.producto.select
              ? Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () =>
                        salesController.selectedItem(id: widget.producto.id),
                    icon: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Center(
                              child:
                                  Text(widget.producto.quantity.toString()),
                            )),
                      ),
                    ),
                  ))
              : Container(),
          // button  subtract quantity
          widget.producto.select
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                      onPressed: () {
                        if (widget.producto.quantity > 1) {
                          widget.producto.quantity--;
                          salesController.update();
                        }
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.horizontal_rule,
                            color: Colors.white,
                          ))))
              : Container(),
          // button  increase quantity
          widget.producto.select
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      onPressed: () {
                        widget.producto.quantity++;
                        salesController.update();
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ))))
              : Container(),
          // button  deselect
          widget.producto.select
              ? Align(
                  alignment: Alignment.center,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.producto.select = !widget.producto.select;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      )))
              : Container(),
        ],
      ),
    );
  }

  // WIDGETS COMPONETS

  Widget contentImage() {
    // var
    String description = widget.producto.description != ''
        ? widget.producto.description.length >= 3
            ? widget.producto.description.substring(0, 3)
            : widget.producto.description.substring(0, 1)
        : Publications.getFormatoPrecio(
            monto: widget.producto.salePrice * widget.producto.quantity);
    return widget.producto.image != ""
        ? SizedBox(
            width: double.infinity,
            child: CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 200),
              fit: BoxFit.cover,
              imageUrl: widget.producto.image,
              placeholder: (context, url) => Container(
                color: Colors.grey[100],
                child: Center(
                  child: Text(description,
                      style:
                          const TextStyle(fontSize: 24.0, color: Colors.grey)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[100],
                child: Center(
                  child: Text(description,
                      style:
                          const TextStyle(fontSize: 24.0, color: Colors.grey)),
                ),
              ),
            ),
          )
        : Container(
            color: Colors.grey[100],
            child: Center(
              child: Text(description,
                  style: const TextStyle(fontSize: 24.0, color: Colors.grey)),
            ),
          );
  }

  Widget contentInfo() {
    return widget.producto.description == ''
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.producto.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                        color: Colors.grey),
                    overflow: TextOverflow.fade,
                    softWrap: false),
                Text(
                    Publications.getFormatoPrecio(
                        monto: widget.producto.salePrice *
                            widget.producto.quantity),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black),
                    overflow: TextOverflow.fade,
                    softWrap: false),
              ],
            ),
          );
  }
}

Widget drawerApp() {
  //Los rieles de navegación brindan acceso a los destinos principales en las aplicaciones cuando se usan pantallas de tabletas y computadoras de escritorio.

  return GetBuilder<HomeController>(
    builder: (homeController) {
      // values
      String email = homeController.getUserAuth.email ?? 'null';

      return Drawer(
        child: Column(
          children: [
            const SizedBox(height: 50),
            //  avatar de la cuenta
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(0.0),
                child: homeController.getProfileAccountSelected.image == ''
                    ? CircleAvatar(backgroundColor: Get.theme.dividerColor)
                    : CachedNetworkImage(
                        imageUrl:homeController.getProfileAccountSelected.image,
                        placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
                        imageBuilder: (context, image) => CircleAvatar(backgroundImage: image),
                        errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
                      ),
              ),
              title: Text(homeController.getIdAccountSelected == ''? 'Seleccionar una cuenta': homeController.getProfileAccountSelected.name,maxLines: 1,overflow: TextOverflow.ellipsis),
              subtitle: homeController.getIdAccountSelected == ''? null: Text(homeController.getProfileAdminUser.superAdmin? 'Administrador': 'Usuario estandar'),
              trailing: const Icon(Icons.arrow_right_rounded),
              onTap: () {
                homeController.showModalBottomSheetSelectAccount();
              },
            ),
            // others items
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                      leading: const Icon(Icons.attach_money_rounded),
                      title: const Text('Vender'),
                      onTap: () => homeController.setIndexPage = 0),
                  ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text('Transacciones'),
                      onTap: () => homeController.setIndexPage = 1),
                  ListTile(
                      leading: const Icon(Icons.apps_rounded),
                      title: const Text('Catálogo'),
                      onTap: () => homeController.setIndexPage = 2),
                ],
              ),
            ),
            /* ListTile(
              leading: const Icon(Icons.launch_rounded),
              title: const Text('Producto App'),
              onTap: () async {
                
                // values
                Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.logicabooleana.commer.producto');
                // primero probamos si podemos abrir la app de lo contrario redireccionara para la tienda de aplicaciones
                try{
                  await LaunchApp.openApp(androidPackageName: 'com.logicabooleana.commer.producto');
                }catch(_){
                  if (await canLaunchUrl(uri)) { await launchUrl(uri,mode: LaunchMode.externalApplication);} else {throw 'Could not launch $uri';}
                }
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
              tileColor: Colors.grey.withOpacity(0.1),
              leading: const Icon(Icons.thumbs_up_down_outlined),
              title: const Text('Dejanos tu opinión 😃'),
              subtitle: const Text('Nos intereza saber lo que piensas'),
              onTap: () async {
                Uri uri = Uri.parse( 'https://play.google.com/store/apps/details?id=com.logicabooleana.commer.producto');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $uri';
                }
              },
            ), */
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
              tileColor: Colors.blue.withOpacity(0.1),
              leading: const Icon(Icons.whatsapp_rounded,color: Colors.green),
              title: const Text('Escribenos tu opinión 😃'),
              subtitle: const Text('Tu opinión o sugerencia es importante'),
              onTap: () async{
                
                // abre la app de mensajeria
                String whatsAppUrl = "";
                String phoneNumber = '541134862939';
                String description = "hola, estoy probando la App!";
                whatsAppUrl ='https://wa.me/+$phoneNumber?text=${Uri.parse(description)}';
                Uri uri = Uri.parse( whatsAppUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $uri';
                }

              },
            ),
            const ListTile(
              leading: Icon(Icons.color_lens_outlined),
              title: Text('Cambiar tema'),
              onTap: ThemeService.switchTheme,
            ),
            ListTile(
              // ignore: prefer_const_constructors
              leading: Icon(Icons.close),
              title: const Text('Cerrar sesión'),
              subtitle:
                  Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: showDialogCerrarSesion,
            ),
          ],
        ),
      );
    },
  );
}

Widget viewDefault() {
  // vista por defecto que se le muestra al usuario para que seleccione un cuenta

  // others controllers
  final HomeController homeController = Get.find();

  return Material(
      child: Center(
          child: Stack(
            fit: StackFit.expand,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Hola 🖐️\n\nEsto es una app en desarrollo muy pronto estara lista\n',textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          TextButton(
            child: const Text('Selecciona una cuenta'),
            onPressed: () {
              homeController.showModalBottomSheetSelectAccount();
            },
          ),
        ],
      ),
      Column(
        children: [
          Expanded(child: Container()),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: TextButton(onPressed: showDialogCerrarSesion, child: Text('Cerrar sesión')),
          ),
        ],
      ),
    ],
  )));
}

// cerrar sesión
void showDialogCerrarSesion() {
  // others controllers
  final HomeController homeController = Get.find();

  Widget widget = AlertDialog(
    title: const Text("Cerrar sesión"),
    content: const Text("¿Estás seguro de que quieres cerrar la sesión?"),
    actions: <Widget>[
      // usually buttons at the bottom of the dialog
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('cancelar')),
      TextButton(
          child: const Text('si'),
          onPressed: () async {
            CustomFullScreenDialog.showDialog();
            // default values
            homeController.setProfileAccountSelected=ProfileAccountModel(creation: Timestamp.now());
            homeController.setProfileAdminUser = UserModel ();
            homeController.setCatalogueCategoryList = [];
            homeController.setCatalogueCategoryList = [];
            homeController.setCatalogueProducts = [];
            homeController.setProductsOutstandingList = [];
            // save key/values Storage
            GetStorage().write('idAccount', '');
            // instancias de FirebaseAuth para proceder a cerrar sesión
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
            Future.delayed(const Duration(seconds: 2)).then((_) {
              firebaseAuth.signOut().then((value) async {
                CustomFullScreenDialog.cancelDialog();
              });
            });
          }),
    ],
  );

  Get.dialog(
    widget,
  );
}

// notification
void showMessageAlertApp({required String title, required String message}) {
  Get.snackbar(title, message,
      margin: const EdgeInsets.all(12),
      backgroundColor: Get.theme.brightness == Brightness.dark
          ? Colors.transparent
          : Colors.white,
      colorText: Get.theme.brightness == Brightness.dark
          ? Colors.white
          : Colors.black);
}

// Cuadro de Dialogo
// un checkbox para agregar el producto a mi cátalogo
// ignore: must_be_immutable
class CheckBoxAddProduct extends StatefulWidget {
  late ProductCatalogue productCatalogue ;

  CheckBoxAddProduct({super.key, required this.productCatalogue});

  @override
  State<CheckBoxAddProduct> createState() => _CheckBoxAddProductState();
}

class _CheckBoxAddProductState extends State<CheckBoxAddProduct> {

  // others controllers
  final HomeController homeController = Get.find();
  //  values
  bool check = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CheckboxListTile(
        secondary: CachedNetworkImage(
          imageUrl: widget.productCatalogue.image,
          placeholder: (context, url) =>
              CircleAvatar(backgroundColor: Get.theme.dividerColor),
          imageBuilder: (context, image) => CircleAvatar(
            backgroundImage: image,
          ),
          errorWidget: (context, url, error) =>
              CircleAvatar(backgroundColor: Get.theme.dividerColor),
        ),
        title:
            const Text('Agregar mi cátalogo', style: TextStyle(fontSize: 14)),
        subtitle: Text(widget.productCatalogue.description,
            style: const TextStyle(fontSize: 12), maxLines: 2),
        value: check,
        checkColor: Colors.white,
        activeColor: Colors.blue,
        onChanged: (value) {
          setState(() {
            check=!check;
            homeController.checkAddProductToCatalogue = check;
          });
        },
      ),
    );
  }
}

class ComponentApp {
  static PreferredSize linearProgressBarApp({Color color = Colors.purple}) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: LinearProgressIndicator(
            minHeight: 6.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color)));
  }
}

class ImageApp {
  static Widget circleImage(
      {required String url, required String texto, double size = 85.0}) {
    //values
    MaterialColor color = Utils.getRandomColor();
    if (texto == '') texto = 'Image';

    Widget imageDefault = CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      radius: size,
      child: Text(texto.substring(0, 1),
          style: TextStyle(
            fontSize: size / 2,
            color: color,
            fontWeight: FontWeight.bold,
          )),
    );

    return SizedBox(
      width: size,
      height: size,
      child: url == "" || url == "default"
          ? imageDefault
          : CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => imageDefault,
              imageBuilder: (context, image) => CircleAvatar(
                backgroundImage: image,
                radius: size,
              ),
              errorWidget: (context, url, error) => imageDefault,
            ),
    );
  }
}

class WidgetSuggestionProduct extends StatelessWidget {
  //values

  bool searchButton = false;
  List<Product> list = <Product>[];
  WidgetSuggestionProduct({super.key, required this.list, this.searchButton = false});

  @override
  Widget build(BuildContext context) {

    // controllers
    CataloguePageController homeController = Get.find<CataloguePageController>();

    if (list.isEmpty) return Container();

    // values
    Color? colorAccent = Get.theme.textTheme.subtitle1?.color;
    double radius = 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("sugerencias para vos",style: Get.theme.textTheme.subtitle1),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            !searchButton
                ? Container()
                : InkWell(
                    onTap: () => Get.toNamed(Routes.SEACH_PRODUCT,arguments: {'id': ''}),
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FadeInLeft(
                        child: CircleAvatar(
                            radius: radius,
                            backgroundColor: colorAccent,
                            child: CircleAvatar(radius: radius-2,backgroundColor:Get.theme.scaffoldBackgroundColor,child: Icon(Icons.search, color: colorAccent))),
                      ),
                    ),
                  ),
            SizedBox(
                width: Get.size.width,
                height: 100,
                child: Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Align(
                          widthFactor: 0.5,
                          child: InkWell(
                            onTap: () => homeController.toProductEdit(productCatalogue: list[index].convertProductCatalogue()),
                            borderRadius: BorderRadius.circular(50),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: FadeInRight(
                                child: CircleAvatar(
                                    backgroundColor: colorAccent,
                                    foregroundColor: colorAccent,
                                    radius: radius,
                                    child: CircleAvatar(
                                        backgroundColor: Colors.grey[100],
                                        foregroundColor: Colors.grey[100],
                                        radius: radius-2,
                                        child: ClipRRect(
                                          borderRadius:BorderRadius.circular(50),
                                          child: CachedNetworkImage(
                                            fadeInDuration: const Duration( milliseconds: 200),
                                            fit: BoxFit.cover,
                                            imageUrl: list[index].image,
                                            placeholder: (context, url) =>CircleAvatar(backgroundColor:Colors.grey[100],foregroundColor:Colors.grey[100]),
                                            errorWidget:(context, url, error) =>CircleAvatar(backgroundColor:Colors.grey[100],foregroundColor:Colors.grey[100]),
                                          ),
                                        ))),
                              ),
                            ),
                          ),
                        );
                      }),
                )),
          ],
        ),
      ],
    );
  }
}
