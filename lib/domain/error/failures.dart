// Created by Hu Wentao.
// Email : hu.wentao@outlook.com
// Date  : 2020/1/17
// Time  : 0:08

import 'package:get_arch_core/get_arch_core.dart';

///
/// 这里是一些常用的Failure

///
/// 需要向后台报告的问题 -说明代码逻辑出错\表示层不合理\非法操作
mixin NeedFeedbackMx on Failure {
  @override
  void onCreate() {
    print('''
    <<<--- 请截屏向我们反馈问题 ### 错误类型: $reportFailureType
    ### 错误信息:
      $msg
    --->>>''');
    super.onCreate();
  }
}

///
/// 服务端出错异常(服务端程序导致的异常)
class ServerFailure extends Failure with NeedFeedbackMx {
  /// 网络请求出错
  ServerFailure.http(String? msg, dynamic rsp)
      : super('ServerFailure.http', '$msg\n$rsp');

  ServerFailure.socket(String describe, String code)
      : super('ServerFailure.socket', 'describe:[$describe],code:[$code]');

  /// ws中的code场景错误, 或者用了未知的code,等
  @Deprecated('请使用 .socket()')
  ServerFailure.ws(String describe, String code)
      : super('ServerFailure.ws', 'describe:[$describe],code:[$code]');

  /// 服务器在ws中传来了非法的参数(不是code)
  ServerFailure.wsParam(String describe)
      : super('ServerFailure.wsParam', 'describe:[$describe],');
}

///
/// 客户端 逻辑代码出错,需要通过更新app版本解决
/// (例如向服务器发送了错误格式的参数)
class ClientFailure extends Failure with NeedFeedbackMx {
  ClientFailure._(String? msg) : super('ClientFailure', '$msg') {
    print(this);
  }

  ClientFailure._bySubType(String subType, String? msg)
      : super('ClientFailure/[$subType]', '$msg');

  // 要访问的远程资源出错, 可能是使用了过时的api,等等
  factory ClientFailure.badReq(int httpCode, String? msg, dynamic rsp) {
    if (httpCode == 401) {
      return NotLoginFailure();
    }
    return ClientFailure._('.badReq:code:[$httpCode],mag:[$msg]\n$rsp');
  }

  // 从服务器校验出客户端发出的参数有误
  factory ClientFailure.badParam(String head, String code, String? msg) {
    // note-m: 各个feat中都需要继承自 ClientFailure的 BadParamFailure类,方便进行异常处理
    return BadParamFailure(head, code, '$msg');
  }

  // 从本地校验出输入值出错
  // 可能是非法输入\逻辑层出错\表示层出错(如,表示层没有做出输入值的范围限制,导致程序出错)
  ClientFailure.badInput(String? msg) : super('.badInput', '$msg');

  // 程序代码有误, 或者代码不完善导致出错
  ClientFailure.badLogic(String? msg) : super('.badLogic', '$msg');

  // 功能正在开发中
  ClientFailure.featDeveloping(String className)
      : super('.featDeveloping', '$className');
}

class NotLoginFailure extends Failure implements ClientFailure {
  NotLoginFailure({String? msg: '您尚未登陆'})
      : super('ClientFailure/NotLogin', '$msg');
}

/// note-m: 考虑通过[cateCode]和[errCode], 映射到具体的module错误类型
class BadParamFailure extends ClientFailure {
  // 确定是什么类型 (公共,user, erp, 还是wms)
  final String cateCode;

  // 确定是什么错误 (账号不存在, 密码错误,等等)
  final String errCode;

  // 错误信息,例如 "密码错误"
  final String msg;

  BadParamFailure(this.cateCode, this.errCode, this.msg)
      : super._bySubType(
            'BadParam', 'cateCode[$cateCode],errCode[$errCode],msg[$msg]');
}

///
/// 网络错误,连不上服务器(可能是用户没联网)
class NetworkFailure extends Failure {
  NetworkFailure(String? msg) : super('NetworkFailure', '$msg');
}

/// 用户输入的格式没有问题, 只是参数值无效, 例如密码错误
class InvalidInputWithoutFeedbackFailure extends Failure {
  InvalidInputWithoutFeedbackFailure(String? msg) : super('[请检查后重试]', '$msg');
}

/// 未知错误,需要反馈
class FeedBackUnknownFailure extends UnknownFailure with NeedFeedbackMx {
  FeedBackUnknownFailure(String? msg, [dynamic trace])
      : super('FeedBackUnknownFailure', '\n[$msg]\ntrace:\n[$trace]');
}
