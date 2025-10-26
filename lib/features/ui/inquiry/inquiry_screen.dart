import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_selector/file_selector.dart';
import 'package:fahman_app/core/routing/routes.dart';
import 'package:fahman_app/core/auth/auth_session.dart';
import 'dart:ui';

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _listening = false;
  final List<_ChatMessage> _messages = [];
  bool _loadingReply = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (s) {},
      onError: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('mic_unavailable'.tr())));
      },
    );
    if (!available) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('mic_unavailable'.tr())));
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: context.locale.languageCode,
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
    );
  }

  void _showHistoryMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Material(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(25.r),
                          child: Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: TextField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: 'بحث',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16.sp,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: 20.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 15.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Expanded(
                        child: _getGroupedHistoryItems().isEmpty
                            ? Center(
                                child: Text(
                                  'no_history_available'.tr(),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                itemCount: _getGroupedHistoryItems().length,
                                itemBuilder: (context, index) {
                                  final group =
                                      _getGroupedHistoryItems()[index];
                                  return _buildHistoryGroup(group);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getGroupedHistoryItems() {
    return [];
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? 'legal';
    final title = item['title']?.toString() ?? '';
    final subtitle = item['subtitle']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: type == 'criminal'
                  ? Colors.red.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              type == 'criminal' ? Icons.gavel : Icons.business,
              color: type == 'criminal' ? Colors.red : Colors.blue,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['time'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
              ),
              SizedBox(height: 4.h),
              Icon(Icons.chevron_right, color: Colors.grey[500], size: 16.sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryGroup(Map<String, dynamic> group) {
    final items =
        group['items'] as List<Map<String, dynamic>>? ??
        <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group title
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
          child: Text(
            group['groupTitle']?.toString() ?? '',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Group items
        ...items.map((item) => _buildHistoryItem(item)).toList(),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(const _ChatMessage(text: '', isUser: true));
    });
    setState(() {
      _messages[_messages.length - 1] = _ChatMessage(text: text, isUser: true);
      _loadingReply = true;
    });
    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();
    _fetchReply(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _fetchReply(String query) async {
    setState(() => _loadingReply = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      final reply = 'auth_demo_reply'.tr();
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
      _scrollToBottom();
    } catch (_) {
      setState(() {
        _messages.add(
          _ChatMessage(text: 'auth_server_error'.tr(), isUser: false),
        );
      });
      _scrollToBottom();
    } finally {
      setState(() => _loadingReply = false);
    }
  }

  Future<void> _pickImage() async {
    final typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['png', 'jpg', 'jpeg'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(file.name)));
    }
  }

  Future<void> _pickDocument() async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'doc', 'docx'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(file.name)));
    }
  }

  void _addAction() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add action')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56.h,
        titleSpacing: 0,
        title: Text(
          'inquiry_appbar_title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          tooltip: 'home',
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dehaze, color: Colors.white),
            onPressed: () {
              _showHistoryMenu(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [ui.Color.fromARGB(255, 73, 47, 97), AppColors.black],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_messages.isEmpty && !_loadingReply) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100.h,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/ropot.gif',
                                  gaplessPlayback: true,
                                  height: 100.h,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'inquiry_welcome_headline'.tr(
                                      namedArgs: {
                                        'name':
                                            (AuthSession().username ??
                                            'مستخدم'),
                                      },
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'inquiry_welcome_sub'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        itemCount: _messages.length + (_loadingReply ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _messages.length) {
                            final msg = _messages[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Align(
                                alignment: msg.isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: _MessageBubble(
                                  text: msg.text,
                                  maxHeight: msg.isUser ? 160.h : 220.h,
                                  scrollable: !msg.isUser,
                                ),
                              ),
                            );
                          }
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _listening
                                      ? Icons.stop_circle_outlined
                                      : Icons.mic_none,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleListening,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: context.locale.languageCode == 'ar'
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: InputDecoration(
                                    hintText:
                                        context.locale.languageCode == 'ar'
                                        ? 'auth_search_hint'.tr()
                                        : 'Search your case',
                                    hintStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              if (_controller.text.trim().isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: _send,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _RoundIconButton(
                              icon: Icons.camera_alt_outlined,
                              onTap: _pickImage,
                            ),
                            SizedBox(width: 8.w),
                            _RoundIconButton(
                              icon: Icons.add_photo_alternate_outlined,
                              onTap: _pickImage,
                            ),
                            SizedBox(width: 8.w),
                            _RoundIconButton(
                              icon: Icons.add,
                              onTap: _addAction,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        splashColor: Colors.white24,
        hoverColor: Colors.white10,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final double maxHeight;
  final bool scrollable;
  const _MessageBubble({
    required this.text,
    required this.maxHeight,
    required this.scrollable,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 0.78.sw),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.6),
        textAlign: TextAlign.right,
      ),
    );

    if (!scrollable) return bubble;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(padding: EdgeInsets.zero, child: bubble),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}
