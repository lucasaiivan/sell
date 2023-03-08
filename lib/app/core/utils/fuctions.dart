import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Publications {


  static String generateUid() => DateFormat('ddMMyyyyHHmmss').format(Timestamp.now().toDate()).toString();
  // obtiene un double y devuelve un monto formateado
  static String getFormatoPrecio({String moneda = "\$", required double monto}) {
    int decimalDigits = (monto % 1) == 0 ? 0 : 2;

    var formatter = NumberFormat.currency(
      locale: 'es_AR',
      name: moneda,
      customPattern: monto >= 0 ? '\u00a4###,###,##0.0' : '-\u00a4###,###,##0.0',
      decimalDigits: decimalDigits,
    );

    return formatter.format(monto.abs());
  }


  static String getFormatAmount({required int value}){
    String price = value.toString();
    String priceInText ='';
    int counter = 0;
    for(int i = (price.length - 1);  i >= 0; i--){
        counter++;
        String str = price[i];
        if((counter % 3) != 0 && i !=0){
          priceInText = "$str$priceInText";
        }else if(i == 0 ){
          priceInText = "$str$priceInText";
        
        }else{
          priceInText = ".$str$priceInText";
        }
    }
    return priceInText.trim();
  }

  // Recibe la fecha y la decha actual para devolver hace cuanto tiempo se publico
  static String getFechaPublicacionFormating({required DateTime dateTime}) => DateFormat('dd/MM/yyyy HH:mm').format(dateTime).toString();
  static String getFechaPublicacion(
      DateTime fechaPublicacion, DateTime fechaActual) {
    String sFecha = "";

    var diffDt = fechaActual.difference(fechaPublicacion);

    // Calcular tiempos (Feacha de pubicación)
    var diff_Munutos = diffDt.inMinutes;
    var diff_Horas = diffDt.inHours;
    var diff_Dias = diffDt.inDays;

    if (diff_Dias == 0) {
      if (diff_Horas > 0) {
        // si la publicacion tiene menos de 24 horas
        if (diff_Horas == 1) {
          sFecha = "Hace " + diff_Horas.toString() + " " + "hora";
        } else {
          sFecha = "Hace " + diff_Horas.toString() + " horas";
        }
      } else if (
          // si la publicacion tiene más de 24 horas
          diff_Munutos != 0) {
        if (diff_Munutos == 1) {
          sFecha = "Hace " + diff_Munutos.toString() + " minutos";
        } else if (diff_Munutos > 1) {
          sFecha = "Hace " + diff_Munutos.toString() + " minutos";
        }
      } else {
        sFecha = "Hace instantes";
      }
    } else if (diff_Dias == 1) {
      sFecha = "Ayer";
    } else if (diff_Dias == 2) {
      sFecha = "Ante ayer";
    } else if (diff_Dias == 3) {
      sFecha = "Hace 3 días";
    } else if (diff_Dias == 4) {
      sFecha = "Hace 4 días";
    } else if (diff_Dias == 5) {
      sFecha = "Hace 5 días";
    } else if (diff_Dias >= 7 && diff_Dias <= 12) {
      sFecha = "Hace una semana";
    } else if (diff_Dias >= 30 && diff_Dias <= 50) {
      sFecha = "Hace un mes";
    } else if (diff_Dias >= 60 && diff_Dias <= 80) {
      sFecha = "Hace dos meses";
    } else if (diff_Dias >= 80 && diff_Dias <= 100) {
      sFecha = "Hace tres meses";
    } else if (diff_Dias >= 100 && diff_Dias <= 120) {
      sFecha = "Hace cuatro meses";
    } else if (diff_Dias >= 365 && diff_Dias <= 600) {
      sFecha = "Hace cuatro meses";
    } else {
      // si la publicación tiene más de 5 dias
      return DateFormat('dd MMM.  yyyy').format(fechaPublicacion);
    }

    return sFecha;
  }

  static String sGanancia(
      {required double precioCompra, required double precioVenta}) {
    double ganancia = 0.0;
    if (precioCompra != 0.0) {
      ganancia = precioVenta - precioCompra;
    }
    return Publications.getFormatoPrecio(monto: ganancia);
  }
}
class Utils {
  // Devuelve un color Random
  static MaterialColor getRandomColor() {
    List<MaterialColor> lista_color = [
      Colors.amber,
      Colors.blue,
      Colors.blueGrey,
      Colors.brown,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.green,
      Colors.grey,
      Colors.indigo,
      Colors.red,
      Colors.lime,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.teal,
      Colors.yellow,
      Colors.deepPurple,
    ];

    return lista_color[Random().nextInt(lista_color.length)];
  }

  String capitalize(String input) {
  if (input.isEmpty) {
    return input;
  }
  final words = input.split(' ');
  final capitalizedWords = words.map((word) {
    if (word.length > 1) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    } else {
      return word.toUpperCase();
    }
  });
  return capitalizedWords.join(' ');
}



}
