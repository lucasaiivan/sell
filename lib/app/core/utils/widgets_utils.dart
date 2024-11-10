
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:sell/app/core/utils/dynamicTheme_lb.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/presentation/sellPage/controller/sell_controller.dart'; 
import '../../domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart'; 
import '../../presentation/sellPage/views/sell_view.dart';
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
  // ignore: prefer_const_constructors_in_immutables
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
  final Color? color;

  /// Crea un widget de icono de escaneo de código de barras.
  ///
  /// [size] es el tamaño deseado del icono en píxeles.
  const ImageIconScanWidget({
    Key? key, 
    required this.size, this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/scanbarcode.png',color: color),
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
      trailing: const Icon(Icons.arrow_forward_ios_rounded), 
      dense: true,
      title: const Text("Crear perfil de mi negocio", style: TextStyle(fontSize: 16.0)),
      onTap: () {
        Get.back(); 
        Get.toNamed(Routes.account, arguments: {'create': true});
      },
    );
  }

  Widget buttonListTileItemCuenta({required ProfileAccountModel perfilNegocio,bool row = false}) {

    // others controllers
    final HomeController homeController = Get.find();

    // var 
    final bool isSelected =  homeController.getProfileAccountSelected.id == perfilNegocio.id; 
    final bool isAdmin = homeController.getProfileAdminUser.admin;
    final bool isSuperAdmin = homeController.getProfileAdminUser.superAdmin;

    // condition : si el perfil de negocio no tiene id no se muestra
    if (perfilNegocio.id == '') { return Container(); }

    // row : si la vista es en forma de lista horizontal , se muesta una vista reducida de el avatar y el nombre debajo
    if(row){
      return InkWell(
        onTap: () { 
          controller.accountChange(idAccount: perfilNegocio.id);
        },
        // touch round
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          width: 80.0,
          // shape : borde delineada con esquinas redondeadas 
          decoration: BoxDecoration(border: Border.all(color: homeController.getDarkMode?Colors.white: Colors.black38,width:0.2,),borderRadius: BorderRadius.circular(10.0)),
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
                    Get.toNamed(Routes.account);
                  }else{
                    // action : ir a la cuenta seleccionada 
                    controller.accountChange(idAccount: perfilNegocio.id);
                  }
                },
                child: SizedBox(
                  height: 50,width: 50,
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
              Text(perfilNegocio.name, style: const TextStyle( overflow: TextOverflow.ellipsis )),
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
          title: Text(perfilNegocio.name,style: const TextStyle( fontSize: 18,overflow: TextOverflow.ellipsis)),
          subtitle: homeController.getProfileAccountSelected.id != perfilNegocio.id ? null  : Text( isSuperAdmin ? 'Super Administrador' : isAdmin ? 'Administrador' : 'Usuario estandar'),
          trailing:  isSelected ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.check_circle_outline_rounded,color: Colors.blue),
          ):null,
          onTap: () {
            if(homeController.getProfileAccountSelected.id == perfilNegocio.id){
                 // no hace ninguna acción
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
  SellController salesController = Get.find<SellController>();

  @override
  Widget build(BuildContext context) {

    //  values 
    final String alertStockText = widget.producto.stock && salesController.homeController.getIsSubscribedPremium ? (widget.producto.quantityStock >=0 ? widget.producto.quantityStock<=widget.producto.alertStock?'Stock bajo':'' : 'Sin stock'): '';

    // aparición animada
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Stack(  
        children: [
          // view : alert stock, image and info
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
              Flexible(child: contentImage()),
              contentInfo(),
            ],
          ),
          // view : selected
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: MouseCursor.uncontrolled,
                onTap: (){ 
                  // action : abre el dialogo para mostrar la informacion completa basica (imagen,codigo y descripcion) del producto
                  Get.dialog( EditProductSelectedDialogView(product: widget.producto) ); 
                },
                onLongPress: (){
                  // action : abre el dialogo para mostrar la informacion completa basica (imagen,codigo y descripcion) del producto
                  Get.dialog( EditProductSelectedDialogView(product: widget.producto) ); 
                },
              ),
            ),
          ),
          // view : cantidad de productos seleccionados
          widget.producto.quantity==1 ?  Container()
          :Positioned(
            top:5,
            right:5,
            child: CircleAvatar(
              backgroundColor: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: CircleAvatar(  
                  backgroundColor: Colors.white,
                  child: Text(widget.producto.quantity.toString(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
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
            value: widget.producto.salePrice * widget.producto.quantity);
    return widget.producto.image != "" && !widget.producto.local
        ? SizedBox(
            width: double.infinity,
            child: CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 200),
              fit: BoxFit.cover,
              imageUrl: widget.producto.image,
              placeholder: (context, url) => Container(
                color: Colors.grey[100],
                child: Center(
                  child: Text(description, style: const TextStyle(fontSize: 24.0, color: Colors.grey,overflow: TextOverflow.clip )),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[100],
                child: Center(
                  child: Text(description,
                      style:  const TextStyle(fontSize: 24.0, color: Colors.grey,overflow: TextOverflow.clip)),
                ),
              ),
            ),
          )
        : Container(
            color: Colors.grey[100],
            child: Center(
              child: Text(description,
                  style: const TextStyle(fontSize: 24.0, color: Colors.grey,overflow: TextOverflow.clip)),
            ),
          );
  }

  Widget contentInfo() {
    return widget.producto.description == ''
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.producto.description,style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.grey ,overflow:TextOverflow.ellipsis),maxLines:1),
                Text( Publications.getFormatoPrecio(value: widget.producto.salePrice * widget.producto.quantity),
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17.0,color: Colors.black),
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
    
    return body(context: context); 
}

