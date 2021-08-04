/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fair/fair.dart';

/*
 * 网络请求demo，实际根据自身业务场景定制
 */
class FairNet extends IFairPlugin {
  static final FairNet _photoSelector = FairNet._internal();

  FairNet._internal();

  factory FairNet() {
    return _photoSelector;
  }

  Future<dynamic> request(dynamic map) async {
    if (map == null) {
      return;
    }
    var req;
    bool isDart;
    if (map is Map) {
      isDart = true;
      req = map;
    } else {
      isDart = false;
      req = jsonDecode(map);
    }
    var pageName = req['pageName'];
    var args = req['args'];
    var url = args['url'];
    var callId = args['callId'];
    var successCallback = args['success'];
    var failureCallback = args['failure'];
    var completeCallback = args['complete'];
    Map<String, dynamic> reqData = args['data'];
    var method = args['method'];
    Response<dynamic> response;

    if (method == null) {
      return Future.value();
    }

    switch (method) {
      case 'GET':
        response = await _get(url, queryParameters: reqData);
        break;
      case 'POST':
        response = await _post(url, queryParameters: reqData);
        break;
    }

    var statusCode = response?.statusCode;
    var data = response?.data;
    var statusMessage = response?.statusMessage;

    //需要判断发起方的请求是dart端还是js端
    if (isDart) {
      //实际处理结合自身app的业务逻辑场景,这个地方仅用于演示
      if (200 == statusCode) {
        successCallback?.call(data);
        completeCallback?.call();
      } else {
        failureCallback?.call(statusMessage);
        completeCallback?.call();
      }

      return Future.value();
    } else {
      var resp = {
        'callId': callId,
        'pageName': pageName,
        'statusCode': response?.statusCode,
        'data': response?.data,
        'statusMessage': response?.statusMessage,
      };
      return Future.value(jsonEncode(resp));
    }
  }

  Future<Response<dynamic>> _post(String path, {Map<String, dynamic> queryParameters}) async {
    var resp = await _getDio().post(path, queryParameters: queryParameters);
    return Future.value(resp);
  }

  Future<Response<dynamic>> _get(String path, {Map<String, dynamic> queryParameters}) async {
    var resp = await _getDio().get(path, queryParameters: queryParameters);
    return Future.value(resp);
  }

  @override
  Map<String, Function> getRegisterMethods() {
    var functions = <String, Function>{};
    functions.putIfAbsent('request', () => request);
    return functions;
  }

  Dio _dio;

  Dio _getDio() {
    _dio ??= Dio();
    return _dio;
  }
}
