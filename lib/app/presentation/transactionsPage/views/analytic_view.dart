import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../home/controller/home_controller.dart';
import '../controller/transactions_controller.dart';

/////////////////
/* CLASS VIEWS */
////////////////  
class StaticsCards extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  StaticsCards({Key? key}) : super(key: key);

  @override
  State<StaticsCards> createState() => _StaticsCardsState();
}

class _StaticsCardsState extends State<StaticsCards> {
  // controllers
  final TransactionsController transactionsController = Get.find();

  final HomeController homeController = Get.find<HomeController>();
 

  @override
  Widget build(BuildContext context) {

    // var
    Color cardColor = Colors.blueGrey.withOpacity(0.2);

    // widgets
    List<Widget> cards =   [ 
      // card : facturación
      CardAnalityc(
        isPremium:true, // siempre es visible su contenido
        backgroundColor: cardColor,
        icon:  const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.attach_money_rounded,color: Colors.white,size:14)))),
        titleText: 'Facturación', 
        valueText: transactionsController.getInfoAmountTotalFilter,
        description: 'Balance total',
        content: MiniLineChart(prices: transactionsController.getBillingByDateList.reversed.toList(),positionIndex: transactionsController.positionIndex),
        ), 
      // card : transacciones
      CardAnalityc( 
        isPremium: true, // siempre es visible su contenido
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.receipt,color: Colors.white,size:14)))),
        titleText: 'Transacciones',
        subtitle: '',
        content: Text(transactionsController.getVisibilityTransactionsList.length.toString(),style: const TextStyle(fontSize: 50,fontWeight: FontWeight.w500)),
        //valueText: transactionsController.getTransactionsList.length.toString(),
        description: '',
        ), 
      // card : ganancia 
      CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon:  const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.show_chart_rounded,color: Colors.white,size:14)))),
        //content: transactionsController.viewPercentageBarValue(text:'%${transactionsController.getPercentEarningsTotal()}',value: transactionsController.getEarningsTotal,total: transactionsController.getAmountTotalFilter),
        titleText: 'Ganancia',
        subtitle: '%${transactionsController.getPercentEarningsFilteredTotal()}',
        valueText:  transactionsController.getEarningsTotalFilteredFormat,
        description: '',
        ),    
      // card : productos vendidos
      !transactionsController.getMostSelledProducts.isNotEmpty ?Container():
      CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.category_rounded,color: Colors.white,size:14)))),
        titleText: 'Productos vendidos', 
        subtitle: 'Total',
        valueText: Publications.getFormatAmount(value:transactionsController.readTotalProducts ),
        description: 'Mejor vendido con ${Publications.getFormatAmount(value:  transactionsController.getMostSelledProducts[0].quantity )} ventas', 
        modalContent: SoldProductsView(),
        // view : item del producto con mayor cantidad de ventas
        widgetDescription: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [ 
              // imagen del producto
              ImageProductAvatarApp(size: 24,url: transactionsController.getMostSelledProducts[0].image),
              const SizedBox(width: 5),
              // text : nombre
              Flexible(child: Text(transactionsController.getMostSelledProducts[0].description,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines: 1)),
            ],
          ),
        ),
        ), 
      // card : clientes
      CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.payment_rounded,color: Colors.white,size:14)))),
        content: transactionsController.viewPercentageBarCharTextDataHorizontal(chartData:  transactionsController.getAnalyticsMeansOfPayment.entries.toList()),
        titleText: 'Medio de pago', 
        //description:'${transactionsController.getPreferredPaymentMethod()['name']} más usado',
        modalContent: PaymentMethodView(),
        ),
      // card : rentabilidad
      CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.query_stats_rounded,color: Colors.white,size:14)))),
        titleText: 'Rentabilidad',
        modalContent: ProfitabilityProductsView(),
        // view : item del producto con mayor rentabilidad
        content: transactionsController.getBestSellingProductWithHighestProfit.isEmpty?Container(): Padding(
          padding: const EdgeInsets.only(top: 5,bottom: 5),
          child: Row(
            children: [ 
              // imagen del producto
              ImageProductAvatarApp(size: 35,url:transactionsController.getBestSellingProductWithHighestProfit[0].image),
              const SizedBox(width:8),
              // text : nombre
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transactionsController.getBestSellingProductWithHighestProfit[0].description,textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                    // text : codigo
                    const SizedBox(width:2),
                    Text(transactionsController.getBestSellingProductWithHighestProfit[0].code,textAlign: TextAlign.center,style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                  ],
                ),
              ),

            ],
          ),
        ),
        valueText: '${transactionsController.getBestSellingProductWithHighestProfit.isNotEmpty?transactionsController.getBestSellingProductWithHighestProfit[0].quantity:''} ventas',
        description: 'Ganancias ${transactionsController.getBestSellingProductWithHighestProfit.isNotEmpty?Publications.getFormatoPrecio(monto: transactionsController.getBestSellingProductWithHighestProfit[0].revenue ):'Sin datos'}',
        ), 
    ]; 
    // description : añadimos las tarjetas de las cajas si es que existen
    // reversed : primero revertimos el orden de las cajas y luego las agregamos a la lista de tarjetas 
    Map.fromEntries(transactionsController.getCashiersList.entries.toList().reversed) .forEach((key, value) {
      // add : agregamos las tarjetas de las cajas en una posicion especifica
      cards.insert(2,CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.point_of_sale_sharp,color: Colors.white,size:14)))),
        titleText: 'Caja ${value['name']}',
        subtitle: 'Facturación',
        modalContent: CashRegisterView(cashRegister: value['object']),
        valueText: Publications.getFormatoPrecio(monto: value['total'] ), 
        description: 'Transacciones: ${value['sales'].toString()}',
        ));
    }); 
 

    return Center(
      child: Wrap( 
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        direction: Axis.horizontal,
        spacing: 4,
        runSpacing: MediaQuery.of(context).size.width < 600 ? 4 : 16,
        children: cards,
      ),
    );
  }
}

