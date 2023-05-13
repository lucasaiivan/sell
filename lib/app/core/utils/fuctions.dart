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
  static String getFechaPublicacionSimple(DateTime postDate, DateTime currentDate) {
  /** 
    Obtiene la fecha de publicación en formato legible para el usuario.
    @param postDate La fecha de publicación del contenido.
    @param currentDate La fecha actual del sistema.
    @return La fecha en formato legible para el usuario.
  */
  if (postDate.year != currentDate.year) {
    // Si la publicación es de un año diferente, muestra la fecha completa
    return DateFormat('dd MMM. yyyy').format(postDate);
  } else if (postDate.month != currentDate.month || postDate.day != currentDate.day) {
    // Si la publicación no es del mismo día de hoy
    if (postDate.year == currentDate.year &&
        postDate.month == currentDate.month &&
        postDate.day == currentDate.day - 1) {
      // Si la publicación es del día anterior, muestra "Ayer"
      return 'Ayer';
    } else {
      // Si la publicación no es del día anterior, muestra la fecha sin el año
      return DateFormat('dd MMM.').format(postDate);
    }
  } else {
    // Si la publicación es del mismo día de hoy, muestra "Hoy"
    return 'Hoy';
  }
} 
static String getFechaPublicacion(DateTime fechaPublicacion, DateTime fechaActual) {
  /** 
    Obtiene la fecha de publicación en formato legible para el usuario.
    @param fechaPublicacion La fecha de publicación del contenido.
    @param fechaActual La fecha actual del sistema.
    @return La fecha en formato legible para el usuario.
  */
  if (fechaPublicacion.year != fechaActual.year) {
    // Si la publicación es de un año diferente, muestra la fecha completa
    return DateFormat('dd MMM. yyyy HH:mm').format(fechaPublicacion);
  } else if (fechaPublicacion.month != fechaActual.month || fechaPublicacion.day != fechaActual.day) {
    // Si la publicación no es del mismo día de hoy
    if (fechaPublicacion.year == fechaActual.year &&
        fechaPublicacion.month == fechaActual.month &&
        fechaPublicacion.day == fechaActual.day - 1) {
      // Si la publicación es del día anterior, muestra "Ayer"
      return 'Ayer ${DateFormat('HH:mm').format(fechaPublicacion)}';
    }else {
      // Si la publicación no es del día anterior, muestra la fecha sin el año
      return DateFormat('dd MMM. HH:mm').format(fechaPublicacion);
    }
  } else {
    // Si la publicación es del mismo día de hoy
    Duration difference = fechaActual.difference(fechaPublicacion);
    if (difference.inMinutes < 30) {
      // Si la publicación fue hace menos de 30 minutos, muestra "Hace instantes"
      return 'Hace instantes';
    } else if (difference.inMinutes < 60) {
      // Si la publicación fue hace menos de una hora, muestra los minutos
      return 'Hace ${difference.inMinutes} min.';
    } else if (difference.inHours < 8) {
      // Si la publicación fue hace menos de 8 horas, muestra las horas
      return 'Hace ${difference.inHours} horas';
    } else {
      // Si la publicación fue hace 8 horas o más, muestra "Hoy"
      return 'Hoy';
    }
  }
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
    List<MaterialColor> listaColor = [
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

    return listaColor[Random().nextInt(listaColor.length)];
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
