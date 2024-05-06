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
    final formatCurrency = NumberFormat('#,##0', 'es_ES');
    /// Formatea un número entero a una cadena de texto con abreviaturas 'K' y 'M'.
    ///
    /// Si el número es menor que 10,000, se devuelve como está.
    /// Si el número es 10,000 o más, pero menos que 1,000,000, se divide por 1,000 y se agrega 'K' al final.
    /// Si el número es 1,000,000 o más, se divide por 1,000,000 y se agrega 'M' al final.
    ///
    /// [value] es el número entero que se va a formatear.
    /// 
    if (value < 10000) {
      // Si el número es menor que 10000, simplemente devuélvelo como una cadena.
      return formatCurrency.format(value);
    } else if (value < 1000000) {
      // Si el número es 10000 o más, pero menos que 1000000, divídelo por 1000 y agrega 'K' al final.
      return '${formatCurrency.format(value / 1000)}K';
    } else {
      // Si el número es 1000000 o más, divídelo por 1000000 y agrega 'M' al final.
      return '${formatCurrency.format(value / 1000000)}M';
    }
  }

  // Recibe la fecha y la decha actual para devolver hace cuanto tiempo se publico
  static String getFechaPublicacionFormating({required DateTime dateTime}) => DateFormat('dd/MM/yyyy HH:mm','es').format(dateTime).toString();
  static String getFechaPublicacionSimple(DateTime postDate, DateTime currentDate) {
  /** 
    Obtiene la fecha de publicación en formato legible para el usuario.
    @param postDate La fecha de publicación del contenido.
    @param currentDate La fecha actual del sistema.
    @return La fecha en formato legible para el usuario.
  */
  if (postDate.year != currentDate.year) {
    // Si la publicación es de un año diferente, muestra la fecha completa
    return DateFormat('dd MMM. yyyy','es').format(postDate);
  } else if (postDate.month != currentDate.month || postDate.day != currentDate.day) {
    // Si la publicación no es del mismo día de hoy
    if (postDate.year == currentDate.year &&
        postDate.month == currentDate.month &&
        postDate.day == currentDate.day - 1) {
      // Si la publicación es del día anterior, muestra "Ayer"
      return 'Ayer';
    } else {
      // Si la publicación no es del día anterior, muestra la fecha sin el año
      return DateFormat('dd MMM.','es').format(postDate);
    }
  } else {
    // Si la publicación es del mismo día de hoy, muestra "Hoy"
    return 'Hoy';
  }
} 
  static String getFechaPublicacion({required DateTime fechaPublicacion, required DateTime fechaActual}) {
  /** 
    Obtiene la fecha de publicación en formato legible para el usuario.
    @param fechaPublicacion La fecha de publicación del contenido.
    @param fechaActual La fecha actual del sistema.
    @return La fecha en formato legible para el usuario.
  */ 
 

  // condition : si el año de la publicacion es diferente al año actual
  if (fechaPublicacion.year != fechaActual.year) {
    // Si la publicación es de un año diferente, muestra la fecha completa
    return DateFormat('dd MMM. yyyy','es').format(fechaPublicacion);
  } else if (fechaPublicacion.month != fechaActual.month || fechaPublicacion.day != fechaActual.day) {
    // Si la publicación no es del mismo día de hoy
    if (fechaPublicacion.year == fechaActual.year &&
        fechaPublicacion.month == fechaActual.month &&
        fechaPublicacion.day == fechaActual.day - 1) {
      // Si la publicación es del día anterior, muestra "Ayer"
      return 'Ayer ${DateFormat('HH:mm','es').format(fechaPublicacion)}';
    }else {
      // Si la publicación no es del día anterior, muestra la fecha sin el año
      return DateFormat('dd MMM.','es').format(fechaPublicacion);
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
