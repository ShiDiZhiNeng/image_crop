export 'package:new_image_crop/extensions/template_extension.dart';

extension TemplateExtension<T> on T {
  ///任意对象扩展函数 返回本身
  T let(Function(T it) fun) {
    fun(this);
    return this;
  }

  ///任意对象扩展函数 返回new type
  R also<R>(R Function(T it) fun) => fun(this);

  ///任意对象扩展函数 无返回
  void go(Function(T it) fun) => fun(this);
}
