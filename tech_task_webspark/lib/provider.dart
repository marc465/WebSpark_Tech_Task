import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MyProvider extends ChangeNotifier {
  ProcessingStates state = LoadingState();
  double progress = 0.0;
  Map<String, String> results = {};
  Map<String, List<String>> resultsToVisualise = {};
  bool isCancelled = false; 

  /// Loads data from server in format that shown at
  /// 
  /// https://flutter.webspark.dev/#/
  /// 
  /// and calls for `startCalculation` method.
  Future<void> loadData(String url) async {
    state = LoadingState();
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);

      bool error = decodedBody['error'];
      if (error) {
        handleError(decodedBody['message']);
        return;
      }

      startCalculation(decodedBody);
    } else {
      handleError('There was an error. Server Response Code: ${response.statusCode}');
    }
  }

  /// Method extracts data from JSON body in specified format.
  /// Then for every field in body calls `findShortestPath` method.
  /// 
  /// Field looks like:
  /// 
  /// [
  /// 
  /// ".X.",
  /// 
  /// ".X.",
  /// 
  /// "..."
  /// 
  /// ]
  /// 
  /// **"." - represents regular cell**
  /// 
  /// **"X" - represents blocked cell**
  /// 
  /// 
  /// Need to find shortest way from start cell to end cell. Start and End coordinates
  /// are also specified in JSON body.
  void startCalculation(Map<String, dynamic> decodedBody) {
    state = ProcessState();
    isCancelled = false;
    notifyListeners();

    final data = decodedBody['data'];
    int total = data.length;

    for (int i = 0; i < total; i++) {
      if (isCancelled) return; 

      String id = data[i]['id'];
      List<String> field = List<String>.from(data[i]['field']);

      final start = data[i]['start'];
      int startX = start['x'];
      int startY = start['y'];

      final end = data[i]['end'];
      int endX = end['x'];
      int endY = end['y'];

      double progressMin = (i / total) * 100;
      double progressMax = ((i + 1) / total) * 100;

      String shortestWay = findShortestPath(field, startX, startY, endX, endY, progressMin, progressMax);
      resultsToVisualise[shortestWay] = field;
      results[id] = shortestWay;
    }

    state = FinishedState();
    notifyListeners();
  }


  /// Main method in whole project.
  /// It works with fields (graphs) that represents as `List<String>`.
  /// Also method accepts coordinates for start and end cells (x, y for each).
  /// 
  /// Logic of method:
  /// 1. If start or end cell is blocked -> return error message
  /// 2. Create queue with elements to work with
  /// 3. Add first element (Start cell)
  /// 4. Start working with next element in queue
  /// 
  /// 5. If element is End cell -> return path of it
  /// 
  /// 6. Find neighbors for this element and add them to queue if:
  /// - Cell exists
  /// - Cell isn't blocked
  /// - Cell isn't visited
  /// 
  /// 7. If there is elements to work - repeat from point 4.
  /// Otherwise -> return erorr message telling that there is no possible path.
  /// 
  /// This function just looking for neighbors in clock direction and uses regular
  /// Breadth-first search (BFS) algorithm.
  /// 
  /// I could make it better by using Best-first search. Need to write function that will
  /// assess which direction is better to move in. For example - create vector
  /// and get amount of closes blocked cells in direction of vector. Then which vector
  /// is closest to Start cell direction and have less blocked cells is vector of movement.
  /// 
  /// It could quicker get results for some cases and work worse in others than
  /// that i provided. For proper work need or better function for assess in Best-first search
  /// or use complex function that contains best ways.
  /// 
  /// But i didn't do it due to:
  /// 1. It takes more time
  /// 2. I have limeted knowladge in graph theory
  /// 3. Again it takes more time
  String findShortestPath(List<String> graph, int startX, int startY, int endX, int endY, double progressMin, double progressMax) {
    double diff = progressMax - progressMin;
    int rows = graph.length - 1;
    int cols = graph[0].length - 1;

    if (graph[startY][startX] == 'X' || graph[endX][endY] == 'X') {
      return 'Start or end point is blocked';
    }

    final startNode = Node(startX, startY);

    Queue<Node> queue = Queue();
    Set<Node> visited = {};
    queue.add(startNode);
    visited.add(startNode);

    List<List<int>> directions = [
      [0, -1],    //top
      [1, -1],    //top-right
      [1, 0],     //right
      [1, 1],     //down-right
      [0, 1],     //down
      [-1, 1],    //down-left
      [-1, 0],    //left
      [-1, -1],   //top-left
    ];
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.x == endX && current.y == endY) {
        progress = progressMax;
        notifyListeners();
        return current.path();
      }

      if (graph[current.y][current.x] == 'X') {
        continue;
      }

      for (var direct in directions) {
        int newX = current.x + direct[0];
        int newY = current.y + direct[1];
        
        if (newX >= 0 && newX <= cols && newY >= 0 && newY <= rows) {
          if (graph[newY][newX] != 'X') {
            Node neighbor = Node(newX, newY);
            if (!visited.contains(neighbor)) {
              neighbor.previous = current;
              queue.add(neighbor);
              visited.add(neighbor);

              double progressInside = progressMin + (diff * (visited.length / (graph.length * graph[0].length)));
              progress = progressInside;
              notifyListeners();
            }
          }
        }
      }
    }
    
    return 'There is no possible path';
  }

  /// Sends processed data to server in format that shown at
  /// 
  /// https://flutter.webspark.dev/#/
  Future<void> sendResults(String url) async {
    state = SendingResultsState();
    notifyListeners();

    List<Map<String, dynamic>> body = [];

    for (final entity in results.entries) {
      String id = entity.key;
      String path = entity.value;
      List<Map<String, String>> steps = extractSteps(path);

      Map<String, dynamic> responseEntity = {
        "id": id,
        "result": {
          "steps": steps,
          "path": path
        }
      };
      body.add(responseEntity);
    }

      

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    // Prints response body for checking solutions. Will make something better.
    print(response.body);

    if (response.statusCode != 200) {
      handleError('There was an error. Server Response Code: ${response.statusCode}');
      return;
    }

    state = FinishedState();
    notifyListeners();
  }

  /// Function extracts steps from format like `(1,2)->(2,2)->(3,2)`
  /// to list of maps where key is coordinates name (`"x"` or `"y"`)
  /// and value is coordinate value.
  List<Map<String, String>> extractSteps(String path) {
    List<Map<String, String>> steps = [];
    final pathElements = path.replaceAll('(', '').replaceAll(')', '').split('->');

    for (final step in pathElements) {
      final tempStepLst = step.split(',');
      Map<String, String> stepMap = {
        'x': tempStepLst[0],
        'y': tempStepLst[1]
      };
      steps.add(stepMap);
    }

    return steps;
  }

  /// Sets `state` to ErorrState. Accepts message that will be represented or
  /// will represent deafult message.
  void handleError([String message = 'There was an error. Please try again']) {
    state = ErorrState(message);
    notifyListeners();
  }

  /// Resets saved data in provider so there wouldn't be data conflict 
  void reset() {
    state = LoadingState();
    progress = 0.0;
    results = {};
    resultsToVisualise = {};
    isCancelled = true;
  }
}

