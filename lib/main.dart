// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';
//
// void main() => runApp(VideoApp());
//
// class VideoApp extends StatefulWidget {
//   @override
//   _VideoAppState createState() => _VideoAppState();
// }
//
// class _VideoAppState extends State<VideoApp> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(
//         'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Demo',
//       home: Scaffold(
//         body: Center(
//           child: _controller.value.isInitialized
//               ? AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           )
//               : Container(),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             // print(_controller.play());
//             print(_controller.value.isPlaying);
//             setState(() {
//               _controller.value.isPlaying
//                   ? _controller.pause()
//                   : _controller.play();
//             });
//           },
//           child: Icon(
//             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show HttpServer;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show dom;

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';



const html = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Grant Access to Flutter</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; }
    main {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol;
    }
    #icon {
      font-size: 96pt;
    }
    #text {
      padding: 2em;
      max-width: 260px;
      text-align: center;
    }
    #button a {
      display: inline-block;
      padding: 6px 12px;
      color: white;
      border: 1px solid rgba(27,31,35,.2);
      border-radius: 3px;
      background-image: linear-gradient(-180deg, #34d058 0%, #22863a 90%);
      text-decoration: none;
      font-size: 14px;
      font-weight: 600;
    }
    #button a:active {
      background-color: #279f43;
      background-image: none;
    }
  </style>
</head>
<body>
  <main>
    <div id="icon">&#x1F3C7;</div>
    <div id="text">Press the button below to sign in using your Localtest.me account.</div>
    <div id="button"><a href="foobar://success?code=1337">Sign in</a></div>
  </main>
</body>
</html>
""";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = '';

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    final server = await HttpServer.bind('127.0.0.1', 43823);

    server.listen((req) async {
      setState(() { _status = 'Received request!'; });

      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      req.response.close();
    });
  }

  void authenticate() async {
    final url = 'http://localtest.me:43823/';
    final callbackUrlScheme = 'foobar';

    try {
      final result = await FlutterWebAuth.authenticate(url: url, callbackUrlScheme: callbackUrlScheme);
      setState(() { _status = 'Got result: $result'; });
    } on PlatformException catch (e) {
      setState(() { _status = 'Got error: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    var document = parse(
        '<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks!');
    print(document.outerHtml);

    const text = """
    <figure class="tmblr-full"  data-npf='{"type":"video","provider":"tumblr","url":"https://va.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm.mp4","media":{"url":"https://va.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm.mp4","type":"video/mp4","width":360,"height":640},"poster":[{"url":"https://64.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm_frame1.jpg","type":"image/jpeg","width":360,"height":640}],"filmstrip":{"url":"https://64.media.tumblr.com/previews/tumblr_qumsy5jvCu1qzezhm_filmstrip.jpg","type":"image/jpeg","width":2000,"height":357}}'>
  	  <video controls="controls" muted="muted" poster="https://64.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm_frame1.jpg">
	  	  <source src="https://va.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm.mp4" type="video/mp4"></source>
	    </video>
    </figure>
    """;

    final css = Style.fromCss(
        "figure{height:400px;} video{height:400px;} body {margin: 0; padding: 0;}",
            (css, errors) {
          print(css);
          print(errors);
        });

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Web Auth example'),
        ),
        body: Container(
          // color: Colors.red,
          // height: 400,

          child: HtmlWidget(text),

          // child: ChewieDemo(),

        //     child: Html(
        //   style: css,
        //   data: "<body>" + text + "</body>",
        //   shrinkWrap: true,
        //   onImageTap: null,
        // )),
        // body: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Text('Status: $_status\n'),
        //       const SizedBox(height: 80),
        //       RaisedButton(
        //         child: Text('Authenticate'),
        //         onPressed: () { this.authenticate(); },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    ));
  }
}


class ChewieDemo extends StatefulWidget {
  const ChewieDemo({
    Key? key,
    this.title = 'Chewie Demo',
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.network(
        'https://va.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm.mp4');
        // 'https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4');
    _videoPlayerController2 = VideoPlayerController.network(
        'https://va.media.tumblr.com/tumblr_qumsy5jvCu1qzezhm.mp4');
        // 'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4');
    await Future.wait([
      _videoPlayerController1.initialize(),
      _videoPlayerController2.initialize()
    ]);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      subtitle: Subtitles([
        Subtitle(
          index: 0,
          start: Duration.zero,
          end: const Duration(seconds: 10),
          text: 'Hello from subtitles',
        ),
        Subtitle(
          index: 0,
          start: const Duration(seconds: 10),
          end: const Duration(seconds: 20),
          text: 'Whats up? :)',
        ),
      ]),
      subtitleBuilder: (context, subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: AppTheme.light.copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized
                    ? Chewie(
                  controller: _chewieController!,
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading'),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _chewieController?.enterFullScreen();
              },
              child: const Text('Fullscreen'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _videoPlayerController1.pause();
                        _videoPlayerController1.seekTo(const Duration());
                        // _chewieController = _chewieController!.copyWith(
                        //   videoPlayerController: _videoPlayerController1,
                        //   autoPlay: true,
                        //   looping: true,
                        //   subtitle: Subtitles([
                        //     Subtitle(
                        //       index: 0,
                        //       start: Duration.zero,
                        //       end: const Duration(seconds: 10),
                        //       text: 'Hello from subtitles',
                        //     ),
                        //     Subtitle(
                        //       index: 0,
                        //       start: const Duration(seconds: 10),
                        //       end: const Duration(seconds: 20),
                        //       text: 'Whats up? :)',
                        //     ),
                        //   ]),
                        //   subtitleBuilder: (context, subtitle) => Container(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: Text(
                        //       subtitle,
                        //       style: const TextStyle(color: Colors.white),
                        //     ),
                        //   ),
                        // );
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Landscape Video"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _videoPlayerController2.pause();
                        _videoPlayerController2.seekTo(const Duration());
                        // _chewieController = _chewieController!.copyWith(
                        //   videoPlayerController: _videoPlayerController2,
                        //   autoPlay: true,
                        //   looping: true,
                        //   /* subtitle: Subtitles([
                        //     Subtitle(
                        //       index: 0,
                        //       start: Duration.zero,
                        //       end: const Duration(seconds: 10),
                        //       text: 'Hello from subtitles',
                        //     ),
                        //     Subtitle(
                        //       index: 0,
                        //       start: const Duration(seconds: 10),
                        //       end: const Duration(seconds: 20),
                        //       text: 'Whats up? :)',
                        //     ),
                        //   ]),
                        //   subtitleBuilder: (context, subtitle) => Container(
                        //     padding: const EdgeInsets.all(10.0),
                        //     child: Text(
                        //       subtitle,
                        //       style: const TextStyle(color: Colors.white),
                        //     ),
                        //   ), */
                        // );
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Portrait Video"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.android;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Android controls"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.iOS;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("iOS controls"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.windows;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Desktop controls"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    accentColor: Colors.red,
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.red,
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
