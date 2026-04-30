import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fahman_app/core/services/routes.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/features/inquiry/data/inquiry_remote_data_source.dart';
import 'package:fahman_app/features/inquiry/data/inquiry_repository.dart';
import 'package:fahman_app/features/inquiry/logic/inquiry_cubit.dart';
import 'package:fahman_app/features/inquiry/ui/widget/chat_message.dart';
import 'package:fahman_app/features/inquiry/ui/widget/message_bubble.dart';
import 'package:fahman_app/features/inquiry/ui/widget/welcome_message.dart';
import 'package:fahman_app/features/inquiry/ui/widget/history_menu.dart';

class InquiryScreen extends StatefulWidget {
  final String? initialMessage;

  const InquiryScreen({super.key, this.initialMessage});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _listening = false;
  final List<ChatMessage> _messages = [];
  bool _loadingReply = false;
  late final InquiryCubit _cubit;
  late final InquiryRepository _repo;
  String? _activeConversationId;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller.addListener(() => setState(() {}));
    // init API and cubit once
    final dio = Dio();
    dio.interceptors.add(ApiInterceptor());
    final api = DioConsumer(dio: dio);
    final ds = InquiryRemoteDataSource(api: api);
    _repo = InquiryRepository(remote: ds);
    _cubit = InquiryCubit(repository: _repo);
    _cubit.loadConversations(pageNumber: 1, pageSize: 20);

    // If there's an initial message from voice recording, send it automatically
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage(widget.initialMessage!);
      });
    }
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
    HistoryMenu.show(context, _cubit);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Stop voice recording if it's active
    if (_listening) {
      _speech.stop();
      setState(() => _listening = false);
    }

    _controller.clear();
    _focusNode.unfocus();

    // Add user message optimistically so it appears immediately
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loadingReply = true;
    });
    _scrollToBottom();

    // Use cubit to send message - it will handle state and update conversations
    _cubit.sendMessage(message: text, conversationId: _activeConversationId);
  }

  void _sendInitialMessage(String message) {
    // Add user message optimistically
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _loadingReply = true;
    });
    _scrollToBottom();
    // Send the initial message from voice recording
    _cubit.sendMessage(message: message, conversationId: _activeConversationId);
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

  // Removed unused _fetchReply and _pickDocument to satisfy lints

  @override
  Widget build(BuildContext context) {
    // Provide initialized cubit instance
    return BlocProvider<InquiryCubit>.value(
      value: _cubit,
      child: Scaffold(
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
        body: BlocConsumer<InquiryCubit, InquiryState>(
          listener: (context, state) {
            // Sync active conversation ID
            if (state.activeConversationId != null) {
              _activeConversationId = state.activeConversationId;
            }

            // When cubit finishes sending (isSending went false) or loads
            // history, replace local messages with the full server list.
            // This merges the optimistic user message with the real AI response.
            if (!state.isSending && state.messages.isNotEmpty) {
              _messages
                ..clear()
                ..addAll(
                  state.messages.map(
                    (m) =>
                        ChatMessage(text: m.content, isUser: m.role == 'user'),
                  ),
                );
              _loadingReply = false;
              _scrollToBottom();
            }

            // If still sending, keep the loading indicator (already set in _send)
            if (state.isSending) {
              _loadingReply = true;
            }

            // When loading messages from history
            if (state.isLoadingMessages) {
              _loadingReply = true;
            }

            // Show error if any
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              _loadingReply = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ui.Color.fromARGB(255, 73, 47, 97),
                          AppColors.black,
                        ],
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
                              return const WelcomeMessage();
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              itemCount:
                                  _messages.length + (_loadingReply ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _messages.length) {
                                  final msg = _messages[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Align(
                                      alignment: msg.isUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: MessageBubble(
                                        text: msg.text,
                                        maxHeight: msg.isUser ? 300.h : 400.h,
                                        scrollable: true,
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
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 120.h,
                                        ),
                                        child: TextField(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction:
                                              TextInputAction.newline,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign:
                                              context.locale.languageCode ==
                                                      'ar'
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                          decoration: InputDecoration(
                                            hintText:
                                                context.locale.languageCode ==
                                                        'ar'
                                                    ? 'auth_search_hint'.tr()
                                                    : 'Search your case',
                                            hintStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
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
                            ],
                          ),
                        ),
                      ),
                    ],
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
