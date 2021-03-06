// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:html';

import 'usage_impl.dart';

/// An interface to a Google Analytics session, suitable for use in web apps.
///
/// [analyticsUrl] is an optional replacement for the default Google Analytics
/// URL (`https://www.google-analytics.com/collect`).
class AnalyticsHtml extends AnalyticsImpl {
  AnalyticsHtml(
      String trackingId, String applicationName, String applicationVersion,
      {String analyticsUrl})
      : super(trackingId, new HtmlPersistentProperties(applicationName),
            new HtmlPostHandler(),
            applicationName: applicationName,
            applicationVersion: applicationVersion,
            analyticsUrl: analyticsUrl) {
    int screenWidth = window.screen.width;
    int screenHeight = window.screen.height;

    setSessionValue('sr', '${screenWidth}x$screenHeight');
    setSessionValue('sd', '${window.screen.pixelDepth}-bits');
    setSessionValue('ul', window.navigator.language);
  }
}

typedef Future<HttpRequest> HttpRequestor(String url,
    {String method, sendData});

class HtmlPostHandler extends PostHandler {
  final HttpRequestor mockRequestor;

  HtmlPostHandler({this.mockRequestor});

  @override
  Future sendPost(String url, Map<String, dynamic> parameters) {
    int viewportWidth = document.documentElement.clientWidth;
    int viewportHeight = document.documentElement.clientHeight;

    parameters['vp'] = '${viewportWidth}x$viewportHeight';

    String data = postEncode(parameters);
    HttpRequestor requestor =
        mockRequestor == null ? HttpRequest.request : mockRequestor;
    return requestor(url, method: 'POST', sendData: data).catchError((e) {
      // Catch errors that can happen during a request, but that we can't do
      // anything about, e.g. a missing internet connection.
    });
  }

  @override
  void close() {}
}

class HtmlPersistentProperties extends PersistentProperties {
  Map _map;

  HtmlPersistentProperties(String name) : super(name) {
    String str = window.localStorage[name];
    if (str == null || str.isEmpty) str = '{}';
    _map = jsonDecode(str);
  }

  @override
  dynamic operator [](String key) => _map[key];

  @override
  void operator []=(String key, dynamic value) {
    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }

    window.localStorage[name] = jsonEncode(_map);
  }

  @override
  void syncSettings() {}
}
