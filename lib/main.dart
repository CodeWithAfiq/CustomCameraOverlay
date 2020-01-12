import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'focus_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'preview_screen.dart';
import 'scanner_overlay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustomCamera(),
    );
  }
}

class CustomCamera extends StatefulWidget {
  @override
  _CustomCameraState createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  String imagePath;

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      print('available cameras $cameras');

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 1;
        });

        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: ${err.code}\nError Message: ${err.message}');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController =
        CameraController(cameraDescription, ResolutionPreset.veryHigh);

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraPreviewWidget(context),
    );
  }

  Widget _cameraPreviewWidget(BuildContext context) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Custom Camera'),
            backgroundColor: Colors.blueGrey,
          ),
          body: Container(
            child: const Text(
              'Loading',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ));
    }

    return Stack(children: <Widget>[
      AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController)),
      Container(
        decoration: ShapeDecoration(
          shape: ScannerOverlayShape(
            borderColor: Colors.red,
            borderWidth: 6.0,
          ),
        ),
      ),

      // Center(
      //   child: CameraFocus.square(color: Colors.black.withOpacity(0.7)),

      // child: CustomPaint(
      //     painter: BoxShadowPainter(),
      //     child: ClipPath(
      //       clipper: SquareModePhoto(), //my CustomClipper
      //       child: Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   color: Colors.black.withOpacity(0.7),
      // ), // my widgets inside
      //     )),
      // ),

      Padding(
        padding: const EdgeInsets.fromLTRB(30, 150, 20, 0),
        child: Text(
          'Take a photo of the front of your MyKad',
          style: TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),

      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          // color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Make sure the picture has no glare and not blurry',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                      child: Icon(Icons.camera),
                      backgroundColor: Colors.green,
                      onPressed: () {
                        _takePicture(context);
                      }),
                  SizedBox(
                    width: 30,
                  ),
                  FlatButton.icon(
                    color: Colors.green,
                    onPressed: _onSwitchCamera,
                    icon: Icon(
                      _getCameraLensIcon(
                          cameras[selectedCameraIndex].lensDirection),
                      color: Colors.white,
                    ),
                    label: Text('Change Camera'),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  void _takePicture(BuildContext context) async {
    try {
      final path =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      print('takePicture path $path');

      await cameraController.takePicture(path);

      // If the picture was taken, display it on a new screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(imagePath: path),
        ),
      );
    } catch (e) {
      print('takePicture error $e');
    }
  }

  // Change the camera icon when tapped on switch camera button
  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription cameraDescription = cameras[selectedCameraIndex];
    _initCameraController(cameraDescription);
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }
}
