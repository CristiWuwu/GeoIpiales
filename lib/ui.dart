import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'restaurantes.dart';
import 'parques.dart';
import 'plazas.dart';
import 'otros.dart';

class CategoriaInfo {
  final List<Map<String, LatLng>> lugares;
  final Color color;

  const CategoriaInfo({required this.lugares, required this.color});
}

class HomePage extends StatelessWidget {
  final Map<String, CategoriaInfo> categorias;

  const HomePage({super.key, required this.categorias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo institucional explícito
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Image.asset('assets/logo.jpg', height: 40),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const EncabezadoInstitucional(),
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/interes.jpg',
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: categorias.entries.map((entry) {
                  final nombre = entry.key;
                  final info = entry.value;

                  Widget destino;
                  switch (nombre) {
                    case 'Restaurantes':
                      destino = RestaurantesPage(info: info);
                      break;
                    case 'Parques':
                      destino = ParquesPage(info: info);
                      break;
                    case 'Plazas':
                      destino = PlazasPage(info: info);
                      break;
                    case 'Otros':
                      destino = OtrosPage(info: info);
                      break;
                    default:
                      destino = Scaffold();
                  }

                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => destino),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: info.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/${nombre.toLowerCase()}.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Text(
                              nombre,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EncabezadoInstitucional extends StatelessWidget {
  const EncabezadoInstitucional({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Perfil(nombre: 'Cristian', imagen: 'assets/Cristian.jpg'),
          Perfil(nombre: 'Milena', imagen: 'assets/Milena.jpg'),
          Perfil(nombre: 'Javier', imagen: 'assets/Javier.jpg'),
        ],
      ),
    );
  }
}

class Perfil extends StatelessWidget {
  final String nombre;
  final String imagen;

  const Perfil({super.key, required this.nombre, required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 20, backgroundImage: AssetImage(imagen)),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