// CLASS : una simple clase llamada 'CardAnalityc' de un tarjeta [Card] vacia con fondo gris con un aspecto de relacion aspecto cuadrado
// ignore: must_be_immutable
class CardAnalityc extends StatelessWidget {

  // controllers
  TransactionsController transactionsController = Get.find();
  // var
  late final dynamic backgroundColor;
  late final String titleText;
  late final String description;
  late final Widget widgetDescription;
  late final String valueText; 
  late final String subtitle;
  late final Widget icon;
  late final bool isPremium;
  late final Widget content; 
  late final Widget modalContent;

  // ignore: prefer_const_constructors_in_immutables
  CardAnalityc({Key? key,this.backgroundColor=Colors.grey,this.isPremium=false,this.titleText='',this.description='',this.valueText='',this.subtitle='' ,this.content = const SizedBox(),this.modalContent=const SizedBox(),required this.icon,this.widgetDescription= const SizedBox()}) : super(key: key);

  double calculateCardWidth(BuildContext context) {
    // var : logica para el tamaño de la tarjeta
    double width =  MediaQuery.of(context).size.width / 2 - 12;
    if( MediaQuery.of(context).size.width > 500){  width = MediaQuery.of(context).size.width / 2 - 12;}
    if( MediaQuery.of(context).size.width > 600){  width = MediaQuery.of(context).size.width / 3 - 12;}
    if(MediaQuery.of(context).size.width > 800){  width = MediaQuery.of(context).size.width / 4 - 12;}
    if(MediaQuery.of(context).size.width > 1000){  width = MediaQuery.of(context).size.width / 5 - 12;}
    return width;
  }

