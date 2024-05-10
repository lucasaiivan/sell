 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import 'package:intl/intl.dart'; 
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart'; 
import '../../../domain/entities/ticket_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart'; 
import '../../home/controller/home_controller.dart';
import '../controller/transactions_controller.dart';
import 'package:animate_do/animate_do.dart';

import 'analytic_view.dart'; 

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
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(TransactionsController());
      },
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

    // controllers
    final TransactionsController transactionsController = Get.find();

 
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Transacciones',textAlign: TextAlign.center),
      bottom: transactionsController.getLoading?ComponentApp().linearProgressBarApp():null,
      actions: [
        
        PopupMenuButton( 
            icon: ComponentApp().buttonAppbar(
              context: context,
              text: transactionsController.getFilterText,
              iconTrailing: Icons.filter_list,  
            ),
            onSelected: (selectedValue) {
              transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'este mes', child: Text('Este mes')),
                  // opciones premium // 
                  transactionsController.homeController.getIsSubscribedPremium?const PopupMenuItem(child: null,height: 0):const PopupMenuItem(value: 'premium', child: Text('Opciones Premium',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.amber))),
                  PopupMenuItem(value: 'el mes pasado',enabled: transactionsController.homeController.getIsSubscribedPremium, child: const Text('El mes pasado')),
                  PopupMenuItem(value: 'este año',enabled: transactionsController.homeController.getIsSubscribedPremium, child: const Text('Este año')),
                  PopupMenuItem(value: 'el año pasado',enabled: transactionsController.homeController.getIsSubscribedPremium, child: const Text('El año pasado')),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {

    // others controllers
    final TransactionsController transactionsController = Get.find();

    // vista para mostrar en el caso que no alla ninguna transacción
    if (transactionsController.getVisibilityTransactionsList.isEmpty) {
      return Center( child: Text( 'Sin transacciones ${transactionsController.getFilterText.toLowerCase()}'));
    }

    // define una variable currentDate para realizar el seguimiento de la fecha actual en la que se está construyendo la lista. Inicializa esta variable con la fecha de la primera transacción en la lista
    DateTime currentDate = transactionsController.getVisibilityTransactionsList[0].creation.toDate();
    // lista de widgets List<Widget> donde se almacenarán los elementos de la lista
    List<Widget> transactions = [];  
    // add : Itera sobre la lista de transacciones y verifica si la fecha de la transacción actual es diferente a la fecha actual. Si es así, crea un elemento Divider y actualiza la fecha actual
    for (int i = 0; i < transactionsController.getVisibilityTransactionsList.length; i++) {
      // condition : si es la primera transacción
      if(i==0){
        // add : añade tarjetas de estadísticas
        transactions.add(StaticsCards()); 
        // add : añade un Text con el texto 'Registros'
        transactions.add(const Padding(padding: EdgeInsets.only(left: 8.0,top: 20.0,bottom:4.0),child: Text('Registros',style:TextStyle(fontSize: 24,fontWeight: FontWeight.w300))));
      }
      // condition : si la fecha actual es diferente a la fecha de la transacción actual
      if (currentDate.day != transactionsController.getVisibilityTransactionsList[i].creation.toDate().day || i==0) {
        //  set : actualiza la fecha actual de la variable
        currentDate = transactionsController.getVisibilityTransactionsList[i].creation.toDate();
        // add : añade un Container con el texto de la fecha como divisor
        transactions.add(Container(padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),width: double.infinity,color: Colors.grey.withOpacity(.05),child: Opacity(opacity: 0.8,child: Text(Publications.getFechaPublicacionSimple(  transactionsController.getVisibilityTransactionsList[i].creation.toDate(),Timestamp.now().toDate()),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w300)))));
      }
      //  add : añade el elemento de la lista actual a la lista de widgets
      transactions.add(tileItem(ticketModel: transactionsController.getVisibilityTransactionsList[i]),);
      // agregar un divider
      transactions.add( ComponentApp().divider());
    }
    // Finalmente, utiliza la lista de widgets widgets e
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) => transactions[index],
    );

  }

  // WIDGETS COMPONENTS

  Widget tileItem({required TicketModel ticketModel}) {
  //  description  : Este 'ListTile' muestra información de cada transacción
    
    // controllers
    final TransactionsController transactionsController = Get.find();

    // values
    final Map payMode =transactionsController.getPayMode(idMode: ticketModel.payMode);
    final double  dRevenue = ticketModel.getProfit; 
    final String sRevenue = dRevenue==0?'': Publications.getFormatoPrecio(monto:dRevenue);  
    final int iPorcent = ticketModel.getPercentageProfit;
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
                      color: (payMode['color'] as Color).withOpacity(0.1),
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: Row(
                        children: [
                          // verificar si existe el dato 'payMode['iconData']' para mostrar el icono de la forma de pago de lo contrario se muestra un contenedor vacio
                          payMode['iconData']!=null?Padding(
                            padding: const EdgeInsets.only(left:5,bottom: 2,top:2,right:0),
                            child: Icon(payMode['iconData'],color: payMode['color'].withOpacity(0.7),size: 20),
                          ):Container(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:5,vertical:0),
                            child: Text(payMode['name'],style: TextStyle(fontWeight: FontWeight.w600,color: (payMode['color'] as Color) .withOpacity(0.7)  )),
                          ),
                        ],
                      )),
                    Opacity(opacity:0.3,child: dividerCircle),
                    // fecha de transacción
                    Text(Publications.getFechaPublicacion(fechaActual: Timestamp.now().toDate(),fechaPublicacion: ticketModel.creation.toDate()),style: TextStyle(color: primaryTextColor.withOpacity(0.3),fontWeight: FontWeight.w400 )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // primera fila : numero de caja, y id del vendedor
                    Row(
                      children: [
                        // text : numero de caja
                        Text('caja ${ticketModel.cashRegisterName}',style:textStyleSecundary),
                        dividerCircle,
                        // text : id del vendedor
                        Text(ticketModel.seller.split('@')[0],style:textStyleSecundary), 
                        
                      ],
                    ), 
                    // segunda fila : cantidad de items, valor del vuelto
                    Opacity(
                      opacity: 0.8,
                      child: Row( 
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //  text : cantidad de items ( productos )
                          Text('${ticketModel.getProductsQuantity()} artículos',style:textStyleSecundary), 
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
            // view : monto de ganancia
            sRevenue==''?Container():Text(sRevenue,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.green.withOpacity(0.9)  )),
            //  view : procentaje de ganancia
            iPorcent==0?Container():
            Row(
              children: [
                // icon
                sRevenue==''?Container():Icon(Icons.arrow_upward_rounded,size: 14,color: Colors.green.withOpacity(0.9)),
                // text : ganancias
                Text('%$iPorcent',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.green.withOpacity(0.9)  )),
              ],
            ),
            //  text : precio totol del ticket
            Text(Publications.getFormatoPrecio(monto: ticketModel.priceTotal),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: primaryTextColor)),
            // text : descuento
            ticketModel.discount==0?Container():Text('-${Publications.getFormatoPrecio(monto: ticketModel.discount)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10,color: Colors.red.withOpacity(0.9)  )),
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
          onLongPress: () =>  showAlertDialogTransactionInformation(buildContext,ticketModel),
          onTap: () => showAlertDialogTransactionInformation(buildContext,ticketModel),
          child: listTile,
          ),
      ),
    );
  }

  // DIALOG : mostrar detalles de la transacción
  void showAlertDialogTransactionInformation(BuildContext context, TicketModel ticket) {
     
 

    // creamos un dialog con GetX
    Get.dialog(
      ClipRRect(
        borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: TransactionInfoView(ticket: ticket),
      ),
    );   
  }
}




