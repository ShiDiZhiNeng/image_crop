// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
// // import 'package:new_image_crop/new_image_crop.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _platformVersion = 'Unknown';
//   final _newImageCropPlugin = NewImageCrop();

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion = await _newImageCropPlugin.getPlatformVersion() ??
//           'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Text('Running on: $_platformVersion\n'),
//         ),
//       ),
//     );
//   }
// }

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Photo editors demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// GlobalKey _globalKey = GlobalKey();

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () async {
                  // print('点击选择照片');
                  // PhotoUtils.selectLocalPhotos(context: context).then((value) {
                  //   print('');
                  // });

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
                    child: const Text('点击进入编辑'),
                  ),
                ))

            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),

            // Container(
            //     key: _globalKey,
            //     color: Colors.yellow,
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         GestureDetector(
            //           onTap: () {
            //             print('tap');
            //           },
            //           child: FutureBuilder(
            //             future: AssertUtils.readImage('assets/images/cat.png'),
            //             builder: (context, snapshot) {
            //               iamgeData = snapshot.data as ui.Image?;
            //               if (snapshot.hasData) {
            //                 return CustomPaint(
            //                     painter: ResultPaint(
            //                         image: iamgeData!,
            //                         tailorRect: Rect.fromLTWH(0, 0,
            //                             iamgeData!.width.toDouble(), 200)),
            //                     size: Size(iamgeData!.width.toDouble(), 200));
            //               }
            //               return const SizedBox();
            //             },
            //           ),
            //         ),
            //       ],
            //     ))
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   // onPressed: _incrementCounter,
      //   onPressed: () async {
      //     // PhotoUtils.selectLocalPhotos(context: context);
      //     // iamgeData = await AssertUtils.readImage('assets/images/cat.png');
      //     // final byteData = await iamgeData!.toByteData();
      //     // setState(() {
      //     //   // _image = Image.memory(byteData!.buffer.asUint8List());
      //     // });
      //     // print('666 ${byteData.toString()}');
      //     // final renderBox = _globalKey.currentContext?.findRenderObject();
      //     // print('666  ${_globalKey.toString()}');
      //     ImageEditorDialog.show(
      //         context: context,
      //         imageData: await AssertUtils.readImageByByteData(
      //             'assets/images/cat.png'));
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
