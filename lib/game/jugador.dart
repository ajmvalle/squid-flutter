import 'dart:math';

class Jugador {
  final int id;
  double posicion;
  bool enMeta = false;

  Jugador({required this.id}) : posicion = 0;

  void avanzar() {
    if (!enMeta) {
      final pasos = 8 + Random().nextInt(8); // entre 8 y 15 pasos
      posicion += pasos;
      if (posicion >= 500) {
        posicion = 500;
        enMeta = true;
      }
    }
  }
}
