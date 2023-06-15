import 'package:flutter/material.dart';
import 'package:arturo/database/Database_helper.dart';

void main() {
  runApp(MaterialApp(
    home: TresEnRaya(),
  ));
}

class TresEnRaya extends StatefulWidget {
  @override
  TresEnRayaState createState() => TresEnRayaState();
}

class TresEnRayaState extends State<TresEnRaya> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  bool playerTurn = true;
  int player1Score = 0;
  int player2Score = 0;
  int totalGames = 0;
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper.instance;
    loadScores();
  }

  void loadScores() async {
    Map<String, dynamic>? scores = await databaseHelper.getScores();
    setState(() {
      player1Score = scores?['player1_score'] ?? 0;
      player2Score = scores?['player2_score'] ?? 0;
      totalGames = scores?['total_games'] ?? 0;
    });
  }

  void resetScores() async {
    await databaseHelper.resetScores();
    setState(() {
      player1Score = 0;
      player2Score = 0;
      totalGames = 0;
    });
  }

  void updateScores(bool player1Won) async {
    await databaseHelper.updateScores(player1Won);
    setState(() {
      if (player1Won) {
        player1Score++;
      } else {
        player2Score++;
      }
      totalGames++;
    });
  }

  void restartGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      playerTurn = true;
    });
  }

  void checkForWin() {
    // Verificar filas
    for (int row = 0; row < 3; row++) {
      if (board[row][0] == board[row][1] && board[row][1] == board[row][2] && board[row][0].isNotEmpty) {
        // Hay una victoria en esta fila
        updateScores(board[row][0] == 'X');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¡Victoria!'),
              content: Text('El Jugador ${board[row][0]} ha ganado.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    restartGame();
                    Navigator.of(context).pop();
                  },
                  child: Text('Reiniciar'),

                ),

              ],
            );
          },
        );
        return;
      }
    }


    for (int col = 0; col < 3; col++) {
      if (board[0][col] == board[1][col] && board[1][col] == board[2][col] && board[0][col].isNotEmpty) {

        updateScores(board[0][col] == 'X');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¡Victoria!'),
              content: Text('El Jugador ${board[0][col]} ha ganado.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    restartGame();
                    Navigator.of(context).pop();
                  },
                  child: Text('Reiniciar'),
                ),
              ],
            );
          },
        );
        return;
      }
    }
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0].isNotEmpty) {
      updateScores(board[0][0] == 'X');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Victoria!'),
            content: Text('El Jugador ${board[0][0]} ha ganado.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  restartGame();
                  Navigator.of(context).pop();
                },
                child: Text('Reiniciar'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2].isNotEmpty) {

      updateScores(board[0][2] == 'X');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Victoria!'),
            content: Text('El Jugador ${board[0][2]} ha ganado.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  restartGame();
                  Navigator.of(context).pop();
                },
                child: Text('Reiniciar'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool isFull = true;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col].isEmpty) {
          isFull = false;
          break;
        }
      }
      if (!isFull) {
        break;
      }
    }

    if (isFull) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Empate!'),
            content: Text('El juego ha terminado en empate.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  restartGame();
                  Navigator.of(context).pop();
                },
                child: Text('Reiniciar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tres en Raya'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Jugador 1: $player1Score',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Jugador 2: $player2Score',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Total de partidas: $totalGames',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (BuildContext context, int index) {
                int row = index ~/ 3;
                int col = index % 3;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (board[row][col].isEmpty) {
                        board[row][col] = playerTurn ? 'X' : 'O';
                        playerTurn = !playerTurn;
                        checkForWin();
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        board[row][col],
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartGame,
              child: Text('Reiniciar'),
            ),
            ElevatedButton(
              onPressed: resetScores,
              child: Text('Anular Puntuaciones'),
            ),
          ],
        ),
      ),
    );
  }
}