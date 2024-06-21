import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'my_flutter_plugin_method_channel.dart';

abstract class MyFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a MyFlutterPluginPlatform.
  MyFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyFlutterPluginPlatform _instance = MethodChannelMyFlutterPlugin();

  /// The default instance of [MyFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyFlutterPlugin].
  static MyFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(MyFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