// WIDGETS VIEWS
Widget body({required BuildContext context}){

  // controllers
    final HomeController homeController = Get.find<HomeController>();
    final SellController sellController = Get.find<SellController>();

    // variables
    UserModel user = homeController.getProfileAdminUser.copyWith(); 
    bool isAnonymous = homeController.getFirebaseAuth.currentUser!.isAnonymous;

    // widgets
    final textButtonLogin = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(width: double.infinity,child: FloatingActionButton(onPressed: homeController.signOutFirebase,elevation: 0,child: const Text('Iniciar sesión',style: TextStyle(color: Colors.white),))),
    );  
    
    return Obx(() => Column(
      children: [
        Flexible(
          child: ListView( 
            children: [
              // view : header
              Row(
                children: [
                  const Spacer(),
                  // iconButton : seleccionar cuenta administradas
                  isAnonymous?Container():homeController.getCashierMode?Container():iconButtonAccount, 
                  // icon : cambia el tema de la  app
                  IconButton(
                    onPressed: () => ThemeService.switchTheme,
                    icon: Icon(Theme.of(context).brightness == Brightness.dark?Icons.light_mode:Icons.nightlight),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              // view : avatar y datos la cuenta y del usuario
              isAnonymous?textButtonLogin
                :ListTile(
                leading: Container(padding: const EdgeInsets.all(0.0),child: ComponentApp().userAvatarCircle(urlImage: homeController.getProfileAccountSelected.image,text: homeController.getProfileAccountSelected.name)),
                title: Text(homeController.getIdAccountSelected == ''? 'Seleccionar una cuenta': homeController.getProfileAccountSelected.name,maxLines: 1,overflow: TextOverflow.ellipsis),
                subtitle: user.name==''? null:Opacity(
                  opacity: 0.7,
                  child: Row(
                    children: [
                      // icon 
                      const Icon(Icons.person_rounded,size: 14),
                      const SizedBox(width:2),
                      // text : nombre del usuario administrador
                      Flexible(child: Text(user.name,overflow: TextOverflow.ellipsis,maxLines: 1)),
                    ],
                  ),
                ),
                trailing: homeController.getCashierMode?null: const Icon(Icons.arrow_right),
                onTap: homeController.getCashierMode?null: () {
                  homeController.showModalBottomSheetConfig();
                },
              ),  
              homeController.getCashierMode || isAnonymous?const Padding(
                padding: EdgeInsets.only(bottom: 0,top: 20),
                child: Divider(height:0,thickness:.5),
              ):Container(),
              // ----------------- //
              // funciones premium //
              // ----------------- //
              // condition : si el usuario de la cuenta no es administrador no se muestra el boton de suscribirse a premium
              user.admin==false?Container():
              isAnonymous?Container():
              homeController.getCashierMode?Container():
                Container(
                  // color degradado de izquierda a derecha [amber,transparent]
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.1),Colors.amber.withOpacity(0.01) ],begin: Alignment.centerLeft,end: Alignment.centerRight)),
                  child: ListTile( 
                    iconColor:  Colors.amber,  
                      leading: const Icon(Icons.star_rounded),
                      title: Text(homeController.getIsSubscribedPremium?'Premium':'Obtener Premium'),
                      subtitle: homeController.getTrialActive? Text('¡Te quedan ${homeController.getDaysLeftTrialFormat} de prueba!'):null,
                      onTap: (){
                        // action : mostrar modal bottom sheet con  las funciones premium
                        homeController.showModalBottomSheetSubcription();
                      }),
                ), 
              // vender 
              ListTile(
                selected: homeController.getIndexPage == 0,
                  leading: const Icon(Icons.attach_money_rounded),
                  trailing: homeController.getIndexPage != 0 ? null : const Icon(Icons.circle,size: 8),
                  title: const Text('Vender'),
                  onTap: () => homeController.setIndexPage = 0),
              // historial de caja
              user.historyArqueo || isAnonymous ?homeController.getCashierMode?Container():ListTile( 
                enabled: !isAnonymous,
                selected: homeController.getIndexPage == 1,
                leading: const Icon(Icons.manage_search_rounded),
                trailing: homeController.getIndexPage != 1 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Historial de caja'),
                onTap: () => homeController.setIndexPage = 1):Container(),
              // transacciones
              user.transactions || isAnonymous?homeController.getCashierMode?Container():ListTile(
                enabled: !isAnonymous,
                selected: homeController.getIndexPage == 2,
                leading: const Icon(Icons.receipt_long_rounded),
                trailing: homeController.getIndexPage != 2 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Transacciones'),
                onTap: () => homeController.setIndexPage = 2):Container(),
              // catalogo
              user.catalogue || isAnonymous?homeController.getCashierMode?Container():ListTile(
                enabled: !isAnonymous,
                selected: homeController.getIndexPage == 3,
                leading: const Icon(Icons.apps_rounded),
                trailing: homeController.getIndexPage != 3 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Catálogo'),
                onTap: () => homeController.setIndexPage = 3):Container(),
              // TODO : desabilitar visualizacion para produccion
              /* ListTile(
                enabled: !isAnonymous,
                selected: homeController.getIndexPage == 5,
                leading: const Icon(Icons.admin_panel_settings_outlined),
                trailing: homeController.getIndexPage != 5 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Moderador'),
                onTap: () {
                  Get.toNamed(Routes.moderator); 
                },
              ), */
              // multiusuario
              user.multiuser || isAnonymous?homeController.getCashierMode?Container():
              ListTile(
                enabled: !isAnonymous,
                selected: homeController.getIndexPage == 4,
                leading: const Icon(Icons.group_add_outlined),
                trailing: homeController.getIndexPage != 4 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Multi Usuario'),
                onTap: () {
                  homeController.setIndexPage = 4;
                  
                }):Container(),
              const SizedBox(height: 20),
              homeController.getCashierMode?Container():Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.withOpacity(0.1),Colors.teal.withOpacity(0.01) ],begin: Alignment.centerLeft,end: Alignment.centerRight)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  tileColor: Colors.transparent,//Colors.blue.withOpacity(0.05),
                  leading: const Icon(Icons.messenger_outline_sharp,color: Colors.green),
                  title: const Text('Escribenos tu opinión 😃'),
                  subtitle: const Text('Tu opinión o sugerencia es importante para mejorar'),
                  onTap: () async {
                    
                    // values
                    Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.logicabooleana.sell');
                    //  redireccionara para la tienda de aplicaciones
                    await launchUrl(uri,mode: LaunchMode.externalApplication);
                  },
                ),
              ),   
              const SizedBox(height: 20)
            ],
          ),
        ),
        const Divider(height: 0),
        const SizedBox(height:5),
        // switch : modo cajero
        ListTile(
          leading: const Icon(Icons.security_rounded),
          title: const Text('Modo cajero'),
          trailing: Switch(
            value: homeController.getCashierMode,
            activeColor: Colors.blue,
            onChanged: (value) {  
              // condition : si esta en modo de app de prueba 
              if(isAnonymous){
                // action : activar el modo cajero
                  homeController.setCashierMode = value;
                  sellController.update();
                  return;
              }
              // condition : para desactivar el modo cajero introducir la pin
              if(value == false ){
                // show dialog : introducir pin para desactivar el modo cajero
                Get.dialog( PinCheckAlertDialog(entry: true),barrierDismissible: false);
              }else{
                // condition : primero verificar que existe un pin 
                if(homeController.getProfileAccountSelected.pin == ''){
                  // show dialog : introducir pin para desactivar el modo cajero
                  Get.dialog(  PinCheckAlertDialog(create: true),barrierDismissible: false);
                }else{
                  // action : activar el modo cajero
                  homeController.setCashierMode = value;
                  sellController.update();
                } 
              }
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    ));
  }
  // VIEW COMPONENTS //
  Widget get iconButtonAccount{ 
    // description : crea un maximo de 3 avatares de cuentas existentes superpuestas con un [stack] horizontalmente
    
    // controllers
    final HomeController homeController = Get.find();
    
    // var
    List<ProfileAccountModel> list = homeController.getManagedAccountsList;   
    double space = 9.0;
    List<Widget> listWidget = [];
    // condition : si no hay cuentas administradas se muestra un iconobutton por defecto
    if (list.isEmpty) {
      return IconButton(
        onPressed: () {
          homeController.showModalBottomSheetSelectAccount();
        },
        icon: const Icon(Icons.change_circle_outlined),
      );
    }
    // loop : crea un maximo de 3 avatares de cuentas existentes superpuestas con un [stack] horizontalmente
    for ( int i = 0; i < list.length  ; i++) {  
      // se muestra el avatar de la cuenta 
      listWidget.add(Positioned(
        left: ( space) * i,
        child: ComponentApp().userAvatarCircle(urlImage: list[i].image,radius:12,lineBorder: true),
      ));
    } 
    // add : posisionar el icono a lo ultimo 
    listWidget.add(Positioned(
      left: (  space) * listWidget.length,
      child: ComponentApp().userAvatarCircle(urlImage: '',radius: 14,iconData: Icons.change_circle_outlined,lineBorder: true),
    ));

    return SizedBox(
      width: 55,
      height: 50,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: Material(
          child: InkWell(
            onTap: () => homeController.showModalBottomSheetSelectAccount(),
            radius: 100.0,// radio de la esquina
            child: Stack(
              clipBehavior: Clip.antiAlias,
              fit: StackFit.loose, // loose :
              alignment: Alignment.center,
              children: listWidget,
            ),
          ),
        ),
      ),
    );

  }

}

