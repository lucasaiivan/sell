import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../domain/entities/ticket_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../home/controller/home_controller.dart';
import '../controller/transactions_controller.dart';
import 'package:animate_do/animate_do.dart';

// ignore: must_be_immutable
class TransactionsView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  TransactionsView({Key? key}) : super(key: key);

  // var 
  bool darkTheme=false;
  late BuildContext buildContext;

  @override
  Widget build(BuildContext context) {

    // set 
    buildContext = context;

    // get
    darkTheme = Get.isDarkMode;

    return GetBuilder<TransactionsController>(
      init: TransactionsController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold( 
          appBar: appbar(context: context),
          drawer: drawerApp(),
          body: body(context: context),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {

    // others controllers
    final TransactionsController transactionsController = Get.find();

    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Transacciones',textAlign: TextAlign.center),
      actions: [
        
        PopupMenuButton(
            icon: Material(
              color: darkTheme?Colors.white:Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(transactionsController.getFilterText,style:TextStyle(color: darkTheme?Colors.black:Colors.white,fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    Icon(Icons.filter_list,color: darkTheme?Colors.black:Colors.white),
                  ],
                ),
              ),
            ),
            onSelected: (selectedValue) {
              transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'este mes', child: Text('Este mes')),
                  const PopupMenuItem(value: 'el mes pasado', child: Text('El mes pasado')),
                  const PopupMenuItem(value: 'este año', child: Text('Este año')),
                  const PopupMenuItem(value: 'el año pasado', child: Text('El año pasado')),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // others controllers
    final TransactionsController transactionsController = Get.find();

    // vista para mostrar en el caso que no alla ninguna transacción
    if (transactionsController.getTransactionsList.isEmpty) {
      return Center( child: Text( 'Sin transacciones ${transactionsController.getFilterText.toLowerCase()}'));
    }

    return ListView.builder(
      
      itemCount: transactionsController.getTransactionsList.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WidgetAnalyticSalesTileExpanded(),
              WidgetAnalyticProductsTileExpanded(),
              tileItem( ticketModel: transactionsController.getTransactionsList[index]),
              ComponentApp().divider(),
            ],
          );
        }

        return Column(
          children: [
            tileItem(ticketModel: transactionsController.getTransactionsList[index]),
            ComponentApp().divider(),
          ],
        );
      },
    );
  }

  // WIDGETS COMPONENTS

  Widget tileItem({required TicketModel ticketModel}) {
  //  description  : Este 'ListTile' muestra información de cada transacción
    
    // controllers
    final TransactionsController transactionsController = Get.find();

    // values
    final Map payMode =transactionsController.getPayMode(idMode: ticketModel.payMode);
    final String revenue = transactionsController.readEarnings(ticket: ticketModel);
    // styles
    final Color primaryTextColor  = Get.isDarkMode?Colors.white70:Colors.black87;
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    // widgets
    final Widget dividerCircle = Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(Icons.circle,size: 4, color: primaryTextColor.withOpacity(0.5)));

    // widgets
    Widget widget = AlertDialog(
      title: const Text('¿Seguro que quieres eliminar esta venta?',textAlign: TextAlign.center),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () {
              transactionsController.deleteTicket(ticketModel: ticketModel);
              Get.back();
            },
            child: const Text('si, eliminar')),
      ]),
    );  

    Widget listTile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
      child: Row(
        children: [
          // content
          Flexible(
            child: Column(
              children: [
                Row(
                  children: [
                    // const Text('Pago con '),
                    Material(
                      color: (payMode['color'] as Color) .withOpacity(0.1),
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10,vertical:0),
                        child: Text(payMode['name'],style: TextStyle(fontWeight: FontWeight.w600,color: (payMode['color'] as Color) .withOpacity(0.7)  )),
                      )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // primera fila : numero de caja, y id del vendedor
                    Row(
                      children: [
                        // text : numero de caja
                        Text('caja ${ticketModel.cashRegister}',style:textStyleSecundary),
                        dividerCircle,
                        // text : id del vendedor
                        Text(ticketModel.seller.split('@')[0],style:textStyleSecundary), 
                        Opacity(opacity:0.3,child: dividerCircle),
                        // fecha de transacción
                        Text(Publications.getFechaPublicacion(ticketModel.creation.toDate(), Timestamp.now().toDate()),style: TextStyle(color: primaryTextColor.withOpacity(0.3),fontWeight: FontWeight.w400 )),
                      ],
                    ), 
                    // segunda fila : cantidad de items, valor del vuelto
                    Opacity(
                      opacity: 0.8,
                      child: Row( 
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //  text : cantidad de items ( productos )
                          Text('${ticketModel.getLengh()} items',style:textStyleSecundary), 
                          // text : valor del vuelto
                          ticketModel.valueReceived == 0? Container(): Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              dividerCircle,
                              Text('Vuelto: ${Publications.getFormatoPrecio(monto: ticketModel.valueReceived - ticketModel.priceTotal)}',style:textStyleSecundary ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
          )),
          // trailing
          Column(
          crossAxisAlignment:CrossAxisAlignment.end,mainAxisSize: MainAxisSize.min,
          children: [
            //  text : precio totol del ticket
            Text(Publications.getFormatoPrecio(monto: ticketModel.priceTotal),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: primaryTextColor)),
            //  text : ganancias
            Text(revenue,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.green.withOpacity(0.9)  )),
          ],
        ),
        ],
      ),
    );

    return ElasticIn(
      child: Dismissible(
        key:  UniqueKey(),
        background: Container(color: Colors.red.shade300.withOpacity(0.5)),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog(
            context: buildContext,
            builder: (BuildContext context) {
              return widget;
            },
          );
        },
        child: InkWell(
          onLongPress: () =>  showAlertDialogTransactionInformation(buildContext,ticketModel.toJson()),
          onTap: () => showAlertDialogTransactionInformation(buildContext,ticketModel.toJson()),
          child: listTile),
      ),
    );
  }

  // DIALOG : mostrar detalles de la transacción
  void showAlertDialogTransactionInformation(BuildContext context, Map<dynamic, dynamic> transactionData) {
    String id = transactionData['id'];
    String seller = transactionData['seller'];
    String cashRegister = transactionData['cashRegister'];
    String payMode = transactionData['payMode'];
    double priceTotal = transactionData['priceTotal'];
    double valueReceived = transactionData['valueReceived'];
    double changeAmount = valueReceived==0?0.0: valueReceived - priceTotal;
    String currencySymbol = transactionData['currencySymbol'];
    List<dynamic> listProduct = transactionData['listPoduct'];
    Timestamp creation = transactionData['creation'];

    // controllers
    final TransactionsController transactionsController = Get.find();

    // Formatear marca de tiempo como fecha
    var formatter = DateFormat('dd/MM/yyyy  HH:mm');
    var formattedCreationDate = formatter.format(creation.toDate());

    // var 
    Map payModeMap =transactionsController.getPayMode(idMode: payMode);
    // styles
    const double opacity = 0.8;
    Widget divider = ComponentApp().divider();
    const TextStyle textStyle = TextStyle(fontSize: 14,fontWeight: FontWeight.w500);

  //  dialog  : mostrar detalles de la transacción
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( 
          contentPadding: const EdgeInsets.all(5),
          //  SingleChildScrollView : para que el contenido de la alerta se pueda desplazar
          content: SizedBox(
            // establece el ancho a toda la pantalla
            width:  MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text("Información de transacción",textAlign: TextAlign.center, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Id: ")),
                        const Spacer(),
                        Text(id,style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Fecha de creación: ")),
                        const Spacer(),
                        Text(formattedCreationDate,style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Caja registradora: ")),
                        const Spacer(),
                        Text(cashRegister,style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Vendedor: ")),
                        const Spacer(),
                        Text(seller,style: textStyle),
                      ],
                    ),
                    divider,
                    const SizedBox(height: 20,width: double.infinity), 
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Cantidad de productos: ")),
                        const Spacer(),
                        Text("${listProduct.length}",style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Modo de pago: ")),
                        const Spacer(),
                        Text("${ payModeMap['name'] }",style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Precio total: ")),
                        const Spacer(),
                        Text( Publications.getFormatoPrecio(monto: priceTotal,moneda: currencySymbol),style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Valor recibido: ")),
                        const Spacer(),
                        Text(Publications.getFormatoPrecio(monto: valueReceived,moneda: currencySymbol),style: textStyle),
                      ],
                    ),
                    divider,
                    Row(
                      children: <Widget>[
                        const Opacity(opacity:opacity,child: Text("Vuelto: ")),
                        const Spacer(),
                        Text( Publications.getFormatoPrecio(monto: changeAmount,moneda: currencySymbol),style: textStyle),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Eliminar",style: TextStyle(color: Colors.red.shade400),),
              onPressed: () {
                Navigator.of(context).pop();
                transactionsController.deleteSale(ticketModel: TicketModel.fromMap(transactionData));
              },
            ),
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            
          ],
        );
      },
    );
  }
}

/////////////////
/* CLASS VIEWS */
////////////////
class WidgetAnalyticSalesTileExpanded extends StatefulWidget {

  // ignore: prefer_const_constructors_in_immutables
  WidgetAnalyticSalesTileExpanded({super.key,});
  // muestra un item con contenedor expandible
  @override
  // ignore: library_private_types_in_public_api
  _WidgetAnalyticSalesTileExpandedState createState() => _WidgetAnalyticSalesTileExpandedState();
}

class _WidgetAnalyticSalesTileExpandedState extends State<WidgetAnalyticSalesTileExpanded> {
  
  // card : estadisticas de las transacciones

    // others controllers
    final TransactionsController transactionsController = Get.find();
    final HomeController homeController = Get.find<HomeController>();

    // valueS  
    double cardBorderRadius = 12.0;
    Color colorCard = Colors.blue.withOpacity(0.1);
    bool darkMode = false;
    bool isExpanded = false;
    Icon iconCategory = const Icon(Icons.monetization_on_outlined,color: Colors.green,);
    String textCategory = 'Volumen de ventas';
    String textFilter = '';
    String priceTotal = '';
    String revenue  = '';
    late ThemeData themeData;
    double elevation = 0.0;
  

  @override
  Widget build(BuildContext context) {


    // get values 
    cardBorderRadius = transactionsController.getCardBoderRadius;
    darkMode = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    colorCard = darkMode? Colors.blue.withOpacity(0.1) : isExpanded?Colors.black.withOpacity(0.1):Colors.black.withOpacity(0.9);
    themeData = darkMode?ThemeData.dark():isExpanded?ThemeData.light():ThemeData.dark();

    // widget : productos de mayor ganancia
    Widget wProductsRevenue = transactionsController.getBestSellingProductList.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.all(20.0),
          child:Opacity(opacity: 0.7,child: Text('De mayor ganancia',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Blur : el blur se usa para que no se vea el contenido si no esta suscrito a la cuenta premium
            Blur(
              colorOpacity: 0,
              blur: homeController.getProfileAccountSelected.subscribed?0:2.5,
              blurColor: Colors.transparent,
              // content : el contenido que se va a mostrar
              child: ListView.builder(
                physics: const  NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: transactionsController.getBestSellingProductList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CachedNetworkImage(
                              imageUrl:transactionsController.getBestSellingProductList[index].image,
                              placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                              imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CircleAvatar(backgroundImage: image),
                                  ),
                                  CircleAvatar(radius: 10 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductList[index].quantity.toString(),style:const TextStyle(fontSize: 10,color:Colors.blue,fontWeight: FontWeight.bold))),
                                ],
                              )),
                              errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                            ),
                        title: Text(transactionsController.getBestSellingProductList[index].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle()),
                        subtitle: Text(transactionsController.getBestSellingProductList[index].description,overflow:TextOverflow.ellipsis,style:const TextStyle( )),
                        trailing:Text('+${Publications.getFormatoPrecio(monto: transactionsController.getBestSellingProductList[index].revenue )}',style: TextStyle(overflow:TextOverflow.ellipsis ,color:Colors.green.shade700,fontWeight: FontWeight.w900 )),
                      ),
                      const Divider(endIndent:20,height: 0,indent:20),
                    ],
                  ); 
              },),
            ),
            // text
            Center(child: homeController.getProfileAccountSelected.subscribed?Container(): LogoPremium(personalize: true,accentColor: Colors.amber.shade600)),
          ],
        ),
      ],
    );
    // widget : modo de pago y su monto total
    Widget widgetAlyticsMeansOfPayment = transactionsController.getAnalyticsMeansOfPayment.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [  
        const Padding(
          padding: EdgeInsets.all(20.0),
          child:Opacity(opacity: 0.7,child: Text('Medios de pago',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
       Stack(
         alignment: Alignment.center,
         children: [
           // Blur : el blur se usa para que no se vea el contenido si no esta suscrito a la cuenta premium
           Blur(
             colorOpacity: 0,
             blur: homeController.getProfileAccountSelected.subscribed?0:2.5,
             blurColor: Colors.transparent,
             // content : lista de medios de pago
            child: ListView.builder(
               physics: const  NeverScrollableScrollPhysics(),
               scrollDirection: Axis.vertical,
               itemCount: transactionsController.getAnalyticsMeansOfPayment.length,
               shrinkWrap: true,
               itemBuilder: (context, index) {
       
                 // var
                 String value =transactionsController.getAnalyticsMeansOfPayment.keys.elementAt(index) ;
                 Color color = transactionsController.getPayMode(idMode: value)['color'];
       
                 return Column(
                   children: [
                     ListTile(
                       dense: true,
                       title:Text(transactionsController.getPayMode(idMode: value)['name'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800,color: color.withOpacity(0.7)  )),
                       trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getAnalyticsMeansOfPayment.values.elementAt(index) ),style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300) )),
                     ),
                     transactionsController.getAnalyticsMeansOfPayment.length!=index+1?const Divider(endIndent:20,height: 0,indent:20):Container(),
                   ],
                 ); 
             },),
          ),
          // text
           Center(child: homeController.getProfileAccountSelected.subscribed?Container(): LogoPremium(personalize: true,accentColor: Colors.amber.shade600)),
        ],
         ),
      ],
    );
    // view : monto de cada caja
    Widget cashAnalysisWidget = transactionsController.getCashAnalysisMap.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Opacity(opacity: 0.7,child: Text('Saldo en caja',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
            ),
            // content : lista de cajas
            ListView.builder(
              physics: const  NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: transactionsController.getCashAnalysisMap.length,
              shrinkWrap: true,
              itemBuilder: (context, index) { 
                return Column(
                  children: [
                    ListTile(
                      title: Text('Caja ${transactionsController.getCashAnalysisMap.keys.elementAt(index)}',overflow:TextOverflow.ellipsis ),
                      trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getCashAnalysisMap.values.elementAt(index) ),style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300))),
                    ),
                    transactionsController.getCashAnalysisMap.length!=index+1?const Divider(endIndent:20,height: 0,indent:20):Container(),
                  ],
                ); 
            },),
          ],
        ),
      ],
    );

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        isExpanded = !isExpanded;
        transactionsController.update();
      },
      // Theme : se usa para aplicar un estilo personalizado
      child: Theme(
        data: themeData,
        // AnimateContainer : se usa para animar el tamaño del card segun el estado de la variable isExpanded
        child: AnimatedContainer(
          curve: !isExpanded ? const ElasticOutCurve(.9) : Curves.elasticOut,
          duration: const Duration(milliseconds: 5000),
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 2, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // card content : mostramos el contenido del card segun el estado de la variable isExpanded
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: elevation,
              color: Colors.transparent,
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(cardBorderRadius),bottomRight: Radius.circular(cardBorderRadius),topLeft: Radius.circular(cardBorderRadius),topRight: Radius.circular(cardBorderRadius))),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: colorCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
              
                    // view : volumen de ventas
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                              fit: FlexFit.tight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // text : titulo
                                  const SizedBox(height: 12),
                                  Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start, style: const TextStyle(fontSize: 24)),
                                  //  text : cantidad de ventas
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // text : monto total de las ventas del filtro
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Opacity(opacity: 0.9, child: Text(transactionsController.getFilterText, style: const TextStyle(fontSize: 10))),
                                          Text(priceTotal, textAlign: TextAlign.start, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis)),
                                          const Opacity(opacity: 0.7, child: Text('Total', style: TextStyle(fontSize: 10))),
                                        ],
                                      ),
                                      const Spacer(),
                                      // text : ganancias
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end, 
                                        children: [
                                          const Text(''),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                            child: Text(revenue, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24,overflow: TextOverflow.ellipsis)),
                                          ),
                                          Opacity(opacity: 0.7, child: Text(revenue == '' ? '' : 'Cantidad ganada', style: const TextStyle(fontSize: 10))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                          
                        ],
                      ),
                    ),
                    // icon : muestra si la tarjeta esta expandida o no
                    isExpanded? Container(): const Padding(padding: EdgeInsets.only(bottom:12),child: Icon(Icons.keyboard_arrow_down,size: 27)),
                    // view : expandible de volumen de ventas
                    AnimatedCrossFade(
                      firstChild: const Text('', style: TextStyle(fontSize: 0)),
                      secondChild: Theme(
                        data: darkMode? ThemeData.dark():ThemeData.light(),
                        child: Column(
                          children: [ 
                            //  view  : cantidad total de ventas
                            Padding(
                              padding: const EdgeInsets.only(left:20,right:20,top: 20),
                              child: Row(
                                children: [
                                  const Text('Ventas',overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  Text(transactionsController.getTransactionsList.length.toString(),style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ),
                            const Divider(endIndent:20,indent:20),
                            // view : saldo total de cada caja
                            cashAnalysisWidget,
                            const Divider(endIndent:20,indent:20,height: 0),
                            // text : titulo de Analíticas
                            Padding(
                              padding: const EdgeInsets.only(left:20,right:20,top: 20),
                              child: Row(
                                children: [
                                  const Text('Analíticas',style: TextStyle(fontSize: 30)),
                                  LogoPremium(size: 12),
                                ],
                              ),
                            ),
                            // view : productos con mayor ganancia
                            wProductsRevenue,
                            //  view : medios de pagos
                            widgetAlyticsMeansOfPayment,
                          ],
                        ),
                      ),
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 1200),
                      reverseDuration: Duration.zero,
                      sizeCurve: Curves.fastLinearToSlowEaseIn,
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WidgetAnalyticProductsTileExpanded extends StatefulWidget {

  // ignore: prefer_const_constructors_in_immutables
  WidgetAnalyticProductsTileExpanded({super.key,});
  // muestra un item con contenedor expandible
  @override
  // ignore: library_private_types_in_public_api
  _WidgetAnalyticProductsTileExpandedState createState() => _WidgetAnalyticProductsTileExpandedState();
}

class _WidgetAnalyticProductsTileExpandedState extends State<WidgetAnalyticProductsTileExpanded> {
  
  // card : estadisticas de las transacciones

    // others controllers
    final TransactionsController transactionsController = Get.find();
    final HomeController homeController = Get.find<HomeController>();

    // valueS 
    double cardBorderRadius = 12.0;
    Color colorCard = Colors.grey;
    bool darkMode = false;
    bool isExpanded = false;
    Icon iconCategory = const Icon(Icons.analytics_outlined,color: Colors.orange);
    String textCategory = 'Productos';
    String textFilter = '';
    String priceTotal = '';
    String revenue  = '';
    late ThemeData themeData;
    double elevation = 0.0 ;

  @override
  Widget build(BuildContext context) {

    // get values 
    cardBorderRadius = transactionsController.getCardBoderRadius;
    darkMode = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    colorCard = darkMode? Colors.blue.withOpacity(0.1) : isExpanded?Colors.black.withOpacity(0.1):Colors.black.withOpacity(0.9);
    themeData = darkMode?ThemeData.dark():isExpanded?ThemeData.light():ThemeData.dark();

    // widget : productos con mayor ganancia
    Widget higherPriedProductsWidget = transactionsController.getBestSellingProductsByAmount.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        // text 
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Opacity(opacity: 0.7,child: Text('Más vendidos con el mayor monto',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            
            Blur(
              colorOpacity: 0,
              blur: homeController.getProfileAccountSelected.subscribed?0:2.5,
              blurColor: Colors.transparent,
              child: ListView.builder(
                physics: const  NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: transactionsController.getBestSellingProductsByAmount.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CachedNetworkImage(
                              imageUrl:transactionsController.getBestSellingProductsByAmount[index].image,
                              placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                              imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: CircleAvatar(backgroundImage: image),
                              )),
                              errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                            ),
                        title: Text(transactionsController.getBestSellingProductsByAmount[index].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle()),
                        subtitle: Text(transactionsController.getBestSellingProductsByAmount[index].description,overflow:TextOverflow.ellipsis,style:const TextStyle( )),
                        trailing: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(color:Colors.blue)),
                      ),
                      transactionsController.getBestSellingProductsByAmount.length!=index+1?const Divider(endIndent:20,height: 0,indent:20):Container(),
                    ],
                  ); 
              },),
            ),
            // text
            Center(child: homeController.getProfileAccountSelected.subscribed?Container(): LogoPremium(personalize: true,accentColor: Colors.amber.shade600)),
          ],
        ),
      ],
    );
    // widget : mostramos los productos más vendidos
    Widget mostselledProductsWidget = transactionsController.getMostSelledProducts.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        // titulo : analiticas
        Padding(
          padding: const EdgeInsets.only(left:20,right:20,top: 20),
          child: Row(
            children: [
              const Text('Analíticas',style: TextStyle(fontSize: 30)),
              LogoPremium(size: 12),
              ],
              ),
        ),  
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Opacity(opacity: 0.7,child: Text('Más vendidos',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // content
            Blur(
              colorOpacity: 0,
              blur: homeController.getProfileAccountSelected.subscribed?0:2.5,
              blurColor: Colors.transparent,
              child: ListView.builder(
                physics: const  NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: transactionsController.getMostSelledProducts.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CachedNetworkImage(
                              imageUrl:transactionsController.getMostSelledProducts[index].image,
                              placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                              imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: CircleAvatar(backgroundImage: image),
                              )),
                              errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                            ),
                        title: Text(transactionsController.getMostSelledProducts[index].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle()),
                        subtitle: Text(transactionsController.getMostSelledProducts[index].description,overflow:TextOverflow.ellipsis,style:const TextStyle( )),
                        trailing: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(color:Colors.blue)),
                      ),
                      transactionsController.getMostSelledProducts.length!=index+1?const Divider(endIndent:20,height: 0,indent:20):Container(),
                    ],
                  ); 
              },),
            ),
            // text
            Center(child: homeController.getProfileAccountSelected.subscribed?Container(): LogoPremium(personalize: true,accentColor: Colors.amber.shade600)),
          ],
        ),
      ],
    );


    return Theme(
      data: themeData,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          isExpanded = !isExpanded;
          transactionsController.update();
        },
        child: AnimatedContainer(
          curve: !isExpanded ? const ElasticOutCurve(.9) : Curves.elasticOut,
          duration: const Duration(milliseconds: 1500),
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 2, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    elevation: elevation, 
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(cardBorderRadius),bottomRight: Radius.circular(cardBorderRadius),topLeft: Radius.circular(cardBorderRadius),topRight: Radius.circular(cardBorderRadius))),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      color: colorCard,
                      child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start, style:const TextStyle( fontSize: 24)),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // widget : total de los productros vendidos
                                      Column(
                                        mainAxisSize:   MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [ 
                                          Text(Publications.getFormatAmount(value:transactionsController.readTotalProducts()),style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                                          const Opacity(opacity: 0.7,child:  Text('Total',style:TextStyle(fontSize: 10)))
                                        ],
                                      ),
                                      const Spacer(),
                                      isExpanded?Container():transactionsController.getMostSelledProducts.isEmpty?Container():transactionsController.getMostSelledProducts[0].image==''?Container():FadeIn(
                                        animate: true,
                                        duration: const Duration(milliseconds: 2000),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:  transactionsController.getMostSelledProducts[0].image,
                                                    placeholder: (context, url) => Container(width: 30,height: 30,decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)),color: Get.theme.dividerColor)),
                                                    imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Container(width: 30,height: 30,decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)),image: DecorationImage(image: image,fit: BoxFit.cover)))),
                                                    errorWidget: (context, url, error) => Container(),
                                                  ),
                                                  //  text  : marca del producto
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: Text(transactionsController.getMostSelledProducts[0].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:20)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Opacity(opacity: 0.8,child: Text('Más vendido',style:TextStyle(fontSize: 10))),
                                          ],
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ],
                              ),
                              ),
                            // icon : muestra si la tarjeta esta expandida o no
                            isExpanded? Container(): const Padding(padding: EdgeInsets.only(bottom:12),child: Icon(Icons.keyboard_arrow_down,size: 27)),
                            // content : contenido expandible 
                            AnimatedCrossFade(
                                  firstChild: const Text('', style: TextStyle(fontSize: 0)),
                                  secondChild: Theme(
                                    data: darkMode? ThemeData.dark():ThemeData.light(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        
                                        // widget : más vendidos
                                        mostselledProductsWidget,
                    
                                        //  widget  : productos más vendido por el valor
                                        higherPriedProductsWidget, 
                    
                                      ],
                                    ),
                                  ),
                                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 1200),
                                  reverseDuration: Duration.zero,
                                  sizeCurve: Curves.fastLinearToSlowEaseIn,
                                ),
                                
                            ],
                          ),
                    ),
                      ),
                ),
        ),
      ),
    );
  }
}
