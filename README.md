# WebSpark Tech Task

## Overview
This project is a technical task for WebSpark, demonstrating my ability to develop a Flutter application that interacts with a server and solves a pathfinding challenge efficiently.

## Getting Started
This project has been developed and tested on macOS and iOS platforms. While Web and Android platforms are technically supported, they have not been extensively tested. Windows systems may experience unpredictable behavior as they were not intended to be supported.

## Prerequisites
For the application to function properly, you will need:
 - An active internet connection
 - App permissions to access the internet enabled on your device

## Project Description
The application takes a URL input, validates it, and sends a request to WebSpark's server. The server responds with a grid-based field where:
* `.` represents a regular cell.
* `X` represents a blocked cell.
* The server also provides start and end coordinates.

Using **Breadth-First Search (BFS)**, the app calculates the shortest path from the given start position to the target, avoiding blocked cells.

Example Grid:

```
.X.
.X.
...
```

In this example, the algorithm finds the optimal way through the open cells.

## Technologies Used
* **Flutter** for frontend development
* **Dart** for logic implementation
* **BFS (Graph Algorithm)** for pathfinding
* **REST API** for server communication

## Why This Project Matters
This project showcases my problem-solving skills, ability to work with APIs, and implement efficient algorithms. It's a demonstration of my ability to build functional, well-structured applications—key skills for a Flutter developer.

## Future Improvements
* Enhance UI for a better user experience
* Implement additional pathfinding algorithms for comparison
* Add error handling for network failures

Looking forward to feedback and potential improvements!




# Task №2
Задача в цілому не складна, більше проблем з реалізацією - обробка помилок, підтримка різних систем, тощо. Якщо ви мали справу з теорією графів, то побачити тут її буде не сильно важко.

Щоб знайти найкоротший шлях з урахуванням заблокованих комірок можемо використати алгоритм пошуку в ширину (BFS) - він гарантує знаходження мінімального шляху (можна було б використати жадібний пошук, але це займе більше часу).

Алгоритм розв’язку
Створюємо кастомний клас (Node) - він репрезентує клітинку в сітці.

Кожен вузол містить координати (x, y) та посилання на попередній вузол, що дозволяє відтворити шлях.

Алгоритм BFS
Якщо стартова або кінцева точка заблоковані - повертаємо повідомлення про помилку.

Використовуємо чергу (Queue<Node>) для поступового проходження сітки.
Для кожної комірки перевіряємо всі 8 можливих напрямків руху в напрямку годинникової стрілки.
Якщо знайдена кінцева точка, відновлюємо найкоротший шлях через збережені посилання на попередні вузли.
Якщо ні то добавляємо в чергу наступний елемент і повторюємо процедуру допоки не знайдемо можливий найкоротший шлях.

Якщо всі елементи з сітки пройдені і шляху не знайдено - то повертаємо повідомлення про помилку.

Результат
Функція повертає строку у форматі (x,y)->(x,y)->(x,y), якf описує найкоротший шлях від стартової точки до цільової. Якщо шлях неможливий, повертається строка з повідомленням про помилку.



Реалізація функції на Dart:

import 'dart:collection';

List<Map<String, int>> findShortestPath(List<String> graph, int startX, int startY, int endX, int endY) {
  int rows = graph.length;
  int cols = graph[0].length;

  if (graph[startY][startX] == 'X' || graph[endY][endX] == 'X') {
    return [];
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
      return current.buildPath();
    }

    for (var dir in directions) {
      int newX = current.x + dir[0];
      int newY = current.y + dir[1];
      
      if (newX >= 0 && newX < cols && newY >= 0 && newY < rows && graph[newY][newX] != 'X') {
        Node neighbor = Node(newX, newY, previous: current);
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
          visited.add(neighbor);
        }
      }
    }
  }
  return []; // Якщо шлях не знайдено
}

class Node {
  final int x, y;
  final Node? previous;

  Node(this.x, this.y, {this.previous});

  List<Map<String, int>> buildPath() {
    List<Map<String, int>> path = [];
    Node? current = this;
    while (current != null) {
      path.add({'x': current.x, 'y': current.y});
      current = current.previous;
    }
    return path.reversed.toList();
  }

  @override
  bool operator ==(Object other) => other is Node && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
