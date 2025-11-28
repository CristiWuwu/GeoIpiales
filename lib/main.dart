import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Map<String, CategoriaInfo> categorias = {
    'Restaurantes': CategoriaInfo(
      lugares: [
        {'Mr Pollo': LatLng(0.833590, -77.640241)},
        {'Broaster King': LatLng(0.823871, -77.637798)},
        {'Press Burguer': LatLng(0.824429, -77.638294)},
        {'La Merced': LatLng(0.830310, -77.633962)},
      ],
      color: const Color(0xFF00FF1E),
    ),
    'Parques': CategoriaInfo(
      lugares: [
        {'Parque 20 de Julio': LatLng(0.823756, -77.634925)},
        {'Parque Santander': LatLng(0.828843, -77.642462)},
        {'Parque San Felipe': LatLng(0.825673, -77.639018)},
      ],
      color: const Color(0xFFF527F2),
    ),
    'Plazas': CategoriaInfo(
      lugares: [
        {'Gran plaza': LatLng(0.830195, -77.649747)},
        {'Plaza de Mercado': LatLng(0.824764, -77.627040)},
        {'Terminal De Ipiales': LatLng(0.826902, -77.631412)},
      ],
      color: const Color(0xFF7D27F5),
    ),
    'Otros': CategoriaInfo(
      lugares: [
        {'Hospital civil de Ipiales': LatLng(0.828146, -77.614009)},
        {'Universidad de Nariño': LatLng(0.822611, -77.625280)},
        {'Santuario De las Lajas': LatLng(0.80695, -77.58425)},
        {'Hotel San Jose': LatLng(0.827395, -77.632377)},
      ],
      color: const Color(0xFFFF0000),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoIpiales',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: HomePage(categorias: categorias),
      debugShowCheckedModeBanner: false,
    );
  }
}
