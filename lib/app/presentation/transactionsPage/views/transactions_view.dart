import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Transacciones'),
      actions: [
        
        PopupMenuButton(
            icon: Material(
              color: darkTheme?Colors.white70:Colors.black87,
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(transactionsController.getFilterText,style:TextStyle(color: darkTheme?Colors.black:Colors.white,fontWeight: FontWeight.w700)),
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
              Divider(thickness: 0.1,color: darkTheme ?Colors.white70:Colors.black87,height: 0),
            ],
          );
        }

        return Column(
          children: [
            tileItem(ticketModel: transactionsController.getTransactionsList[index]),
            Divider(thickness: 0.1,color: darkTheme ?Colors.white70:Colors.black87,height: 0),
          ],
        );
      },
    );
  }

  // WIDGETS COMPONENTS

  Widget tileItem({required TicketModel ticketModel}) {
    
    // controllers
    final TransactionsController transactionsController = Get.find();

    // values
    Map payMode =transactionsController.getPayMode(idMode: ticketModel.payMode);
    String revenue = transactionsController.readEarnings(ticket: ticketModel);

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

    return ElasticIn(
      child: Dismissible(
        key:  UniqueKey(),
        background: AnimatedContainer(duration: const Duration(milliseconds: 5000),color: Colors.black12),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog(
            context: buildContext,
            builder: (BuildContext context) {
              return widget;
            },
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          onLongPress: () =>  transactionsController.deleteSale(ticketModel: ticketModel),
          title: Row(
            children: [
              Text('Pago con:  ',style: TextStyle(fontWeight: FontWeight.w300,color: Get.theme.textTheme.bodyMedium?.color )),
              Material(
                color: (payMode['color'] as Color) .withOpacity(0.1),
                clipBehavior: Clip.antiAlias,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10,vertical:0),
                  child: Text(payMode['name'],style: TextStyle(fontWeight: FontWeight.w600,color: (payMode['color'] as Color) .withOpacity(0.7)  )),
                )),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // primera fila
                Row(
                  children: [
                    Text(ticketModel.seller.split('@')[0],style: const TextStyle(fontSize: 14,overflow: TextOverflow.ellipsis,fontWeight: FontWeight.w400)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                    Text('caja ${ticketModel.cashRegister}',style:const TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
                // segunda fila
                Opacity(
                  opacity: 0.8,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // text : fecha de publicación
                      Text(Publications.getFechaPublicacionFormating(dateTime: ticketModel.creation.toDate()),style: const TextStyle(fontSize:12)),
                      //  text : cantidad de items ( productos )
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                      Text('${ticketModel.getLengh()} items'),
                      // text : valor del vuelto
                      ticketModel.valueReceived == 0? Container(): Row(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal:3), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                          Text('Vuelto: ${Publications.getFormatoPrecio(monto: ticketModel.valueReceived - ticketModel.priceTotal)}',style: const TextStyle(fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            crossAxisAlignment:CrossAxisAlignment.end,mainAxisSize: MainAxisSize.max,
            children: [
              //  text : precio totol del ticket
              Text(Publications.getFormatoPrecio(monto: ticketModel.priceTotal),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
              //  text : ganancias
              Text(revenue,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12,color: Colors.green.withOpacity(0.9)  )),
              //  text : fecha de publicación 
              Opacity(opacity: 0.8,child: Text(Publications.getFechaPublicacion(ticketModel.creation.toDate(), Timestamp.now().toDate()),style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 10)))
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////
/* CLASS VIEWS */
/////////////////


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
    bool isDark = false;
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
    isDark = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    Color? colorCard = isDark? Colors.blue.withOpacity(0.1) : isExpanded?Colors.white:Colors.blue[800]; // color te la tarjeta expandible
    themeData = isDark?ThemeData.dark():isExpanded?ThemeData.light():ThemeData.dark();
    elevation = isDark?isExpanded?0:0:isExpanded?8:0;

    // widget : productos de mayor ganancia
    Widget wProductsRevenue = transactionsController.getBestSellingProductList.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.all(20.0),
          child:Opacity(opacity: 0.7,child: Text('De mayor ganancia',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Material(
          elevation: 0,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
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
       Material(
          elevation: 0,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
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
                          trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getAnalyticsMeansOfPayment.values.elementAt(index) ),style: const TextStyle(overflow:TextOverflow.ellipsis,fontWeight: FontWeight.w900))),
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
                      //subtitle: Text(transactionsController.getAnalyticsMeansOfPayment[index].description,overflow:TextOverflow.ellipsis,style:const TextStyle( )),
                      trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getCashAnalysisMap.values.elementAt(index) ),style: const TextStyle(overflow:TextOverflow.ellipsis,fontWeight: FontWeight.w900 ))),
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
      child: Theme(
        data: themeData,
        child: AnimatedContainer(
          curve: !isExpanded ? const ElasticOutCurve(.9) : Curves.elasticOut,
          duration: const Duration(milliseconds: 5000),
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 2, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: elevation,
              color: colorCard,
              margin: const EdgeInsets.all(0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12),bottomRight: Radius.circular(12),topLeft: Radius.circular(12),topRight: Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                Row(
                                  children: [
                                    Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 24)),
                                    // icon : muestra si la tarjeta esta expandida o no
                                    Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,size: 27),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // text : analiticas
                                Row(
                                  children: [
                                    // text : monto total de las ventas del filtro
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Opacity(opacity: 0.9,child:  Text(transactionsController.getFilterText,style:const TextStyle(fontSize: 10 ))),
                                        Text(priceTotal,textAlign: TextAlign.start,style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                                        const Opacity(opacity: 0.7,child:  Text('Total',style:TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom:3),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 1),
                                            child: Text(revenue,style: const TextStyle(fontWeight: FontWeight.w900,fontSize: 24)),
                                          ),
                                        ),
                                        Opacity(opacity: 0.7,child:  Text(revenue==''?'':'Cantidad ganada',style:const TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ))
                        
                      ],
                    ),
                  ),
                  // view : expandible de volumen de ventas
                  AnimatedCrossFade(
                    firstChild: const Text('', style: TextStyle(fontSize: 0)),
                    secondChild: Theme(
                      data: isDark? ThemeData.dark():ThemeData.light(),
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
    Color colorCard = Colors.grey;
    bool isDark = false;
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
    
    isDark = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    Color? colorCard = isDark? Colors.blue.withOpacity(0.1) : isExpanded?Colors.white:Colors.teal[800];
    themeData = isDark?ThemeData.dark():isExpanded?ThemeData.light():ThemeData.dark();
    elevation = isDark?isExpanded?0:0:isExpanded?8:0;

    // widget : mostramos los productos de mayor precio más vendidos
    Widget higherPriedProductsWidget = transactionsController.getBestSellingProductsByAmount.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Opacity(opacity: 0.7,child: Text('Más vendidos con el mayor monto',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Material(
          elevation: 0,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
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
                          trailing: CircleAvatar( radius: 16,backgroundColor: Colors.blue.withOpacity(0.1),child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(color:Colors.blue))),
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
        ),
      ],
    );
    // widget : mostramos los productos más vendidos
    Widget mostselledProductsWidget = transactionsController.getMostSelledProducts.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Opacity(opacity: 0.7,child: Text('Más vendidos',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
        ),
        Material(
          elevation: 0,
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
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
                          trailing: CircleAvatar( radius: 16,backgroundColor: Colors.blue.withOpacity(0.1),child: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(color:Colors.blue))),
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
                    color: colorCard,
                    clipBehavior: Clip.antiAlias,
                    elevation: elevation, 
                    margin: const EdgeInsets.all(0),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12),bottomRight: Radius.circular(12),topLeft: Radius.circular(12),topRight: Radius.circular(12))),
                    child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style:const TextStyle( fontSize: 24)),
                                    // icon : muestra si la tarjeta esta expandida o no
                                    Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,size: 27),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // widget : total de los productros vendidos
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [ 
                                        Text(Publications.getFormatAmount(value:transactionsController.readTotalProducts()),style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
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
                                          Row(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:  transactionsController.getMostSelledProducts[0].image,
                                                placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                                                imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
                                                  alignment: Alignment.bottomLeft,
                                                  children: [
                                                    CircleAvatar(radius: 15 ,backgroundImage: image),
                                                    CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductList[0].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
                                                  ],
                                                )),
                                                errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                                              ),
                                              //  text  : marca del producto
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Text(transactionsController.getMostSelledProducts[0].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12)),
                                              ),
                                            ],
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
                          AnimatedCrossFade(
                                firstChild: const Text('', style: TextStyle(fontSize: 0)),
                                secondChild: Theme(
                                  data: isDark? ThemeData.dark():ThemeData.light(),
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
    );
  }
}

/* 
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

    // valueS
    bool isDark = false;
    bool isExpanded = false;
    Icon iconCategory = const Icon(Icons.monetization_on_outlined,color: Colors.green,);
    String textCategory = 'Volumen de ventas';
    String textFilter = '';
    String priceTotal = '';
    String revenue  = '';
  

  @override
  Widget build(BuildContext context) {


    // get values
    isDark = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    Color? colorCard =  Colors.blue[800]; // color te la tarjeta expandible

    // widget : productos de mayor ganancia
    Widget wProductsRevenue = transactionsController.getBestSellingProductList.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('De mayor ganancia',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        ),
        SizedBox( //220
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
                    trailing:Text('+${Publications.getFormatoPrecio(monto: transactionsController.getBestSellingProductList[index].revenue )}',style: TextStyle(overflow:TextOverflow.ellipsis ,color:Colors.green.shade400,fontWeight: FontWeight.w900,fontSize: 18)),
                  ),
                  const Divider(),
                ],
              ); 
          },),
        ),
      ],
    );
    // widget : modo de pago y su monto total
    Widget widgetAlyticsMeansOfPayment = transactionsController.getAnalyticsMeansOfPayment.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Medios de pago',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        ),
        SizedBox( //220
          child: ListView.builder(
            physics: const  NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: transactionsController.getAnalyticsMeansOfPayment.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {

              String value =transactionsController.getAnalyticsMeansOfPayment.keys.elementAt(index) ;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        tileColor: (transactionsController.getPayMode(idMode: value)['color'] as Color) .withOpacity(0.1),
                        dense: true,
                        title:Padding(
                          padding: const EdgeInsets.symmetric(horizontal:10,vertical:5),
                          child: Text(transactionsController.getPayMode(idMode: value)['name'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800,color: (transactionsController.getPayMode(idMode: value)['color']as Color) .withOpacity(0.7)  )),
                        ),
                        trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getAnalyticsMeansOfPayment.values.elementAt(index) ),style: const TextStyle(overflow:TextOverflow.ellipsis,fontWeight: FontWeight.w900,fontSize: 18))),
                      ),
                    ),
                  ),
                ],
              ); 
          },),
        ),
      ],
    );
    // view : monto de cada caja
    Widget cashAnalysisWidget = transactionsController.getCashAnalysisMap.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( //220
          //height:transactionsController.getCashAnalysisMap.isEmpty?0:transactionsController.getCashAnalysisMap.length==1?50:transactionsController.getCashAnalysisMap.length==2?100:175,width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12,vertical: 20),
                child: Text('saldo de caja',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                physics: const  NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: transactionsController.getCashAnalysisMap.length,
                shrinkWrap: true,
                itemBuilder: (context, index) { 
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        title: Text('Caja ${transactionsController.getCashAnalysisMap.keys.elementAt(index)}',overflow:TextOverflow.ellipsis,style:const TextStyle()),
                        //subtitle: Text(transactionsController.getAnalyticsMeansOfPayment[index].description,overflow:TextOverflow.ellipsis,style:const TextStyle( )),
                        trailing:Opacity(opacity: 0.75,child: Text(Publications.getFormatoPrecio(monto: transactionsController.getCashAnalysisMap.values.elementAt(index) ),style: const TextStyle(overflow:TextOverflow.ellipsis,fontWeight: FontWeight.w900,fontSize: 18))),
                      ),
                    ),
                  ); 
              },),
            ],
          ),
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
      child: Theme(
        data: ThemeData.dark(),
        child: AnimatedContainer(
          curve: !isExpanded ? const ElasticOutCurve(.9) : Curves.elasticOut,
          duration: const Duration(milliseconds: 1500),
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 2, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              color: colorCard,
              margin: const EdgeInsets.all(0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12),bottomRight: Radius.circular(12),topLeft: Radius.circular(12),topRight: Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                Row(
                                  children: [
                                    Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 24)),
                                    // icon : muestra si la tarjeta esta expandida o no
                                    Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,size: 27),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // text : analiticas
                                Row(
                                  children: [
                                    // text : monto total de las ventas del filtro
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Opacity(opacity: 0.9,child:  Text(transactionsController.getFilterText,style:const TextStyle(fontSize: 10))),
                                        Text(priceTotal,textAlign: TextAlign.start,style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                                        const Opacity(opacity: 0.7,child:  Text('Total',style:TextStyle(fontSize: 10)))
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Opacity(opacity: 0.7,child:  Text(revenue==''?'':'Cantidad ganada',style:const TextStyle(fontSize: 10))),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom:3),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 1),
                                            child: Text(revenue,style: const TextStyle(fontWeight: FontWeight.w900,fontSize: 24)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ))
                        
                      ],
                    ),
                  ),
                  // view : expandible de volumen de ventas
                  AnimatedCrossFade(
                    firstChild: const Text('', style: TextStyle(fontSize: 0)),
                    secondChild: Theme(
                      data: isDark? ThemeData.dark():ThemeData.light(),
                      child: Material(
                        elevation: 0,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        color: isDark? Colors.grey.shade900 : Colors.blueGrey.shade100,
                        child: Column(
                          children: [ 
                            //  view  : cantidad total de ventas
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      const Text('Ventas',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16)),
                                      const Spacer(),
                                      Text(transactionsController.getTransactionsList.length.toString(),style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            cashAnalysisWidget,
                            // view : productos con mayor ganancia
                            wProductsRevenue,
                            widgetAlyticsMeansOfPayment,
                          ],
                        ),
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

    // valueS
    Color colorCard = Colors.grey;
    bool isDark = false;
    bool isExpanded = false;
    Icon iconCategory = const Icon(Icons.analytics_outlined,color: Colors.orange);
    String textCategory = 'Productos';
    String textFilter = '';
    String priceTotal = '';
    String revenue  = '';

  @override
  Widget build(BuildContext context) {

    // get values
    isDark = Theme.of(context).brightness == Brightness.dark;
    textFilter = transactionsController.getFilterText;
    priceTotal = transactionsController.getInfoPriceTotal();
    revenue  = transactionsController.readTotalEarnings();
    Color? colorCard = Colors.teal[800]; // color te la tarjeta expandible 
    
    // widget : mostramos los productos de mayor precio más vendidos
    Widget higherPriedProductsWidget = transactionsController.getBestSellingProductsByAmount.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 20),
          child: Text('Más vendidos con el mayor monto',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
        ),

        SizedBox( //220
          child: ListView.builder(
            physics: const  NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: transactionsController.getBestSellingProductsByAmount.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 0,clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                  child: ListTile(
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
                    trailing: CircleAvatar( radius: 16,backgroundColor: Colors.blue.withOpacity(0.1),child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(color:Colors.blue))),
                  ),
                ),
              ); 
          },),
        ),
      ],
    );
    // widget : mostramos los productos más vendidos
    Widget mostselledProductsWidget = transactionsController.getMostSelledProducts.isEmpty?Container():Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 20),
          child: Text('Más vendidos',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
        ),
        SizedBox( //220
          child: ListView.builder(
            physics: const  NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: transactionsController.getMostSelledProducts.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 0,clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                  child: ListTile(
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
                    trailing: CircleAvatar( radius: 16,backgroundColor: Colors.blue.withOpacity(0.1),child: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(color:Colors.blue))),
                  ),
                ),
              ); 
          },),
        ),
      ],
    );


    return Theme(
      data: ThemeData.dark(),
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
                    color: colorCard,
                    clipBehavior: Clip.antiAlias,
                    elevation: isExpanded?0:0, 
                    margin: const EdgeInsets.all(0),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12),bottomRight: Radius.circular(12),topLeft: Radius.circular(12),topRight: Radius.circular(12))),
                    child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style:const TextStyle( fontSize: 24)),
                                    // icon : muestra si la tarjeta esta expandida o no
                                    Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,size: 27),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // widget : total de los productros vendidos
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(Publications.getFormatAmount(value:transactionsController.readTotalProducts()),style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
                                        const Opacity(opacity: 0.7,child:  Text('Total',style:TextStyle(fontSize: 10)))
                                      ],
                                    ),
                                    const Spacer(),
                                    transactionsController.getBestSellingProductList.isEmpty?Container():transactionsController.getBestSellingProductList[0].image==''?Container():Column(
                                      children: [
                                        Row(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:  transactionsController.getBestSellingProductList[0].image,
                                              placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                                              imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
                                                alignment: Alignment.bottomLeft,
                                                children: [
                                                  CircleAvatar(radius: 15 ,backgroundImage: image),
                                                  CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductList[0].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
                                                ],
                                              )),
                                              errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                                            ),
                                            //  text  : marca del producto
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Text(transactionsController.getBestSellingProductList[0].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12)),
                                            ),
                                          ],
                                        ),
                                        const Opacity(opacity: 0.8,child: Text('mayor ganancias',style:TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                            ),
                          AnimatedCrossFade(
                                firstChild: const Text('', style: TextStyle(fontSize: 0)),
                                secondChild: Theme(
                                  data: isDark? ThemeData.dark():ThemeData.light(),
                                  child: Material(
                                    clipBehavior: Clip.antiAlias,borderRadius: BorderRadius.circular(12),
                                    color: isDark? Colors.grey.shade900 : Colors.blueGrey.shade100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          //  widget  : productos más vendido por el valor
                                          higherPriedProductsWidget, 
                                          // widget : más vendidos
                                          mostselledProductsWidget,
                                        ],
                                      ),
                                    ),
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
    );
  }
}
 */