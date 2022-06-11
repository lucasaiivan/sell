import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/salesPage/controller/sales_controller.dart';
import 'package:sell/app/modules/splash/controllers/splash_controller.dart';
import 'package:sell/app/utils/fuctions.dart';

class ProductoItem extends StatefulWidget {
  final ProductCatalogue producto;

  ProductoItem({required this.producto});

  @override
  State<ProductoItem> createState() => _ProductoItemState();
}

class _ProductoItemState extends State<ProductoItem> {
  // controllers
  SalesController salesController = Get.find<SalesController>();

  //var
  late bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    // aparición animada
    return ElasticIn(
      // transición animada
      child: Hero(
        tag: widget.producto.id,
        // widget
        child: Card(
          color: Colors.white,
          elevation:2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: contentImage()),
                  contentInfo(),
                ],
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: MouseCursor.uncontrolled,
                    onTap: () {
                      setState(() {
                        isFocus = !isFocus;
                      });
                    },
                    onLongPress: () {},
                  ),
                ),
              ),
              isFocus
                  ? Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            salesController.removeProduct =
                                widget.producto.id;
                          },
                          icon: const CircleAvatar(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.red)))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS COMPONETS
  Widget contentImage() {
    // var
    String description = widget.producto.description != ''
        ? widget.producto.description.substring(0, 4)
        : Publications.getFormatoPrecio(monto: widget.producto.salePrice);
    return widget.producto.image != ""
        ? Container(
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
                        monto: widget.producto.salePrice),
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

  return Drawer(
    child: Column(
      children: [
        const SizedBox(height: 50),
        const ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
          ),
          title: Text('Mi negocio'),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text('Vender'),
                  onTap: () {}),
              ListTile(
                  leading: const Icon(Icons.check),
                  title: const Text('Transacciones'),
                  onTap: () {}),
              ListTile(
                  leading: const Icon(Icons.check_box_outline_blank_rounded),
                  title: const Text('Stock'),
                  onTap: () {}),
              ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {}),
            ],
          ),
        ),
         ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('Cambiar tema'),
          onTap:() {
            Get.changeThemeMode(
                        Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
          },
        ),
        const ListTile(
          leading: Icon(Icons.close),
          title: Text('Cerrar sesión'),
          onTap: showDialogCerrarSesion,
        ),
      ],
    ),
  );
}

// cerrar sesión
void showDialogCerrarSesion() {
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

            // Guardamos una referencia  de la cuenta seleccionada
            GetStorage().write('idAccount', '');
            //setIdAccountSelected = '';
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