Widget viewSelectedAccount() {

  // description  : vista por defecto que se le muestra al usuario para que seleccione un cuenta

  // controllers
  final HomeController homeController = Get.find();
  // style
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
                  child: Text('Hola 🖐️\n\nIngresa a una cuenta para gestionar la tienda\n',textAlign: TextAlign.center,style: textStyle,),
                ),
                const SizedBox(height: 20), 

                !homeController.getLoadedManagedAccountsList?Container():homeController.checkAccountExistence?Container():
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:75),
                  child: ComponentApp().button(
                    disable: homeController.getProfileAdminUser.superAdmin,
                    text: 'Crear perfil de mi negocio',
                    onPressed: () { 
                      Get.toNamed(Routes.account,arguments: {'create':true});
                    },
                  ),
                ),

                // lista de cuentas administradas o boton para crear una cuenta
                !homeController.getLoadedManagedAccountsList?const CircularProgressIndicator(): homeController.getManagedAccountsList.isEmpty? Container()
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
          child: Column(
            children: [
              // text : email del usuario
              Opacity(opacity:0.5,child: Text(homeController.getFirebaseAuth.currentUser!.email??'')),
              // button : cerrar sesion
              TextButton(onPressed: homeController.showDialogCerrarSesion, child: const Text('Cerrar sesión')),
            ],
          ),
        ),
      ],
    )),
  );
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
  // view : grafico de barra para mostrar el progreso de carga de la app
  PreferredSize linearProgressBarApp({Color color = Colors.blue}) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: LinearProgressIndicator(
            minHeight: 6.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color)));
  }
  // view : grafico divisor estandar de la app 
  Divider divider({double thickness = 0.3}) {
    return Divider(
      thickness: thickness,height: 0, 
    );
  }
  // view : grafico punto divisor estandar de la app
  Widget dividerDot({double size = 4.0,Color color = Colors.black}) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child:Icon(Icons.circle,size:size, color: color.withOpacity(0.4)));
  }
  // view : imagen avatar del usuario
  Widget userAvatarCircle({ Color? background,IconData? iconData,bool empty=false,String urlImage='',String text = '', double radius = 20.0,bool lineBorder = false,Color? lineBorderColor }) {
    
    // style
    lineBorderColor ??= Colors.white;
    Color backgroundColor =background??Get.theme.dividerColor ;
    // widgets
    late Widget avatar;
    late Widget iconDefault;
    Widget iconText = text == ''?Container(): Text( text.substring( 0,1),style: TextStyle(color: Colors.white,fontSize: radius*0.8));
    if(empty){
      iconDefault = Container();
    }else if(urlImage == '' && text == ''){
      iconDefault =  iconText;
    }else if(urlImage == '' && text != ''){
      iconDefault = iconText;
    }else{
      iconDefault = Container();
    }
    if(iconData!=null){
      iconDefault = Icon(iconData,color:lineBorderColor);
    }
    
    // crear avatar
    avatar = urlImage == ''
      ? CircleAvatar(
        backgroundColor:lineBorderColor,
        radius:radius,
        child: CircleAvatar(backgroundColor:backgroundColor,radius:lineBorder==false?radius:radius-0.5, child: Center(child: iconDefault)))
        : CachedNetworkImage(
          imageUrl: urlImage,
          placeholder: (context, url) => CircleAvatar(
            backgroundColor:lineBorderColor,
            radius:radius,
            child: CircleAvatar(backgroundColor:backgroundColor,radius:lineBorder==false?radius:radius-0.5, child:iconDefault)),
          imageBuilder: (context, image) => CircleAvatar(
            backgroundColor:lineBorderColor,
            radius:radius,
            child: CircleAvatar(backgroundImage: image,radius:lineBorder==false?radius:radius-0.5, child: iconDefault)),
          errorWidget: (context, url, error) {
            // return : un circleView con la inicial de nombre como icon 
            return CircleAvatar(
              backgroundColor:lineBorderColor,
              radius:radius,
              child: CircleAvatar(
                backgroundColor: backgroundColor,
                radius:lineBorder==false?radius:radius-0.5,
                child: Center(child: iconText),
                ),
            );
          },
    );

    return avatar;
  }
  // BUTTONS 
  Widget buttonAppbar({ required BuildContext context,Function() ?onTap,required String text,Color ?colorBackground ,Color ?colorAccent,IconData ?iconLeading ,IconData ?iconTrailing,EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0)}){ 
    
    // values default
    colorBackground ??= Theme.of(context).brightness == Brightness.dark?Colors.white:Colors.black;
    colorAccent ??= Theme.of(context).brightness == Brightness.dark?Colors.black:Colors.white;

    return Padding(
      padding: padding,
      child: Material(
        clipBehavior: Clip.antiAlias, 
        color: colorBackground,
        borderRadius: BorderRadius.circular(25),
        elevation: 0,
        child: InkWell(
          onTap:  onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 14, top: 8, bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // icon leading
                iconLeading==null?Container():Icon(iconLeading,color: colorAccent,size: 24),
                iconLeading==null?Container():const SizedBox(width:8),
                // text
                Flexible(child: Text(text,style: TextStyle(color: colorAccent,fontSize: 16 ),overflow: TextOverflow.ellipsis)), 
                iconTrailing==null?Container():const SizedBox(width:8), 
                iconTrailing==null?Container():Icon(iconTrailing,color: colorAccent,size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  } 
  Widget button( {bool defaultStyle = false,double elevation=0,double fontSize = 14,double width = double.infinity,bool disable = false, Widget? icon, String text = '',required dynamic onPressed,EdgeInsets padding =const EdgeInsets.symmetric(horizontal:0, vertical:16),Color? colorButton= Colors.blue,Color colorAccent = Colors.white , EdgeInsets margin =const EdgeInsets.symmetric(horizontal: 0, vertical: 0)}) {
     
    // button : personalizado
    return FadeIn(
        child: Padding(
      padding: margin,
      child: SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: disable?null:onPressed,
          style: ElevatedButton.styleFrom(  
            elevation:defaultStyle?0: elevation,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: padding,
            backgroundColor: colorButton ,
            textStyle: TextStyle(color: colorAccent,fontWeight: FontWeight.w700),
          ),  
          icon: icon??Container(),
          label: Text(text, style: TextStyle(color: colorAccent,fontSize: fontSize),textAlign: TextAlign.center),
        ),
      ),
    ));
  }

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
}


class WidgetSuggestionProduct extends StatelessWidget {

  // ignore: prefer_const_constructors_in_immutables
  WidgetSuggestionProduct({Key? key, required this.list, this.searchButton = false,this.positionDinamic=false}): super(key: key);

  //values
  final bool positionDinamic;
  final bool searchButton ;
  final List<Product> list ; 
   
  @override
  Widget build(BuildContext context) {

    // controllers
    HomeController controller = Get.find();

    if (list.isEmpty) return Container();

    // values
    Color? colorAccent = Get.theme.textTheme.titleMedium!.color?.withOpacity(0.1);
    double radius = 32.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // button : buscar producto
        !searchButton
            ? Container()
            : InkWell(
                onTap: () => Get.toNamed(Routes.searchProduct,arguments: {'id': ''}),
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
        // condition : si la posicion es dinamica
        positionDinamic?
        CustomAvatarRow(
          width: Get.size.width,
          height: 100,
          avatars: list.map((e) => CircleAvatar(
            backgroundColor: colorAccent,
            foregroundColor: colorAccent,
            radius: radius,
            child: CircleAvatar(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[100],
                radius: radius-2,
                child: ClipRRect(
                  borderRadius:BorderRadius.circular(50),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),  
                   onTap: () => controller.navigationToPage(productCatalogue: e.convertProductCatalogue()),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration( milliseconds: 200),
                      fit: BoxFit.cover,
                      imageUrl: e.image,
                      placeholder: (context, url) =>CircleAvatar(backgroundColor:Colors.grey[100],foregroundColor:Colors.grey[100]),
                      errorWidget:(context, url, error) =>CircleAvatar(backgroundColor:Colors.grey[100],foregroundColor:Colors.grey[100]),
                    ),
                  ),
                )),
          )).toList(),
        )
        // si la posicion no es dinamica
        :SizedBox(
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
                        onTap: () => controller.navigationToPage(productCatalogue: list[index].convertProductCatalogue()),
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
    );
  }
}
class CustomAvatarRow extends StatelessWidget {
  final double width;
  final double height;
  final List<CircleAvatar> avatars;

