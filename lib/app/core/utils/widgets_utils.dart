
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sell/app/core/utils/dynamicTheme_lb.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/presentation/sellPage/controller/sell_controller.dart';

import '../../domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart';
import '../../presentation/cataloguePage/controller/catalogue_controller.dart';
import '../routes/app_pages.dart';

/// Un widget que muestra una imagen
///
/// Este widget se puede utilizar en cualquier lugar donde se necesite mostrar una imagen del scan. El tamaño de la imagen se puede especificar utilizando la propiedad [size].
class ImageBarWidget extends StatelessWidget {
  /// Tamaño deseado y color deseado.
  final double size;
  late final  Color color;

  /// Crea un widget de una imagen de Scan.
  ///
  /// [size] es el tamaño deseado de la imagen en píxeles.
  ImageBarWidget({
    Key? key,
    required this.size,
    this.color=Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // get 
    color = Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black;
    
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/productoLogo.png',color: color),
    );
  }
}

/// Un widget que muestra un icono de escaneo de código de barras.
///
/// Este widget se puede utilizar en cualquier lugar donde se necesite mostrar un icono de escaneo de código de barras. El tamaño del icono se puede especificar utilizando la propiedad [size].
class ImageIconScanWidget extends StatelessWidget {
  /// Tamaño deseado del icono.
  final double size;

  /// Crea un widget de icono de escaneo de código de barras.
  ///
  /// [size] es el tamaño deseado del icono en píxeles.
  const ImageIconScanWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/scanbarcode.png',color: Colors.white),
    );
  }
}

class WidgetButtonListTile extends StatelessWidget {

  // controllers
  final HomeController controller = Get.find<HomeController>();

  WidgetButtonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return buttonListTileCrearCuenta();
  }

  Widget buttonListTileCrearCuenta() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      trailing: const Icon(Icons.add), 
      dense: true,
      title: const Text("Crear mi perfil de mi negocio", style: TextStyle(fontSize: 16.0)),
      onTap: () {
        Get.back();
        Get.toNamed(Routes.ACCOUNT);
      },
    );
  }

  Widget buttonListTileItemCuenta({required ProfileAccountModel perfilNegocio,bool row = false}) {

    // others controllers
    final HomeController homeController = Get.find();

    if (perfilNegocio.id == '') { return Container(); }

    // row : si la vista es en forma de lista horizontal , se muesta una vista reducida de el avatar y el nombre debajo
    if(row){
      return InkWell(
        onTap: () {
          controller.accountChange(idAccount: perfilNegocio.id);
        },
        // touch round
        borderRadius: BorderRadius.circular(10.0),
        child: SizedBox(
          width: 75.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min ,
            children: [ 
              GestureDetector(
                onTap: () {
                  // condition : si el usuario es superAdmin y el perfil seleccionado es el mismo que el perfil que se esta mostrando
                  if(homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id){
                    Get.back();
                    Get.toNamed(Routes.ACCOUNT);
                  }else{
                    // action : ir a la cuenta seleccionada 
                    controller.accountChange(idAccount: perfilNegocio.id);
                  }
                },
                child: SizedBox(
                  height: 75,width: 75,
                  child: perfilNegocio.image != '' || perfilNegocio.image.isNotEmpty
                      ? CachedNetworkImage(
                          fadeInDuration: const Duration(milliseconds: 200),
                          fit: BoxFit.cover,
                          imageUrl: perfilNegocio.image.contains('https://')? perfilNegocio.image : "https://${perfilNegocio.image}",
                          placeholder: (context, url) => CircleAvatar(
                            backgroundColor: Colors.black26,
                            radius: 100.0,
                            child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle( fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                          ),
                          imageBuilder: (context, image) => CircleAvatar(backgroundImage: image,radius: 24.0),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: Colors.black26,
                            radius: 100.0,
                            child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle( fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.black26,
                          radius: 100.0,
                          child: Text(perfilNegocio.name.substring(0, 1),style: const TextStyle( fontSize: 18.0,color: Colors.white,fontWeight: FontWeight.bold)),
                        ),
                ),
              ),
              const SizedBox(height: 5.0),
              Text(perfilNegocio.name, style: const TextStyle(overflow: TextOverflow.ellipsis )),
            ],
          ),
        ),
      );

    }
    
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding:const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
          subtitle: homeController.getProfileAccountSelected.id != perfilNegocio.id ? null  : Text( homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id?'Administrador':'Tienes que ser administrador para editar esta cuenta'  ),
          trailing: homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id ? TextButton(onPressed: (){
              Get.back();
              Get.toNamed(Routes.ACCOUNT);
          }, child: const Text('Editar')): Radio(
            activeColor: Colors.blue,
            value: controller.isSelected(id: perfilNegocio.id) ? 0 : 1,
            groupValue: 0,
            onChanged: (val) {
              if(homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id){
                Get.back();
                Get.toNamed(Routes.ACCOUNT);
              }else{
                controller.accountChange(idAccount: perfilNegocio.id);
              }
              
            },
          ),
          onTap: () {
            if(homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id){
                Get.back();
                Get.toNamed(Routes.ACCOUNT);
              }else{
                controller.accountChange(idAccount: perfilNegocio.id);
              }
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
                      backgroundColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Center(
                              child:
                                  Text(widget.producto.quantity.toString(),style: const TextStyle(color: Colors.black),),
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
                          backgroundColor: Colors.blue,
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
                          backgroundColor: Colors.blue,
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
                    overflow: TextOverflow.clip,
                    softWrap: false),
                Text(
                    Publications.getFormatoPrecio(
                        monto: widget.producto.salePrice *
                            widget.producto.quantity),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black),
                    overflow: TextOverflow.clip,
                    softWrap: false),
              ],
            ),
          );
  }
}

