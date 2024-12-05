import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginStore extends ChangeNotifier {
  final Dio _dio = Dio();

  LoginStore() {
    _dio.options = BaseOptions(
      baseUrl: "https://im.cclite.co", // 替换为你的后端基础地址
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
  }

  String telephone = '';
  String password = '';
  bool isLogin = false;
  String prefix = '86';
  String inviteCode = '';
  int sex = 0;
  String nickname = '';
  bool hasSetSecret = false;
  String areaCode = '';
  String smsCode = '';
  bool changState = true;
  bool loading = false;
  String onLoadingExplain = '';

  // 用户设置 (模拟 observable)
  Map<String, dynamic> userSetting = {};

  // 登录数据
  Map<String, dynamic> loginData = {};

  // 通用 MD5 加密方法
  String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  // 登录方法
  Future<Map<String, dynamic>> login({
    required String telephone,
    required String password,
    required String serial,
    required String loginIp,
    String? code,
  }) async {
    if (telephone.isEmpty || serial.isEmpty) {
      return {
        "status": false,
        "message": "Telephone and serial cannot be empty",
      };
    }

    Map<String, dynamic> params = {};
    String path;

    if (code == null) {
      // 普通登录
      path = "/user/login";
      params = {
        "areaCode": prefix,
        "telephone": _generateMd5(telephone),
        "password": _generateMd5(password),
        "serial": _generateMd5(serial),
        "loginIp": loginIp,
        "appBrand": "web",
      };
    } else {
      // 验证码登录
      path = "/user/otherLogin";
      params = {
        "code": code,
        "otherType": 4,
        "xmppVersion": "12",
        "osVersion": "wechat",
        "serial": serial,
        "loginIp": loginIp,
        "latitude": '',
        "longitude": '',
        "appBrand": "web",
      };
    }

    try {
      final response = await _dio.post(path, data: params);
      if (response.data["resultCode"] == 1) {
        loginData = response.data["data"] ?? {};
        notifyListeners();
        return {
          "status": true,
          "data": loginData,
        };
      } else {
        return {
          "status": false,
          "message": response.data["data"]?["resultMsg"] ?? "登录失败",
        };
      }
    } on DioError catch (e) {
      return {
        "status": false,
        "message": e.response?.data?["message"] ?? e.message,
      };
    } catch (e) {
      return {
        "status": false,
        "message": e.toString(),
      };
    }
  }

  // 注册方法
  Future<Map<String, dynamic>> register(String serial) async {
    if (telephone.isEmpty || serial.isEmpty) {
      return {
        "status": false,
        "info": "Telephone and serial cannot be empty",
      };
    }

    loading = true;
    notifyListeners();

    Map<String, dynamic> params = {
      "telephone": telephone,
      "password": _generateMd5(password),
      "registerType": smsCode.isNotEmpty ? 0 : 1,
      "nickname": nickname.isNotEmpty ? nickname : "User",
      "sex": sex,
      "inviteCode": inviteCode,
      "questions": "[]",
      "areaCode": areaCode,
      "smsCode": smsCode,
      "serial": _generateMd5(serial),
    };

    try {
      final response = await _dio.post('/user/register', data: params);
      if (response.data["resultCode"] == 1) {
        loading = false;
        notifyListeners();
        return {
          "status": true,
          "info": "",
        };
      } else {
        loading = false;
        notifyListeners();
        return {
          "status": false,
          "info": response.data["data"]?["resultMsg"] ?? "注册失败",
        };
      }
    } on DioError catch (e) {
      loading = false;
      notifyListeners();
      return {
        "status": false,
        "info": e.response?.data?["message"] ?? e.message,
      };
    } catch (e) {
      loading = false;
      notifyListeners();
      return {
        "status": false,
        "info": e.toString(),
      };
    }
  }

  // 修改密码方法
  Future<Map<String, dynamic>> resetPassword(String newPassword) async {
    if (telephone.isEmpty || newPassword.isEmpty) {
      return {
        "status": false,
        "info": "Telephone and new password cannot be empty",
      };
    }

    Map<String, dynamic> params = {
      "telephone": telephone,
      "newPassword": _generateMd5(newPassword),
      "registerType": smsCode.isNotEmpty ? 0 : 1,
    };

    try {
      final response = await _dio.post('/user/password/reset', data: params);
      if (response.data["resultCode"] == 1) {
        return {
          "status": true,
          "info": "",
        };
      } else {
        return {
          "status": false,
          "info": response.data["data"]?["resultMsg"] ?? "修改失败",
        };
      }
    } on DioError catch (e) {
      return {
        "status": false,
        "info": e.response?.data?["message"] ?? e.message,
      };
    } catch (e) {
      return {
        "status": false,
        "info": e.toString(),
      };
    }
  }

  // 请求二维码
  Future<dynamic> getQRCodeUrl() async {
    try {
      final response = await _dio.get('/user/qrcode');
      return response.data;
    } on DioError catch (e) {
      return {
        "status": false,
        "info": e.response?.data?["message"] ?? e.message,
      };
    } catch (e) {
      return {
        "status": false,
        "info": e.toString(),
      };
    }
  }

  // 检测二维码
  Future<dynamic> checkQRCodeUrl(String qrData, String serial) async {
    try {
      final response = await _dio.post('/user/check/qrcode', data: {
        "qrData": qrData,
        "serial": _generateMd5(serial),
      });
      return response.data;
    } on DioError catch (e) {
      return {
        "status": false,
        "info": e.response?.data?["message"] ?? e.message,
      };
    } catch (e) {
      return {
        "status": false,
        "info": e.toString(),
      };
    }
  }
}