  const CustomAvatarRow({super.key, 
    required this.width,
    required this.height,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal:20.0),
        scrollDirection: Axis.horizontal,
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Align(
              alignment: index % 2 == 0 ? Alignment.topCenter : Alignment.bottomCenter,
              child: avatars[index],
            ),
          );
        },
      ),
    );
  }
}


// ignore: must_be_immutable
class LogoPremium extends StatelessWidget {

  late bool visible;
  late double size;
  late Color accentColor;
  late Color backgroundColor;
  late final bool personalize;
  late String id;

  LogoPremium({Key? key,this.personalize=false,this.backgroundColor=Colors.amber,this.accentColor=Colors.white,this.size=14,this.visible=false,this.id='premium'}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // others controllers
    final HomeController homeController = Get.find(); 
    bool isDarkMode = Get.theme.brightness == Brightness.dark;

    backgroundColor = isDarkMode?Colors.black26:backgroundColor;
    accentColor = isDarkMode?Colors.amber:accentColor;


    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material( 
        clipBehavior: Clip.antiAlias,
        // background color
        color:backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        child: InkWell(
          onTap: () => homeController.showModalBottomSheetSubcription(id:id ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // icon : corona
                Icon(Icons.star_rounded,color:accentColor,size: size),
                // text 
                Text(' Premium',style: TextStyle(fontSize: size,color:accentColor,fontWeight: FontWeight.w900),textAlign: TextAlign.center,overflow: TextOverflow.clip),
              ],
            ),
          ),
        )
      ),
    );

  }
}

