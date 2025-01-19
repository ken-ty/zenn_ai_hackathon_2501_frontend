import 'package:flutter/material.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/image_display.dart';

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
                ImageDisplay(
                    onTap: _popuptext,
                    screenSize: MediaQuery.of(context).size,
                    path: 'images/digidepo_1312245_00000010.jpg'),
                // SizedBox(height: screenWidth * 0.05),
                ImageDisplay(
                    onTap: _popuptext,
                    screenSize: MediaQuery.of(context).size,
                    path: 'images/digidepo_1312240_00000005.jpg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
