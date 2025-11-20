import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<LatLng>> obtenerRutaOSRM(LatLng origen, LatLng destino) async {
  final url =
      'https://router.project-osrm.org/route/v1/driving/${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}?overview=full&geometries=geojson';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final coords = data['routes'][0]['geometry']['coordinates'] as List;
    return coords
        .map((c) => LatLng(c[1], c[0]))
        .toList(); // lat, lon invertidos
  } else {
    return [origen, destino]; // fallback: línea recta
  }
}
