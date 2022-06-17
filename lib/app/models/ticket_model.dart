import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String id = '';
  String payMode = 'efective';
  double priceTotal = 0.0;
  double valueReceived = 0.0;
  List<dynamic> listPoduct = [];
  late Timestamp creation; // Marca de tiempo ( hora en que se reporto el producto )

  TicketModel({
    this.id = "",
    this.payMode = "",
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "payMode": payMode,
        "priceTotal": priceTotal,
        "valueReceived": valueReceived,
        "listPoduct": listPoduct,
        "creation": creation,
      };
  factory TicketModel.fromMap(Map<String, dynamic> data) {
    return TicketModel(
      id: data['id'] ?? '',
      payMode: data['payMode'] ?? '',
      priceTotal: data['priceTotal'] ?? 0.0,
      valueReceived: data['valueReceived'] ?? 0.0,
      listPoduct: data['listPoduct'] ?? [],
      creation: data['creation'],
    );
  }
  TicketModel.fromDocumentSnapshot(
      {required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    payMode = data['payMode'] ?? '';
    priceTotal = data['priceTotal'];
    listPoduct = data['listPoduct'];
    creation = data['creation'];
  }
}
