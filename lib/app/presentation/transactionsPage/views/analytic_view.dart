import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart'; 
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
        icon:  const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Color.fromARGB(31, 94, 43, 43),shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.show_chart_rounded,color: Colors.white,size:14)))),
        titleText: 'Ganancia',
        subtitle: '%${transactionsController.getPercentEarningsFilteredTotal()}',
        valueText: transactionsController.getPercentEarningsFilteredTotal()==0? 'Sin registros': transactionsController.getEarningsTotalFilteredFormat,
        description: '',
        ),    
      // card : productos vendidos
      !transactionsController.getMostSelledProducts.isNotEmpty ?Container():
      CardAnalityc( 
        isPremium: homeController.getIsSubscribedPremium,
        backgroundColor: cardColor,
        icon: const Padding(padding: EdgeInsets.only(right: 5),child:  Material(color: Colors.black12,shape: CircleBorder(),child: Padding(padding: EdgeInsets.all(5.0),child: Icon(Icons.category_rounded,color: Colors.white,size:14)))),
        titleText: 'Productos', 
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
              Flexible(child: Text(transactionsController.getMostSelledProducts[0].description==''?'Desconocido':transactionsController.getMostSelledProducts[0].description,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines: 1)),
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
        valueText: transactionsController.getBestSellingProductWithHighestProfit.isNotEmpty? '${transactionsController.getBestSellingProductWithHighestProfit[0].quantity} Ventas': 'Sin datos',
        description: 'Ganancias ${transactionsController.getBestSellingProductWithHighestProfit.isNotEmpty?Publications.getFormatoPrecio(value: transactionsController.getBestSellingProductWithHighestProfit[0].revenue ):'Sin datos'}',
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
        valueText: Publications.getFormatoPrecio(value: value['total'] ), 
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
            child: viewContent,
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
    Color? buttonColor = Get.isDarkMode?Colors.white70:Colors.grey.shade700;

    return Stack(
      fit: StackFit.expand,
      children: [
        // view : contenedor de informacion estadisticos 
        ImageFiltered(
          enabled: !isPremium,
            imageFilter: ImageFilter.blur(sigmaX:4,sigmaY:4,tileMode: TileMode.decal),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
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
                          widgetDescription,
                        ],
                      ),
                    ],
                    
                  ),
                ),
                // position : posiciona en la parte inferior izquiedo
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: modalContent is SizedBox ?Container(): Padding(padding: const EdgeInsets.only(left: 8),child: CircleAvatar(backgroundColor: Colors.black26,maxRadius: 14,child: Icon(Icons.expand_circle_down_sharp,size: 24,color:buttonColor),) ),
                ),
              ],
            ),
          ), 
          // view : logo de premium
          isPremium?Container():Center(child: LogoPremium(personalize: true,id: 'analytic')),
          // position : posicionar en la parte superior  al inicio  de lado izquierdo
          Positioned(
            top:12,
            left:12,
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
    // var
    List<Widget> list = [];
    // obtenemos la informacion de los productos
    for (var i = 0; i < transactionsController.getMostSelledProducts.length; i++) {
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
                  const SizedBox(width:50),
                  // text : cantidad
                  Container( 
                    // circular
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:  const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                    child: Text(transactionsController.getMostSelledProducts[i].quantity.toString(),style: const TextStyle(fontWeight: FontWeight.bold))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [  
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
  
  Widget get body => transactionsController.getBestSellingProductWithHighestProfit.isEmpty? const Center(child: Text('Sin datos de ganancias')): Padding(
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
      // agregamos el item a la lista
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
                      Text('x${transactionsController.getBestSellingProductWithHighestProfit[i].quantity} ${Publications.getFormatoPrecio(value: priceTotal)}',style: const TextStyle(fontWeight: FontWeight.bold)),
                      // view : en un row el monto total de la ganancia y el porcentaje de ganancia de color verde
                      revenue==0?Container():Row(
                        mainAxisAlignment:  MainAxisAlignment.end,

                        children: [
                          // text : monto total de la ganancia
                          Text(Publications.getFormatoPrecio(value: revenue),style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                          const SizedBox(width: 5),
                          // text : porcentaje de ganancia
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal:3,vertical:1),
                            child: Text('%$percentage',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green))),
                          
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [   
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
        map.add({'name':transactionsController.getPayMode(idMode: item.key)['name'],'value':item.value,'priceTotal':Publications.getFormatoPrecio(value: item.value),'color':transactionsController.getPayMode(idMode: item.key)['color'],'iconData':transactionsController.getPayMode(idMode: item.key)['iconData']});
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

      // determinar el index que mayor valor tiene
      int indexMax = 0;
      for (var i = 0; i < map.length; i++) {
        if(map[i]['porcent'] > map[indexMax]['porcent']) indexMax = i;
      }
  

      return ListView( 
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(chartData.length, (index) {

          // var 
          height = indexMax == index ? height+6 : height;
          Widget icon = map[index]['iconData']!=null?Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(map[index]['iconData'],color: Colors.white),
          ):Container();

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
                // text : nombre del medio de pago
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical:5),
                  child: Text(map[index]['name'] ,style: textStyle,overflow: TextOverflow.ellipsis),
                ),
                // view :  datos de porcentaje y monto total
                Stack(  
                  alignment: Alignment.centerLeft, // centrar contenido
                  children: [
                    percentageBarBackground,
                    percentageBar,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        children: [
                          // icon : icono de medio de pago si es que existe
                          icon,
                          // text : porcentaje y monto total
                          Text( '$porcent $priceTotal',style: textStyle.copyWith(color: Colors.white),overflow: TextOverflow.ellipsis),
                        ],
                      ),
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
                Text(Publications.getFormatoPrecio(value: cashRegister.initialCash),style: const TextStyle(fontWeight: FontWeight.w300)),

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
                Text(Publications.getFormatoPrecio(value: cashRegister.cashInFlow),style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.green)),

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
                Text(Publications.getFormatoPrecio(value: cashRegister.cashOutFlow),style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.red)),

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
                Text(Publications.getFormatoPrecio(value: cashRegister.billing),style: const TextStyle(fontWeight: FontWeight.w300)),

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
                Text(Publications.getFormatoPrecio(value: cashRegister.discount),style: const TextStyle(fontWeight: FontWeight.w300)),

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
                Text(Publications.getFormatoPrecio(value: cashRegister.getExpectedBalance),style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18)),

              ],
            ),

            
          
        
          ],
        ),
      ),
    );
  }
}

