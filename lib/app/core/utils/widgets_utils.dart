
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
                    Get.toNamed(Routes.ACCOUNT);
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
    bool isSelect = salesController.getIdProductSelected == widget.producto.id;
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
              Flexible(child: contentImage()),
              contentInfo(),
            ],
          ),
          // selected
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: MouseCursor.uncontrolled,
                onTap: (){
                  // action : selecciona producto de la lista de productos del ticket
                  salesController.setIdProductSelected = widget.producto.id; 
                }, 
              ),
            ),
          ),
          // color selected
          isSelect ?Positioned.fill(child: Container(color: Colors.black26,)):Container(),
          // button delete
          isSelect
              ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        salesController.getTicket.removeProduct(product: widget.producto);
                        salesController.update();
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ))))
              : Container(),
          // value quantity
          widget.producto.quantity > 1 || isSelect
              ? Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: (){
                     salesController.setIdProductSelected = widget.producto.id;
                    },
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
          isSelect
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                      onPressed: () {
                        salesController.getTicket.decrementProduct(product: widget.producto);
                        salesController.update();
                      },
                      icon: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.horizontal_rule,
                            color: Colors.white,
                          ))))
              : Container(),
          // button  increase quantity
          isSelect
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      onPressed: () {
                        salesController.getTicket.incrementProduct(product: widget.producto);
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
          isSelect
              ? Align(
                  alignment: Alignment.center,
                  child: IconButton(
                      onPressed: () {
                        salesController.setIdProductSelected = '';
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
    
    return GetBuilder<HomeController>( 
      initState: (_) {},
      builder: (_) {
        return  body(context: context); 
      },
    );
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
    
    return ListView( 
      children: [
        const SizedBox(height: 50),
        isAnonymous?textButtonLogin
          :ListTile(
          leading: Container(padding: const EdgeInsets.all(0.0),child: ComponentApp().userAvatarCircle(urlImage: homeController.getProfileAccountSelected.image)),
          title: Text(homeController.getIdAccountSelected == ''? 'Seleccionar una cuenta': homeController.getProfileAccountSelected.name,maxLines: 1,overflow: TextOverflow.ellipsis),
          subtitle: homeController.getIdAccountSelected == ''? null: Row(
            crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment:  MainAxisAlignment.start,
            children: [
              user.name==''?Container():const Flexible(child: Text( 'ivan de turno manana',overflow: TextOverflow.ellipsis,maxLines: 1)),
              // view : punto de seracion
              user.name==''?Container():const Icon(Icons.arrow_right_rounded), 
              Text( user.admin? 'Administrador': 'Usuario estandar',overflow: TextOverflow.ellipsis,maxLines: 1),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          onTap: () {
            homeController.showModalBottomSheetSelectAccount();
          },
        ),  
        // funciones premium //
        // condition : si el usuario de la cuenta no es administrador no se muestra el boton de suscribirse a premium
        user.admin==false?Container():
        isAnonymous?Container():
          ListTile(
            tileColor: homeController.getIsSubscribedPremium?null:Colors.amber.withOpacity(0.05),
            iconColor:  Colors.amber, 
            //titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              leading: const Icon(Icons.star_rounded),
              title: Text(homeController.getIsSubscribedPremium?'Premium':'Funciones Premium'),
              onTap: (){
                // action : mostrar modal bottom sheet con 
                Get.back(); // cierra drawer
                homeController.showModalBottomSheetSubcription();
              }),
        isAnonymous?Container():const Opacity(opacity: 0.3,child: Divider(height:0)),
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
          leading: const Icon(Icons.add_moderator_outlined),
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
          subtitle: const Text('Tu opinión o sugerencia es importante'),
          onTap: () async {
            
            // values
            Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.logicabooleana.sell');
            //  redireccionara para la tienda de aplicaciones
            await launchUrl(uri,mode: LaunchMode.externalApplication);
          },
        ), 
        //  option :  cambiar el brillo del tema de la app
        ListTile(
          leading: Icon(Theme.of(context).brightness==Brightness.dark?Icons.light_mode_outlined:Icons.mode_night_outlined),
          title: Text(Theme.of(context).brightness==Brightness.dark?'Tema claro':'Tema oscuro'),
          onTap: ()=> ThemeService.switchTheme,
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
  PreferredSize linearProgressBarApp({Color color = Colors.purple}) {
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
  Widget userAvatarCircle({String urlImage='',String text = '', double radius = 20.0}) {
    
    // style
    Color backgroundColor = Get.theme.dividerColor.withOpacity(0.5);
    // widgets
    late Widget avatar;
    Widget iconDedault = Icon(Icons.person_outline_rounded,color: Colors.white,size: radius*1.5,);

    if(urlImage == '' && text == ''){
      iconDedault = Icon(Icons.person_outline_rounded,color: Colors.white,size: radius*1 );
    }else if(urlImage == '' && text != ''){
      iconDedault = Text( text.substring( 0,1),style: const TextStyle(color: Colors.white));
    }
    
    // crear avatar
    avatar = urlImage == ''
      ? CircleAvatar(backgroundColor:backgroundColor,child: Center(child: iconDedault))
        : CachedNetworkImage(
          imageUrl: urlImage,
          placeholder: (context, url) => CircleAvatar(backgroundColor:backgroundColor,child:iconDedault),
          imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: CircleAvatar(backgroundImage: image)),
          errorWidget: (context, url, error) {
            // return : un circleView con la inicial de nombre como icon 
            return CircleAvatar(
              backgroundColor: backgroundColor,
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
                Text(text,style: TextStyle(color: colorAccent,fontSize: 16 )), 
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
  Widget button( {bool defaultStyle = false,double elevation=0,double fontSize = 14,double width = double.infinity,bool disable = false, Widget? icon, String text = '',required dynamic onPressed,EdgeInsets padding =const EdgeInsets.symmetric(horizontal: 12, vertical: 12),Color colorButton = Colors.blue,Color colorAccent = Colors.white}) {
    // button : personalizado
    return FadeIn(
        child: Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: disable?null:onPressed,
          style: ElevatedButton.styleFrom(
            elevation:defaultStyle?0: elevation,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.all(20.0),
            backgroundColor:defaultStyle?null: colorButton,
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
                            onTap: () => homeController.toNavigationProductEdit(productCatalogue: list[index].convertProductCatalogue()),
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

  LogoPremium({Key? key,this.personalize=false,this.accentColor=Colors.amber,this.size=14,this.visible=false,this.id='premium'}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // others controllers
    final HomeController homeController = Get.find();
    
    // value
    if( personalize  == false ){ 
      // valores por defecto
      accentColor = Theme.of(context).brightness==Brightness.dark?Colors.white70:Colors.black87; 
    }


    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material( 
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).brightness==Brightness.dark?Colors.black26:Colors.amber.shade50,
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
  ImageProductAvatarApp({Key? key,this.iconAdd=false,this.canvasColor=Colors.black12,this.favorite=false,this.url='',this.size=50,this.radius=12,this.description='',this.path='', this.onTap }) : super(key: key);

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
      child: Icon( Icons.add_a_photo,color: iconColor,));
    }else {
      imageDefault = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: backgroundColor,
      child: Image.asset('assets/default_image.png',fit: BoxFit.cover,color: iconColor,));
    }
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
