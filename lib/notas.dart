import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui.dart';

class Nota {
  String contenido;
  DateTime fecha;
  bool editando;
  List<String> imagenes;

  Nota({
    required this.contenido,
    required this.fecha,
    this.editando = false,
    this.imagenes = const [],
  });

  Map<String, dynamic> toJson() => {
    'contenido': contenido,
    'fecha': fecha.toIso8601String(),
    'editando': editando,
    'imagenes': imagenes,
  };

  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
    contenido: json['contenido'],
    fecha: DateTime.parse(json['fecha']),
    editando: json['editando'] ?? false,
    imagenes: List<String>.from(json['imagenes'] ?? []),
  );
}

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final List<Nota> notas = [];
  final TextEditingController nuevaNotaController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cargarNotas();
  }

  Future<void> cargarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('notas_guardadas');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      setState(() {
        notas.clear();
        notas.addAll(decoded.map((e) => Nota.fromJson(e)).toList());
      });
    }
  }

  Future<void> guardarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(notas.map((n) => n.toJson()).toList());
    await prefs.setString('notas_guardadas', jsonString);
  }

  void agregarNota() {
    final texto = nuevaNotaController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        notas.add(Nota(contenido: texto, fecha: DateTime.now()));
        nuevaNotaController.clear();
      });
      guardarNotas();
    }
  }

  void eliminarNota(int index) {
    setState(() {
      notas.removeAt(index);
    });
    guardarNotas();
  }

  void editarNota(int index) {
    setState(() {
      notas[index].editando = true;
    });
  }

  void guardarEdicion(int index, String nuevoTexto) {
    setState(() {
      notas[index].contenido = nuevoTexto;
      notas[index].editando = false;
    });
    guardarNotas();
  }

  void mostrarOpcionesImagen(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tomar foto'),
            onTap: () {
              Navigator.pop(context);
              agregarImagen(index, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Elegir de galería'),
            onTap: () {
              Navigator.pop(context);
              agregarImagen(index, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> agregarImagen(int index, ImageSource source) async {
    final XFile? imagen = await picker.pickImage(source: source);
    if (imagen != null) {
      final dir = await getApplicationDocumentsDirectory();
      final nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}.png';
      final nuevaRuta = '${dir.path}/$nombreArchivo';
      await File(imagen.path).copy(nuevaRuta);

      setState(() {
        notas[index].imagenes = [...notas[index].imagenes, nuevaRuta];
      });
      guardarNotas();
    }
  }

  void eliminarImagen(int notaIndex, int imagenIndex) {
    final ruta = notas[notaIndex].imagenes[imagenIndex];
    File(ruta).delete();
    setState(() {
      notas[notaIndex].imagenes.removeAt(imagenIndex);
    });
    guardarNotas();
  }

  void mostrarImagen(
    BuildContext context,
    String ruta,
    int notaIndex,
    int imagenIndex,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(File(ruta)),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context);
                eliminarImagen(notaIndex, imagenIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF15EAFF),
        title: Row(
          children: [
            Image.asset('assets/notas.png', height: 30, width: 30),
            const SizedBox(width: 12),
            Stack(
              children: [
                Text(
                  'Notas',
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
                  'Notas',
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Agrega una nueva nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nuevaNotaController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Escribe algo...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: agregarNota,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar nota'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notas.length,
                  itemBuilder: (context, index) {
                    final nota = notas[index];
                    final controller = TextEditingController(
                      text: nota.contenido,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nota.editando
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: controller,
                                      autofocus: true,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        hintText: 'Edita tu nota...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => guardarEdicion(
                                        index,
                                        controller.text.trim(),
                                      ),
                                      icon: const Icon(Icons.save),
                                      label: const Text('Guardar cambios'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nota.contenido,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Creada: ${formatearFecha(nota.fecha)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: List.generate(
                                        nota.imagenes.length,
                                        (imgIndex) => GestureDetector(
                                          onTap: () => mostrarImagen(
                                            context,
                                            nota.imagenes[imgIndex],
                                            index,
                                            imgIndex,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(nota.imagenes[imgIndex]),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => editarNota(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => eliminarNota(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.orange,
                                ),
                                onPressed: () => mostrarOpcionesImagen(index),
                              ),
                            ],
                          ),
                        ],
                      ),
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
