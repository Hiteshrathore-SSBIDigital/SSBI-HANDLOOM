import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_plugin/my_flutter_plugin.dart';
import 'package:my_flutter_plugin/my_flutter_plugin_platform_interface.dart';
import 'package:my_flutter_plugin/my_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyFlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyFlutterPluginPlatform initialPlatform = MyFlutterPluginPlatform.instance;

  test('$MethodChannelMyFlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyFlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    MyFlutterPlugin myFlutterPlugin = MyFlutterPlugin();
    MockMyFlutterPluginPlatform fakePlatform = MockMyFlutterPluginPlatform();
    MyFlutterPluginPlatform.instance = fakePlatform;

    expect(await myFlutterPlugin.getPlatformVersion(), '42');
  });
}
