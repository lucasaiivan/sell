
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:get/get.dart'; 
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:sell/app/domain/entities/ticket_model.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../../data/providers/firebase_data_provider.dart';
import '../../../data/providers/local_data_provider.dart';
import '../../../data/repositories/catalogue_repository_impl.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../../domain/use_cases/catalogue_use_case.dart';
import '../../home/controller/home_controller.dart';
import '../controller/sell_controller.dart'; 

// ignore: must_be_immutable
class SalesView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SalesView({Key? key}) : super(key: key);

  late BuildContext buildContext;

  // others controllers
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    // set
    buildContext = context; 

    return GetBuilder<SellController>(
      init: SellController(),
      // initState : se activa cuando se crea el widget
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(SellController());
      },
      builder: (controller) {
        return Obx(() {
            return Scaffold(
              // view : barra de navegacion supeior de la app
              appBar: appbar(controller: controller),
              // view : barra de navegacion de la app
              drawer: drawerApp(),
              // view : cuerpo de la app
              body: LayoutBuilder(builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // view : cuerpo de la app
                    Flexible(child: body(controller: controller)),
                    // view : informacion del ticket actual
                    drawerTicket(controller: controller),
                  ],
                );
              }),
              // view : barra de navegacion inferior de la app
              floatingActionButton: controller.getTicketView ? floatingActionButtonTicket(controller: controller): floatingActionButton(controller: controller).animate( delay: const Duration( milliseconds:  0)).fade(),
            );
          }
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required SellController controller}) { 

    return AppBar( 
      titleSpacing: 0.0,
      // icon drawer  
      leading: controller.getStateLoadDataAdminUserComplete?null: const Center(child: SizedBox(width: 24,height: 24,child: CircularProgressIndicator())),
      title: ComponentApp().buttonAppbar( 
        context:  buildContext,
        onTap: () => controller.showSeach(context: buildContext), 
        text: 'Vender',
        iconLeading: Icons.search,
        colorBackground: Theme.of(buildContext).colorScheme.outline.withOpacity(0.1),//Colors.blueGrey.shade300.withOpacity(0.4),
        colorAccent: Theme.of(buildContext).textTheme.bodyLarge!.color?.withOpacity(0.7),
        ),
      centerTitle: false,
      actions: [
        controller.getListProductsSelestedLength != 0
          ? TextButton.icon(
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Descartar Ticket'),onPressed: controller.dialogCleanTicketAlert)
          : Container(
              key: homeController.floatingActionButtonSelectedCajaKey,
              child: cashRegisterNumberPopupMenuButton()),
      ],  
    );
  }
  Widget body({required SellController controller}) {
    // Widgets
    Widget updateview = homeController.getUpdateApp
        ? InkWell(
          onTap: () async => await launchUrl(Uri.parse(homeController.getUrlPlayStore),mode: LaunchMode.externalApplication),
          child: AnimatedContainer(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            color: Colors.green,
            child: const Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined,color: Colors.white),
                SizedBox(width: 8),
                Text('Actualizar',style: TextStyle(color: Colors.white, fontSize: 18)),

              ],
            )),
          ),
        )
      : Container(); 
    // view : cuerpo de la app
    return NestedScrollView(
      /* le permite crear una lista de elementos que se desplazarían hasta que el cuerpo alcanzara la parte superior */
      floatHeaderSlivers: true,
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // atentos a cualquier cambio que surja en los datos de la lista de marcas
          SliverList(
              delegate: SliverChildListDelegate([ 
                updateview,
                widgeSuggestedProducts(context: context ), 
              ])
          ),
        ];
      },
      //  LayoutBuilder : control de vista
      body: LayoutBuilder(builder: (context, constraints) {
        // var : logica de la vista para la web
        int crossAxisCount = constraints.maxWidth<700?3:constraints.maxWidth<900?4:6;

        return GridView.builder( 
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0),
          itemCount: controller.getTicket.listPoduct.length + 18,
          itemBuilder: (context, index) {
            // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
            List list = controller.getTicket.listPoduct.reversed.toList();
            // conditional : si el index es menor a la lista de productos seleccionados
            if (index < list.length) {
              // conditional : si el index es igual a 0
              if (index == 0) {
                return ZoomIn(
                    controller: (p0) => controller.newProductSelectedAnimationController = p0,
                    child: ProductoItem(producto: ProductCatalogue.fromMap(list[index])));
              }
              return ProductoItem(producto: ProductCatalogue.fromMap(list[index]));
            } else {
              return ElasticIn( child: Card( elevation: 0, color: Colors.grey.withOpacity(0.1)));
            }
          },
        );
      }),
    );
  }

  Widget drawerTicket({required SellController controller}) {
    // values
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical:1);
    final TicketModel ticket = controller.getTicket;
    ticket.priceTotal = 500.0;

    // style
    Color borderColor = Get.isDarkMode ? Colors.white : Colors.black;
    Color backgroundColor = Get.isDarkMode ? Get.theme.scaffoldBackgroundColor : Colors.white; 
    const TextStyle textValuesStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold );
    const TextStyle textDescrpitionStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold );
    TextStyle textDescrpitionDesing2Style = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold,color: Get.isDarkMode?Colors.white:Colors.black );

    // widgets
    Widget dividerLinesWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal:20, vertical: 5),
      child: CustomDivider(
        color: borderColor,
        height: 0.5,
        dashWidth: 10.0,
        dashGap: 5.0, 
      ),
    );

    // var : logica de la vista para la web
    final screenWidth = Get.size.width;
    final isMobile = screenWidth < 700; // ejemplo: pantalla de teléfono
 
    
    return AnimatedContainer( 
      width: controller.getTicketView ? isMobile ? screenWidth : 400 : 0,
      curve: Curves.fastOutSlowIn, // Curva de animación
      duration: const Duration(milliseconds: 300),   
      child:  Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0, 
        color: backgroundColor,
        shape:  RoundedRectangleBorder(
          side: BorderSide(color: borderColor.withOpacity(0.7), width: 0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: controller.getStateConfirmPurchase
            ? widgetConfirmedPurchase()
            : ListView(
                key: const Key('ticket'),
                shrinkWrap: false,
                children: [  
                  // view : informacion del ticket
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Ticket',textAlign: TextAlign.center,style: textDescrpitionStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold))),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // image : avatar del usuario
                            ComponentApp().userAvatarCircle(urlImage: homeController.getProfileAccountSelected.image,text: homeController.getProfileAccountSelected.name),
                            const SizedBox(width:4),
                            // text : name 
                            Text(homeController.getProfileAccountSelected.name,textAlign: TextAlign.center,style: textValuesStyle.copyWith(fontSize: 18,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // view : lines ------
                      dividerLinesWidget,
                      const SizedBox(height: 20),
                      // view : cantidad de elementos 'productos' seleccionados
                      Padding(
                        padding: padding,
                        child: Row(
                          children: [
                            const Opacity(opacity: 0.7,child: Text('Productos:',style: textDescrpitionStyle)),
                            const Spacer(),
                            Text(controller.getListProductsSelestedLength.toString(),style: textValuesStyle),
                          ],
                        ),
                      ), 
                      const SizedBox(height:12), 
                      // view : el monto total de la transacción
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical:0),
                        color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text('Total',style: textDescrpitionStyle.copyWith(fontSize: 16,fontWeight: FontWeight.w900,color: Colors.white)),
                              const Spacer(),
                              const SizedBox(width:12),
                              Text(Publications.getFormatoPrecio(value: controller.getTicket.getTotalPrice),style: textValuesStyle.copyWith(fontSize: 24,fontWeight: FontWeight.w900,color: Colors.white)),
                            ],
                          ),
                        ),
                      ), 
                      const SizedBox(height: 12),
                      // text : paga con
                      controller.getValueReceivedTicket == 0 || controller.getTicket.payMode != 'effective'
                          ? Container()
                          : Padding(
                              padding: padding,
                              child: Row(
                                children: [
                                  const Opacity(opacity: 0.7,child: Text('Pago con:',style: textDescrpitionStyle)),
                                  const Spacer(),
                                  Text(controller.getValueReceived(),style: textValuesStyle),
                                ],
                              ),
                            ),
                      // view :  vuelto
                      controller.getValueReceivedTicket == 0 || controller.getTicket.payMode != 'effective'
                        ? Container()
                        : Padding(
                          padding: padding,
                          child: Row(
                            children: [
                              const Opacity(opacity: 0.7,child: Text('Vuelto:',style: textDescrpitionStyle)),
                              const Spacer(),
                              Container( 
                                color: Colors.black26, 
                                child: Padding(
                                  padding: const EdgeInsets.symmetric( horizontal: 12, vertical: 1),
                                  child: Row(
                                    children: [
                                      const Text('Dar vuelto ', style: textValuesStyle ),
                                      Text(controller.getValueChange(),style: textValuesStyle.copyWith(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),  
                    ],
                  ),
                  // view : agregar descuento 
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        controller.getDiscount==''?Container():IconButton(
                          onPressed: controller.clearDiscount,
                          icon: const Icon(Icons.clear_rounded,color: Colors.red),
                        ),
                        TextButton( 
                          onPressed: controller.showDialogAddDiscount, 
                          child: Text(controller.getDiscount==''?'Agregar descuento':controller.getDiscount,style: TextStyle(color:controller.getDiscount==''?Colors.blue:Colors.red,fontSize: 18,fontWeight: FontWeight.w400))),
                      ],
                    ),
                  ),
                  // spacer
                  const SizedBox(height: 12),
                  // view : lines ------
                  dividerLinesWidget,
                  // spacer
                  const SizedBox(height: 12),
                  // view 2
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('El cliente paga con:',style: textDescrpitionDesing2Style ),
                            const SizedBox(height: 12),
      
                            Wrap(
                              spacing: 5,
                              children: [
                                // choiceChip : pago con efectivo
                                ChoiceChip( 
                                  label: const Text('Efectivo'),
                                  selected: controller.getTicket.payMode == 'effective',
                                  onSelected: (bool selected) {
                                    controller.setPayModeTicket = 'effective'; 
                                    controller.dialogSelectedIncomeCash(); 
                                  }, 
                                ),
                                // choiceChip : pago con mercado pago
                                ChoiceChip(
                                  label: const Text('Mercado Pago'),
                                  selected: controller.getTicket.payMode == 'mercadopago',
                                  onSelected: (bool selected) { 
                                    controller.setPayModeTicket = 'mercadopago';
                                      // default value
                                      controller.setValueReceivedTicket = 0.0;
                                  },
                                ),
                                // choiceChip : pago con tarjeta de credito/debito
                                ChoiceChip(
                                  label: const Text('Tarjeta de Debito/Credito'),
                                  selected: controller.getTicket.payMode == 'card',
                                  onSelected: (bool selected) { 
                                    controller.setPayModeTicket = 'card';
                                  // default values
                                  controller.setValueReceivedTicket = 0.0;
                                  },
                                ),
                              ],
                            ), 
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  // ------------------ //
  // WIDGETS COMPONENTS //
  // ------------------ //
  
  Widget cashRegisterNumberPopupMenuButton() { 

    // opcion premium : esta funcionalidad de arqueo de caja solo esta disponible en la version premium
    bool isPremium = homeController.getIsSubscribedPremium;
    // controllers
    final controller = Get.find<SellController>(); 
 
    // condition : si el esta en modo de prueba, solo muestra el boton de inciar caja
    if( homeController.getUserAnonymous ){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: 0.3,
          child: ComponentApp().buttonAppbar(
            context: buildContext,
            onTap: null,
            text: 'Iniciar caja',
            iconTrailing: Icons.keyboard_arrow_down_rounded,
            colorAccent: homeController.getDarkMode? Colors.white: Colors.black,
            colorBackground:homeController.getDarkMode ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
      ); 
    }

    // condition : si el usuario de la cuenta no es administrador y tampoco es premium, no se muestra el boton de iniciar caja
      if(  homeController.getProfileAdminUser.admin == false && isPremium==false){
        return Container();
      }
      
    // condition : si no es premium se muestra el boton de suscribirse a premium 
    if(isPremium==false ){ 
      // condition : comprobar si esta en [modo cajero]  
      if(homeController.getCashierMode  ){
        return Container();
      }
      
      // button : suscribirse a premium
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ComponentApp().buttonAppbar(
          context: buildContext,
          onTap: ()=> homeController.showModalBottomSheetSubcription(),
          text: 'Iniciar caja',
          iconTrailing: Icons.keyboard_arrow_down_rounded,
          colorAccent: Colors.white,
          colorBackground: Colors.amber,
        ),
      ); 
    }
    // condition : si no hay caja abierta
    if (homeController.cashRegisterActive.id == '' ) {
      // no hay caja abierta
      // view : button : iniciar caja
      return PopupMenuButton( 
          icon:ComponentApp().buttonAppbar( context: buildContext,text: 'Iniciar caja',iconTrailing: Icons.keyboard_arrow_down_rounded),
          onSelected: (selectedValue) { 
            // opcion premium : esta funcionalidad de arqueo de caja solo esta disponible en la version premium
            if(homeController.getIsSubscribedPremium==true){ 
              // es premium
              if (selectedValue == 'apertura') {
                // Get : abrir dialogo de apertura de caja 
                Get.dialog(ViewCashRegister(id: 'apertura'));
              } else {
                // Get : abrir dialogo de apertura de caja
                controller.upgradeCashRegister(id: selectedValue);
              }
            }else{
              // no es premium 
              //...
            }
          },
          itemBuilder: (BuildContext ctx) {
            
            // var : list of items
            List<PopupMenuItem> items = [];
            items.add(const PopupMenuItem(
                value: 'apertura',
                child: Row(children: [
                  Icon(Icons.add),
                  Padding(padding: EdgeInsets.fromLTRB(12, 0, 0, 0),child: Text('Nueva arqueo de caja')),
                ])));
            // agregar las cajas existentes
            for (var element in homeController.listCashRegister) {
              items.add(PopupMenuItem(value: element.id,child: Row(children: [Padding(padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),child: Text(element.description))])));
            }
            // generate vista de cada item de homeController.cashRegisterList
            return List.generate(homeController.listCashRegister.length + 1,
                (index) {
              return items[index];
            });
          });
    }

    return PopupMenuButton( 
        icon: Material(
          color: homeController.getDarkMode ? Colors.white : Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text('Caja ${homeController.cashRegisterActive.description}',style: TextStyle(color: homeController.getDarkMode? Colors.black: Colors.white)),
                const SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: homeController.getDarkMode? Colors.black: Colors.white),
              ],
            ),
          ),
        ),
        onSelected: (selectedValue) {
          late String id;
          switch (selectedValue) {
            case 0:
              id = 'detalles';
              break;
            case 1:
              id = 'ingreso';
              break;
            case 2:
              id = 'egreso';
              break;
            case 3:
              id = 'cierre';
              break;
            default:
              id = 'apertura';
              break;
          }
          // Get : view dialog
          Get.dialog(ViewCashRegister(id: id), useSafeArea: true);
        },
        itemBuilder: (BuildContext ctx) => [
              PopupMenuItem(
                  value: 0,
                  child: RichText(
                    text: TextSpan(
                      text: "Balance total\n",
                      style: TextStyle( color: homeController.getDarkMode ? Colors.white : Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: Publications.getFormatoPrecio(value: homeController.cashRegisterActive.getExpectedBalance),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                  )),
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      // icon
                      Icon(Icons.south_west_rounded,
                          color: Colors.green.shade400),
                      // text
                      RichText(
                        text: TextSpan(
                          text: 'Ingreso',
                          style: TextStyle(
                              color: Colors.green.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          children: homeController.cashRegisterActive.cashInFlow == 0
                              ? null
                              : <TextSpan>[
                                  TextSpan(
                                    text: '\n${Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashInFlow)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.green.shade400.withOpacity(0.5)),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      // icon
                      Icon(Icons.arrow_outward_rounded,
                          color: Colors.red.shade400),
                      // text
                      RichText(
                        text: TextSpan(
                          text: 'Egreso',
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          children: homeController.cashRegisterActive.cashOutFlow == 0
                              ? null
                              : <TextSpan>[
                                  TextSpan(
                                    text: '\n${Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashOutFlow)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.red.shade400.withOpacity(0.5)),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  )),
              const PopupMenuItem(
                  value: 3,
                  child: Row(children: [
                    Icon(Icons.close),
                    Padding(padding: EdgeInsets.fromLTRB(12, 0, 0, 0),child: Text('Cerrar Caja')),
                  ])),
            ]);
  }

  Widget widgeSuggestedProducts({required BuildContext context}) {
    
    // controllers
    HomeController controller = Get.find(); 

    // values
    int numItemDefault = 5;
    const double height = 130;
    final bool viewDefault = controller.getProductsOutstandingList.isEmpty;
    final int itemCount = viewDefault?6:controller.getProductsOutstandingList.length + numItemDefault;
    // condition : si no ahi productos destacados ni recientes
    if (viewDefault) {
      return const SizedBox(height:20,width: double.infinity);
    }
    // views : load widget mientras se carga la data
    if(homeController.productsBestSellersLoadComplete.value == false ){
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Get.theme.scaffoldBackgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 10),
                scrollDirection: Axis.horizontal,
                itemCount: 15,
                itemBuilder: (context, index) => circleAvatarDefault(context: context),
              ),
            ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: const EdgeInsets.only(left: 10),
        itemBuilder: (context, index) {
          // values
          Widget widget = index <= (controller.getProductsOutstandingList.length - 1) && index < itemCount - numItemDefault
            ? circleAvatarProduct(productCatalogue:controller.getProductsOutstandingList[index].copyWith())
            : circleAvatarProduct(productCatalogue: ProductCatalogue(creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()));
          // condition : views default
          if (viewDefault) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 5 : 0),
              child: circleAvatarDefault(context: context),
            );
          } 
    
          return widget;
        },
      ),
    );
  }

  Widget circleAvatarDefault({ required BuildContext context}) {
     

    // values
    double radius = 40.0; 

    return ElasticIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
                Container(margin: const EdgeInsets.only(top:5),width: radius, height: 10.0,color: Colors.grey.withOpacity(0.1),),
              ],
            ),
          );
  }

  Widget circleAvatarProduct({required ProductCatalogue productCatalogue}) {

    // controller
    final SellController salesController = Get.find();

    // values
    bool defaultValues = productCatalogue.id == '';
    double radius = 45.0;
    double spaceImageText = 1;
    Color backgroundColor = Colors.grey.withOpacity(0.1);
    bool stateAlertStock = productCatalogue.stock && homeController.getIsSubscribedPremium ? productCatalogue.quantityStock < 5 : false;
    Color borderCicleColor = stateAlertStock  ? Colors.red : productCatalogue.favorite ? Colors.amber : backgroundColor;

    return ElasticIn(
      child: Container(
        width: 95.0,
        height: 130.0,
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (defaultValues == false) {
                  salesController.selectedProduct(item: productCatalogue);
                }
              },
              child: Column(
                children: <Widget>[
                  // image
                  CachedNetworkImage(
                    imageUrl: productCatalogue.local?'': productCatalogue.image,
                    placeholder: (context, url) => CircleAvatar(
                        radius: radius,
                        backgroundColor: backgroundColor,
                        child: defaultValues ? Container(): Text(Publications.getFormatoPrecio(value: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyLarge?.color))),
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: radius,
                      backgroundColor: borderCicleColor,
                      child: CircleAvatar(
                        radius: radius - 6.5,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        child: CircleAvatar(radius: radius - 8,backgroundColor: backgroundColor,child: defaultValues ? Container() : CircleAvatar(radius: radius, backgroundImage: image)),
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: radius,
                      backgroundColor: backgroundColor,
                      child: defaultValues? Container():Text(Publications.getFormatoPrecio(value: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyMedium?.color)),
                    ),
                  ),
                  SizedBox(height: spaceImageText),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(productCatalogue.description,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetConfirmedPurchase() {
    //---------------------------//
    // Slpach view : Pago hecho! //
    //---------------------------//  

    // controllers
    final SellController salesController = Get.find();
    // values 
    Color background = Colors.green.shade400;  

    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Container(
        color: background,
        child: Column(
          children: [
            Expanded(
              child: ElasticIn(
                child: Column(
                  children: [
                    // view : card con la facturacion de la venta
                    Expanded(
                      child:  
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [ 
                          // iconbutton : close
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                iconSize: 30,
                                onPressed: () {
                                  // views
                                  salesController.setStateConfirmPurchase = false;
                                  salesController.setTicketView = false;
                                  salesController.setStateConfirmPurchaseComplete = false;
                                },
                                icon: const Icon(Icons.close_rounded,color: Colors.white),
                              ),
                            ],
                          ),
                          const Spacer(), 
                          const Icon(Icons.check_circle_outline_rounded,color: Colors.white,size: 60),
                          const SizedBox(height: 12),
                          // text : '¡Listo!'
                          const Text('¡Listo! Transacción exitosa',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w300)),
                          const SizedBox(height: 20),
                          // view : card con la facturacion de la venta
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              child: Column(
                                children: [
                                  ListTile(
                                    // avatar : icono de check
                                    leading: const Icon(Icons.check,color: Colors.green),
                                    // title : texto 'Facturado' con tono mas claro y '$3.445' en negrita
                                    title: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Facturado  ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w300)),
                                        Text(Publications.getFormatoPrecio(value: salesController.getLastTicket.getTotalPrice),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w800)),
                                      ],
                                    ),  
                                  ),
                                  // elevatedButton : boton con un icon y un texto  que diga 'compartir' 
                                  ComponentApp().button( 
                                    defaultStyle: false,
                                    elevation: 0, 
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    icon: const Row(
                                      children: [
                                        Icon(Icons.share_outlined,color: Colors.white),
                                        SizedBox(width:8),
                                        Text('Compartir comprobante',style:TextStyle(color: Colors.white,fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                    colorButton: Colors.blue,  
                                    onPressed: () => Utils().getTicketScreenShot( ticketModel: salesController.getLastTicket,context: Get.context!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ), 
                    //view : buttons
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextButton(
                          onPressed: () {
                            //views
                            salesController.setStateConfirmPurchase = false;
                            salesController.setTicketView = false; 
                            salesController.setStateConfirmPurchaseComplete = false;
                          },
                          child: const Text('Volver a vender',style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floatingActionButton({required SellController controller}) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        // FloatingActionButton : efectuar una venta rapida
        FloatingActionButton(
          heroTag: 'uniqueTag3',
            key: homeController.floatingActionButtonRegisterFlashKeyButton,
            backgroundColor: Colors.amber,
            onPressed: () {
              // default values
              controller.textEditingControllerAddFlashPrice.text = '';
              controller.textEditingControllerAddFlashDescription.text = '';
              controller.showDialogQuickSale();
            },
            child: const Icon(Icons.flash_on_rounded,color: Colors.white),
        ), 
        const SizedBox(width: kIsWeb?0:8), 
        // FloatingActionButton : determinar si es un dispositivo movil o web para mostrar este buton
        kIsWeb? const SizedBox(width: kIsWeb?0:8):FloatingActionButton(
          heroTag: 'uniqueTag2',
          key: homeController.floatingActionButtonScanCodeBarKey,
          backgroundColor: Colors.blue,
          onPressed: (){ 
            controller.scanBarcodeNormal(); 
          },
          child: SizedBox(width: 30,height: 30,child: Image.asset('assets/scanbarcode.png',color: Colors.white) ),
        ),
        const SizedBox(width: 8),
        // floationActionButton : cobrar
        ElasticIn(
          key: homeController.floatingActionButtonTransacctionRegister,
          controller: (p0) => controller.floatingActionButtonAnimateController = p0,
          child: FloatingActionButton.extended(
            heroTag: 'uniqueTag1',
              onPressed: controller.getTicket.listPoduct.isEmpty
                  ? null
                  : () {
                      controller.setTicketView = true; 
                    },
              backgroundColor: controller.getTicket.listPoduct.isEmpty
                  ? Colors.grey
                  : null,
              label: Text(
                  'Cobrar ${controller.getTicket.listPoduct.isEmpty ? '' : Publications.getFormatoPrecio(value: controller.getTicket.getTotalPrice)}',
                  style: const TextStyle(color: Colors.white))),
        ),
      ],
    );
  }

  Widget floatingActionButtonTicket({required SellController controller}) {
    return controller.getStateConfirmPurchase
        ? Container()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    controller.setTicketView = false;
                  },
                  child: const Icon(Icons.close, color: Colors.white)),
              const SizedBox(width: 8),
              FloatingActionButton.extended(
                  key: homeController.floatingActionButtonTransacctionConfirm,
                  onPressed: controller.confirmedPurchase,
                  label: const Text(
                    'Confirmar venta',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          );
  }
}

class CustomDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const CustomDivider({
    super.key,
    this.height = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height;
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class ViewCashRegister extends StatefulWidget {
  late String id;
  ViewCashRegister({super.key, required this.id});

  @override
  State<ViewCashRegister> createState() => _ViewCashRegisterState();
}

class _ViewCashRegisterState extends State<ViewCashRegister> {

  // controllers views
  final HomeController homeController = Get.find<HomeController>();
  final SellController salesController = Get.find<SellController>();

  // others controllers
  final AppMoneyTextEditingController moneyMaskedTextController =AppMoneyTextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _amountCashRegisterFocusNode = FocusNode();
  // var 
  bool checkShare = false;
  String titleAppBar = '';
  bool confirmCloseState = false;
  late Widget view;   

  // void
  void loadData({required BuildContext buildContext}) {
    switch (widget.id) {
      case 'apertura':
        titleAppBar = 'Apertura de caja';
        view = body;
        break;
      case 'detalles':
        titleAppBar = 'Arqueo de caja';
        view = detailContent(buildContext: buildContext);
        break;
      case 'cierre':
        confirmCloseState = true;
        titleAppBar = 'Cierre de caja';
        view = detailContent(buildContext: buildContext);
        break;
      case 'ingreso':
        titleAppBar = 'Ingreso';
        view = bodyEgresoIngreso();
        break;
      case 'egreso':
        titleAppBar = 'Egreso';
        view = bodyEgresoIngreso(isEgreso: true);
        break;
      default:
        titleAppBar = 'Apertura de caja';
        view = body;
        break;
    }
  }

  // init
  @override
  void initState() {
    super.initState();
    //  set : values
    homeController.cashRegisterActive.balance = 0; // reseteamos el balance  para evitar que se acumule
  }

  @override
  void dispose() {
    _amountCashRegisterFocusNode.dispose();
    textEditingController.dispose();
    moneyMaskedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // var 
    loadData(buildContext: context);

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Material(
            color: Colors.transparent,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Scaffold(
                appBar: appbar(text: widget.id),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: view,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required String text}) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(titleAppBar[0].toUpperCase() + titleAppBar.substring(1)),
      centerTitle: true,
      actions: [
        IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget bodyEgresoIngreso({
    bool isEgreso = false,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView( 
            children: [
              const SizedBox(height: 12),
              // textfield : efectivo inicial de la caja
              const Text('Escriba el monto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              const SizedBox(height: 8),
              TextField(
                controller: moneyMaskedTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [AppMoneyInputFormatter()], // Permite solo dígitos
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  labelText: 'Monto',
                ),
              ),
              // textfield : descripcion (opcional)
              const SizedBox(height: 20),
              TextField(
                controller: textEditingController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  labelText: 'Descripción (opcional)',
                ),
              ),  
              const SizedBox(height: 20),
            ],
          ),
        ),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: ComponentApp().button(
              onPressed: () {
                // values : description
                if(textEditingController.text==''){
                  textEditingController.text = 'Sin especificar';
                }
                if (moneyMaskedTextController.doubleValue > 0) {
                  if (isEgreso) {
                    salesController.cashRegisterOutFlow(
                        amount: -moneyMaskedTextController.doubleValue,
                        description: textEditingController.text);
                  } else {
                    salesController.cashRegisterInFlow(
                        amount: moneyMaskedTextController.doubleValue,
                        description: textEditingController.text);
                  }
    
                  Get.back();
                }
                Get.back();
              },
              colorButton: Colors.blue,
              text: isEgreso ? 'Egreso' : 'Ingreso',
            ),
          ),
        ), 
      ],
    );
  }

  Widget detailContent({required BuildContext buildContext}) {
    // var
    Color separatorColor = Colors.grey.withOpacity(0.04);  
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300);
    TextStyle textStyleValue = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // view info : descripcion
              Row(children: [
                Text('Descripción', style: textStyleDescription),
                const Spacer(),
                Text(homeController.cashRegisterActive.description,
                    style: textStyleValue)
              ]),

              // view info : fecha
              const SizedBox(height: 12),
              Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Apertura', style: textStyleDescription),
                  const Spacer(),
                  Text(
                      Publications.getFechaPublicacionFormating(
                          dateTime: homeController.cashRegisterActive.opening),
                      style: textStyleValue)
                ]),
              ),
              // view info : efectivo incial
              homeController.cashRegisterActive.expectedBalance==0?Container():const SizedBox(height: 12),
              homeController.cashRegisterActive.expectedBalance==0?Container():Row(children: [
                Text('Efectivo inicial', style: textStyleDescription),
                const Spacer(),
                Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.expectedBalance),style: textStyleValue)
              ]),
              // view info : cantidad de ventas
              homeController.cashRegisterActive.sales==0?Container():const SizedBox(height: 12),
              homeController.cashRegisterActive.sales==0?Container():Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Transacciones', style: textStyleDescription),
                  const Spacer(),
                  Text(homeController.cashRegisterActive.sales.toString(),
                      style: textStyleValue)
                ]),
              ),
              // view info : facturacion
              homeController.cashRegisterActive.billing==0?Container():const SizedBox(height: 12),
              homeController.cashRegisterActive.billing==0?Container():Row(children: [
                Text('Facturación', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        value: homeController.cashRegisterActive.billing),
                    style: textStyleValue)
              ]),
              // view info : descuentos
              homeController.cashRegisterActive.discount==0?Container():
              const SizedBox(height: 12),
              homeController.cashRegisterActive.discount==0?Container():Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Descuentos', style: textStyleDescription),
                  const Spacer(),
                  Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.discount),style: textStyleValue.copyWith(color: Colors.red.shade300))
                ]),
              ),
              // view info : ingresos y egresos
              homeController.cashRegisterActive.cashOutFlowList.isEmpty && homeController.cashRegisterActive.cashInFlowList.isEmpty
              ? Container()
              : Column(
                children: [
                  const SizedBox(height: 12),
                  ComponentApp().divider(thickness:0.5),
                  egressAndEntryExpansionPanelListView, 
                  ComponentApp().divider(thickness:0.5),
                  const SizedBox(height: 12),
                ],
              ),  
              // view info : monto esperado en la caja
              const SizedBox(height: 12),
              Row(children: [
                Text('Balance esperado en la caja', style: textStyleDescription),
                const Spacer(),
                Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.getExpectedBalance),style: textStyleValue)
              ]),
              const SizedBox(height: 20),
              // textfield : Monto en caja
              confirmCloseState
                  ? TextField(
                      focusNode: _amountCashRegisterFocusNode,
                      controller: moneyMaskedTextController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                      inputFormatters: [AppMoneyInputFormatter()],
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        labelText: 'Balance real en caja (opcional)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          // get diference
                          homeController.cashRegisterActive.balance =
                              moneyMaskedTextController.doubleValue;
                        });
                      },
                    )
                  : Container(),
              // text : diferencia
              confirmCloseState ? const SizedBox(height: 20) : Container(),
              homeController.cashRegisterActive.getDifference == 0
                  ? Container()
                  : confirmCloseState
                      ? Row(children: [
                          Text('Diferencia', style: textStyleDescription),
                          const Spacer(),
                          // text : monto de la diferencia
                          Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.getDifference),style: textStyleValue.copyWith(color: homeController.cashRegisterActive.getDifference<0?Colors.red.shade300: Colors.green.shade300))
                        ])
                      : Container(),
            ],
          ),
        ),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // checkBox : compartir comprobante
                !confirmCloseState?Container():
                CheckboxListTile( 
                  secondary: const Icon(Icons.share_outlined),
                  title: const Text('Compartir comprobante'),
                  value: checkShare,
                  onChanged: (value) {
                    setState(() {
                      checkShare = value!;
                    });
                  },
                ),
                // button : confirmar o cerrar caja
                ComponentApp().button( 
                  colorButton: Colors.blue,
                  text: confirmCloseState ? 'Confirmar':'Cerrar caja',
                  onPressed: () {
                    // comprobamos si el usuario ya confirmo el cierre de caja
                    if (confirmCloseState) {
                      // comprobamos si el usuario ingreso un monto en caja
                      if (moneyMaskedTextController.doubleValue != 0) {
                        homeController.cashRegisterActive.balance = moneyMaskedTextController.doubleValue;
                      }
                      homeController.setCashRegisterActiveTemp = homeController.cashRegisterActive;
                      // cerramos la caja
                      salesController.closeCashRegisterDefault();
                      // comprobamos si el usuario quiere compartir el comprobante
                      if (checkShare) {
                        Utils().getDetailArqueoScreenShot(cashRegister: homeController.getCashRegisterActiveTemp,context:buildContext);
                      }

                      Get.back();
                      
                    } else {
                      setState(() {
                        confirmCloseState = !confirmCloseState;
                        _amountCashRegisterFocusNode.requestFocus();
                      });
                    }
                  },
                
                ),
              ],
            ),
          ),
        ), 
      ],
    );
  }

  Widget get body {
    // description : vista para la apertura de la caja
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 12),
              // textfield : efectivo inicial de la caja
              const Text('Efectivo inicial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              const SizedBox(height: 5),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                controller: moneyMaskedTextController,
                style: const TextStyle(fontSize: 24),
                inputFormatters: [AppMoneyInputFormatter()],
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  labelText: 'Monto',
                ),
              ),
              // textfield : descripcion (opcional)
              const SizedBox(height: 12),
              const Text('Descripción de la caja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              const SizedBox(height: 5),

              // textfield con autocompletado: descripcion (opcional)
              TextField(
                controller: textEditingController,
                //focusNode: focusNode,
                keyboardType: TextInputType.text,
                maxLength: 9, // Límite de caracteres
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  labelText: 'Descripción',
                ),
                onChanged: (value) {
                  textEditingController.text = value;
                },
              ),
              // chips : sugerencias de descripciones
              FutureBuilder<List<String>>(
                future: salesController.loadFixerDescriotions(), // tu Future
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(); // o algún otro widget de carga
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Los datos están disponibles, muestra la lista
                    return Wrap(
                      spacing: 3.0, // espacio entre chips
                      runSpacing: 1.0, // espacio entre líneas de chips
                      children: snapshot.data!.map((option) {
                        return InputChip( 
                          label: Text(option), 
                          onPressed: () {
                            textEditingController.text = option;
                          },
                          deleteIcon: const Icon(Icons.close, size: 20),
                          onDeleted: () {
                            setState(() {
                              // eliminar de 'snapshot' la descripcion
                              snapshot.data!.remove(option);
                              // eliminamos la descripcion de la base de datos
                              salesController.deleteFixedDescription(description: option);
                            });
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              )
            ],
          ),
        ),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: ComponentApp().button(
              colorButton: Colors.blue,
              text: 'Inciar caja',
              onPressed: () {
                // recordamos la descripcion ingresada por el usuario
                salesController.registerFixerDescription(description: textEditingController.text);
                // iniciamos la caja
                salesController.startCashRegister( 
                  description: textEditingController.text,
                  initialCash: moneyMaskedTextController.doubleValue,
                  expectedBalance: moneyMaskedTextController.doubleValue,
                );
                Get.back();
              },),
          ),
        ),
      ],
    );
  }

  // WIDGETS COMPONENTS
  Widget get egressAndEntryExpansionPanelListView{

    // style 
    TextStyle textStyleValue = const TextStyle(fontSize: 14);
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300);

    return ExpansionPanelList.radio(
      elevation:0,  
      dividerColor: Colors.transparent,
      materialGapSize:0,// separacion entre los elementos 
      expandedHeaderPadding: EdgeInsets.zero,
      children: [
        // ExpansionPanelRadio : ingresos 
        ExpansionPanelRadio(
          canTapOnHeader: true,
          value: 1, 
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Row(
              children: [
                Text('Ingresos',style: textStyleDescription,),
                const Spacer(),
                Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashInFlow),style: textStyleValue.copyWith(color: homeController.cashRegisterActive.cashInFlow == 0? null: Colors.green.shade300)),
              ],
            );
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: homeController.cashRegisterActive.cashInFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical:1,horizontal:12),
                child: Row(
                  children: [
                    // text : description
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(homeController.cashRegisterActive.cashInFlowList[index]['description'],style: textStyleValue,overflow: TextOverflow.ellipsis,maxLines:2)),
                    const Spacer(),
                    // text : value
                    Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashInFlowList[index]['amount']),style: textStyleValue),
                  ],
                ),
              );
            },
          ), 
        ),
        // ExpansionPanelRadio : egresos 
        ExpansionPanelRadio(
          value: 2,
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Row(
              children: [
                Text('Egresos',style: textStyleDescription,),
                const Spacer(),
                Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashOutFlow),style: textStyleValue.copyWith(color:  homeController.cashRegisterActive.cashOutFlow == 0? null: Colors.red.shade300)),
              ]);
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: homeController.cashRegisterActive.cashOutFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    // text : description
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(homeController.cashRegisterActive.cashOutFlowList[index]['description'],style: textStyleValue,overflow: TextOverflow.ellipsis,maxLines:2)),
                    
                    // text : value
                    Text(Publications.getFormatoPrecio(value: homeController.cashRegisterActive.cashOutFlowList[index]['amount']),style: textStyleValue),
                  ],
                ),
              );
            },
          ), 
        ),
      ],
    );
  }
}

