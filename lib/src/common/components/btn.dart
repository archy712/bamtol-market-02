import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  // 버튼의 문구만 받을 수도 있지만, 확장성을 고려해서 위젯을 받음
  final Widget child;

  // onTap 이벤트를 부모 위젯에서 처리할 수 있도록
  final Function() onTap;

  // 버튼 간격
  final EdgeInsets padding;

  // 버튼 색상
  final Color color;

  // 비활성화 여부
  final bool disabled;

  const Btn({
    super.key,
    required this.child,
    required this.onTap,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    this.color = const Color(0xFFED7738),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!disabled) onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: Container(
          padding: padding,
          color: disabled ? Colors.grey : color,
          child: child,
        ),
      ),
    );
  }
}