  @override
  Widget build(BuildContext context) { 


    // var : logica para el tamaño de la tarjeta
    double width =  calculateCardWidth(context); 


    return SizedBox(
      width:width,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: !isPremium || modalContent is SizedBox? null: () {  
              // showModalBottomSheet
              showModalBottomSheet(
                context: context, 
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(12))),
                clipBehavior: Clip.antiAlias, 
                
                builder:  (BuildContext context) => modalContent,
              );
              
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: viewContent,
            ),
          ),
        ),
      ),
    );
  }
  // WIDGETS VIEWS
  Widget get viewContent {



    // style  
    TextStyle subtitleStyle = const TextStyle(fontSize: 18,fontWeight: FontWeight.w300);
    TextStyle valueTextStyle = TextStyle(fontSize: description=='' && subtitle==''? 30: 24, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);
    TextStyle descriptionStyle = const TextStyle(fontSize: 12);  

    return Stack(
      children: [
        // view : contenedor de informacion estadisticos 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [  
            const Spacer(), 
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                content,
                subtitle==''?Container(): Flexible(child: Opacity(opacity: 0.7, child: Text(subtitle,style: subtitleStyle))),
                valueText==''?Container():Flexible(child: Text(valueText,maxLines:2, textAlign: TextAlign.start, style: valueTextStyle)),
                description==''?Container():Flexible(child: Opacity(opacity: 0.7, child: Text(description, style: descriptionStyle))),
                Row(   
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: widgetDescription),
                      // condition : si ruta esta vacio no muesta el icono de ver mas informacion
                    modalContent is SizedBox ?Container():const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Opacity(opacity: 0.2,child: Icon(Icons.expand_circle_down_sharp,size: 24)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ), 
        // condition : si es premium desenfoca el contenido
        isPremium?Container(): 
          BackdropFilter(
          filter: ImageFilter.blur(sigmaX:5, sigmaY:5),
          // view :  texto y icon version premium  
          child: Center(child: LogoPremium(personalize: true,id: 'analytic')),
          ),
        // position : posicionar en la parte superior  al inicio  de lado izquierdo
        Positioned(
          top: 0,
          left: 0,
          child: Row( 
          children: [
            icon,
            Text(titleText,style: const TextStyle(fontWeight: FontWeight.w400),overflow:  TextOverflow.ellipsis)
          ],
        ),
        ),  
      ],
    );
  }
}

// class : analiticas de productos Vendidos
class SoldProductsView extends StatelessWidget {
  SoldProductsView({super.key});