// VIEW : agregar descuento
class ViewAddDiscount extends StatefulWidget {
  const ViewAddDiscount({super.key});

  @override
  State<ViewAddDiscount> createState() => _ViewAddDiscountState();
}

class _ViewAddDiscountState extends State<ViewAddDiscount> {

  // controllers
  final SellController salesController = Get.find<SellController>();
  final AppMoneyTextEditingController textEditingDiscountController = AppMoneyTextEditingController();
  final TextEditingController textEditingPorcentController = TextEditingController();
  FocusNode focusNodeDiscount = FocusNode();
  FocusNode focusNodePorcent = FocusNode();

  @override 
  void initState() { 
    super.initState();
    // controllers listeners : se complementan ambos controllers para que se actualicen entre si, si cambiar el monto se actualiza el porcentaje y viceversa
    textEditingDiscountController.addListener(() { 
      if(focusNodePorcent.hasFocus){ 
        // si el focus esta en el textfield del porcentaje entonces no se actualiza el descuento
        return;
      }
      // var 
      double priceTotal = salesController.getTicket.getTotalPrice;
      double discount = textEditingDiscountController.doubleValue;
      // evita que el descuento sea mayor al precio total
      if(discount > priceTotal){
        textEditingDiscountController.updateValue(priceTotal);
        return;
      }
      // devuelve el porcentaje del descuento
      if(discount == 0.0 ){
        // si el descuento es 0 entonces el porcentaje es 0
        textEditingPorcentController.text = '0';
        setState(() {});
      }else{
        // devuelve el porcentaje sin reciduos y redondeado al entero mas cercano
        textEditingPorcentController.text = ((discount * 100) / priceTotal).round().toInt().toString();
        setState(() {});
      }
    
    }); 
    textEditingPorcentController.addListener(() {
      if(focusNodeDiscount.hasFocus){ 
        // si el focus esta en el textfield del descuento entonces no se actualiza el porcentaje
        return;
      }
      // var 
      double priceTotal = salesController.getTicket.getTotalPrice;
      int porcent = textEditingPorcentController.text.isEmpty ? 0 : (double.tryParse(textEditingPorcentController.text) ?? 0.0).round().toInt();

          
      // evitar el que porcentaje sea mayor a 100 evitando que se siga escribiendo otro digito
      if(porcent > 100){
        textEditingPorcentController.text = '100';
        return;
      } 
      // devuelve el descuento  del porcentaje
      if(porcent == 0 ){
        // si el porcentaje es 0 entonces el descuento es 0
        textEditingDiscountController.updateValue(0) ;
        setState(() {});
      }else{
        // devuelve el descuento  del porcentaje 
        textEditingDiscountController.updateValue(priceTotal * porcent / 100);
        setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar ,
      body: body(),
    );
  }
  // WIDGETS VIEWS 
  PreferredSizeWidget get appbar => AppBar(
    title: const Text('Descuento'),
    actions: [
      IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
    ],
  );
  Widget body (){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // view : escriba el monto del descuento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            focusNode: focusNodeDiscount,
            autofocus: true,
            controller: textEditingDiscountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [AppMoneyInputFormatter()],
            decoration: const InputDecoration( 
              hintText: '\$',
              labelText: "Monto",
            ),
            style: const TextStyle(fontSize: 20.0),
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 20),
        // view : escriba el porcentaje del descuento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            focusNode: focusNodePorcent,
            controller: textEditingPorcentController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [ FilteringTextInputFormatter.allow(RegExp('[1234567890]'))],
            decoration: const InputDecoration( 
              icon: Icon(Icons.percent_rounded), 
              labelText: "Porcentaje",
            ),
            style: const TextStyle(fontSize: 20.0),
            textInputAction: TextInputAction.next,
          ),
        ),
        const Spacer(),
        // view : button confirmar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton( 
              onPressed: textEditingDiscountController.doubleValue==0?null: () {
                // var
                double discount = textEditingDiscountController.doubleValue;
                // comprobamos si el descuento es mayor a 0
                if(discount > 0){
                  // agregamos el descuento
                  salesController.setDiscount = discount;
                }
                Get.back();
              },
              style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(20)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)))),
              child: const Text('Confirmar'),
            ),
          ),
        ),
      ],
    );
  }
}

