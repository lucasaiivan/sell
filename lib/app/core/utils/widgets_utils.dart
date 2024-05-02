
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      trailing: const Icon(Icons.add), 
      dense: true,
      title: const Text("Crear perfil de mi negocio", style: TextStyle(fontSize: 16.0)),
      onTap: () {
        Get.back();
        Get.toNamed(Routes.account);
      },
    );
  }

  Widget buttonListTileItemCuenta({required ProfileAccountModel perfilNegocio,bool row = false}) {

    // others controllers
    final HomeController homeController = Get.find();

    // var 
    bool editAccount =  homeController.getProfileAdminUser.editAccount && homeController.getProfileAccountSelected.id == perfilNegocio.id;

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
          subtitle: homeController.getProfileAccountSelected.id != perfilNegocio.id ? null  : Text( editAccount ?'Administrador':'Tienes que ser administrador para editar esta cuenta'  ),
          trailing:  editAccount ? TextButton(onPressed: (){
              Get.back();
              Get.toNamed(Routes.account);
          }, child: const Text('Editar')): Radio(
            activeColor: Colors.blue,
            value: controller.isSelected(id: perfilNegocio.id) ? 0 : 1,
            groupValue: 0,
            onChanged: (val) {
              if(homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id){
                Get.back();
                Get.toNamed(Routes.account);
              }else{
                controller.accountChange(idAccount: perfilNegocio.id);
              }
              
            },
          ),
          onTap: () {
            if(homeController.getProfileAdminUser.superAdmin && homeController.getProfileAccountSelected.id == perfilNegocio.id){
                Get.back();
                Get.toNamed(Routes.account);
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
            monto: widget.producto.salePrice * widget.producto.quantity);
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
                Text( Publications.getFormatoPrecio(monto: widget.producto.salePrice * widget.producto.quantity),
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

    // variables
    UserModel user = homeController.getProfileAdminUser.copyWith(); 
    bool isAnonymous = homeController.getFirebaseAuth.currentUser!.isAnonymous;

    // widgets
    final textButtonLogin = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(width: double.infinity,child: FloatingActionButton(onPressed: homeController.signOutFirebase,elevation: 0,child: const Text('Iniciar sesión',style: TextStyle(color: Colors.white),))),
    );  
    
    return Obx(() => ListView( 
          children: [
            Row(
              children: [
                const Spacer(),
                // icon : cambia el tema de la  app
                IconButton(
                  onPressed: () => ThemeService.switchTheme,
                  icon: Icon(Theme.of(context).brightness == Brightness.dark?Icons.light_mode:Icons.nightlight),
                ),
                const SizedBox(width: 10),
              ],
            ),
            isAnonymous?textButtonLogin
              :ListTile(
              leading: Container(padding: const EdgeInsets.all(0.0),child: ComponentApp().userAvatarCircle(urlImage: homeController.getProfileAccountSelected.image)),
              title: Text(homeController.getIdAccountSelected == ''? 'Seleccionar una cuenta': homeController.getProfileAccountSelected.name,maxLines: 1,overflow: TextOverflow.ellipsis),
              subtitle: homeController.getIdAccountSelected == ''? null: Row(
                crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment:  MainAxisAlignment.start,
                children: [
                  user.name==''?Container():Flexible(child: Text(user.name,overflow: TextOverflow.ellipsis,maxLines: 1)),
                ],
              ),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                homeController.showModalBottomSheetSelectAccount();
              },
            ),  
            // ----------------- //
            // funciones premium //
            // ----------------- //
            // condition : si el usuario de la cuenta no es administrador no se muestra el boton de suscribirse a premium
            user.admin==false?Container():
            isAnonymous?Container():
              ListTile(
                tileColor: Colors.amber.withOpacity(homeController.getIsSubscribedPremium?0.02:0.05),
                iconColor:  Colors.amber, 
                //titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                  leading: const Icon(Icons.star_rounded),
                  title: Text(homeController.getIsSubscribedPremium?'Premium':'Funciones Premium'),
                  onTap: (){
                    // action : mostrar modal bottom sheet con  las funciones premium
                    homeController.showModalBottomSheetSubcription();
                  }),
            isAnonymous?const Opacity(opacity: 0.3,child: Divider(height:0)):Container(),
            const SizedBox(height: 20),
            // vender 
            ListTile(
              selected: homeController.getIndexPage == 0,
                leading: const Icon(Icons.attach_money_rounded),
                trailing: homeController.getIndexPage != 0 ? null : const Icon(Icons.circle,size: 8),
                title: const Text('Vender'),
                onTap: () => homeController.setIndexPage = 0),
            // historial de caja
            user.historyArqueo || isAnonymous ?ListTile( 
              enabled: !isAnonymous,
              selected: homeController.getIndexPage == 1,
              leading: const Icon(Icons.manage_search_rounded),
              trailing: homeController.getIndexPage != 1 ? null : const Icon(Icons.circle,size: 8),
              title: const Text('Historial de caja'),
              onTap: () => homeController.setIndexPage = 1):Container(),
            // transacciones
            user.transactions || isAnonymous?ListTile(
              enabled: !isAnonymous,
              selected: homeController.getIndexPage == 2,
              leading: const Icon(Icons.receipt_long_rounded),
              trailing: homeController.getIndexPage != 2 ? null : const Icon(Icons.circle,size: 8),
              title: const Text('Transacciones'),
              onTap: () => homeController.setIndexPage = 2):Container(),
            user.catalogue || isAnonymous?ListTile(
              enabled: !isAnonymous,
              selected: homeController.getIndexPage == 3,
              leading: const Icon(Icons.apps_rounded),
              trailing: homeController.getIndexPage != 3 ? null : const Icon(Icons.circle,size: 8),
              title: const Text('Catálogo'),
              onTap: () => homeController.setIndexPage = 3):Container(),
            user.multiuser || isAnonymous?ListTile(
              enabled: !isAnonymous,
              selected: homeController.getIndexPage == 4,
              leading: const Icon(Icons.group_add_outlined),
              trailing: homeController.getIndexPage != 4 ? null : const Icon(Icons.circle,size: 8),
              title: const Text('Multi Usuario'),
              onTap: () {
                if( homeController.getProfileAccountSelected.subscribed ){
                  homeController.setIndexPage = 4;
                }else{
                  Get.back(); // cierra drawer
                  homeController.showModalBottomSheetSubcription(id: 'multiuser');
                }
                
              }):Container(),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: Colors.blue.withOpacity(0.05),
              leading: const Icon(Icons.messenger_outline_sharp,color: Colors.green),
              title: const Text('Escribenos tu opinión 😃'),
              subtitle: const Text('Tu opinión o sugerencia es importante para mejorar esta app'),
              onTap: () async {
                
                // values
                Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.logicabooleana.sell');
                //  redireccionara para la tienda de aplicaciones
                await launchUrl(uri,mode: LaunchMode.externalApplication);
              },
            ),   
            const SizedBox(height: 20)
          ],
        ));
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
                ComponentApp().button(
                  disable: homeController.getProfileAdminUser.superAdmin,
                  text: 'Crear perfil de mi negocio',
                  onPressed: () { 
                    Get.toNamed(Routes.account);
                  },
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
  Divider divider({double thickness = 0.1}) {
    return Divider(
      thickness: thickness,height: 0,
      color: Get.isDarkMode?Colors.white30:Colors.black38,
    );
  }
  // view : grafico punto divisor estandar de la app
  Widget dividerDot({double size = 4.0,Color color = Colors.black}) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child:Icon(Icons.circle,size:size, color: color.withOpacity(0.4)));
  }
  // view : imagen avatar del usuario
  Widget userAvatarCircle({ Color? background,IconData? iconData,bool empty=false,String urlImage='',String text = '', double radius = 20.0}) {
    
    // style
    Color backgroundColor =background??Get.theme.dividerColor.withOpacity(empty?0.03:0.5);
    // widgets
    late Widget avatar;
    Widget iconDedault = Icon( Icons.person_outline_rounded,color: Colors.white,size: radius*1.5,);
    if(empty){
      iconDedault = Container();
    }else if(urlImage == '' && text == ''){
      iconDedault = Icon(iconData??Icons.person_outline_rounded,color: Colors.white,size: radius*1 );
    }else if(urlImage == '' && text != ''){
      iconDedault = Text( text.substring( 0,1),style: const TextStyle(color: Colors.white));
    }
    
    // crear avatar
    avatar = urlImage == ''
      ? CircleAvatar(backgroundColor:backgroundColor,radius:radius, child: Center(child: iconDedault))
        : CachedNetworkImage(
          imageUrl: urlImage,
          placeholder: (context, url) => CircleAvatar(backgroundColor:backgroundColor,radius:radius, child:iconDedault),
          imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: CircleAvatar(backgroundImage: image,radius:radius)),
          errorWidget: (context, url, error) {
            // return : un circleView con la inicial de nombre como icon 
            return CircleAvatar(
              backgroundColor: backgroundColor,
              radius:radius,
              child: Center(child: iconDedault),
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
                Text(text,style: TextStyle(color: colorAccent,fontSize: 16 ),overflow: TextOverflow.clip), 
                iconTrailing==null?Container():const SizedBox(width:8),
                // icon trailing
                iconTrailing==null?Container():Icon(iconTrailing,color: colorAccent,size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  } 
  Widget button( {bool defaultStyle = false,double elevation=0,double fontSize = 14,double width = double.infinity,bool disable = false, Widget? icon, String text = '',required dynamic onPressed,EdgeInsets padding =const EdgeInsets.symmetric(horizontal: 12, vertical: 12),Color? colorButton= Colors.blue,Color colorAccent = Colors.white , EdgeInsets margin =const EdgeInsets.symmetric(horizontal: 12, vertical: 12)}) {
     
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
          label: Text(text, style: TextStyle(color: colorAccent,fontSize: fontSize)),
        ),
      ),
    ));
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
    CataloguePageController homeController = Get.find<CataloguePageController>();

    if (list.isEmpty) return Container();

    // values
    Color? colorAccent = Get.theme.textTheme.titleMedium!.color?.withOpacity(0.1);
    double radius = 32.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
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
                   onTap: () => homeController.toNavigationProduct(productCatalogue: e.convertProductCatalogue()),
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
                        onTap: () => homeController.toNavigationProduct(productCatalogue: list[index].convertProductCatalogue()),
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
  late final bool favorite;
  late final String url;
  late final double size;
  late final double radius;
  late final String description;
  late final String path;
  final VoidCallback?  onTap;
  late final Color canvasColor;
  // ignore: prefer_const_constructors_in_immutables
  ImageProductAvatarApp({Key? key,this.url='', this.size = 75, this.radius = 6.0, this.description = '', this.path = '', this.onTap, this.iconAdd = false, this.favorite = false, this.canvasColor = Colors.grey,this.icon }) : super(key: key);

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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),border: Border.all(color: favorite?Colors.yellow.shade700:Colors.transparent,width: favorite?2:0)),
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
  final SalesController controller = Get.find<SalesController>();

  
  
  @override
  Widget build(BuildContext context) { 

    // widgets
    Widget titleWidget = Text(widget.product.description,style: const TextStyle(fontWeight: FontWeight.bold),maxLines: 5,overflow: TextOverflow.ellipsis);
    Widget subtitleWidget = Text(Publications.getFormatoPrecio(monto: widget.product.salePrice * widget.product.quantity),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue ));

    return AlertDialog(
      title: Text(widget.product.code==''?'Item':widget.product.code,style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: ImageProductAvatarApp(url: widget.product.image),
            title:widget.product.description==''?subtitleWidget:titleWidget,
            // subtitle : codigo del producto si es q existe 
            subtitle: widget.product.description==''? null:subtitleWidget,
          ), 
          const SizedBox(height: 12),
          const Divider(thickness:0.6,),
          // text : cantidad
          const Text('Cantidad'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // button : disminuir cantidad
              FloatingActionButton(
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
                child: Text(widget.product.quantity.toString(),style: const TextStyle(fontSize: 20)),
              ),
              // button : aumentar cantidad
              FloatingActionButton(
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
          child: Text('Eliminar',style: TextStyle(color: Colors.red.shade400)),
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

    return Material( 
      child: Column(
        children: [
          ListTile(
            // leading : imagen del producto
            leading: ImageProductAvatarApp(url: widget.product.image,size: 50),
            // title : nombre del producto
            title: Text(widget.product.description,style: const TextStyle(fontWeight: FontWeight.bold)),
            // trailing : buttons para incrementar y disminuir la cantidad del producto
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Get.find<SalesController>().getTicket.decrementProduct(product: widget.product);
                    Get.back();
                  },
                  icon: const Icon(Icons.horizontal_rule),
                ),
                Text(widget.product.quantity.toString()),
                IconButton(
                  onPressed: () {
                    Get.find<SalesController>().getTicket.incrementProduct(product: widget.product);
                    Get.back();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }

  // views
  Widget body({required BuildContext context}) {
    return Container();
  }
}