import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blockly/flutter_blockly.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'content.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      //   WebView.platform = AndroidWebView();
      // } else if (Platform.isIOS) {
      //   WebView.platform = WebKitWebView();
    }
  }

  // Use default media path; static options work on mobile
  final BlocklyOptions workspaceConfiguration = BlocklyOptions.fromJson(const {
    'grid': {
      'spacing': 20,
      'length': 3,
      'colour': '#ccc',
      'snap': true,
    },
    'toolbox': initialToolboxJson,
    'media': 'packages/flutter_blockly/assets/media',
  });

  void onInject(BlocklyData data) {
    debugPrint('onInject: ${data.xml}\n${jsonEncode(data.json)}');
  }

  void onChange(BlocklyData data) {
    debugPrint('onChange: ${data.xml}\n${jsonEncode(data.json)}\n${data.dart}');
  }

  void onDispose(BlocklyData data) {
    debugPrint('onDispose: ${data.xml}\n${jsonEncode(data.json)}');
  }

  void onError(dynamic err) {
    debugPrint('onError: $err');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocklyEditorWidget(
          workspaceConfiguration: workspaceConfiguration,
          // initialXml: initialXml, // add xml initial state for mobile
          // initialJson: initialJson, // add json initial state
          onInject: onInject,
          onChange: onChange,
          onDispose: onDispose,
          onError: onError,
          style: '.wrapper-web {top:58px;}',
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: const Text('Blockly Playground'),
      ),
    );
  }
}
