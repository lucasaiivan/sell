import 'package:cloud_firestore/cloud_firestore.dart'; 

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
      id: data['id'] ?? '',
      payMode: data['payMode'] ?? '',
      seller: data['seller'] ?? '',
      currencySymbol: data['currencySymbol'] ?? '\$',
      cashRegisterName: data['cashRegisterName'] ?? '',
      cashRegisterId: data['cashRegisterId'] ?? '',
      priceTotal: (data['priceTotal'] ?? 0).toDouble(),
      valueReceived: (data['valueReceived'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      listPoduct: data['listPoduct'] ?? [],
      creation: data['creation'],
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
}
