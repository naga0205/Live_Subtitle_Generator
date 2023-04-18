import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_captions/screens/SubtitlePlayer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class VideoConverterScreen extends StatefulWidget {
  const VideoConverterScreen({super.key});

  @override
  State<VideoConverterScreen> createState() => _VideoConverterScreenState();
}

class _VideoConverterScreenState extends State<VideoConverterScreen> {
  final picker = ImagePicker();
  File? _pickedFile;
  VideoPlayerController? _controller;
  FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  String fileName = "";
  String RESULT = "";

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _pickedFile = File(pickedFile!.path);
      _controller = VideoPlayerController.file(_pickedFile!)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    });

    final storageReference = FirebaseStorage.instance
        .ref()
        .child('videos/${pickedFile!.path.split('/').last}');
    final uploadTask = storageReference.putFile(_pickedFile!);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    fileName = pickedFile.path.split('/').last;
  }

  Future<void> _convertVideoToAudio() async {
    DateTime now = DateTime.now();

    String actualDate = now.toString().substring(0);
    String p = actualDate.replaceAll(RegExp(r'(?:/_|[^\w\s])+'), "");
    final outputPath = '/storage/emulated/0/Download/+${p}.aac';
    final input = '${_pickedFile?.path}';

    final arguments = ['-i', input, '-vn', '-acodec', 'copy', outputPath];
    final executionId = await flutterFFmpeg.executeWithArguments(arguments);
    if (executionId == 0) {
      Fluttertoast.showToast(
          msg: "Converted succesfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      final pickedFile = File(outputPath);
      final Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('audios/${outputPath.split('/').last}');
      if (_pickedFile != null) {
        final UploadTask task = firebaseStorageRef.putFile(pickedFile);
        final TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
        return;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future predict() async {
    showDialog(
      context: this.context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    http.Response res = await http.get(Uri.parse(
        "https://99ef-2409-4070-4e85-7ab0-8c9-3025-96-af34.in.ngrok.io/?query=$fileName"));
    var next = res.body;
    // var decoded = jsonDecode(next);
    // //return Text(decoded["output"]);
    // Navigator.of(this.context).pop();
    // setState(() {
    //   RESULT = decoded["output"];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Live Subtitle Generator'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pickedFile == null
                  ? const Center(
                      child: Text('No video selected'),
                    )
                  : AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
              _controller != null && _controller!.value.isPlaying
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _controller!.pause();
                        });
                      },
                      icon: Icon(Icons.pause),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _controller!.play();
                        });
                      },
                      icon: Icon(Icons.play_arrow),
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text(
                  'Select video',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _convertVideoToAudio,
                  child: const Text(
                    'Convert to audio',
                    style: TextStyle(fontSize: 15.0),
                  )),
              ElevatedButton(
                onPressed: predict,
                child: const Text(
                  'Get Subtitle Video',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                child: ElevatedButton(
                  child: Text(
                    'Display Subtitle Video',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  style: ButtonStyle(),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubtitlePlayerScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