class ImageProductAvatarApp extends StatelessWidget { 
  late final  Widget? icon;
  late final bool iconAdd; 
  late final String url;
  late final double size;
  late final double radius;
  late final String description;
  late final String path;
  final VoidCallback?  onTap;
  late final Color canvasColor;
  // ignore: prefer_const_constructors_in_immutables
  ImageProductAvatarApp({Key? key,this.url='', this.size = 75, this.radius = 6.0, this.description = '', this.path = '', this.onTap, this.iconAdd = false, this.canvasColor = Colors.grey,this.icon }) : super(key: key);

  // avatar que se va usar en toda la app, especialemnte en los 'ListTile'

  @override
  Widget build(BuildContext context) { 


    // var
    final bool darkMode = Theme.of(context).brightness==Brightness.dark;
    // style 
    Color backgroundColor = Colors.grey.withOpacity(0.2);
    Color iconColor = darkMode?Colors.white38 :Colors.white70;


    /// widgets
    Widget imageDefault=Container();
    if(iconAdd){
      imageDefault = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: backgroundColor,
      child: Icon( Icons.add_a_photo,color: iconColor));
    }else {
      imageDefault = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: backgroundColor,
      child:icon??Image.asset('assets/default_image.png',fit: BoxFit.cover,color: iconColor));
    }
    return SizedBox(
      width: size,height: size,
      child: path =='' ?InkWell(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 75,
          height: 75,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),border: Border.all(color: Colors.transparent,width: 0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),  
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

// view : dialog para editar item del producto seleccionado
class EditProductSelectedDialogView extends StatefulWidget {
  
  final ProductCatalogue product;
  const EditProductSelectedDialogView({Key? key,required this.product}) : super(key: key);

  @override
  State<EditProductSelectedDialogView> createState() => _EditProductSelectedDialogViewState();
}

class _EditProductSelectedDialogViewState extends State<EditProductSelectedDialogView> {
  
  // controllers
  final SellController controller = Get.find<SellController>();
  // var 
  bool favorite = false;  
  
  
  @override
  Widget build(BuildContext context) {
  
    // set values
    favorite = widget.product.favorite;
    // widgets
    Widget titleWidget = Text(widget.product.description,style: const TextStyle(fontWeight: FontWeight.w400),maxLines: 5,overflow: TextOverflow.ellipsis);
    Widget subtitleWidget = Text(Publications.getFormatoPrecio(value: widget.product.salePrice),style: const TextStyle(fontWeight: FontWeight.bold));
    Widget priceTotalText = Text(Publications.getFormatoPrecio(value: widget.product.salePrice * widget.product.quantity),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.blue ));


    return AlertDialog(
      title: Row(
        children: [
          // text : titulo barrar superior
          Flexible(
            fit: FlexFit.tight,
            child: Text(widget.product.code==''?'Item':widget.product.code,style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 18),overflow: TextOverflow.ellipsis,)
           ),
           // button : agregar a favorito
          widget.product.code==''?Container():!controller.homeController.getProfileAdminUser.catalogue?Container()
          :IconButton(
            onPressed: (){
              setState(() {
                favorite=!favorite;
                controller.setProductFavorite(product: widget.product, favorite: favorite);
              });
            },
            icon: Icon(favorite?Icons.star: Icons.star_border,color: favorite?Colors.amber:null,)),
          // button : editar product
          widget.product.code==''?Container():!controller.homeController.getProfileAdminUser.catalogue?Container()
          :IconButton(
            onPressed: (){
              Get.back();
              controller.showUpdatePricePurchaseAndSalesDialog(product: widget.product);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          // button : cerrar dialog
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.close)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile( 
            leading: ImageProductAvatarApp(url: widget.product.image,size: 35),
            title:widget.product.description==''?subtitleWidget:titleWidget, 
            // subtitle : codigo del producto si es q existe 
            subtitle: widget.product.description==''? null:subtitleWidget,
          ),  
          //priceTotalText,
          // divider : seleccionar cantidad 
          Row(  
            children: [
              const Flexible(child: Divider(thickness:0.6 )), 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: widget.product.quantity==1?const Text('Cantidad'): priceTotalText,
              ),
              const Flexible(child: Divider(thickness:0.6)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // button : disminuir cantidad
              FloatingActionButton(
                elevation: 3,
                onPressed: () {
                  controller.getTicket.decrementProduct(product: widget.product); 
                  controller.update();
                  if(widget.product.quantity>1){
                    setState(() {widget.product.quantity--;});
                  }
                },
                child: const Icon(Icons.horizontal_rule,color: Colors.white),
              
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(widget.product.quantity.toString(),style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              ),
              // button : aumentar cantidad
              FloatingActionButton(
                elevation: 3,
                onPressed: () {
                  controller.getTicket.incrementProduct(product: widget.product); 
                  controller.update();
                  setState(() {widget.product.quantity++;});
                },
                child: const Icon(Icons.add,color: Colors.white),
              ),  
            ],
          ),
        ],
      ),
      actions: [
        // butoom : eliminar
        TextButton(
          onPressed: () {
            controller.getTicket.removeProduct(product: widget.product); 
            controller.update();
            Get.back();
          },
          child: Text('Quitar',style: TextStyle(color: Colors.red.shade400)),
        ),
        // button : cancelar
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Ok'),
        ),
        
      ],
    );

  }

  // views
  Widget body({required BuildContext context}) {
    return Container();
  }
}
// ---------------------------------- //
// ---------- Paint ----------------- //
// ---------------------------------- //
class RoundedBubblePainter extends CustomPainter {
  // description : Clase que dibuja un globo de conversación redondeado
  final Color color;
  final double radius;
  final bool isPointingUp;
  final bool isPointingLeft;
  final double notchMargin; // Margen para la muesca

