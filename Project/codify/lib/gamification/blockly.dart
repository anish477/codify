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
  late final BlocklyEditor editor;

  BlocklyOptions _getMobileOptimizedConfig() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Create a new configuration instead of spreading the existing one
    return BlocklyOptions.fromJson({
      'grid': {
        'spacing': 20,
        'length': 3,
        'colour': '#ccc',
        'snap': true,
      },
      'toolbox': initialToolboxJson,
      'collapse': null,
      'comments': null,
      'horizontalLayout': isMobile, // Enable horizontal layout on mobile
      'zoom': {
        'controls': true,
        'wheel': true,
        'startScale': isMobile ? 0.7 : 1.0, // Smaller scale on mobile
        'maxScale': 3,
        'minScale': 0.3,
        'scaleSpeed': 1.2,
      },
      'scrollbars': {
        'horizontal': true,
        'vertical': true,
        'horizontalGap': isMobile ? 25 : 10, // More space on mobile
      },
      'css': true,
      'trashcan': true,
      'sounds': false,
    });
  }

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
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: RepaintBoundary(
          child: BlocklyEditorWidget(
            workspaceConfiguration: _getMobileOptimizedConfig(),
            initial: initialJson,
            onInject: onInject,
            onChange: onChange,
            onDispose: onDispose,
            style: '''
            .blocklyToolboxDiv { 
              min-width: ${isMobile ? '35%' : '24%'}; 
            }
            .blocklyTreeRow { 
              min-height: ${isMobile ? '48px' : '32px'}; 
              padding: ${isMobile ? '8px 4px' : '4px'}; 
            }
            .blocklyTreeLabel {
              font-size: ${isMobile ? '16px' : '13px'};
            }
            .blocklyFlyoutBackground {
              width: ${isMobile ? '100%' : 'auto'} !important;
            }
          ''',
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: const Text('Blockly Playground'),
      ),
    );
  }
}