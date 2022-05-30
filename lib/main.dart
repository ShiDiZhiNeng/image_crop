import 'package:flutter/material.dart';
import 'package:new_image_crop/example_demo.dart';
import 'package:new_image_crop/tools/assert_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo editors demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Photo editors demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () async {
                  //Click to edit
                  ExampleDemo.show(
                      context: context,
                      imageData: await AssertUtils.readImageByByteData(
                          'assets/images/cat.png'));
                },
                child: Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  child: Container(
                    width: 160,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Text('Click to edit'),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
