import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_task_webspark/provider.dart';
import 'package:tech_task_webspark/results_list.dart';

/// ProcessingScreen is page that handles all server request, responses using custom provider.
/// In init state it calls for `provider.loadData(url)` with URL that user inputed in previous page.
/// Also this page handles changing `state` of provider.
/// It shows `state.message` in center and depending on what is current state
/// progress percent and `CircularProgressIndicator` bounded with progress.
/// 
/// And this page controls color of `FloatingActionButton` and handles `onPressed` function.
/// If provider is waiting for server response or calculating shortest way -> color of FAB is
/// grey and it disables button. 
class ProcessingScreen extends StatefulWidget {
  final String url;

  const ProcessingScreen({super.key, required this.url});

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  
  @override
  void initState() {
    super.initState();
    dataInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Resets provider (clears data inside) then loads data from server
  void dataInit() async {
    final provider = Provider.of<MyProvider>(context, listen: false);
    provider.reset();
    provider.loadData(widget.url);
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
          'Process Screen',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MyProvider>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.state.message,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (provider.state is FinishedState || provider.state is ProcessState) Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "${provider.progress.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    if (provider.state is FinishedState || provider.state is ProcessState) SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: provider.progress,
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                );
              },
            )
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: SizedBox(
          width: double.infinity,
          child: Consumer<MyProvider>(
            builder: (context, provider, child) {
              return FloatingActionButton(
                backgroundColor: provider.state is FinishedState? Colors.blue : Colors.grey,
                onPressed: () async {
                  if (provider.state is! FinishedState) {
                    return;
                  }
                  await provider.sendResults(widget.url);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ResultsList()));
                },
                tooltip: 'Send Results',
                child: const Text(
                  'Send Results To Server',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}