  RoundedBubblePainter({
    required this.color,
    this.radius = 16.0,
    this.isPointingUp = false, // Por defecto la muesca apunta hacia abajo
    this.isPointingLeft = true, // Por defecto la muesca apunta hacia la izquierda
    this.notchMargin = 20.0, // Margen por defecto para la muesca
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calcular la posición de la muesca con margen
    final double notchXStart = isPointingLeft ? notchMargin : size.width - notchMargin;
    
    // Rectángulo principal del globo
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        isPointingLeft ? 10 : 0,
        isPointingUp ? 10 : 0,
        isPointingLeft ? size.width : size.width - 10,
        isPointingUp ? size.height : size.height - 10,
      ),
      Radius.circular(radius),
    );

    // Dibujar la forma principal del globo de conversación
    canvas.drawRRect(bubbleRect, paint);

    // Dibujar la muesca del globo de conversación
    final path = Path();
    if (isPointingUp) {
      // Muesca arriba
      path.moveTo(notchXStart - 10, 10);
      path.lineTo(notchXStart, 0);
      path.lineTo(notchXStart + 10, 10);
    } else {
      // Muesca abajo
      path.moveTo(notchXStart - 10, size.height - 10);
      path.lineTo(notchXStart, size.height);
      path.lineTo(notchXStart + 10, size.height - 10);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
class RoundedChatBubble extends StatelessWidget {
  // description : Widget que dibuja un globo de conversación redondeado
  final Widget widget;
  final Color bubbleColor;
  final bool isPointingUp;
  final bool isPointingLeft;
  final double notchMargin;

  const RoundedChatBubble({
    super.key,
    required this.widget,
    this.bubbleColor = Colors.blue,
    this.isPointingUp = false, // Por defecto la muesca apunta hacia abajo
    this.isPointingLeft = true, // Por defecto la muesca apunta hacia la izquierda
    this.notchMargin = 20.0, // Margen por defecto para la muesca
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RoundedBubblePainter(
        color: bubbleColor,
        isPointingUp: isPointingUp,
        isPointingLeft: isPointingLeft,
        notchMargin: notchMargin,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isPointingLeft ? 20.0 : 12.0,
          isPointingUp ? 25.0 : 20.0,
          isPointingLeft ? 12.0 : 20.0,
          isPointingUp ? 20.0 : 25.0,
        ),
        child: widget,
      ),
    );
  }
}


// AppMoneyInputFormatter : Formateador de texto para campos de dinero
// Este formateador se encarga de formatear el texto de un campo de texto para que se vea como un monto de dinero
class AppMoneyInputFormatter extends TextInputFormatter {

