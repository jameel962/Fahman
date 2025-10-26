import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthSplitScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final double topFraction;

  const AuthSplitScaffold({
    super.key,
    required this.header,
    required this.body,
    this.topFraction = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment(0, -0.4 + (0.25 - topFraction)),
                  child: header,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: body,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
