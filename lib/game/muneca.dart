enum EstadoMuneca { feliz, triste }

class Muneca {
  EstadoMuneca estado = EstadoMuneca.feliz;
  int segundosRestantes = 5;

  String imagenActual() {
    return estado == EstadoMuneca.feliz
        ? 'assets/cara_feliz.png'
        : 'assets/cara_triste.png';
  }

  void reiniciarCuentaRegresiva() {
    segundosRestantes = 5;
  }

  void decrementarTiempo() {
    if (segundosRestantes > 0) {
      segundosRestantes--;
    }
  }

  bool tiempoTerminado() {
    return segundosRestantes == 0;
  }
}
