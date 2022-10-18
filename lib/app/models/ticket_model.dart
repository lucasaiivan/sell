import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String id = '';
  String seller = ''; // nombre del vendedor
  String cashRegister = ''; // nombre o numero de caja que se efectuo la venta
  String payMode = 'effective'; // efective (Efectivo) - mercadopago (Mercado Pago) - card (Tarjeta De Crédito/Débito)
  double priceTotal = 0.0;
  double valueReceived = 0.0;
  List<dynamic> listPoduct = [];
  late Timestamp
      creation; // Marca de tiempo ( hora en que se reporto el producto )

  TicketModel({
    this.id = "",
    this.payMode = "",
    this.seller = "",
    this.cashRegister = "",
    this.priceTotal = 0.0,
    this.valueReceived = 0.0,
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
  String get getPayMode{
    if(payMode == 'effective') return 'Efectivo';
    if(payMode == 'mercadopago') return 'Mercado Pago';
    if(payMode == 'card') return 'Tarjeta De Crédito/Débito';
    return 'Sin Especificar';
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "payMode": payMode,
        "seller": seller,
        "cashRegister": cashRegister,
        "priceTotal": priceTotal,
        "valueReceived": valueReceived,
        "listPoduct": listPoduct,
        "creation": creation,
      };
  factory TicketModel.fromMap(Map<String, dynamic> data) {
    return TicketModel(
      id: data['id'] ?? '',
      payMode: data['payMode'] ?? '',
      seller: data['seller'] ?? '',
      cashRegister: data['cashRegister'] ?? '',
      priceTotal: data['priceTotal'] ?? 0.0,
      valueReceived: data['valueReceived'] ?? 0.0,
      listPoduct: data['listPoduct'] ?? [],
      creation: data['creation'],
    );
  }
  TicketModel.fromDocumentSnapshot({required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    payMode = data['payMode'] ?? '';
    seller = data['seller'] ?? '';
    cashRegister = data['cashRegister'] ?? '';
    priceTotal = data['priceTotal'];
    listPoduct = data['listPoduct'];
    creation = data['creation'];
  }
}
