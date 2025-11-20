import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ui.dart';
import 'helpers.dart';
import 'servicio_rutas.dart'; // nuevo import

class PlazasPage extends StatelessWidget {
  final CategoriaInfo info;

  const PlazasPage({super.key, required this.info});

  final Map<String, String> descripciones = const {
    'Gran plaza':
        'Espacio amplio para eventos, comercio y encuentro ciudadano.',
    'Plaza de Mercado': 'Centro tradicional de abastecimiento y cultura local.',
  };

  final Map<String, String> imagenes = const {
    'Gran plaza': 'assets/granplaza.jpg',
    'Plaza de Mercado': 'assets/plazamercado.jpg',
  };

  void navegarConRuta(
    BuildContext context,
    String nombre,
    LatLng destino,
    Color color,
  ) async {
    final origen = await obtenerUbicacionActual();
    if (origen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo obtener tu ubicación. Verifica permisos y conexión.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final puntosRuta = await obtenerRutaOSRM(origen, destino);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaRuta(
          nombre: nombre,
          origen: origen,
          destino: destino,
          color: color,
          puntosRuta: puntosRuta,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: info.color,
        title: Row(
          children: [
            Image.asset('assets/plazas.png', height: 30, width: 30),
            const SizedBox(width: 12),
            Stack(
              children: [
                Text(
                  'Plazas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.black,
                  ),
                ),
                const Text(
                  'Plazas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/fondo.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const EncabezadoInstitucional(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: info.lugares.length,
                  itemBuilder: (context, index) {
                    final nombre = info.lugares[index].keys.first;
                    final coordenadas = info.lugares[index][nombre]!;
                    final descripcion =
                        descripciones[nombre] ?? 'Sin descripción disponible.';
                    final imagen = imagenes[nombre] ?? 'assets/plazas.png';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: info.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size.fromHeight(50),
                            elevation: 6,
                          ),
                          onPressed: () => navegarConRuta(
                            context,
                            nombre,
                            coordenadas,
                            info.color,
                          ),
                          child: Stack(
                            children: [
                              Text(
                                nombre,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.5
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagen,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            border: Border.all(color: info.color, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            descripcion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapaRuta extends StatelessWidget {
  final String nombre;
  final LatLng origen;
  final LatLng destino;
  final Color color;
  final List<LatLng> puntosRuta;

  const MapaRuta({
    super.key,
    required this.nombre,
    required this.origen,
    required this.destino,
    required this.color,
    required this.puntosRuta,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Stack(
          children: [
            Text(
              nombre,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: destino, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.geo',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: origen,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              Marker(
                point: destino,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(points: puntosRuta, strokeWidth: 4, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}