class TransactionInfoView extends StatelessWidget { 

  final TicketModel ticket; 
  const TransactionInfoView({Key? key,required this.ticket}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    
    String id = ticket.id;
    String seller = ticket.seller;
    String cashRegister = ticket.cashRegisterName == ''?'sin especificar':ticket.cashRegisterName;
    String payMode = ticket.payMode;
    double priceTotal = ticket.priceTotal;
    double valueReceived = ticket.valueReceived;
    double changeAmount = valueReceived==0?0.0: valueReceived - priceTotal;
    String currencySymbol = ticket.currencySymbol; 
    Timestamp creation = ticket.creation;

    // controllers
    final TransactionsController transactionsController = Get.find();

    // Formatear marca de tiempo como fecha
    var formatter = DateFormat('dd/MM/yyyy  HH:mm');
    var formattedCreationDate = formatter.format(creation.toDate());
 

    // var 
    Map payModeMap =transactionsController.getPayMode(idMode: payMode);
    // styles
    Color separatorColor = Colors.black.withOpacity(0.03);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const double opacity = 0.8; 
    Widget spacer = const SizedBox(height:6);
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300);
    TextStyle textStyleValue = const TextStyle(fontWeight: FontWeight.w600);

  return Scaffold(
      appBar: AppBar(
        title: const Text('Transacción'), 
        actions: [
          // button : close
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              transactionsController.deleteSale(ticketModel: ticket);
            },
          ),
        ],
        
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // button : eliminar
          FloatingActionButton(
            onPressed: () {
              Get.back();
            },
            backgroundColor:isDarkMode?Colors.grey.shade500:Colors.grey.shade500,
            child: const Icon(Icons.close,color: Colors.white),
          ),
          const SizedBox(width: 10),
          //  button : ver ticket 
          FloatingActionButton.extended(
            onPressed: () { 

              // creamos un dialog con GetX
              Get.dialog(
                ClipRRect(
                  borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
                  child: TicketView(ticket: ticket),
                ),
              ); 

            }, 
            icon: const Icon(Icons.receipt,color: Colors.white),
            label: const Text('Ver ticket',style: TextStyle(color: Colors.white)),
          ), 
          
        ],
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[ 
              const SizedBox(height: 20),
              // text
              Row(
                children: <Widget>[
                  Opacity(opacity:opacity,child: Text("Id: ",style: textStyleDescription)),
                  const Spacer(),
                  Text(id,style: textStyleValue),
                ],
              ), 
              spacer,
              Container(
                color: separatorColor,
                child: Row(
                  children: <Widget>[
                    Opacity(opacity:opacity,child: Text("Fecha: ",style: textStyleDescription)),
                    const Spacer(),
                    Text(formattedCreationDate,style: textStyleValue,overflow:TextOverflow.ellipsis)
                  ],
                ),
              ),
              spacer,
              Row(
                children: <Widget>[
                  Opacity(opacity:opacity,child: Text("Vendedor: ",style: textStyleDescription,overflow:TextOverflow.ellipsis)),
                  const Spacer(),
                  Text(seller,style: textStyleValue,overflow:TextOverflow.ellipsis),
                ],
              ), 
              spacer,
              Container(
                color: separatorColor,
                child: Row(
                  children: <Widget>[
                    Opacity(opacity:opacity,child: Text("Caja: ",style: textStyleDescription)),
                    const Spacer(),
                    Text(cashRegister,style: textStyleValue),
                  ],
                ),
              ),
              spacer,
              Row(
                children: <Widget>[
                  Opacity(opacity:opacity,child: Text("Modo de pago: ",style: textStyleDescription)),
                  const Spacer(),
                  Text("${ payModeMap['name'] }",style: textStyleValue,overflow:TextOverflow.ellipsis),
                ],
              ),
              spacer,  
              const Divider(),
              spacer,  
              // text : descuentos
              ticket.discount==0?Container():
              Row(
                children: <Widget>[
                  const Spacer(),
                  Opacity(opacity:opacity,child: Text("Descuentos:  ",style: textStyleDescription)),
                  Text(Publications.getFormatoPrecio(monto: ticket.discount,moneda: currencySymbol),overflow:TextOverflow.ellipsis,style: textStyleValue.copyWith(color: Colors.red.shade400)),
                ],
              ),
              spacer, 
              // text : precio total
              Row(
                children: [
                  const Spacer(),
                  Container(
                    color: Colors.black12,
                    child: Row(
                      children: <Widget>[ 
                        Opacity(opacity:opacity,child: Text("Total:  ",style: textStyleDescription)),
                        Text( Publications.getFormatoPrecio(monto: priceTotal,moneda: currencySymbol),overflow:TextOverflow.ellipsis,style: textStyleValue ),
                      ],
                    ),
                  ),
                ],
              ),
              spacer,
              // text : ganancias
              ticket.getProfit==0?Container():
              Row(
                children: <Widget>[
                  const Spacer(),
                  Opacity(opacity:opacity,child: Text("Ganancias:  ",style: textStyleDescription)),
                  Text( Publications.getFormatoPrecio(monto: ticket.getProfit,moneda: currencySymbol),overflow:TextOverflow.ellipsis,style: textStyleValue.copyWith(color: Colors.green)),
                ],
              ),
              spacer,
              // text : valor recibido
              valueReceived==0?Container():
              Row(
                children: <Widget>[
                  const Spacer(),
                  Opacity(opacity:opacity,child: Text("Valor recibido:  ",style: textStyleDescription)),
                  Text(Publications.getFormatoPrecio(monto: valueReceived,moneda: currencySymbol),style: textStyleValue),
                ],
              ),
              spacer,
              // text : valor del vuelto
              changeAmount == 0?Container():
              Row(
                children: <Widget>[
                  const Spacer(),
                  Opacity(opacity:opacity,child: Text("Vuelto:  ",style: textStyleDescription)),
                  Text( Publications.getFormatoPrecio(monto: changeAmount,moneda: currencySymbol),style: textStyleValue),
                ],
              ),
              const Divider(),
              Row(
                children: <Widget>[
                  Opacity(opacity:opacity,child: Text("Artículos  ",style: textStyleDescription)),
                  const Spacer(),
                  Text("Total:  ",style: textStyleDescription),
                  Text("${ticket.getProductsQuantity()}",style: textStyleValue),
                ],
              ),
              // crear items de los productos vendidos 
              Column(
                children: ticket.listPoduct.map((product) { 
                  // style 
                  TextStyle style = const TextStyle(fontWeight: FontWeight.bold,fontSize: 12);
                  // obj
                  ProductCatalogue productCatalogue = ProductCatalogue.fromMap(product);
                  return Column(
                    children: [ 
                      ListTile(
                        title: Opacity(opacity: 0.7,child: Text(productCatalogue.description,style: style)),
                        leading: Opacity(opacity: 0.5,child: Text('x${productCatalogue.quantity}',style: style)),
                        trailing: Opacity(opacity: 0.6,child: Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice*productCatalogue.quantity,moneda: currencySymbol),style: style)),
                      ),
                      const Divider(height: 0.5,thickness: 0.3),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 75),
            
            ],
          ),
        ),
      ),
    );
  }
}
class TicketView extends StatelessWidget {
  final TicketModel ticket; 
  const TicketView({Key? key,required this.ticket}) : super(key: key);

