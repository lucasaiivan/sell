import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../domain/entities/ticket_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';
import '../controller/transactions_controller.dart';

// ignore: must_be_immutable
class TransactionsView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  TransactionsView({Key? key}) : super(key: key);

  // var 
  bool darkTheme=false;

  @override
  Widget build(BuildContext context) {

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
        Text(transactionsController.getFilterText),
        PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: (selectedValue) {
              transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'este mes', child: Text('Este mes')),
                  const PopupMenuItem(value: 'el mes pasado', child: Text('El mes pasado')),
                  const PopupMenuItem(value: 'este año', child: Text('Este año')),
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

    return ElasticIn(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onLongPress: () =>  transactionsController.deleteSale(ticketModel: ticketModel),
        title: Row(
          children: [
            Text('Pago con:  ',style: TextStyle(fontWeight: FontWeight.w400,color: Get.theme.textTheme.bodyMedium?.color )),
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
        // title: Text('Pago con: ${payMode['name']}',style: TextStyle(fontWeight: FontWeight.w400,color: payMode['color'] )),
        subtitle: Padding(
          padding: const EdgeInsets.only(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticketModel.seller.split('@')[0],style: const TextStyle(fontSize: 14)),
              Wrap(crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // text : fecha de publicación
                  Text(Publications.getFechaPublicacionFormating(dateTime: ticketModel.creation.toDate()),style: const TextStyle(fontSize:12)),
                  //  text : cantidad de productos
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                  Text('${ticketModel.getLengh()} items'),
                  // text : valor del vuelto
                  ticketModel.valueReceived == 0? Container(): Row(
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                      Text('Vuelto: ${Publications.getFormatoPrecio(monto: ticketModel.valueReceived - ticketModel.priceTotal)}',style: const TextStyle(fontWeight: FontWeight.w300)),
                    ],
                  ),
                ],
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
            revenue==''?  const Material():Padding(
              padding: const EdgeInsets.symmetric(horizontal:10,vertical:0),
              child: Text( '+$revenue' ,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 9,color: Colors.green.withOpacity(0.9)  )),
            ),
            //  text : fecha formateada 
            Text(Publications.getFechaPublicacion(ticketModel.creation.toDate(), Timestamp.now().toDate()),style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 10))
          ],
        ),
      ),
    );
  }
}


/* CLASS VIEWS */
// ignore: must_be_immutable
class CarruselCardsAnalytic extends StatefulWidget {

  // ignore: prefer_const_constructors_in_immutables
  CarruselCardsAnalytic({Key? key}): super(key: key);

  @override
  State<CarruselCardsAnalytic> createState() => _CarruselCardsAnalyticState();
}

class _CarruselCardsAnalyticState extends State<CarruselCardsAnalytic> {


  // var 
  int currentSlide=0;

