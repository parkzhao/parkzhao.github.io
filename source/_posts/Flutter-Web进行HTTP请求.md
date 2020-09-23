title: Flutter Web进行HTTP请求
date: 2020-09-22 10:01:20
tags:
---
最近进行`flutter web`开发的尝试，中间涉及到http请求数据。记录下来，希望能够帮到你。
```
import 'package:http/http.dart' as http;

class HttpOriginService {
  static Future<dynamic> post(BuildContext context,
      {String path, Map<String, dynamic> payLoad}) async {
    try {
      var response = await http.post(
        Uri.encodeFull(path),
        body: jsonEncode(payLoad),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // If the server did return a 200 CREATED response,
        // then parse the JSON.
        var result = json.decode(response.body);
        if (result != null) {
          BaseResp respo = BaseResp.fromJson(result);
          if (respo.status == 1) {
            ToastUtil.shortShow(respo.message);
          } else {
            return Future.value(respo.data);
          }
        } else {
          return Future.error('获取数据为空');
        }
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        Future.error('获取数据失败');
      }
    } on http.ClientException catch (e) {
      ToastUtil.shortShow("请求失败:${e.message}");
    } on Exception catch (e) {
      print(e);
      if (e is String) {
        ToastUtil.shortShow("请求失败:$e");
      }
    }
  }
}
```