import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String id = '';
  String payMode = '';
  double priceTotal = 0.0;
  double valueReceived = 0.0;
  List<dynamic> listPoduct = [];
  late Timestamp time; // Marca de tiempo ( hora en que se reporto el producto )

  TicketModel({
    this.id = "",
    this.payMode = "",
    this.priceTotal = 0.0,
    this.valueReceived = 0.0,
    required this.listPoduct ,
    required this.time,
  });
  Map<String, dynamic> toJson() => {
        "id": id,
        "payMode": payMode,
        "priceTotal": priceTotal,
        "valueReceived": valueReceived,
        "listPoduct": listPoduct,
        "time": time,
      };
  factory TicketModel.fromMap(Map<String, dynamic> data) {
    return TicketModel(
      id: data['id'] ?? '',
      payMode: data['payMode'] ?? '',
      priceTotal: data['priceTotal'] ?? 0.0,
      valueReceived: data['valueReceived'] ??0.0,
      listPoduct: data['listPoduct'] ?? [],
      time: data['time'],
    );
  }
  TicketModel.fromDocumentSnapshot(
      {required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    payMode = data['payMode'] ?? '';
    time = data['time'];
    priceTotal = data['priceTotal'];
    listPoduct = data['listPoduct'];
    time = data['time'];
  }
}