/// Custom class for working with graphs nodes.
/// 
/// Usefull item that could return path from start of graph tree,
/// saves coordinates `x`, `y` and could be compared.
/// 
/// If Node is a child in graph -> than it calls for parent to give it
/// path and adds to it arrow `->`.
/// 
/// If Node is a parent in graph and have no parents -> it returns
/// coordinates in format `(x,y)`
class Node {
  final int x;
  final int y;
  Node? previous;

  Node(this.x, this.y);

  String path() {
    String add = previous != null ? '${previous!.path()}->' : '';
    return '$add($x,$y)';
  }

  @override
  String toString() => '($x,$y)';

  @override
  bool operator ==(Object other) {
    return other is Node && x == other.x && y == other.y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Custom abstract class that will be inherited by other custom clasess.
/// Inherited classes will represent state of process:
/// - Load
/// - Process
/// - Finished
/// - Send Results
/// - Erorr
/// 
/// Every class-state have it's own message that tells user about process.
abstract class ProcessingStates {
  String get message;
}

class ProcessState implements ProcessingStates {
  @override
  final String message = 'Processing...';

  ProcessState();
}

class LoadingState implements ProcessingStates {
  @override
  final String message = 'Please wait, sending request to server...';

  LoadingState();
}

class FinishedState implements ProcessingStates {
  @override
  final String message = 'All calculations has finished, you can send your results to server';

  FinishedState();
}

class SendingResultsState implements ProcessingStates {
  @override
  final String message = 'Please wait, sending results...';

  SendingResultsState();
}

class ErorrState implements ProcessingStates {
  @override
  String message;

  ErorrState(this.message) {
    message = message;
  }
}