Widget drawerApp() {
  //Los rieles de navegación brindan acceso a los destinos principales en las aplicaciones cuando se usan pantallas de tabletas y computadoras de escritorio.
  
  
  return Drawer(child: WidgetDrawer());
}

class WidgetDrawer extends StatelessWidget {
   // ignore: prefer_const_constructors_in_immutables
   WidgetDrawer({super.key});
 
  

  @override
  Widget build(BuildContext context) {

    // controllers
    final HomeController homeController = Get.find<HomeController>();

    // variables
    bool superAdmin = homeController.getProfileAdminUser.superAdmin;
    homeController.getFirebaseAuth.currentUser!.isAnonymous; 

    // widgets
    final textButtonLogin = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(width: double.infinity,child: FloatingActionButton(onPressed: homeController.signOutFirebase,elevation: 0,child: const Text('Iniciar sesión',style: TextStyle(color: Colors.white),))),
    );



    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        homeController.getFirebaseAuth.currentUser!.isAnonymous?textButtonLogin
        //  avatar de la cuenta
        :ListTile(
          leading: Container(
            padding: const EdgeInsets.all(0.0),
            child: homeController.getProfileAccountSelected.image == ''
                ? CircleAvatar(backgroundColor: Get.theme.dividerColor,child: Center(child: Text(homeController.getProfileAccountSelected.name.substring( 0,1))),)
                : CachedNetworkImage(
                    imageUrl:homeController.getProfileAccountSelected.image,
                    placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor,child: Center(child: Text(homeController.getProfileAccountSelected.name.substring( 0,1))),),
                    imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: CircleAvatar(backgroundImage: image)),
                    errorWidget: (context, url, error) {
                      // return : un circleView con la inicial de nombre como icon 
                      return CircleAvatar(
                        backgroundColor: Get.theme.dividerColor,
                        child: Center(child: Text(homeController.getProfileAccountSelected.name.substring( 0,1))),
                        );
                    },
                  ),
          ),
          title: Text(homeController.getIdAccountSelected == ''? 'Seleccionar una cuenta': homeController.getProfileAccountSelected.name,maxLines: 1,overflow: TextOverflow.ellipsis),
          subtitle: homeController.getIdAccountSelected == ''? null: Text( superAdmin? 'Administrador': 'Usuario estandar'),
          trailing: const Icon(Icons.arrow_right_rounded),
          onTap: () {
            homeController.showModalBottomSheetSelectAccount();
          },
        ), 
        const SizedBox(height: 20),
        // others items
        ListTile(
          tileColor: homeController.getIsSubscribedPremium?null:Colors.amber.withOpacity(0.1),
          iconColor:  Colors.amber, 
          titleTextStyle: const TextStyle(color: Colors.amber,fontWeight: FontWeight.bold),
            leading: const Icon(Icons.star_rounded),
            title: Text(homeController.getIsSubscribedPremium?'Premium':'Funciones Premium'),
            onTap: (){
              // action : mostrar modal bottom sheet con 
              Get.back(); // cierra drawer
              homeController.showModalBottomSheetSubcription();
            }),
        // vender 
        ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('Vender'),
            onTap: () => homeController.setIndexPage = 0),
        // historial de caja
        superAdmin?ListTile(
            leading: const Icon(Icons.manage_search_rounded),
            title: const Text('Historial de caja'),
            onTap: () => homeController.setIndexPage = 1):Container(),
        // transacciones
        superAdmin?ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Transacciones'),
            onTap: () => homeController.setIndexPage = 2):Container(),
        superAdmin?ListTile(
            leading: const Icon(Icons.apps_rounded),
            title: const Text('Catálogo'),
            onTap: () => homeController.setIndexPage = 3):Container(),
        superAdmin?ListTile(
            leading: const Icon(Icons.add_moderator_outlined),
            title: const Text('Multi Usuario'),
            onTap: () {
              if( homeController.getProfileAccountSelected.subscribed ){
                homeController.setIndexPage = 4;
              }else{
                Get.back(); // cierra drawer
                homeController.showModalBottomSheetSubcription(id: 'multiuser');
              }
              
            }):Container(),
        const SizedBox(height: 30),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
          tileColor: Colors.blue.withOpacity(0.1),
          leading: const Icon(Icons.messenger_outline_sharp,color: Colors.green),
          title: const Text('Escribenos tu opinión 😃'),
          subtitle: const Text('Tu opinión o sugerencia es importante'),
          onTap: () async{
            
            // abre la app de mensajeria
            String whatsAppUrl = "";
            String phoneNumber = '541134862939';
            String description = "hola, estoy probando la App SELL - Gestiona Tus Ventas y me gustaría compartirte mi opinión";
            whatsAppUrl ='https://wa.me/+$phoneNumber?text=$description';
            Uri uri = Uri.parse( whatsAppUrl);
            await launchUrl(uri,mode: LaunchMode.externalNonBrowserApplication);

          },
        ),
        // option : comprobar actualizacion
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: const Text('Comprobar actualización'),
          subtitle: const Text('Play Store'),
          onTap: () async {
            
            // values
            Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.logicabooleana.sell');
            //  redireccionara para la tienda de aplicaciones
            await launchUrl(uri,mode: LaunchMode.externalApplication);
          },
        ), 
        //  option :  cambiar el brillo del tema de la app
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: Text(Theme.of(context).brightness==Brightness.dark?'Tema claro':'Tema oscuro'),
          onTap: ThemeService.switchTheme,
        ),
      const SizedBox(height: 20)
      ],
    );
  }
}