  final String symbol; 
  AppMoneyInputFormatter({this.symbol = '\$'});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,TextEditingValue newValue) { 
    
    // Eliminar cualquier cosa que no sea un número o una coma
    var newText = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    // elimina el 0 si es que esta al principioque existe de la primera posición
    if (newText.length > 1 && newText[0] == '0') {
      newText = newText.substring(1);
    }

    // Separar la parte entera y la parte decimal
    var parts = newText.split(',');
    var integerPart = parts[0];
    var decimalPart = parts.length > 1 ? parts[1] : '';

    // Limitar a 2 decimales
    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // Formatear la parte entera con puntos de miles
    var buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    // Construir el texto formateado
    var formattedText = buffer.toString();
    if (newText.contains(',')) {
      formattedText += ',$decimalPart';
    }

    // Añadir el signo de dólar al principio
    formattedText = '$symbol$formattedText';

    // Mantener la posición del cursor
    var selectionIndex = formattedText.length;
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
//  AppMoneyTextEditingController : Controlador de texto para campos de dinero
// Este controlador se encarga de manejar el valor de un campo de texto para que se vea como un monto de dinero
class AppMoneyTextEditingController extends TextEditingController {
  AppMoneyTextEditingController({String? value}) : super(text: value);

  // Método para obtener el valor como double
  double get doubleValue {
    String textWithoutCommas = text.replaceAll('.', '').replaceAll(',', '.').replaceAll('\$','');
    return double.tryParse(textWithoutCommas) ?? 0.0;
  }

  // Método para obtener el valor formateado como string
  String get formattedValue {
    return text;
  }
  // actualizar el valor del controlador
  void updateValue(double value) {
    // actualiza el nuevo valor teniendo en cuenta si tiene o no decimales
    text = Publications.getFormatoPrecio(value: value);
  }
}