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

class TransactionsView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const CarruselCardsAnalytic(),
              tileItem( ticketModel: transactionsController.getTransactionsList[index]),
              const Divider(thickness: 0.1),
            ],
          );
        }

        return Column(
          children: [
            tileItem(ticketModel: transactionsController.getTransactionsList[index]),
            const Divider(thickness: 0.1),
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
    String payMode =transactionsController.getPayModeFormat(idMode: ticketModel.payMode);

    return ElasticIn(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onLongPress: () =>  transactionsController.deleteSale(ticketModel: ticketModel),
        title: Text('Pago con: $payMode',style: const TextStyle(fontWeight: FontWeight.w400)),
        subtitle: Padding(
          padding: const EdgeInsets.only(),
          child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // text : fecha de publicación
              Text(Publications.getFechaPublicacionFormating(dateTime: ticketModel.creation.toDate())),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
              Text('${ticketModel.getLengh()} items'),
              ticketModel.valueReceived == 0? Container(): Text('Vuelto: ${Publications.getFormatoPrecio(monto: ticketModel.valueReceived - ticketModel.priceTotal)}',style: const TextStyle(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Publications.getFormatoPrecio(monto: ticketModel.priceTotal),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
            Text(Publications.getFechaPublicacion(ticketModel.creation.toDate(), Timestamp.now().toDate()),style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 12))
          ],
        ),
      ),
    );
  }
}


/* CLASS VIEWS */
// ignore: must_be_immutable
class CarruselCardsAnalytic extends StatefulWidget {

  const CarruselCardsAnalytic({Key? key}): super(key: key);

  @override
  State<CarruselCardsAnalytic> createState() => _CarruselCardsAnalyticState();
}

class _CarruselCardsAnalyticState extends State<CarruselCardsAnalytic> {


  // var 
  int currentSlide=0;

  @override
  Widget build(BuildContext context) {

    // values 
    List<Widget> widgetsList = [cardAnalyticSales,cardAnalyticProducts,cardAnalyticOthers];
    int lengh = widgetsList.length;

    return CarouselSlider.builder(
      options: CarouselOptions(onPageChanged: (index, reason) => setState(()=> currentSlide=index),viewportFraction: 0.85,enableInfiniteScroll: lengh == 1 ? false : true,autoPlay: lengh == 1 ? false : true,aspectRatio: 2.0,enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.height),
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
    const Icon iconCategory = Icon(Icons.monetization_on_outlined);
    const String textCategory = 'Ventas';
    String text0 = transactionsController.getFilterText;
    String text1 = transactionsController.getInfoPriceTotal();

    return Card(
      color: Colors.blue.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding:const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // text : información de la cátegoria
            Opacity(
              opacity: 0.5,
              child: Row(
                children:const [
                  iconCategory,
                  SizedBox(width:5),
                  Text(textCategory),
                ],
              ),
            ),
            const Spacer(),
            // text : fecha del filtro
            Opacity(opacity:0.5,child: Text(text0,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
            // text : valor
            Text(text1,textAlign: TextAlign.start,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
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
    const Icon iconCategory = Icon(Icons.analytics_outlined);
    const String textCategory = 'Productos más vendidos';
    String text0 = transactionsController.getFilterText;
    Widget wProducts = SizedBox(
      height: 50,width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: transactionsController.getMostSelledProducts.length,shrinkWrap: true,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl:transactionsController.getMostSelledProducts[index].image,
            placeholder: (context, url) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
            imageBuilder: (context, image) => Padding(padding: const EdgeInsets.all(2.0),child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                CircleAvatar(radius: 24 ,backgroundImage: image),
                CircleAvatar(radius: 10 ,backgroundColor: Colors.white,child: Text(transactionsController.getMostSelledProducts[index].quantity.toString(),style:const TextStyle(fontSize: 8,color:Colors.blue))),
              ],
            )),
            errorWidget: (context, url, error) => CircleAvatar(backgroundColor: Get.theme.dividerColor),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                // text : fecha del filtro
                Opacity(opacity:0.5,child: Text(text0,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
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
            child: Column(children: [Opacity(opacity: 0.5,child: Row(children:const [iconCategory,SizedBox(width:5),Text(textCategory)])),const Spacer()]),
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