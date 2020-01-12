import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  PreviewScreen({this.imagePath});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Preview Image'),
      //   backgroundColor: Colors.blueGrey,
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400),
              child: Container(
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover,),
              ),
            ),
          ),
          SizedBox(height: 20,),
          FloatingActionButton(
              child: Icon(Icons.arrow_back),
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
