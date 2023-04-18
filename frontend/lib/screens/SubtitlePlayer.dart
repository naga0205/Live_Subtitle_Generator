import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SubtitlePlayerScreen extends StatefulWidget {
  const SubtitlePlayerScreen({super.key});

  @override
  State<SubtitlePlayerScreen> createState() => _SubtitlePlayerScreenState();
}
class _SubtitlePlayerScreenState extends State<SubtitlePlayerScreen> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  Future initializeVideo() async {
    videoPlayerController = VideoPlayerController.asset("assets/video_Subtitled.mp4");

    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: true,
    );
    setState(() { });

  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController == null) {
      return Container(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Playvid"),
      ),
      body: Container(
        height: 250,
        child: Chewie(
          controller: chewieController!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
} 