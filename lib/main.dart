import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mem_test/memory_monitor.dart';
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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

const onheap = bool.fromEnvironment("ON_HEAP", defaultValue: false);

class _MyHomePageState extends State<MyHomePage> {
  List<ui.Image> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    const format = ui.PixelFormat.bgra8888;
    const width = 4000;
    const height = 4000;

    for (var i = 0; i < 10; i++) {
      if (onheap) {
        final pixels = Uint8List(width * height * 4);
        for (var x = 0; x < width; x++) {
          for (var y = 0; y < height; y++) {
            final offset = (y * width + x) * 4;
            pixels[offset] = x % 100 < 50 ? 0xff : 0;
            pixels[offset + 1] = 0x00;
            pixels[offset + 2] = 0x00;
            pixels[offset + 3] = 0xff;
          }
        }

        ui.decodeImageFromPixels(pixels, width, height, format, (image) {
          if (mounted) {
            setState(() {
              images.add(image);
            });
          }
        });
      } else {
        final pixels = Uint8ClampedList(width * height * 4);
        for (var x = 0; x < width; x++) {
          for (var y = 0; y < height; y++) {
            final offset = (y * width + x) * 4;
            pixels[offset] = 0x00;
            pixels[offset + 1] = 0x00;
            pixels[offset + 2] = x % 100 < 50 ? 0xff : 0;
            pixels[offset + 3] = 0xff;
          }
        }

        final image = await ui_web.createImageFromTextureSource(
            web.ImageData(pixels.toJS, width.toInt(), height.toJS,
                web.ImageDataSettings(colorSpace: "srgb")),
            width: width,
            height: height);

        if (mounted) {
          setState(() {
            images.add(image);
          });
        }
      }
    }
  }

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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: ListView(children: [
              for (final image in images)
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: RawImage(image: image, width: 200, height: 200)),
            ])),
            const Text("on heap: $onheap"),
            const MemoryMonitor(),
          ],
        ),
      ),
    );
  }
}