  Widget getBody({required BuildContext context}) {
    return Theme(
      data: ThemeData.light(),
      child: body(context: context));
  } 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:12.0),
        child: body(context: context),
      ),
      floatingActionButton: floatingActionButton(context:context),
    );
  }
    // -- VIEW WIDGETS -- //
    PreferredSizeWidget get appBar {
      return AppBar(title: const Text('Ticket'));
    }
    Widget body({required BuildContext context}) {

    String id = ticket.id;
    String seller = ticket.seller;
    String cashRegister = ticket.cashRegisterName == ''?'sin especificar':ticket.cashRegisterName; 
    double priceTotal = ticket.priceTotal;
    double valueReceived = ticket.valueReceived;
    double changeAmount = valueReceived==0?0.0: valueReceived - priceTotal;
    String currencySymbol = ticket.currencySymbol; 
    Timestamp creation = ticket.creation;

    // controllers
    final HomeController homeController = Get.find();

    // Formatear marca de tiempo como fecha
    var formatter = DateFormat('dd/MM/yyyy  HH:mm');
    var formattedCreationDate = formatter.format(creation.toDate());
 

    // var 
    String payModeName =ticket.getNamePayMode ;
    String town = homeController.getProfileAccountSelected.town;
    String province = homeController.getProfileAccountSelected.province; 
    String direction = town == ''?province:'$town, $province';
    // styles
    Color separatorColor = Colors.black.withOpacity(0.03); 
    const double opacity = 0.8; 
    Widget spacer = const SizedBox(height:2);
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300,fontFamily: 'Monospace',letterSpacing: -1.0,color: Colors.black);
    TextStyle textStyleValue = const TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Monospace',letterSpacing: -0.9,color: Colors.black);

      
      return SingleChildScrollView( 
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ 
                const SizedBox(height: 10),
                // text : nombre del negocio 
                Text(homeController.getProfileAccountSelected.name,style: textStyleValue.copyWith(fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Monospace',letterSpacing: -1.0)),
                // text : dirección del negocio 
                Text(direction,style: textStyleValue.copyWith(fontWeight: FontWeight.w300,fontSize: 14,fontFamily: 'Monospace')),
                const SizedBox(height: 20),
                // item view : id de la transacción
                Row(
                  children: <Widget>[
                    Opacity(opacity:opacity,child: Text("Id: ",style: textStyleDescription)),
                    const Spacer(),
                    Text(id,style: textStyleValue),
                  ],
                ), 
                spacer,
                // item view : fecha de la transacción
                Container(
                  color: separatorColor,
                  child: Row(
                    children: <Widget>[
                      Opacity(opacity:opacity,child: Text("Fecha: ",style: textStyleDescription)),
                      const Spacer(),
                      Text(formattedCreationDate,style: textStyleValue,overflow:TextOverflow.ellipsis)
                    ],
                  ),
                ),
                spacer,
                // item view : vendedor y caja
                Row(
                  children: <Widget>[
                    Opacity(opacity:opacity,child: Text("Vendedor: ",style: textStyleDescription,overflow:TextOverflow.ellipsis)),
                    const Spacer(),
                    Text(seller,style: textStyleValue,overflow:TextOverflow.ellipsis),
                  ],
                ), 
                spacer,
                Container(
                  color: separatorColor,
                  child: Row(
                    children: <Widget>[
                      Opacity(opacity:opacity,child: Text("Caja: ",style: textStyleDescription)),
                      const Spacer(),
                      Text(cashRegister,style: textStyleValue),
                    ],
                  ),
                ),
                spacer, 
                const Divider(),
                Row(
                  children: <Widget>[
                    Opacity(opacity:opacity,child: Text("Artículos  ",style: textStyleDescription)),
                    const Spacer(),
                    Text("Total:  ",style: textStyleDescription),
                    Text("${ticket.getProductsQuantity()}",style: textStyleValue),
                  ],
                ),
                // -------------------------------------------------- //
                // -- view : crear items de los productos vendidos -- //
                Column(
                  children: ticket.listPoduct.asMap().map((index, product) { 
                    // style 
                    TextStyle style = textStyleValue.copyWith(fontWeight: FontWeight.bold,fontSize: 12,fontFamily: 'Monospace',letterSpacing: -1.0);
                    // obj
                    ProductCatalogue productCatalogue = ProductCatalogue.fromMap(product);
          
                    return MapEntry(index, Column(
                      children: [ 
                        Row(
                          children: [
                            Opacity(opacity: 0.5,child: Text('x${productCatalogue.quantity}',style: style)),
                            const SizedBox(width: 10),
                            Flexible(fit: FlexFit.tight,child: Opacity(opacity: 0.7,child: Text(productCatalogue.description,style: style,maxLines:1,overflow:TextOverflow.ellipsis,))),
                            const SizedBox(width: 12),
                            Opacity(opacity: 0.6,child: Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice*productCatalogue.quantity,moneda: currencySymbol),style: style)),
                          ],
                        ),
                        // condition : si es el ultimo item , no agregar un divider
                        if (index != ticket.listPoduct.length - 1) const Padding(padding: EdgeInsets.symmetric(vertical:2),child: Divider(height: 0.5,thickness: 0.3)),
                      ],
                    ));
                  }).values.toList(),
                ),
                const SizedBox(height: 20), 
                spacer, 
                // view : precio total del ticket
                Container(
                  // dibujar borde con una linea negra
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54 ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: <Widget>[ 
                        Opacity(opacity:opacity,child: Text("Total:  ",style: textStyleDescription.copyWith(fontSize: 20))),
                        const Spacer(),
                        Text( Publications.getFormatoPrecio(monto: priceTotal,moneda: currencySymbol),overflow:TextOverflow.ellipsis,style: textStyleValue.copyWith(fontSize: 24) ),
                      ],
                    ),
                  ),
                ),
                spacer,
                // text : descuentos
                ticket.discount==0?Container():
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Opacity(opacity:opacity,child: Text("Descuentos:  ",style: textStyleDescription)),
                    Text(Publications.getFormatoPrecio(monto: ticket.discount,moneda: currencySymbol),overflow:TextOverflow.ellipsis,style: textStyleValue.copyWith(color: Colors.red.shade400)),
                  ],
                ), 
                spacer,
                // text : valor recibido
                valueReceived==0?Container():
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Opacity(opacity:opacity,child: Text("Valor recibido:  ",style: textStyleDescription)),
                    Text(Publications.getFormatoPrecio(monto: valueReceived,moneda: currencySymbol),style: textStyleValue),
                  ],
                ),
                spacer,
                // text : valor del vuelto
                changeAmount == 0?Container():
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Opacity(opacity:opacity,child: Text("Vuelto:  ",style: textStyleDescription)),
                    Text( Publications.getFormatoPrecio(monto: changeAmount,moneda: currencySymbol),style: textStyleValue),
                  ],
                ), 
                // view : modo de pago
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Opacity(opacity:opacity,child: Text("Modo de pago: ",style: textStyleDescription)),
                    Text(payModeName,style: textStyleValue,overflow:TextOverflow.ellipsis),
                  ],
                ), 
                const SizedBox(height: 12),
                const Divider(),
                // text : 'Gracias por su compra'
                const SizedBox(height: 12),
                Text('Gracias por su compra',style:textStyleValue.copyWith(fontSize: 18,fontWeight: FontWeight.w500)),
                const SizedBox(height: 75),
              
              ],
            ),
          ),
        ),
      );
    
  }
    Widget floatingActionButton ({required BuildContext context}) { 

      return FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () { 
          Utils().getTicketScreenShot( ticketModel: ticket,context: context); 
        },
        child: const Icon(Icons.share,color: Colors.white),
      );
    }
}
