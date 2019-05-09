import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uol_companion/models/WeatherData.dart';
class Weather extends StatelessWidget {
  final WeatherData weather;

  Weather({Key key, @required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
        children: <Widget>[
          Text(weather.name, style: new TextStyle(color: Colors.white)),
          Text(weather.main,
            style: new TextStyle(color: Colors.white, fontSize: 32.0)),
          Text('${weather.temp.toString()}°C',
            style: new TextStyle(color: Colors.white)),
          Image.network('https://openweathermap.org/img/w/${weather.icon}.png'),
          Text(new DateFormat.yMMMd().format(weather.date),
            style: new TextStyle(color: Colors.white)),
          Text(new DateFormat.Hm().format(weather.date),
            style: new TextStyle(color: Colors.white)),
      ],
      )
    )
    );
  }
}