import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 반복적으로 사용하는 TextField 위젯을 공통 컴포넌트화
// StatefulWidget으로 제작 : 상품을 수정할 때 초기값을 설정해야 할 필요
// 초기값 설정하려면 TextEditingController 사용해야 함
// > StatefulWidget 라이프사이클 이용
class CommonTextField extends StatefulWidget {
  final String? hintText;
  final Color? hintColor;
  final String? initText;
  final int maxLines;
  final TextInputType textInputType;
  final List<FilteringTextInputFormatter>? inputFormatters;
  final Function(String)? onChange;

  const CommonTextField({
    super.key,
    this.hintText,
    this.hintColor,
    this.initText,
    this.textInputType = TextInputType.text,
    this.onChange,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CommonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initText == null) return;
    controller = TextEditingController(text: widget.initText);
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: widget.hintColor),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: widget.onChange,
    );
  }
}
