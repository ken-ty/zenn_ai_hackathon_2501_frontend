import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //pop up text
  void _popuptext() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: AlertDialog(title: Text('あなたの勝ちです')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // display image
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // tap to open image
                InkWell(
                  onTap: () {
                    _popuptext();
                  },
                  child: Image.asset('images/digidepo_1312245_00000010.jpg',
                      width: screenWidth * 0.4, height: screenHeight * 0.4),
                ),
                SizedBox(height: screenWidth * 0.05),
                InkWell(
                  onTap: () {
                    _popuptext();
                  },
                  child: Image.asset('images/digidepo_1312240_00000005.jpg',
                      width: screenWidth * 0.4, height: screenHeight * 0.4),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