  // controllers
  final TransactionsController transactionsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: body,
    );
  }
  // appbar
  PreferredSizeWidget get appbar => AppBar(
    title: const Text('Productos vendidos'), 
  );
  // body 
  Widget get body => Padding(
    padding: const EdgeInsets.all(12.0), 
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          totalProducts,
        Padding(
          padding: const EdgeInsets.symmetric(vertical:8),
          child: ComponentApp().divider(),
        ),
        bestSellingProduct,
        ],
      ),
    ),
  );
  // Widget : total de productos vendidos
  Widget get totalProducts => Row(
    children: [ 
      const Text('Total de productos',style: TextStyle( fontWeight: FontWeight.w300)),
      const Spacer(),
      Text( Publications.getFormatAmount(value: transactionsController.readTotalProducts),style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
  // widget : obtener un maximo de productos vendidos`
  Widget get bestSellingProduct { 
    // obtener un maximo de 3 producto de transactionsController.getBestSellingProductList
    List<Widget> list = [];
    for (var i = 0; i < transactionsController.getMostSelledProducts.length; i++) {
      if(i<5){
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 5),
            child: Column(
              children: [
                // view : item del producto
                Row(
                  children: [ 
                    // imagen del producto
                    ImageProductAvatarApp(size: 35,url:transactionsController.getMostSelledProducts[i].image),
                    const SizedBox(width:8),
                    // text : nombre
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transactionsController.getMostSelledProducts[i].description,textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                          // text : codigo
                          const SizedBox(width:2),
                          Text(transactionsController.getMostSelledProducts[i].code,textAlign: TextAlign.center,style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // text : cantidad
                    Text('x${transactionsController.getMostSelledProducts[i].quantity.toString()}',style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ComponentApp().divider(),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        Text( list.length==1?'El más vendido':'Los ${list.length} más vendidos por cantidad',style: const TextStyle( fontWeight: FontWeight.w300)),
        const SizedBox(height: 12),
        ...list,
      ],
    );
  }


}
// class : analiticas de rentabilidad de productos
class ProfitabilityProductsView extends StatelessWidget {
  ProfitabilityProductsView({super.key});

  // controllers
  final TransactionsController transactionsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: body,
    );
  }
  // appbar
  PreferredSizeWidget get appbar => AppBar(
    title: const Text('Rentabilidad'), 
  );
  // body 
  Widget get body => Padding(
    padding: const EdgeInsets.all(12.0),
    // scrollview : para que se pueda desplazar el contenido 
    child: SingleChildScrollView(
      child: bestSellingProduct,
    ),
  );
  // Widget : Obtener el producto mas rentable
  Widget get bestSellingProduct {
    // var
    List<Widget> list = []; 
    // obtenemos la informacion de los productos
    for (var i = 0; i < transactionsController.getBestSellingProductWithHighestProfit.length; i++) {

      // var
      double revenue = transactionsController.getBestSellingProductWithHighestProfit[i].revenue;
      double priceTotal = transactionsController.getBestSellingProductWithHighestProfit[i].salePrice*transactionsController.getBestSellingProductWithHighestProfit[i].quantity;
      int percentage = ((revenue/priceTotal)*100).round();
      // condition  : mostramos 4 productos
      if(i<5){
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 5),
            child: Column(
              children: [
                Row(
                  children: [ 
                    // imagen del producto
                    ImageProductAvatarApp(size: 35,url:transactionsController.getBestSellingProductWithHighestProfit[i].image),
                    const SizedBox(width:8),
                    // text : nombre
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transactionsController.getBestSellingProductWithHighestProfit[i].description,textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                          // text : codigo
                          const SizedBox(width:2),
                          Text(transactionsController.getBestSellingProductWithHighestProfit[i].code,textAlign: TextAlign.center,style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // view : monto total y ganancia
                    Column(
                      mainAxisAlignment:  MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // text : cantidad y monto total
                        Text('x${transactionsController.getBestSellingProductWithHighestProfit[i].quantity} ${Publications.getFormatoPrecio(monto: priceTotal)}',style: const TextStyle(fontWeight: FontWeight.bold)),
                        // view : en un row el monto total de la ganancia y el porcentaje de ganancia de color verde
                        revenue==0?Container():Row(
                          mainAxisAlignment:  MainAxisAlignment.end,

                          children: [
                            // text : monto total de la ganancia
                            Text(Publications.getFormatoPrecio(monto: revenue),style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                            const SizedBox(width: 5),
                            // text : porcentaje de ganancia
                            Row(
                              children: [
                                const Icon(Icons.arrow_outward_rounded,size: 14,color: Colors.green),
                                const SizedBox(width: 2),
                                Text('%$percentage',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                              ],
                            ),
                            
                          ],
                        ),
                      ],
                    ),
                    
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ComponentApp().divider(),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [  
        Text(list.length==1?'Con mayor beneficio':'Los ${list.length} productos con mayor ganancia',style: const TextStyle( fontWeight: FontWeight.w300)),
        const SizedBox(height: 12),
        ...list,
      ],
    );
  }

}
// class : analiticas de medio de pago
class PaymentMethodView extends StatelessWidget {
  PaymentMethodView({super.key});

  // controllers
  final TransactionsController transactionsController = Get.find();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: body,
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget get appbar => AppBar(
    title: const Text('Medio de pago'), 
  );
  Widget get body { 
    // scrollview : para que se pueda desplazar el contenido
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // view : porcentaje de medio de pago
            viewPercentageBarCharTextDataHorizontal(height: 28,chartData:  transactionsController.getAnalyticsMeansOfPayment.entries.toList()),
            const SizedBox(height: 12),
            // text : el mas vendido
            Text('${transactionsController.getPreferredPaymentMethod()['name']} más usado',style: const TextStyle(fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );

  }

  Widget viewPercentageBarCharTextDataHorizontal({required List<MapEntry<dynamic, dynamic>> chartData, double height = 24 }){
      // description : muestra una lista con barra de porcentajes coloreada en forma horizontal
      // 
      // var 
      TextStyle textStyle = TextStyle(fontSize: height*0.5,fontWeight: FontWeight.w900 );

      // converit chartData en una nuevo Map
      List<Map> map = [];
      for (var item in chartData) {
        map.add({'name':transactionsController.getPayMode(idMode: item.key)['name'],'value':item.value,'priceTotal':Publications.getFormatoPrecio(monto: item.value),'color':transactionsController.getPayMode(idMode: item.key)['color']});
      } 
      
      // var
      List<int> listPorcent = [];
      double value = 0;
      // obtener el total de los valores 
      for (Map item in map){
        value += item['value'];
      }
      // convertir los valores de [list] en porcentajes  expresados en el rango de [0 al 100]
      for (Map item in map) {
        listPorcent.add((item['value'] * 100 / value).round());
      } 

      // agregar el nuevo campo 'porcent' a chartData en su respectivas posisicon
      for (var i = 0; i < chartData.length; i++) {
        map[i]['porcent'] = listPorcent[i];
      }
  

      return ListView( 
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(chartData.length, (index) {

          // obtener el porcentaje formateado  redondeado sin reciduo
          String porcent = map[index]['porcent'] % 1 == 0 ? '${map[index]['porcent'].round()}%' : '${map[index]['porcent']}%';
          String priceTotal = map[index]['priceTotal'];
          // crear la barra de porsentaje de fondo con color gris
          Widget percentageBarBackground = Material( 
            borderRadius: BorderRadius.circular(3),
            color: Colors.black12,
            child: SizedBox(height:height,width: double.infinity,),
          );
          // crear un [Material] con el color del 'chartData[index]['color']'  y pintado segun el porcentaje 
          Widget percentageBar = Material( 
            borderRadius: BorderRadius.circular(3),
            color: map[index]['color'],
            child: FractionallySizedBox(
              widthFactor: map[index]['porcent'] / 100,  
              child:  Container(height:height),
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0 ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical:5),
                  child: Text(map[index]['name'] ,style: textStyle,overflow: TextOverflow.ellipsis),
                ),
                Stack(  
                  alignment: Alignment.centerLeft, // centrar contenido
                  children: [
                    percentageBarBackground,
                    percentageBar,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text( '$porcent $priceTotal',style: textStyle.copyWith(color: Colors.white),overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        
        ),
      );
  }
}
// class : analiticas de caja registradora
class CashRegisterView extends StatelessWidget {
  final CashRegister cashRegister;
  const CashRegisterView({required this.cashRegister,super.key});

  // var : tiempo transcurrido
  String get timeElapsed {
    // var : tiempo de apertura de caja
    int hour = Timestamp.now().toDate().difference(cashRegister.opening).inHours;
    int minutes = Timestamp.now().toDate().difference(cashRegister.opening).inMinutes.remainder(60);
    String time = hour==0?'$minutes minutos':'$hour horas y $minutes minutos';
    return time;
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: appbar,
      body: body,
    );
  }
  // WIDGETS VIEWS
  PreferredSizeWidget get appbar => AppBar(
    title: const Text('Caja registradora'), 
  );
  Widget get body { 
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            // view : descripcion
            Row(
              children: [
                // text : descripcion
                const Text('Descripción:'),
                const Spacer(),
                // text : estado de la caja
                Text(cashRegister.description,style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ),
          Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
          // view : apertura
            Row(
              children: [
                // text : apertura
                const Text('Apertura:'),
                const Spacer(),
                // text : fecha de apertura
                Text(Publications.getFechaPublicacionFormating(dateTime: cashRegister.opening),style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            // view : tiempo transcurrido
            Row(
              children: [
                // text : tiempo transcurrido
                const Text('Tiempo transcurrido:'),
                const Spacer(),
                Text(timeElapsed,style: const TextStyle(fontWeight: FontWeight.w300)),
              ],
            ),

            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            // view : efectivo inicial
            Row(
              children: [
                // text : efectivo inicial
                const Text('Efectivo inicial:'),
                const Spacer(),
                // text : monto de efectivo inicial
                Text(Publications.getFormatoPrecio(monto: cashRegister.initialCash),style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ),    
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            // view : Ingresos
            Row(
              children: [
                // text : Ingresos
                const Text('Ingresos:'),
                const Spacer(),
                // text : cantidad de Ingresos
                Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.green)),

              ],
            ), 
            // view : Egresos
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            // view : Egresos
            Row(
              children: [
                // text : Egresos
                const Text('Egresos:'),
                const Spacer(),
                // text : cantidad de Egresos
                Text(Publications.getFormatoPrecio(monto: cashRegister.cashOutFlow),style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.red)),

              ],
            ), 
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            // view : transacciones
            Row(
              children: [
                // text : transacciones
                const Text('transacciones:'),
                const Spacer(),
                // text : cantidad de transacciones
                Text(cashRegister.sales.toString(),style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ), 
            // view : Facturación
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            Row(
              children: [
                // text : facturación total
                const Text('Facturación:'),
                const Spacer(),
                // text : monto de facturación total
                Text(Publications.getFormatoPrecio(monto: cashRegister.billing),style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ),
            // view : descuentos
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            Row(
              children: [
                // text : descuentos
                const Text('Descuentos:'),
                const Spacer(),
                // text : monto de descuentos
                Text(Publications.getFormatoPrecio(monto: cashRegister.discount),style: const TextStyle(fontWeight: FontWeight.w300)),

              ],
            ),
            // view : Balance esperado en la caja
            Padding(padding: const EdgeInsets.symmetric(vertical:8),child: ComponentApp().divider()),
            Row(
              children: [
                // text : Balance esperado en la caja
                const Text('Balance esperado en la caja:'),
                const Spacer(),
                // text : monto de Balance esperado en la caja
                Text(Publications.getFormatoPrecio(monto: cashRegister.getExpectedBalance),style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18)),

              ],
            ),

            
          
        
          ],
        ),
      ),
    );
  }
}










// ignore: must_be_immutable
class MiniLineChart extends StatelessWidget {

  List<double> prices=[];
  int positionIndex=0;
  
  MiniLineChart({Key? key,required this.prices,this.positionIndex=0}) : super(key: key);
 

  @override
  Widget build(BuildContext context) {

    if(prices.isEmpty) return Container();
 
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: LineChart(
        LineChartData( 
          lineTouchData: LineTouchData(  
            handleBuiltInTouches: true, // habilita el touch
            longPressDuration: const Duration(milliseconds: 100), // duracion del touch

            touchTooltipData: LineTouchTooltipData(  
              tooltipPadding: const EdgeInsets.all(2), 
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot; 
                  return LineTooltipItem(
                    formatValue(flSpot.y),
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              }, 
            ),
          ),
          lineBarsData: [
            LineChartBarData(  
              spots: [
                for (int i = 0; i < prices.length; i++)
                  FlSpot(i.toDouble(), prices[i]),
              ],   
              isCurved: true,
              color:Colors.blue,
              barWidth: 2,
              dotData: FlDotData(
                show: true, 
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: index==0?4: index == positionIndex ? 6 : 4,
                    color:Colors.blue,
                    strokeColor: Colors.white ,
                    strokeWidth: index==0?0: index == positionIndex ? 2 : 0,

                  );
                },
        ),  
            ),
            
            
          ],
          gridData: const FlGridData(
            show: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
        ),
        
      ),
    );
  }

  String formatValue(double value) {
    // return : devuelve el valor formateado en miles 
    if (value >= 1000) {
      return '\$${(value /1000).toStringAsFixed(1)}k';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  } 


}