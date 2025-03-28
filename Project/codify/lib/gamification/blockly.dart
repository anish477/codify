import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blockly/flutter_blockly.dart';

import 'content.dart';



class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();

}

class _WebViewAppState extends State<WebViewApp> {
  // final BlocklyOptions workspaceConfiguration = BlocklyOptions(
  //   grid: const GridOptions(
  //     spacing: 20,
  //     length: 3,
  //     colour: '#ccc',
  //     snap: true,
  //   ),
  //   toolbox: ToolboxInfo.fromJson(initialToolboxJson),
  // );
  bool _isloading=false;

  final BlocklyOptions workspaceConfiguration = BlocklyOptions.fromJson(const {
    'grid': {
      'spacing': 20,
      'length': 3,
      'colour': '#ccc',
      'snap': true,
    },
    'toolbox': initialToolboxJson,
    // null safety example
    'collapse': null,
    'comments': null,
    'css': null,
    'disable': null,
    'horizontalLayout': null,
    'maxBlocks': null,
    'maxInstances': null,
    'media': null,
    'modalInputs': null,
    'move': null,
    'oneBasedIndex': null,
    'readOnly': null,
    'renderer': null,
    'rendererOverrides': null,
    'rtl': null,
    'scrollbars': null,
    'sounds': null,
    'theme': null,
    'toolboxPosition': null,
    'trashcan': null,
    'maxTrashcanContents': null,
    'plugins': null,
    'zoom': null,
    'parentWorkspace': null,
  });

  void onInject(BlocklyData data) {
    debugPrint('onInject: ${data.xml}\n${jsonEncode(data.json)}');
    _isloading=true;
  }

  void onChange(BlocklyData data) {
    debugPrint('onChange: ${data.xml}\n${jsonEncode(data.json)}\n${data.dart}');
  }

  void onDispose(BlocklyData data) {
    debugPrint('onDispose: ${data.xml}\n${jsonEncode(data.json)}');
  }

  void onError(dynamic err) {
    debugPrint('onError: $err');
    _isloading=true;
  }

  @override
  Widget build(BuildContext context) {
    return

      Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        
        child: _isloading?
        Center(child: CircularProgressIndicator(),)
        :
        BlocklyEditorWidget(
          workspaceConfiguration: workspaceConfiguration,
          initial: initialJson,
          onInject: onInject,
          onChange: onChange,
          onDispose: onDispose,
          onError: onError,
          style: '.wrapper-web {top:58px;}',
        ),
        
      ),
      appBar: AppBar(
        title: const Text('Blockly PlayGround'),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      //   backgroundColor:Color(0xFFFFFFFF),
      // ),
    );
  }
}