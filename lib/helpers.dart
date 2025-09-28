import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng?> obtenerUbicacionActual() async {
  LocationPermission permiso = await Geolocator.checkPermission();

  if (permiso == LocationPermission.denied ||
      permiso == LocationPermission.deniedForever) {
    permiso = await Geolocator.requestPermission();
    if (permiso != LocationPermission.always &&
        permiso != LocationPermission.whileInUse) {
      return null; // El usuario no otorgó permisos suficientes
    }
  }

  try {
    final posicion = await Geolocator.getCurrentPosition();
    return LatLng(posicion.latitude, posicion.longitude);
  } catch (e) {
    return null; // Error al obtener ubicación
  }
}