  @override
  Widget build(BuildContext context) {

    // values 
    List<Widget> widgetsList = [WidgetAnalyticSalesTileExpanded(),cardAnalyticProducts];
    int lengh = widgetsList.length;

    return CarouselSlider.builder(
      options: CarouselOptions(
        onPageChanged: (index, reason) => setState(()=> currentSlide=index),
        viewportFraction: 0.80,
        enableInfiniteScroll: lengh == 1 ? false : true,
        autoPlay: lengh == 1 ? false : false,
        //aspectRatio: 1.5,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height),
      //options: CarouselOptions(enableInfiniteScroll: lista.length == 1 ? false : true,autoPlay: lista.length == 1 ? false : true,aspectRatio: 2.0,enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.scale),
      itemCount: lengh,
      itemBuilder: (context, index, realIndex) {
        // AnimatedOpacity : Versión animada de Opacity que cambia automáticamente la opacidad del niño durante un período determinado cada vez que cambia la opacidad dada
        return widgetsList[index];

      },
    );
  }

  Widget get cardAnalyticSales{

    // card : estadisticas de las transacciones

    // others controllers
    final TransactionsController transactionsController = Get.find();

    // values
    const Icon iconCategory = Icon(Icons.monetization_on_outlined,color: Colors.green,);
    const String textCategory = 'Volumen de ventas';
    String textFilter = transactionsController.getFilterText;
    String priceTotal = transactionsController.getInfoPriceTotal();
    String revenue  = transactionsController.readTotalEarnings();

    return Card(
      color: Colors.blue.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // text : información de la cátegoria
            Opacity(opacity: 0.8,child: Row(children: [const Text(textCategory,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),const Spacer(),CircleAvatar(backgroundColor: iconCategory.color!.withOpacity(0.5),child: iconCategory,)])),
            const Spacer(),
            // text
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // text : ganancias
                Column(
                  children: [
                    const Opacity(opacity:0.4,child: Text('Ganancias',style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                    Text(revenue,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
                  ],
                ),
                // text : numero de ventas
                Padding(
                  padding: const EdgeInsets.only(left:20),
                  child: Column(
                    children: [
                      const Opacity(opacity:0.4,child: Text('Ventas',style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                      Text(transactionsController.getTransactionsList.length.toString(),style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
                    ],
                  ),
                ),
              ],
              
            ),
            // text : fecha del filtro
            Opacity(opacity:0.5,child: Text(textFilter,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
            // text : monto total de las ventas del filtro
            Text(priceTotal,textAlign: TextAlign.start,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          ],
        ),
      )
    );
  }
  Widget get cardAnalyticProducts{

    // card : estadisticas de las transacciones

    // others controllers
    final TransactionsController transactionsController = Get.find();
    final HomeController homeController = Get.find();

    // values
    const Icon iconCategory = Icon(Icons.analytics_outlined,color: Colors.orange,);
    const String textCategory = 'Productos';
    Widget wProducts = SizedBox(
      height: 50,width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: transactionsController.getMostSelledProducts.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl:transactionsController.getMostSelledProducts[index].image,
            placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
            imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                CircleAvatar(radius: 20 ,backgroundImage: image),
                CircleAvatar(radius: 10 ,backgroundColor: Colors.white,child: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
              ],
            )),
            errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
          );
      },),
    );
    // widget : los productos de mayor monto
    Widget wProductsSales = SizedBox(
      height: 30,width: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: transactionsController.getBestSellingProductsByAmount.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl:transactionsController.getBestSellingProductsByAmount[index].image,
            placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
            imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                CircleAvatar(radius: 15 ,backgroundImage: image),
                CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
              ],
            )),
            errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
          );
      },),
    );
    // widget : productos de mayor ganancia
    Widget wProductsRevenue = SizedBox(
      height: 100,width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: transactionsController.getBestSellingProductList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl:transactionsController.getBestSellingProductList[index].image,
                  placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                  imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CircleAvatar(radius: 15 ,backgroundImage: image),
                      CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
                    ],
                  )),
                  errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                ),
                //  text  : marca del producto
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(transactionsController.getBestSellingProductList[index].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12)),
                ),
                const Spacer(),
                // text : ganancias del producto
                Text('+${Publications.getFormatoPrecio(monto: transactionsController.getBestSellingProductList[index].revenue)}',style: TextStyle(fontSize: 12,color:Colors.green.shade400)),
              ],
            ),
          );
      },),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.blue.withOpacity(0.1),
      elevation: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // datos
          Container(
            padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // text : total de los productros vendidos
                    Text(Publications.getFormatAmount(value:transactionsController.readTotalProducts()),style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(opacity:0.4,child: Text('De mayor monto',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                        const SizedBox(height:5),
                        wProductsSales,
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Opacity(opacity:0.4,child: Text('De mayor ganancia',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                    wProductsRevenue,
                  ],
                ),
                const SizedBox(height: 12),
                // text : fecha del filtro
                const Opacity(opacity:0.5,child: Text('Más vendidos',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                // widget : productos más vendidos
                wProducts,
              ],
            ),
          ), 
          // Premium
          homeController.getProfileAccountSelected.subscribed?Container():Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: InkWell(
                  onTap: (){ homeController.showModalBottomSheetSubcription(id: 'analytic'); },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(child: LogoPremium(personalize: true,accentColor: Colors.amber,id:'analytic')),
                  ),
                ),
              ),
            ),
          ),
          // text : información de la cátegoria
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: 
            [
              Opacity(opacity: 0.8,child: Row(children: [const Text(textCategory,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),const Spacer(),CircleAvatar(backgroundColor: iconCategory.color!.withOpacity(0.5),child: iconCategory,)])),
              const Spacer()]),
          ),
                  
        ],
      )
    );
  }
  Widget get cardAnalyticOthers{

    // card : estadisticas de las transacciones

    // others controllers
    final TransactionsController transactionsController = Get.find();
    final HomeController homeController = Get.find();

    // values
    const Icon iconCategory = Icon(Icons.bar_chart_rounded);
    const String textCategory = 'Otras estadisticas relevantes';
    String text0 = transactionsController.getFilterText;
    String text1 = transactionsController.getFilterText;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.blue.withOpacity(0.1),
      elevation: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                // text : fecha del filtro
                Opacity(opacity:0.5,child: Text(text0,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                // widget : productos más vendidos
                Text(text1),
              ],
            ),
          ), 
          // Premium
          homeController.getProfileAccountSelected.subscribed?Container():Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: InkWell(
                  onTap: (){ homeController.showModalBottomSheetSubcription(id: 'analytic'); },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(child: LogoPremium(personalize: true,accentColor: Colors.amber,id:'analytic')),
                  ),
                ),
              ),
            ),
          ),
          // text : información de la cátegoria
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [Opacity(opacity: 0.5,child: Row(children:const [iconCategory,SizedBox(width:5),Text(textCategory)])),const Spacer()]),
          ),
                  
        ],
      )
    );
  }
}


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
    bool isExpanded = true;
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

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        isExpanded = !isExpanded;
        transactionsController.update();
      },
      child: AnimatedContainer(
        curve: !isExpanded ? const ElasticOutCurve(.9) : Curves.elasticOut,
        duration: const Duration(milliseconds: 1500),
        margin:
            EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 2, vertical: 5),
        child: Card(
          elevation: isExpanded ? 0 : 0,
          color: Colors.blue.withOpacity(0.1),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    
                    // titulo
                    Flexible(
                        fit: FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.titleLarge),
                                // icon : muestra si la tarjeta esta expandida o no
                                Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,color: Theme.of(context).textTheme.titleLarge!.color,size: 27),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // text : monto total de las ventas del filtro
                                Text(priceTotal,textAlign: TextAlign.start,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Text('+$revenue',style: const TextStyle(color: Colors.green,fontWeight: FontWeight.w900,fontSize: 16)),
                              ],
                            ),
                          ],
                        )),
                    
                  ],
                ),
                /* isExpanded ? const SizedBox() : const SizedBox(height: 20),
                AnimatedCrossFade(
                  firstChild: const Text('', style: TextStyle(fontSize: 0)),
                  secondChild: Text('...Descripción...',
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context) .textTheme.titleMedium ),
                  crossFadeState: isExpanded ? CrossFadeState.showFirst: CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 1200),
                  reverseDuration: Duration.zero,
                  sizeCurve: Curves.fastLinearToSlowEaseIn,
                ), */
                isExpanded ? const SizedBox() : const SizedBox(height: 20),
                AnimatedCrossFade(
                  firstChild: const Text('', style: TextStyle(fontSize: 0)),
                  secondChild: Row(
                    children: [
                      const Text('Ventas'),
                      const Spacer(),
                      Text(transactionsController.getTransactionsList.length.toString(),style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
                    ],
                  ),//Column(children: widget.list),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 1200),
                  reverseDuration: Duration.zero,
                  sizeCurve: Curves.fastLinearToSlowEaseIn,
                ),
              ],
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
    bool isDark = false;
    bool isExpanded = true;
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

    // values
    Widget wProducts = SizedBox(
      height: 50,width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: transactionsController.getMostSelledProducts.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl:transactionsController.getMostSelledProducts[index].image,
            placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
            imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: CircleAvatar(radius: index==0?30:20 ,backgroundImage: image),
                ),
                CircleAvatar(radius: index==0?12:10 ,backgroundColor: Colors.white,child: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
              ],
            )),
            errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
          );
      },),
    );
    // widget : los productos de mayor monto
    Widget wProductsSales = SizedBox(
      height: 30,width: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: transactionsController.getBestSellingProductsByAmount.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl:transactionsController.getBestSellingProductsByAmount[index].image,
            placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
            imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                CircleAvatar(radius: 15 ,backgroundImage: image),
                CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
              ],
            )),
            errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
          );
      },),
    );
    // widget : productos de mayor ganancia
    Widget wProductsRevenue = SizedBox(
      height: 100,width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: transactionsController.getBestSellingProductList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl:transactionsController.getBestSellingProductList[index].image,
                  placeholder: (context, url) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                  imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CircleAvatar(radius: 15 ,backgroundImage: image),
                      CircleAvatar(radius: 8 ,backgroundColor: Colors.white,child: Text(transactionsController.getBestSellingProductsByAmount[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
                    ],
                  )),
                  errorWidget: (context, url, error) => CircleAvatar(radius: 14,backgroundColor: Get.theme.dividerColor),
                ),
                //  text  : marca del producto
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(transactionsController.getBestSellingProductList[index].nameMark,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12)),
                ),
                const Spacer(),
                // text : ganancias del producto
                Text('+${Publications.getFormatoPrecio(monto: transactionsController.getBestSellingProductList[index].revenue)}',style: TextStyle(fontSize: 12,color:Colors.green.shade400)),
              ],
            ),
          );
      },),
    );

    return InkWell(
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
              child: Card(
                elevation: isExpanded ? 0 : 0,
                color: Colors.blue.withOpacity(0.1),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          
                          // titulo
                          Flexible(
                              fit: FlexFit.tight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(textCategory,maxLines: isExpanded ? 1 : 2,overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.titleLarge),
                                      // icon : muestra si la tarjeta esta expandida o no
                                      Icon(isExpanded? Icons.keyboard_arrow_down: Icons.keyboard_arrow_up,color: Theme.of(context).textTheme.titleLarge!.color,size: 27),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // text : total de los productros vendidos
                                      Text(Publications.getFormatAmount(value:transactionsController.readTotalProducts()),style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400)),
                                      const Spacer(),
                                    ],
                                  ),
                                ],
                              )),
                          
                        ],
                      ),
                      isExpanded ? const SizedBox() : const SizedBox(height: 20),
                      AnimatedCrossFade(
                        firstChild: const Text('', style: TextStyle(fontSize: 0)),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Opacity(opacity:0.4,child: Text('De mayor monto',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                                const SizedBox(height:5),
                                wProductsSales,
                              ],
                            ),
                            const SizedBox(height: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Opacity(opacity:0.4,child: Text('De mayor ganancia',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                                  wProductsRevenue,
                                ],
                              ),
                              // text : fecha del filtro
                              const Opacity(opacity:0.5,child: Text('Más vendidos',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                              // widget : productos más vendidos
                              wProducts,
                          ],
                        ),
                        crossFadeState: isExpanded ? CrossFadeState.showFirst: CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 1200),
                        reverseDuration: Duration.zero,
                        sizeCurve: Curves.fastLinearToSlowEaseIn,
                      ),
                      
              ],
            ),
          ),
        ),
      ),
    );
  }
}