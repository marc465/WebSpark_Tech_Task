import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_task_webspark/preview.dart';
import 'package:tech_task_webspark/provider.dart';

/// Page for reviewing calculated results list.
/// 
/// **Possible feature:** add icon on right in list item.
/// Icon will represent correctness of solving:
/// 
///   ❌ - wrong
/// 
///   ✅ - correct
class ResultsList extends StatefulWidget {
  const ResultsList({super.key});

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {

  Widget itemBuilder(BuildContext context, int index) {
    final key = Provider.of<MyProvider>(context, listen: false).resultsToVisualise.keys.toList()[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(path: key)));
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 0.3
          ),
        ),
        child: Center(
          child: Text(
            key
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
          'Result List Screen',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<MyProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemBuilder: itemBuilder,
            itemCount: provider.resultsToVisualise.length,
          );
        },
      ),
    );
  }
}