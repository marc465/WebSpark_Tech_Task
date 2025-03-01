import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_task_webspark/provider.dart';

/// Preview Page contains only three elements:
/// - AppBar,
/// - GridView (represents field),
/// - Shortest way in text format
class PreviewScreen extends StatefulWidget {
  final String path;

  const PreviewScreen({super.key, required this.path});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {

  /// Usefull function for extracting Color from hex format
  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// As it seems from name, that function will decide what color will be cell.
  /// - Black is blocked cell.
  /// - Dark green is end cell.
  /// - Ligth green is start cell.
  /// - Green is one of shortest way cells.
  Color decideColor(String character, int rowInx, int colInx) {
    if (character == "X") return Colors.black;

    List<String> path = widget.path.replaceAll('(', '').replaceAll(')', '').split('->').toList();

    bool isContains = path.contains("$colInx,$rowInx");
    int index = -1;
    if (isContains) {
      index = path.indexOf("$colInx,$rowInx");
    }


    if (isContains && index == 0) {
      return getColorFromHex("#64FFDA");
    }

    if (isContains && index == (path.length - 1)) {
      return getColorFromHex("#009688");
    }

    if (isContains) return getColorFromHex("#4CAF50");
    
    return Colors.white;
  }

  /// Regular item builder.
  /// Used it GridView to represent field with blocked, start, end and shortest way cells.
  Widget cellbuilder(BuildContext context, int index) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    int width = provider.resultsToVisualise[widget.path]![0].length;

    int rowsIndex = index ~/ width;
    int colsIndex = index % width;

    String character = provider.resultsToVisualise[widget.path]![rowsIndex][colsIndex];

    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        color: decideColor(character, rowsIndex, colsIndex),
        border: Border.all(
          color: Colors.black,
          width: 1.0
        )
      ),
      child: Center(
        child: Text(
          '($colsIndex,$rowsIndex)',
          style: TextStyle(
            color: character == "X" ? Colors.white : Colors.black,
            fontSize: 20
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = Provider.of<MyProvider>(context, listen: false).resultsToVisualise[widget.path];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Preview Screen',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55, 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: field![0].length,
                        ), 
                        itemBuilder: cellbuilder,
                        itemCount: field.length * field[0].length,
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.path,
                        style: const TextStyle(
                          fontSize: 20
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}