// DIALOG 
// ignore: must_be_immutable
class PinCheckAlertDialog extends StatefulWidget {

  late bool create;
  late bool update;
  late bool entry;
  
  PinCheckAlertDialog({super.key,this.create=false,this.update=false,this.entry=true});

  @override
  State<PinCheckAlertDialog> createState() => _PinCheckAlertDialogState();
}

class _PinCheckAlertDialogState extends State<PinCheckAlertDialog> {

  //  controllers
  final HomeController homeController = Get.find<HomeController>();
  final SellController salesController = Get.find<SellController>();
  final TextEditingController textFieldController0 = TextEditingController();
  final TextEditingController textFieldController1 = TextEditingController();
  final TextEditingController textFieldController2 = TextEditingController();

  // var : textfield
  String errorTextField0 = '';
  String errorTextField1 = '';
  String errorTextField2 = ''; 
  // var : logic
  bool updatePinAction = false;
  
  @override
  Widget build(BuildContext context) { 
    return widget.create?createPindialog:widget.update?updatePinDialog:entryPinDialog;
  }

  // VIEW 
  Widget get entryPinDialog{
    // AlertDialog : pide pin para desactivar el modo cajero
    return AlertDialog(
      title: const Text('Desactivar modo cajero'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // text : informacion
          const Text('Para desactivar el modo cajero, por favor ingrese su pin'),
          const SizedBox(height: 20),
          // textfield : pin
          TextField(
            controller: textFieldController0,
            autofocus: true,
            obscureText: true, 
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: InputDecoration( 
              prefixIcon: const Icon(Icons.security_sharp),
              labelText: 'Pin', 
              errorText: errorTextField0!=''? errorTextField0 : null,
            ),
          ),  
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () { 
            // condition : verificar si el pin tiene 4 digitos 
            if(textFieldController0.text.length < 4){
              setState(() {
                errorTextField0 = 'El pin debe tener 4 digitos';
              });
              return;
            }else{
              // condition : verificar si el pin es correcto
              if(homeController.pinSegurityCheck(pin: textFieldController0.text)){
                homeController.setCashierMode = false;
                salesController.update();
                Get.back();
              }else{
                setState(() {
                  errorTextField0 = 'El pin es incorrecto';
                });
                return;
              }
            }
          },
          child: const Text('Desactivar'),
        ),
      ],
    );
  }
  Widget get createPindialog{
    // AlertDialog : pide pin para crear un pin
    return AlertDialog(
      title: const Text('Crear PIN de seguridad'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // text : informacion
            const Text('Por favor ingresa un pin numérico de 4 dígitos'),
            const SizedBox(height: 20),
            // textfield : pin
            TextField(
              controller: textFieldController0,
              autofocus: true,
              obscureText: true, 
              maxLength: 4,  
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(  
                prefixIcon: const Icon(Icons.security_sharp),
                labelText: 'PIN',  
                errorText: errorTextField0!=''? errorTextField0 : null,
              ),
            ), 
            // textfield : confirmar pin
            TextField(
              controller: textFieldController1,
              obscureText: true, 
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration( 
                prefixIcon:  const Icon(Icons.security_sharp),
                labelText: 'Vuelve a introducir el PIN', 
                errorText: errorTextField0!=''? errorTextField0 : null,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () { 
            // condition : verificar si el pin tiene 4 digitos 
            if(textFieldController0.text.length < 4){
              setState(() {
                errorTextField0 = 'El pin debe tener 4 digitos';
              });
              return;
            }else{
              // condition : verifica que coincidan los pines
              if(textFieldController0.text != textFieldController1.text){
                setState(() {
                  errorTextField0 = 'Los pines no coinciden';
                });
                return;
              }else{
                // creamos el pin
                homeController.createPin(pin: textFieldController0.text); 
                salesController.update();
                Get.back();
              } 
            }

          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
  Widget get updatePinDialog{ 
    // AlertDialog : si no es superusuario (propietario) pide pin actual para actualizar 

    // var 
    bool isSuperUser = homeController.getProfileAdminUser.superAdmin;
    
    // set
    textFieldController0.text = isSuperUser?homeController.getProfileAccountSelected.pin: '';

    return AlertDialog(
      title: const Text('Actualizar PIN'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // text : informacion
            const Text('Para actualizar su PIN, por favor ingrese su pin actual'),
            const SizedBox(height: 20),
            // textfield : pin actual
            TextField(
              enabled: isSuperUser?false:true,
              controller: textFieldController0, 
              autofocus: true,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.next, 
              keyboardType: TextInputType.number,
              decoration: InputDecoration( 
                prefixIcon: const Icon(Icons.security_sharp),
                labelText: 'PIN actual',
                errorText: errorTextField0!=''? errorTextField0 : null,
              ), 
            ),  
            const SizedBox(height:5),
            // textfield : nuevo pin
            TextField( 
              controller: textFieldController1,
              obscureText: true, 
              maxLength: 4,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next, 
              decoration: InputDecoration( 
                prefixIcon: const Icon(Icons.security_sharp),
                labelText: 'Nuevo PIN', 
                errorText: errorTextField1!=''? errorTextField1 : null,
              ), 
            ), 
            const SizedBox(height:5),
            // textfield : confirmar pin
            TextField( 
              controller: textFieldController2,
              obscureText: true, 
              maxLength: 4,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next, 
              decoration: InputDecoration( 
                prefixIcon: const Icon(Icons.security_sharp),
                labelText: 'Confirmar nuevo PIN', 
                errorText: errorTextField2!=''? errorTextField2 : null,
              ), 
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // condition : verificar textofield 0
            if(textFieldController0.text.length < 4){
              setState(() {
                errorTextField0 = 'El pin debe tener 4 digitos';
              }); 
            }else if(homeController.pinSegurityCheck(pin: textFieldController0.text) == false ){
              setState(() {
                errorTextField0 = 'El pin es incorrecto';
              }); 
            }else{
              setState(() {
                errorTextField0 = '';
              });
            }
            // condition : verificar textofield 1
            if(textFieldController1.text.length < 4){
              setState(() {
                errorTextField1 = 'El pin debe tener 4 digitos';
              }); 
            }else{
              setState(() {
                errorTextField1 = '';
              });
            }
            // condition : verificar textofield 2
            if(textFieldController2.text.length < 4){
              setState(() {
                errorTextField2 = 'El pin debe tener 4 digitos';
              }); 
            }else{
              setState(() {
                errorTextField2 = '';
              });
            }
            // condition : verificar si los pines coinciden
            if(textFieldController1.text != textFieldController2.text){
              setState(() {
                errorTextField1 = 'No coinciden';
                errorTextField2 = 'No coinciden';
              }); 
            }
            // condition : verificar si no hay errores
            if(errorTextField0.isEmpty && errorTextField1.isEmpty && errorTextField2.isEmpty){
              // actualizamos el pin
              homeController.createPin(pin: textFieldController1.text);
              salesController.update();
              Get.back();
            }
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}
