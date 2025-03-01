import 'package:flutter/material.dart';
import 'package:tech_task_webspark/processing.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  _MyAppState createState() => _MyAppState();
  }



class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  Map<String, String> results = {};
  ValueNotifier<double> progress = ValueNotifier(0.0);
  ValueNotifier<bool> isCalculating = ValueNotifier(false);


  /// Main function of Home Page. 
  /// Basicaly it just check is URL valid and transfers and gives control to other Page,
  /// or informing user that URL isn't valid.
  Future<void> handleStart() async {
    String url = controller.text;
    if (url.isNotEmpty && isUrlValid(url)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(url: url)));
    } else {
      showUrlUnvalidErorr();
    }
  }

  /// Function for checking is URL valid
  bool isUrlValid(String url) {
    return Uri.parse(url).isAbsolute;
  }

  /// Function for informing user that inserted URL isn't valid
  void showUrlUnvalidErorr() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Url is not valid'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.blue,
        leading: null,
        title: const Text(
          'Home Screen', 
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set valid API base URL",
                        style: TextStyle(
                          fontSize: 16
                        ),
                      )
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 15.0),
                        child: Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: handleStart,
            tooltip: 'Start',
            child: const Text(
              'Start Calculating process',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
