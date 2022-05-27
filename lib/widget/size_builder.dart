import 'package:flutter/material.dart';

class SizeBuilder extends StatefulWidget {
  final Widget Function(Size? size) builder;

  const SizeBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SizeBuilderState();
}

class _SizeBuilderState extends State<SizeBuilder> {
  Size? _size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _size = context.size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_size);
  }
}
