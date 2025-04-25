import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'jugador.dart';
import 'muneca.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<Jugador> jugadores = List.generate(4, (index) => Jugador(id: index));
  Muneca muneca = Muneca();
  bool luzVerde = true;
  bool juegoIniciado = false;
  Timer? contadorTimer;
  Timer? avanceTimer;
  DateTime? ultimaEliminacion;
  String mensaje = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  void iniciarTurno() {
    setState(() {
      luzVerde = true;
      muneca.estado = EstadoMuneca.feliz;
      muneca.reiniciarCuentaRegresiva();
      mensaje = '¡Corre!';
    });

    _audioPlayer.play(AssetSource('squid-game.mp3'));

    contadorTimer?.cancel();
    contadorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        muneca.decrementarTiempo();
        if (muneca.tiempoTerminado()) {
          timer.cancel();
          iniciarFaseTriste();
        }
      });
    });
  }

  void iniciarFaseTriste() {
    setState(() {
      mensaje = '¡DETENTE!';
      luzVerde = false;
      muneca.estado = EstadoMuneca.triste;
      muneca.reiniciarCuentaRegresiva();
    });

    contadorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        muneca.decrementarTiempo();
        if (muneca.tiempoTerminado()) {
          timer.cancel();
          if (jugadores.isNotEmpty) {
            iniciarTurno();
          }
        }
      });
    });
  }

  void iniciarAvance() {
    avanceTimer?.cancel();
    avanceTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (!luzVerde) {
          final ahora = DateTime.now();
          if (ultimaEliminacion == null ||
              ahora.difference(ultimaEliminacion!).inSeconds >= 1) {
            if (jugadores.isNotEmpty) {
              final random = Random();
              jugadores.removeAt(random.nextInt(jugadores.length));
              ultimaEliminacion = ahora;
              mensaje = '¡Jugador eliminado!';
            }
          }
          return;
        }

        for (var j in jugadores) {
          j.avanzar();
        }

        if (jugadores.any((j) => j.enMeta)) {
          detenerAvance();
          contadorTimer?.cancel();
          mensaje = '¡Ganaste el juego!';
        } else if (jugadores.isEmpty) {
          detenerAvance();
          contadorTimer?.cancel();
          mensaje = 'Sin jugadores. ¡Intenta de nuevo!';
        }
      });
    });
  }

  void detenerAvance() {
    avanceTimer?.cancel();
  }

  void moverJugadores() {
    if (!juegoIniciado) {
      juegoIniciado = true;
      iniciarTurno();
      iniciarAvance();
    } else {
      iniciarAvance();
    }
  }

  void reiniciarJuego() {
    contadorTimer?.cancel();
    avanceTimer?.cancel();
    setState(() {
      jugadores = List.generate(4, (index) => Jugador(id: index));
      muneca = Muneca();
      luzVerde = true;
      juegoIniciado = false;
      ultimaEliminacion = null;
      mensaje = 'Práctica Flutter';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (mensaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(muneca.imagenActual(), height: 100),
                                const SizedBox(width: 20),
                                Text(
                                  '${muneca.segundosRestantes}',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 500,
                                left: 0,
                                right: 0,
                                child: Container(height: 4, color: Colors.red),
                              ),
                              ...jugadores.map(
                                (j) => Positioned(
                                  bottom: j.posicion,
                                  left: 50.0 + j.id * 60,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              const CircleBorder(),
                            ),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(24),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.green,
                            ),
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.greenAccent;
                                  }
                                  return null;
                                }),
                          ),
                          onPressed: moverJugadores,
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              const CircleBorder(),
                            ),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(24),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.red,
                            ),
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.redAccent;
                                  }
                                  return null;
                                }),
                          ),
                          onPressed: detenerAvance,
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              const CircleBorder(),
                            ),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(24),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.yellow,
                            ),
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.amber;
                                  }
                                  return null;
                                }),
                          ),
                          onPressed: reiniciarJuego,
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    contadorTimer?.cancel();
    avanceTimer?.cancel();
    super.dispose();
  }
}