Widget viewDefault() {

  // description  : vista por defecto que se le muestra al usuario para que seleccione un cuenta

  // controllers
  final HomeController homeController = Get.find();
  const TextStyle textStyle = TextStyle(
    fontFamily: 'Roboto', // o 'Open Sans'
    fontSize: 20,
    fontWeight: FontWeight.w400, // o cualquier otra variante
  );

  return Scaffold(
    body: Center(
        child: Column(  
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // text : bienvenida
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Hola 🖐️\n\nIngresa a tu cuenta para gestionar tu tienda\n',textAlign: TextAlign.center,style: textStyle,),
                ),
                const SizedBox(height: 20), 
                // lista de cuentas administradas o boton para crear una cuenta
                !homeController.getLoadedManagedAccountsList?const CircularProgressIndicator(): !homeController.checkAccountExistence? WidgetButtonListTile().buttonListTileCrearCuenta()
                :Flexible(  
                  fit: FlexFit.loose,
                  child: SizedBox( 
                    height: 200,   
                    child: Wrap( 
                      runSpacing: 12, // espaciado entre filas
                      spacing: 12, // espaciado entre columnas
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.center,
                      children: homeController.getManagedAccountsList.map((e) => WidgetButtonListTile().buttonListTileItemCuenta(perfilNegocio: e,row: true)).toList(),
                    ), 
                  ),
                ),
              ],
            ),
          ),
        ),
        // textButton : cerrar sesion
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(onPressed: homeController.showDialogCerrarSesion, child: const Text('Cerrar sesión')),
        ),
      ],
    )),
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
 
 

