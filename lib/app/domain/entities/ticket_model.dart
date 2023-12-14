import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart'; 

class TicketModel {
  String id = '';
  String seller = ''; // nombre del vendedor
  String cashRegisterName = '1'; // nombre o numero de caja que se efectuo la venta
  String cashRegisterId = ''; // id de la caja que se efectuo la venta
  String payMode = ''; // efective (Efectivo) - mercadopago (Mercado Pago) - card (Tarjeta De Crédito/Débito)
  double priceTotal = 0.0; // precio total de la venta
  double valueReceived = 0.0;
  double discount = 0.0;
  String currencySymbol = '\$';
  List<dynamic> listPoduct= [];
  late Timestamp creation; // Marca de tiempo ( hora en que se reporto el producto )

  TicketModel({
    this.id = "",
    this.payMode = "",
    this.currencySymbol = "\$",
    this.seller = "",
    this.cashRegisterName = "",
    this.cashRegisterId = "",
    this.priceTotal = 0.0,
    this.valueReceived = 0.0,
    this.discount = 0.0,
    required this.listPoduct,
    required this.creation,
  });
  int getLengh() {
    int count = 0;
    for (var element in listPoduct) {
      count += element['quantity'] as int;
    }
    return count;
  }

  // format : formateo de texto 
  String get  getNamePayMode{
    if(payMode == 'effective') return 'Efectivo';
    if(payMode == 'mercadopago') return 'Mercado Pago';
    if(payMode == 'card') return 'Tarjeta De Crédito/Débito';
    return 'Sin Especificar';
  }
  static String getFormatPayMode({required String id}){
    if(id == 'effective') return 'Efectivo';
    if(id == 'mercadopago') return 'Mercado Pago';
    if(id == 'card') return 'Tarjeta De Crédito/Débito';
    return 'Sin Especificar';
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "payMode": payMode,
        "currencySymbol": currencySymbol,
        "seller": seller,
        "cashRegisterName": cashRegisterName,
        'cashRegisterId' : cashRegisterId,
        "priceTotal": priceTotal,
        "valueReceived": valueReceived,
        "discount": discount,
        "listPoduct": listPoduct,
        "creation": creation,
      };
  factory TicketModel.fromMap(Map<dynamic, dynamic> data) {
    return TicketModel(
      id: data.containsKey('id') ? data['id'] : '',
      payMode: data.containsKey('payMode') ? data['payMode'] : '',
      seller: data.containsKey('seller') ? data['seller'] : '',
      currencySymbol: data.containsKey('currencySymbol') ? data['currencySymbol'] : '\$',
      cashRegisterName: data.containsKey('cashRegisterName') ? data['cashRegisterName'] : '',
      cashRegisterId: data.containsKey('cashRegisterId') ? data['cashRegisterId'] : '',
      priceTotal: data.containsKey('priceTotal') ? (data['priceTotal'] ?? 0).toDouble() : 0.0,
      valueReceived:  data.containsKey('valueReceived') ? (data['valueReceived'] ?? 0).toDouble() : 0.0,
      discount: data.containsKey('discount') ? (data['discount'] ?? 0).toDouble() : 0.0,
      listPoduct: data.containsKey('listPoduct') ? data['listPoduct'] : [],
      creation: data.containsKey('creation') ? data['creation'] : Timestamp.now(),
    );
  }
  TicketModel.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    payMode = data['payMode'] ?? '';
    seller = data['seller'] ?? '';
    currencySymbol = data['currencySymbol'] ?? '\$';
    cashRegisterName = data['cashRegister'] ?? '';
    cashRegisterId = data['cashRegisterId'] ?? '';
    priceTotal = data['priceTotal'];
    valueReceived = data['valueReceived'];
    discount = data['discount'];
    listPoduct = data['listPoduct'] ??[];
    creation = data['creation'];
  }

  // get : obtenemos el porcentaje de ganancia de la venta del ticket
  int get getPercentageProfit {
    // se obtiene el total de la venta de los productos sin descuento 
    double total = 0.0;
    for (var element in listPoduct) {
      // obtenemos el objeto del producto
      ProductCatalogue product = ProductCatalogue.fromMap(element); 
      // condition : si el producto tiene un valor de compra y venta se calcula la ganancia
      if(product.purchasePrice != 0 ){ 
        total += (product.salePrice - product.purchasePrice) * product.quantity;
      }
    }
    // si existe un descuento se resta al total de la ganancia
    if(discount != 0) total = total - discount;
    // se calcula el porcentaje de ganancia 
    double percentage = (total * 100) / getTotalPrice;
    return percentage.toInt();
  }

  // double : obtenemos las ganancias de la venta del ticket
  double get getProfit {
    // se obtiene el total de la venta de los productos sin descuento 
    double total = 0.0;
    for (var element in listPoduct) {
      // obtenemos el objeto del producto
      ProductCatalogue product = ProductCatalogue.fromMap(element); 
      // condition : si el producto tiene un valor de compra y venta se calcula la ganancia
      if(product.purchasePrice != 0 ){ 
        total += (product.salePrice - product.purchasePrice) * product.quantity;
      }
    }
    return total - discount;
  }
  // get : obtiene el monto total del ticket sin descuento aplicados
  double get getTotalPriceWithoutDiscount {
    // se obtiene el total de la venta de los productos sin descuento 
    double total = 0.0;
    for (var element in listPoduct) {
      ProductCatalogue product = ProductCatalogue.fromMap(element);
      total += product.salePrice * product.quantity;
    }
    // si existe un descuento se resta al total de la ganancia
    if(discount != 0) total = total - discount;
    return total;
  }

  // get : obtiene el monto total del ticket con descuento aplicados
  double get getTotalPrice {
    // se obtiene el total de la venta de los productos con todos los descuentos aplicados al ticket
    double total = 0.0;
    for (var element in listPoduct) {
      ProductCatalogue product = ProductCatalogue.fromMap(element);
      int qauntity = product.quantity;
      double salePrice = product.salePrice;
      total += salePrice * qauntity;
    }
    return total - discount;
  }

  // 
  // Fuctions
  //


  // void : incrementa el producto seleccionado del ticket
  void incrementProduct({required ProductCatalogue product}) {
    // se verifica la coincidencia del producto en la lista de productos del ticket
    for (var i = 0; i < listPoduct.length; i++) { 
      if (listPoduct[i]['id'] == product.id) {
        listPoduct[i]['quantity'] ++;
        return;
      }
    }
  }
  // void : decrementa el producto seleccionado del ticket
  void decrementProduct({required ProductCatalogue product}) {
    // se verifica la coincidencia del producto en la lista de productos del ticket
    for (var i = 0; i < listPoduct.length; i++) { 
      if (listPoduct[i]['id'] == product.id) {
        // condition : si la cantidad del producto es mayor a 1 se decrementa
        if(listPoduct[i]['quantity'] > 1){
          listPoduct[i]['quantity']=listPoduct[i]['quantity']-1;
        }
        return;
      }
    }
  }
  // void : elimina el producto seleccionado del ticket
  void removeProduct({required ProductCatalogue product}) {
    // se verifica la coincidencia del producto en la lista de productos del ticket
    for (var i = 0; i < listPoduct.length; i++) { 
      if (listPoduct[i]['id'] == product.id) {
        listPoduct.removeAt(i);
        return;
      }
    }
  }
  // void : agrega un producto al ticket
  void addProduct({required ProductCatalogue product}) {
    // se verifica si el producto ya esta en el ticket
    bool exist = false;
    for (var i = 0; i < listPoduct.length; i++) { 
      if (listPoduct[i]['id'] == product.id) {
        listPoduct[i]['quantity'] ++;
        exist = true;
        break; 
      }
    }
    // si el producto no esta en el ticket se agrega
    if(!exist){
      listPoduct.add(product.toJson());
    }
  }


}
