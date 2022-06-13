
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String id = ''; 
  String payMode = '';
  late Timestamp time; // Marca de tiempo ( hora en que se reporto el producto )

  TicketModel({
    this.id = "",
    this.payMode= "",
    required this.time,
  });
  Map<String, dynamic> toJson() => {
        "id": id,
        "payMode": payMode,
        "time": time,
      };
  factory TicketModel.fromMap(Map<String, dynamic> data) {
    return TicketModel(
      id: data['id'] ?? '',
      payMode: data['payMode'] ?? '',
      time: data['time'],
    );
  }
  TicketModel.fromDocumentSnapshot(
      {required DocumentSnapshot documentSnapshot}) {
    Map data = documentSnapshot.data() as Map;

    id = data['id'] ?? '';
    payMode = data['payMode'] ?? '';
    time = data['time'];
  }
}