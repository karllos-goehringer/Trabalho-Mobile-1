import 'package:hive/hive.dart';
import 'dart:typed_data';
part 'NotaClass.g.dart';

@HiveType(typeId: 1)
class Nota {
  Nota({
    required this.titulo,
    required this.texto,
    required this.momentoCadastro,
    this.imageBytes,
  });
  @HiveField(0)
  String titulo;
  @HiveField(1)
  String texto;
  @HiveField(2)
  String momentoCadastro;
  @HiveField(3)
  Uint8List? imageBytes;
}