// ignore: must_be_immutable
class ComponentApp extends StatelessWidget {
  ComponentApp({Key? key}) : super(key: key);

  // var 
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {

    // set 
    darkMode = Get.theme.brightness == Brightness.dark;
    return Container();
  }

  PreferredSize linearProgressBarApp({Color color = Colors.purple}) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: LinearProgressIndicator(
            minHeight: 6.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color)));
  }

  Divider divider({double thickness = 0.1}) {
    return Divider(
      thickness: thickness,height: 0,
      color: Get.isDarkMode?Colors.white30:Colors.black38,
    );
  }
}


class WidgetSuggestionProduct extends StatelessWidget {

  // ignore: prefer_const_constructors_in_immutables
  WidgetSuggestionProduct({Key? key, required this.list, this.searchButton = false}): super(key: key);

  //values
  final bool searchButton ;
  final List<Product> list ;
  

  @override
  Widget build(BuildContext context) {

    // controllers
    CataloguePageController homeController = Get.find<CataloguePageController>();

    if (list.isEmpty) return Container();

    // values
    Color? colorAccent = Get.theme.textTheme.titleMedium?.color;
    double radius = 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("Sugerencias para vos",style: Get.theme.textTheme.titleMedium),
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


// ignore: must_be_immutable
class LogoPremium extends StatelessWidget {

  late bool visible;
  late double size;
  late Color accentColor;
  late final bool personalize;
  late String id;

  LogoPremium({Key? key,this.personalize=false,this.accentColor=Colors.amber,this.size=12,this.visible=false,this.id='premium'}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // others controllers
    final HomeController homeController = Get.find();
    
    // value
    if( personalize  == false ){ 
      // valores por defecto
      accentColor = Theme.of(context).brightness==Brightness.dark?Colors.white70:Colors.black87; 
    }


    return InkWell(
  onTap: () => homeController.showModalBottomSheetSubcription(id:id ),
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Opacity(
      opacity: 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
          decoration: BoxDecoration(border: Border.all(color: accentColor)),
          child: Text('Funciones Premium',style: TextStyle(fontSize: size,color:accentColor),textAlign: TextAlign.center,overflow: TextOverflow.clip,)
        ),
      ),
    ),
  ),
);

  }
}

class ImageAvatarApp extends StatelessWidget {
  late final bool iconAdd;
  late final bool favorite;
  late final String url;
  late final double size;
  late final double radius;
  late final String description;
  late final String path;
  final VoidCallback?  onTap;
  late final Color canvasColor;
  // ignore: prefer_const_constructors_in_immutables
  ImageAvatarApp({Key? key,this.iconAdd=false,this.canvasColor=Colors.black12,this.favorite=false,this.url='',this.size=50,this.radius=12,this.description='',this.path='', this.onTap }) : super(key: key);

  // avatar que se va usar en toda la app, especialemnte en los 'ListTile'

  @override
  Widget build(BuildContext context) { 


     // var
     final bool darkMode = Theme.of(context).brightness==Brightness.dark;


    /// widgets
    Widget imageDefault = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: darkMode?Colors.black12:Colors.black12,
      child:iconAdd?const Opacity(opacity: 0.5,child: Icon(Icons.add_a_photo)): Image.asset('assets/default_image.png',fit: BoxFit.cover,color: darkMode?Colors.white12 :Colors.grey.shade200,));
 
    return SizedBox(
      width: size,height: size,
      child: path =='' ?InkWell(
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: favorite?Colors.yellow.shade700:Colors.transparent,
              width: favorite?2:0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: InkWell(
              onTap: onTap,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) =>  imageDefault,
                errorWidget: (context, url, error) =>imageDefault,
              ),
            ),
          ),
        ),
      ) : Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.file(File(path), fit: BoxFit.cover),
            ),
        ),
      ),
    );
  }
}
