import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);
    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();
      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }
  runApp(MaterialApp(home: MyApp()));
}

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
//     await InAppWebViewController.setWebContentsDebuggingEnabled(true);
//   }

//   runApp(MaterialApp(home: new MyApp()));
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     useShouldOverrideUrlLoading: true,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // pullToRefreshController = kIsWeb
    //     ? null
    //     : PullToRefreshController(
    //         settings: PullToRefreshSettings(
    //           color: Colors.blue,
    //         ),
    //         onRefresh: () async {
    //           if (defaultTargetPlatform == TargetPlatform.android) {
    //             webViewController?.reload();
    //           } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //             webViewController?.loadUrl(
    //                 urlRequest:
    //                     URLRequest(url: await webViewController?.getUrl()));
    //           }
    //         },
    //       );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              // var url = WebUri(value);
              // if (url.scheme.isEmpty) {
              //   url = WebUri("https://www.google.com/search?q=" + value);
              // }
              //webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse("https://fashionbiz.org/get_news_feed"),
                  ),
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(
                        source: "var foo = 49;");
                    await controller.evaluateJavascript(
                        source: "var bar = 19;",
                        contentWorld: ContentWorld.PAGE);
                    print(await controller.evaluateJavascript(
                        source: "foo + bar;"));

                    print(await controller.evaluateJavascript(
                        source: "bar;",
                        contentWorld: ContentWorld.DEFAULT_CLIENT));
                    await controller.evaluateJavascript(
                        source: "var bar = 2;",
                        contentWorld: ContentWorld.DEFAULT_CLIENT);
                    print(await controller.evaluateJavascript(
                        source: "bar;",
                        contentWorld: ContentWorld.DEFAULT_CLIENT));

                    if (Platform.isIOS) {
                      await controller.evaluateJavascript(
                          source: "document.body.innerHTML = 'LOL';",
                          contentWorld: ContentWorld.world(name: "MyWorld"));
                    } else {
                      await controller.evaluateJavascript(
                          source: "window.top.document.body.innerHTML = 'LOL';",
                          contentWorld: ContentWorld.world(name: "MyWorld"));
                    }
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                // InAppWebView(
                //   key: webViewKey,
                //   initialUrlRequest:
                //       URLRequest(url: WebUri("https://inappwebview.dev/")),
                //   initialSettings: settings,
                //   pullToRefreshController: pullToRefreshController,
                //   onWebViewCreated: (controller) {
                //     webViewController = controller;
                //   },
                //   onLoadStart: (controller, url) {
                //     setState(() {
                //       this.url = url.toString();
                //       urlController.text = this.url;
                //     });
                //   },
                //   onPermissionRequest: (controller, request) async {
                //     return PermissionResponse(
                //         resources: request.resources,
                //         action: PermissionResponseAction.GRANT);
                //   },
                //   shouldOverrideUrlLoading:
                //       (controller, navigationAction) async {
                //     var uri = navigationAction.request.url!;

                //     if (![
                //       "http",
                //       "https",
                //       "file",
                //       "chrome",
                //       "data",
                //       "javascript",
                //       "about"
                //     ].contains(uri.scheme)) {
                //       if (await canLaunchUrl(uri)) {
                //         // Launch the App
                //         await launchUrl(
                //           uri,
                //         );
                //         // and cancel the request
                //         return NavigationActionPolicy.CANCEL;
                //       }
                //     }

                //     return NavigationActionPolicy.ALLOW;
                //   },
                //   onLoadStop: (controller, url) async {
                //     pullToRefreshController?.endRefreshing();
                //     setState(() {
                //       this.url = url.toString();
                //       urlController.text = this.url;
                //     });
                //   },
                //   onReceivedError: (controller, request, error) {
                //     pullToRefreshController?.endRefreshing();
                //   },
                //   onProgressChanged: (controller, progress) {
                //     if (progress == 100) {
                //       pullToRefreshController?.endRefreshing();
                //     }
                //     setState(() {
                //       this.progress = progress / 100;
                //       urlController.text = this.url;
                //     });
                //   },
                //   onUpdateVisitedHistory: (controller, url, androidIsReload) {
                //     setState(() {
                //       this.url = url.toString();
                //       urlController.text = this.url;
                //     });
                //   },
                //   onConsoleMessage: (controller, consoleMessage) {
                //     print(consoleMessage);
                //   },
                // ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () {
                  webViewController?.goBack();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  webViewController?.goForward();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
            ],
          ),
        ])));
  }
}
