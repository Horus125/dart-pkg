// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:io';

import 'package:path/path.dart' as path;

import '../usage.dart';
import 'usage_impl.dart';

Future<Analytics> createAnalytics(
  String trackingId,
  String applicationName,
  String applicationVersion, {
  String analyticsUrl
}) {
  return new Future.value(new AnalyticsIO(
    trackingId,
    applicationName,
    applicationVersion,
    analyticsUrl: analyticsUrl
  ));
}

class AnalyticsIO extends AnalyticsImpl {
  AnalyticsIO(String trackingId, String applicationName, String applicationVersion, {
    String analyticsUrl
  }) : super(
    trackingId,
    new IOPersistentProperties(applicationName),
    new IOPostHandler(),
    applicationName: applicationName,
    applicationVersion: applicationVersion,
    analyticsUrl: analyticsUrl
  );
}

String _createUserAgent() {
  if (Platform.isMacOS) {
    return 'Mozilla/5.0 (Macintosh; Intel Mac OS X)';
  } else if (Platform.isMacOS) {
    return 'Mozilla/5.0 (Windows; Windows)';
  } else if (Platform.isLinux) {
    return 'Mozilla/5.0 (Linux; Linux)';
  } else {
    // Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_1_1 like Mac OS X; en)
    // Dart/1.8.0-edge.41170 (macos; macos; macos; null)
    String os = Platform.operatingSystem;
    String locale = Platform.environment['LANG'];
    return "Dart/${_dartVersion()} (${os}; ${os}; ${os}; ${locale})";
  }
}

String _userHomeDir() {
  String envKey = Platform.operatingSystem == 'windows' ? 'APPDATA' : 'HOME';
  String value = Platform.environment[envKey];
  return value == null ? '.' : value;
}

String _dartVersion() {
  String ver = Platform.version;
  int index = ver.indexOf(' ');
  if (index != -1) ver = ver.substring(0, index);
  return ver;
}

class IOPostHandler extends PostHandler {
  final String _userAgent;
  final HttpClient mockClient;

  IOPostHandler({HttpClient this.mockClient}) : _userAgent = _createUserAgent();

  Future sendPost(String url, Map<String, dynamic> parameters) async {
    // Add custom parameters for OS and the Dart version.
    parameters['cd1'] = Platform.operatingSystem;
    parameters['cd2'] = 'dart ${_dartVersion()}';

    String data = postEncode(parameters);

    HttpClient client = mockClient != null ? mockClient : new HttpClient();
    client.userAgent = _userAgent;
    try {
      HttpClientRequest req = await client.postUrl(Uri.parse(url));
      req.write(data);
      HttpClientResponse response = await req.close();
      response.drain();
    } catch(exception) {
      // Catch errors that can happen during a request, but that we can't do
      // anything about, e.g. a missing internet conenction.
    }
  }
}

class IOPersistentProperties extends PersistentProperties {
  File _file;
  Map _map;

  IOPersistentProperties(String name) : super(name) {
    String fileName = '.${name.replaceAll(' ', '_')}';
    _file = new File(path.join(_userHomeDir(), fileName));

    try {
      if (!_file.existsSync()) _file.createSync();
      String contents = _file.readAsStringSync();
      if (contents.isEmpty) contents = '{}';
      _map = JSON.decode(contents);
    } catch (_) {
      _map = {};
    }
  }

  dynamic operator[](String key) => _map[key];

  void operator[]=(String key, dynamic value) {
    if (value == null && !_map.containsKey(key)) return;
    if (_map[key] == value) return;

    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }

    try {
      _file.writeAsStringSync(JSON.encode(_map) + '\n');
    } catch (_) { }
  }
}
