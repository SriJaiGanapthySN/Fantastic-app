// ignore_for_file: file_names
import 'dart:async';
import 'package:fab/components/chat/chat_app_bar.dart';
import 'package:fab/components/chat/chat_background.dart';
import 'package:fab/components/chat/chat_content.dart';
import 'package:fab/factories/message_factory.dart';
import 'package:fab/managers/animation_controller_manager.dart';
import 'package:fab/services/speech_recognition_service.dart';
import 'package:fab/utils/question_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final String email;

  const ChatScreen({super.key, required this.email});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Widget> messages = [];
  final TextEditingController _controller = TextEditingController();
  late VideoPlayerController _videoController;
  late AnimationControllerManager _animationManager;
  late SpeechRecognitionService _speechService;
  late MessageFactory _messageFactory;
  final ScrollController _scrollController = ScrollController();

  // State variables
  bool isThresholdReached = false;
  bool _isMessageBoxVisible = false;
  final FocusNode _focusNode = FocusNode();
  double _opacity = 0.0;
  bool _isLongPressing = false;
  String displayText = "Hold to Speak";
  late Timer _timer;
  bool _showContainer = false;
  bool _isSendingMessage = false;
  bool isusersendingmessage = false;
  bool _shouldShowTextBox = false;
  bool _showMindText = true;
  final String sentence =
      "How about a rejuvenating walk outside? It's a great way to refresh your mind and uplift your spirits. ";

  // Add variables to control auto scrolling behavior
  bool _userIsScrolling = false;
  bool _shouldAutoScroll = true;
  bool isquestion = false;

  @override
  void initState() {
    super.initState();

    _speechService = SpeechRecognitionService();
    _speechService.initialize();

    _animationManager = AnimationControllerManager(this);
    _messageFactory = MessageFactory(this);

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showContainer = true;
      });
    });

    // Add scroll controller listener
    _scrollController.addListener(_scrollListener);

    _videoController = VideoPlayerController.asset('assets/videos/chatBg.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
      });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    _startTextSwitching();

    _controller.addListener(_handleTextInputChange);
  }

  void _handleTextInputChange() {
    if (_controller.text.isNotEmpty && _showMindText) {
      setState(() {
        _showMindText = false;
        _shouldShowTextBox = false;
        _animationManager.stopMindAnimation();
      });
    } else if (_controller.text.isEmpty &&
        !_showMindText &&
        _isMessageBoxVisible) {
      setState(() {
        _showMindText = true;
        _shouldShowTextBox = true;
        _animationManager.startMindAnimation();
      });
    }
  }

  // Add scroll listener to detect user scrolling
  void _scrollListener() {
    // If user is scrolling manually (not our programmatic scrolls)
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      _userIsScrolling = true;

      // Check if user is near bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _shouldAutoScroll = true;
      } else {
        _shouldAutoScroll = false;
      }
    }
  }

  // Method to scroll to bottom with ability to be overridden by user scrolling
  void _scrollToBottom({Duration? duration}) {
    if (!_shouldAutoScroll && _userIsScrolling) return;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: duration ?? Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _animationManager.dispose();
    _timer.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _startTextSwitching() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        displayText =
            (displayText == "Hold to Speak") ? "Tap to Chat" : "Hold to Speak";
      });
    });
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _showMindText = false;
      _shouldShowTextBox = false;
      _animationManager.stopMindAnimation();
      _animationManager.resetRipple();
      _speechService.startListening();
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      if (_speechService.recognizedText.value.isNotEmpty) {
        _sendCard(_speechService.recognizedText.value);
      }
      _isLongPressing = false;
      _showMindText = true;
      _shouldShowTextBox = true;
      _animationManager.startMindAnimation();
      _speechService.stopListening();
      _speechService.clearText();
    });
  }

  void _sendCard(String voiceText) {
    final String messageText =
        _controller.text.isNotEmpty ? _controller.text.trim() : voiceText;
    _controller.clear();

    isquestion = QuestionDetector.isQuestion(messageText);

    if (isquestion && _scrollController.hasClients) {
      _shouldAutoScroll = true;
      _scrollToBottom(duration: Duration(milliseconds: 300));
    }

    setState(() {
      Future.delayed(Duration(milliseconds: 0), () {
        _isSendingMessage = true;
        isThresholdReached = isquestion ? false : true;
      });

      messages.add(
        _messageFactory.createUserMessage(
          messageText: messageText,
          onAnimationComplete: () {
            _handleUserMessageAnimationComplete();
          },
        ),
      );
    });
  }

  void _handleUserMessageAnimationComplete() {
    if (!mounted) return;

    Future.delayed(Duration(milliseconds: 6300), () {
      if (mounted) {
        setState(() {
          isquestion = false;
          _isSendingMessage = false;
        });
      }
    });

    setState(() {
      isusersendingmessage = true;
      messages.add(
        _messageFactory.createCardMessage(
          isQuestion: isquestion,
          onAnimationComplete: () {
            if (isquestion) {
              setState(() {
                isThresholdReached = false;
              });
            }
          },
        ),
      );
    });

    _scrollToBottom(duration: Duration(milliseconds: 300));
  }

  void _toggleMessageBoxVisibility() {
    setState(() {
      _isMessageBoxVisible = !_isMessageBoxVisible;
      if (_isMessageBoxVisible) {
        if (_controller.text.isNotEmpty) {
          _showMindText = false;
          _shouldShowTextBox = false;
          _animationManager.stopMindAnimation();
        }
      } else {
        _showMindText = true;
        _shouldShowTextBox = true;
        _animationManager.startMindAnimation();
      }
    });

    if (_isMessageBoxVisible) {
      Future.delayed(const Duration(milliseconds: 10), () {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background component
          ChatBackground(isThresholdReached: isThresholdReached),

          Column(
            children: [
              // App Bar component
              ChatAppBar(isThresholdReached: isThresholdReached),

              Expanded(
                child: ChatContent(
                  messages: messages,
                  scrollController: _scrollController,
                  textController: _controller,
                  focusNode: _focusNode,
                  isMessageBoxVisible: _isMessageBoxVisible,
                  isSendingMessage: _isSendingMessage,
                  isLongPressing: _isLongPressing,
                  rippleController: _animationManager.rippleController,
                  opacity: _opacity,
                  displayText: displayText,
                  voiceText: _speechService.recognizedText.value,
                  shouldShowTextBox: _shouldShowTextBox,
                  showMindText: _showMindText,
                  showContainer: _showContainer,
                  mindController: _animationManager.mindController,
                  toggleMessageBoxVisibility: _toggleMessageBoxVisibility,
                  onLongPressStart: _onLongPressStart,
                  onLongPressEnd: _onLongPressEnd,
                  sendMessage: _sendCard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
