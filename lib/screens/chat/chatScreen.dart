import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
  late AnimationController _ccontroller;
  late AnimationController _mindcontroller;
  late AnimationController _rippleController;
  late AnimationController _mindboxcontroller;
  late AnimationController _sparkleController;
  late Animation<Color?> _colorAnimation;
  bool isListening = false;
  final ScrollController _scrollController = ScrollController();
  bool isThresholdReached = false;
  bool _isMessageBoxVisible = false;
  final FocusNode _focusNode = FocusNode();
  double _opacity = 0.0;
  bool _isLongPressing = false;
  String displayText = "Hold to Speak";
  late Timer _timer;
  bool _isReversing = false;
  final bool _isRippleDone = false;
  bool _showContainer = false;
  double _scale = 0.0;
  bool _isSendingMessage = false;
  bool isusersendingmessage = false;
  String voicetext = "";
  bool _shouldShowTextBox = false;
  bool _showMindText = true;
  late AnimationController _boxAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _animationController;
  final String sentence =
      "How about a rejuvenating walk outside? It's a great way to refresh your mind and uplift your spirits. ";
  late stt.SpeechToText speech;

  // Add variables to control auto scrolling behavior
  bool _userIsScrolling = false;
  bool _shouldAutoScroll = true;
  double _lastScrollPosition = 0.0;

  bool isquestion = false;
  final Color _backgroundColor = Colors.transparent;

  void requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Microphone permission denied");
    }
  }

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();
    requestPermissions();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showContainer = true;
        _scale = 1.0;
      });
    });

    // Add scroll controller listener
    _scrollController.addListener(_scrollListener);

    _mindcontroller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() {
        setState(() {
          _shouldShowTextBox = true;
        });
        if (_mindcontroller.value > 0.99 && !_isReversing) {
          _isReversing = true;
          _mindcontroller.reverse();
        } else if (_mindcontroller.value < 0.13 && _isReversing) {
          _isReversing = false;
          _mindcontroller.forward();
        }
      });

    _mindcontroller.forward();

    _mindboxcontroller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _videoController = VideoPlayerController.asset('assets/videos/chatBg.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
      });

    _ccontroller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.white,
    ).animate(_ccontroller);
    _ccontroller.forward();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _opacity = 1.0;
      });
    });
    _startTextSwitching();

    int textDurationMs = (sentence.length * 10) + 800;
    Duration textAnimationDuration = Duration(milliseconds: textDurationMs);

    _boxAnimationController = AnimationController(
      vsync: this,
      duration: textAnimationDuration,
    );

    _glowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _boxAnimationController.forward();
    _glowAnimationController.forward();

    _controller.addListener(() {
      if (_controller.text.isNotEmpty && _showMindText) {
        setState(() {
          _showMindText = false;
          _shouldShowTextBox = false;
          _mindcontroller.stop();
        });
      } else if (_controller.text.isEmpty &&
          !_showMindText &&
          _isMessageBoxVisible) {
        setState(() {
          _showMindText = true;
          _shouldShowTextBox = true;
          _mindcontroller.reset();
          _mindcontroller.forward();
        });
      }
    });
  }

  // Add scroll listener to detect user scrolling
  void _scrollListener() {
    // If user is scrolling manually (not our programmatic scrolls)
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      _userIsScrolling = true;
      _lastScrollPosition = _scrollController.position.pixels;

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
    _rippleController.dispose();
    _animationController.dispose();
    _mindcontroller.dispose();
    _mindboxcontroller.dispose();
    _boxAnimationController.dispose();
    _glowAnimationController.dispose();
    _ccontroller.dispose();
    _sparkleController.dispose();
    _timer.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    super.dispose();
  }

  void _startlisten() async {
    bool available = await speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      setState(() {
        isListening = true;
      });
      speech.listen(
        onResult: (result) {
          setState(() {
            voicetext = result.recognizedWords;
          });
        },
      );
    }
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

  void _stopListening() {
    setState(() => isListening = false);
    speech.stop();
    setState(() {
      voicetext = "";
    });
  }

  void checkquestion(String text) {
    text = text.trim();
    if (text.endsWith("?")) {
      setState(() {
        isquestion = true;
      });
      print("true");
    } else {
      List<String> questionWords = [
        "what",
        "where",
        "why",
        "how",
        "explain",
        "some tips",
        "give",
        "any",
        "advise me",
        "brief me",
        "share",
        "list",
        "can you",
        "can we",
        "could you",
        "could we",
        "do you",
        "i need",
        "suggest",
        "is it",
        "are we",
        "are you",
        "do you",
        "does anyone",
        "should i",
        "should we",
        "gonna",
        "wanna",
        "shall we",
        "shouldn't we",
        "wouldn't it",
        "haven't you",
        "hasn't she",
        "hasn't he",
        "hasn't it",
        "didn't she",
        "didn't he",
        "aren't",
        "would you",
        "will that work"
      ];

      List<String> words = text.toLowerCase().split(RegExp(r'\s+'));

      if (questionWords.contains(words.first)) {
        print("true");
        setState(() {
          isquestion = true;
        });
      } else {
        print("false");
        setState(() {
          isquestion = false;
        });
      }
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _showMindText = false;
      _shouldShowTextBox = false;
      _mindcontroller.stop();
      _rippleController.reset();
      _rippleController.forward();
      _startlisten();
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      if (voicetext.isNotEmpty) {
        _sendCard(voicetext);
      }
      _isLongPressing = false;
      _showMindText = true;
      _shouldShowTextBox = true;
      _mindcontroller.reset();
      _mindcontroller.forward();
      _stopListening();
    });
  }

  void _sendMessage(String response) {
    if (!mounted) return;

    final String messageText =
        _controller.text.isNotEmpty ? _controller.text.trim() : voicetext;
    _controller.clear();

    checkquestion(messageText);

    AnimationController animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, -3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutQuint,
    ));

    if (mounted) {
      setState(() {
        Future.delayed(Duration(milliseconds: 0), () {
          _isSendingMessage = true;
        });
        if (messageText.isNotEmpty) {
          messages.add(AnimatedMessageBubble(
            message: messageText,
            alignment: Alignment.centerRight,
            animation: slideAnimation,
            controller: animationController,
            bubbleColor: Colors.white,
            textColor: Colors.black,
          ));

          // Set auto-scroll to true when sending new message
          _shouldAutoScroll = true;
          Future.delayed(Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        }
      });
    }

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        AnimationController replyController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 10),
        );

        Animation<Color?> colorAnimation = TweenSequence<Color?>(
          [
            TweenSequenceItem(
              tween: ColorTween(begin: Colors.white10, end: Colors.white30)
                  .chain(CurveTween(curve: Curves.easeIn)),
              weight: 50.0,
            ),
            TweenSequenceItem(
              tween: ColorTween(begin: Colors.white30, end: Colors.white10)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 50.0,
            ),
          ],
        ).animate(replyController);

        double iconOpacity = 0.0;
        bool repeatGlow = true;
        bool isGlowVisible = true;
        bool isBoxVisible = false;
        int textDurationMs = (response.length * 10) + 800;

        late AnimationController gradientcontroller;

        gradientcontroller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 800),
        );

        gradientcontroller.forward();

        late AnimationController imagecontroller;
        double opacity = 0.0;
        bool applyBlur = false;
        bool outerGlow = true;

        imagecontroller = AnimationController(vsync: this);

        imagecontroller.addListener(() {
          setState(() {
            opacity = imagecontroller.value;
          });
        });
        imagecontroller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              applyBlur = true;
            });
          }
        });

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 80),
          curve: Curves.easeOut,
        );

        setState(() {
          messages.add(
            StatefulBuilder(
              builder: (context, setLocalState) {
                if (context.mounted) {
                  Future.delayed(Duration(milliseconds: isquestion ? 2000 : 0),
                      () {
                    if (context.mounted) {
                      setLocalState(() {
                        isBoxVisible = true;
                      });
                    }

                    Future.delayed(Duration(milliseconds: 800), () {
                      if (context.mounted) {
                        if (context.mounted) {
                          setLocalState(() {
                            isGlowVisible = false;

                            Future.delayed(Duration(milliseconds: 500), () {
                              if (context.mounted) {
                                setLocalState(() {
                                  iconOpacity = 1.0;
                                  repeatGlow = false;
                                });
                              }
                            });
                          });
                        }
                      }
                    });
                  });
                }

                return AnimatedBuilder(
                  animation: colorAnimation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          children: [
                            if (isGlowVisible)
                              Lottie.asset(
                                'assets/animations/All Lottie/Glowing Star/Image Preload Gradient.json',
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                fit: BoxFit.cover,
                                repeat: false,
                              ),
                            if (isBoxVisible) ...[
                              Lottie.asset(
                                "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
                                width: MediaQuery.of(context).size.width * 0.87,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.fill,
                                repeat: false,
                              ),
                              if (outerGlow)
                                Lottie.asset(
                                  "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
                                  width:
                                      MediaQuery.of(context).size.width * 0.87,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  fit: BoxFit.fill,
                                  repeat: repeatGlow,
                                ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, left: 18, right: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 10, left: 5, right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextAnimator(
                                              "Here is a reference to the card",
                                              incomingEffect:
                                                  WidgetTransitionEffects(
                                                      blur:
                                                          const Offset(10, 10),
                                                      duration: const Duration(
                                                          milliseconds: 800)),
                                              outgoingEffect:
                                                  WidgetTransitionEffects(
                                                      blur:
                                                          const Offset(10, 10)),
                                              atRestEffect:
                                                  WidgetRestingEffects.wave(
                                                      effectStrength: 0.2,
                                                      duration: Duration(
                                                          milliseconds: 750),
                                                      numberOfPlays: 1),
                                              style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                fontFamily: "Original",
                                                letterSpacing: 1,
                                                fontSize: 14,
                                                color: Colors.white,
                                              )),
                                              textAlign: TextAlign.left,
                                              initialDelay: const Duration(
                                                  milliseconds: 0),
                                              spaceDelay: const Duration(
                                                  milliseconds: 100),
                                              characterDelay: const Duration(
                                                  milliseconds: 10),
                                              maxLines: 8,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(top: 10),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: AnimatedOpacity(
                                                      duration: Duration(
                                                          milliseconds: 100),
                                                      curve: Curves.easeInOut,
                                                      opacity:
                                                          ((opacity - 0.5) <=
                                                                  0.0)
                                                              ? 0
                                                              : opacity - 0.5,
                                                      child: Image.asset(
                                                        'assets/images/login.jpg',
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                        height: 200,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned.fill(
                                                    child: Lottie.asset(
                                                      'assets/animations/gradient.json',
                                                      fit: BoxFit.cover,
                                                      repeat: false,
                                                      controller:
                                                          imagecontroller,
                                                      onLoaded: (composition) {
                                                        imagecontroller
                                                          ..duration =
                                                              composition
                                                                  .duration
                                                          ..forward();
                                                      },
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    left: 30,
                                                    right: 50,
                                                    child: AnimatedOpacity(
                                                      duration: Duration(
                                                          milliseconds: 800),
                                                      curve: Curves.easeIn,
                                                      opacity: opacity >= 0.8
                                                          ? 1.0
                                                          : 0.0,
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            imagecontroller,
                                                        builder:
                                                            (context, child) {
                                                          return Transform
                                                              .translate(
                                                            offset: Offset(
                                                                0,
                                                                imagecontroller
                                                                            .value <
                                                                        0.8
                                                                    ? 20
                                                                    : 0),
                                                            child: Text(
                                                              "Dolphins Doing a Backflip in the Ocean",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              margin: EdgeInsets.only(top: 1),
                                              child: AnimatedOpacity(
                                                duration:
                                                    Duration(milliseconds: 500),
                                                opacity: iconOpacity,
                                                curve: Curves.easeIn,
                                                child: SizedBox(
                                                  height: 30,
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {},
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .heart,
                                                          color: Colors.white,
                                                          size: 10,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      IconButton(
                                                        onPressed: () {},
                                                        icon: FaIcon(
                                                          FontAwesomeIcons.plus,
                                                          color: Colors.white,
                                                          size: 10,
                                                        ),
                                                      ),
                                                      SizedBox(width: 45),
                                                      TextButton.icon(
                                                        onPressed: () {},
                                                        icon: Text(
                                                          "View More",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 8,
                                                          ),
                                                        ),
                                                        label: Icon(
                                                          Icons.arrow_forward,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        });
      }
    });
  }

  void _sendCard(String response) {
    if (true) {
      final String messageText =
          _controller.text.isNotEmpty ? _controller.text.trim() : voicetext;
      _controller.clear();

      checkquestion(messageText);

      if (isquestion && _scrollController.hasClients) {
        // Modified to use our new scroll method that respects user scrolling
        _shouldAutoScroll = true;
        _scrollToBottom(duration: Duration(milliseconds: 300));
      }

      AnimationController animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );

      if (isquestion) {
        animationController.addListener(() {
          if (animationController.value >= 0.65 && !isThresholdReached) {
            setState(() {
              _isSendingMessage = true;
            });
            print("State changed at 85% progress");
          }
        });
      }

      Animation<Offset> slideAnimation = Tween<Offset>(
        begin: const Offset(-10, 80),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutQuint,
      ));

      setState(() {
        Future.delayed(Duration(milliseconds: 0), () {
          _isSendingMessage = true;
          isThresholdReached = isquestion ? false : true;
        });

        messages.add(AnimatedMessageBubble(
          message: messageText,
          alignment: Alignment.centerRight,
          animation: slideAnimation,
          controller: animationController,
          bubbleColor: Colors.white,
          textColor: Colors.black,
        ));
      });

      animationController.forward();

      animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          Future.delayed(Duration(milliseconds: 6300), () {
            if (mounted) {
              setState(() {
                isquestion = false;
                _isSendingMessage = false;
              });
            }
          });

          AnimationController replyController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 10),
          );

          Animation<Color?> colorAnimation = TweenSequence<Color?>(
            [
              TweenSequenceItem(
                tween: ColorTween(begin: Colors.white10, end: Colors.white30)
                    .chain(CurveTween(curve: Curves.easeIn)),
                weight: 50.0,
              ),
              TweenSequenceItem(
                tween: ColorTween(begin: Colors.white30, end: Colors.white10)
                    .chain(CurveTween(curve: Curves.easeOut)),
                weight: 50.0,
              ),
            ],
          ).animate(replyController);

          double iconOpacity = 0.0;
          bool repeatGlow = true;
          bool isGlowVisible = true;
          bool isBoxVisible = false;

          late AnimationController gradientcontroller;

          gradientcontroller = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 800),
          );

          gradientcontroller.forward();

          late AnimationController imagecontroller;
          double opacity = 0.0;
          bool applyBlur = false;
          double opacityLevel = 1.0;

          bool isQuesAnimVisible = true;

          imagecontroller = AnimationController(vsync: this);

          imagecontroller.addListener(() {
            setState(() {
              opacity = imagecontroller.value;
            });
          });
          imagecontroller.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                applyBlur = true;
              });
            }
          });
          void decreaseOpacity() async {
            for (double i = 1.0; i >= 0.0; i -= 0.05) {
              await Future.delayed(
                  Duration(milliseconds: 100)); // Smooth transition
              setState(() {
                opacityLevel = i;
              });
            }
          }

          setState(() {
            isusersendingmessage = true;
            messages.add(
              StatefulBuilder(
                builder: (context, setLocalState) {
                  Future.delayed(Duration(milliseconds: 2100), () {
                    if (mounted) {
                      setLocalState(() {
                        decreaseOpacity();

                        Future.delayed(Duration(milliseconds: 500), () {
                          setLocalState(() {
                            isGlowVisible = false;
                          });
                        });
                      });
                    }
                  });
                  Future.delayed(
                      Duration(milliseconds: isquestion ? 2800 : 2400), () {
                    setLocalState(() {
                      isBoxVisible = true;
                      Future.delayed(Duration(milliseconds: 800), () {
                        setLocalState(() {
                          iconOpacity = 1.0;
                          repeatGlow = false;
                          isQuesAnimVisible = false;
                        });
                        isquestion
                            ? setState(() {
                                isThresholdReached = false;
                              })
                            : null;
                      });
                    });
                  });

                  _scrollToBottom(duration: Duration(milliseconds: 300));

                  return AnimatedBuilder(
                    animation: colorAnimation,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            children: [
                              if (isGlowVisible || isQuesAnimVisible)
                                AnimatedOpacity(
                                  opacity: opacityLevel,
                                  duration: Duration(
                                      milliseconds: isquestion ? 170 : 300),
                                  child: Lottie.asset(
                                    isquestion
                                        ? "assets/animations/QnA/2. Circle/data.json"
                                        : 'assets/animations/All Lottie/Glowing Star/Image Preload Gradient.json',
                                    width: isquestion
                                        ? MediaQuery.of(context).size.width *
                                            0.65
                                        : MediaQuery.of(context).size.width *
                                            0.8,
                                    height: isquestion
                                        ? MediaQuery.of(context).size.height *
                                            0.25
                                        : MediaQuery.of(context).size.height *
                                            0.3,
                                    fit: BoxFit.cover,
                                    repeat: true,
                                  ),
                                ),
                              if (isBoxVisible) ...[
                                Lottie.asset(
                                  "assets/animations/Inner+Outerbox+Glow/Outerbox/Outerbox.json",
                                  width:
                                      MediaQuery.of(context).size.width * 0.87,
                                  height:
                                      MediaQuery.of(context).size.height * 0.33,
                                  fit: BoxFit.fill,
                                  repeat: false,
                                ),
                                Lottie.asset(
                                  "assets/animations/Inner+Outerbox+Glow/Outer Glow/Outerbox.json",
                                  width:
                                      MediaQuery.of(context).size.width * 0.87,
                                  height:
                                      MediaQuery.of(context).size.height * 0.33,
                                  fit: BoxFit.fill,
                                  repeat: repeatGlow,
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, left: 18, right: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 10, left: 5, right: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextAnimator(
                                                "Here is a reference to the card",
                                                incomingEffect:
                                                    WidgetTransitionEffects(
                                                        blur: const Offset(
                                                            10, 10),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    800)),
                                                outgoingEffect:
                                                    WidgetTransitionEffects(
                                                        blur: const Offset(
                                                            10, 10)),
                                                atRestEffect:
                                                    WidgetRestingEffects.wave(
                                                        effectStrength: 0.2,
                                                        duration: Duration(
                                                            milliseconds: 750),
                                                        numberOfPlays: 1),
                                                style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                  fontFamily: "Original",
                                                  letterSpacing: 1,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                )),
                                                textAlign: TextAlign.left,
                                                initialDelay: const Duration(
                                                    milliseconds: 0),
                                                spaceDelay: const Duration(
                                                    milliseconds: 100),
                                                characterDelay: const Duration(
                                                    milliseconds: 10),
                                                maxLines: 8,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 10, left: 10),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: AnimatedOpacity(
                                                        duration: Duration(
                                                            milliseconds: 100),
                                                        curve: Curves.easeInOut,
                                                        opacity:
                                                            ((opacity - 0.3) <=
                                                                    0.0)
                                                                ? 0
                                                                : opacity - 0.3,
                                                        child: Image.asset(
                                                          'assets/images/login.jpg',
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Lottie.asset(
                                                        'assets/animations/gradient.json',
                                                        fit: BoxFit.cover,
                                                        repeat: false,
                                                        controller:
                                                            imagecontroller,
                                                        onLoaded:
                                                            (composition) {
                                                          imagecontroller
                                                            ..duration =
                                                                composition
                                                                    .duration
                                                            ..forward()
                                                                .then((value) {
                                                              setState(() {
                                                                applyBlur =
                                                                    true;
                                                              });
                                                            });
                                                        },
                                                      ),
                                                    ),
                                                    if (applyBlur)
                                                      Positioned(
                                                        bottom: 0,
                                                        left: 0,
                                                        right: 0,
                                                        child: Opacity(
                                                          opacity: 0.26,
                                                          child: Image.asset(
                                                            'assets/images/blur.jpeg',
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.07,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    Positioned(
                                                      bottom: 10,
                                                      left: 20,
                                                      right: 20,
                                                      child: AnimatedOpacity(
                                                        duration: Duration(
                                                            milliseconds: 800),
                                                        curve: Curves.easeIn,
                                                        opacity: opacity >= 0.8
                                                            ? 1.0
                                                            : 0.0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              imagecontroller,
                                                          builder:
                                                              (context, child) {
                                                            return Transform
                                                                .translate(
                                                              offset: Offset(
                                                                  0,
                                                                  imagecontroller
                                                                              .value <
                                                                          0.8
                                                                      ? 20
                                                                      : 0),
                                                              child: Text(
                                                                "Dolphins Doing a Backflip in the Ocean",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          });
        }
      });
    }
  }

  void _toggleMessageBoxVisibility() {
    setState(() {
      _isMessageBoxVisible = !_isMessageBoxVisible;
      if (_isMessageBoxVisible) {
        if (_controller.text.isNotEmpty) {
          _showMindText = false;
          _shouldShowTextBox = false;
          _mindcontroller.stop();
        }
      } else {
        _showMindText = true;
        _shouldShowTextBox = true;
        _mindcontroller.reset();
        _mindcontroller.forward();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (isThresholdReached)
            Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Lottie.asset(
                    'assets/animations/All Lottie/BG Glow Gradient/3 in 1/BG Glow Gradient.json',
                    fit: BoxFit.cover,
                    repeat: false,
                    onLoaded: (composition) {
                      Future.delayed(
                        composition.duration + Duration(milliseconds: 390),
                        () {
                          setState(() {
                            _isSendingMessage = false;
                            isThresholdReached = false;
                          });
                        },
                      );
                    },
                  )),
            ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: EdgeInsets.only(left: 8, top: 10),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isThresholdReached
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.more_horiz,
                              color: Colors.white, size: 22),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 10),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isThresholdReached
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.stacked_bar_chart,
                                color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (messages.isEmpty)
                      Stack(
                        children: [
                          AnimatedOpacity(
                            opacity: _shouldShowTextBox ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                            child: Center(
                              child: Lottie.asset(
                                'assets/animations/BG small Blur/BG small Blur.json',
                                width: screenWidth / 0.9,
                                height: screenHeight / 1.8,
                                fit: BoxFit.fill,
                                controller: _mindcontroller,
                              ),
                            ),
                          ),
                          if (_shouldShowTextBox)
                            Center(
                              child: AnimatedOpacity(
                                opacity:
                                    _showContainer && _showMindText ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 1500),
                                curve: Curves.easeInOut,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: screenWidth / 2.15,
                                    height: screenHeight / 13,
                                    color: Colors.white.withOpacity(0.1),
                                    padding: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "What's on your mind?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: screenWidth * 0.038,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            physics:
                                AlwaysScrollableScrollPhysics(), // Ensure always scrollable
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.only(
                                  bottom: (index == 0 && _isLongPressing)
                                      ? screenHeight * 0.15
                                      : 0,
                                ),
                                child: messages[index],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              if (!_isSendingMessage)
                                GestureDetector(
                                  onTap: _toggleMessageBoxVisibility,
                                  onLongPressStart: _onLongPressStart,
                                  onLongPressEnd: _onLongPressEnd,
                                  onLongPressDown: (_) {},
                                  onLongPressUp: () {},
                                  child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: _isMessageBoxVisible ||
                                              _isLongPressing
                                          ? Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            )
                                          : Icon(
                                              Icons.blur_circular,
                                              color: Colors.white,
                                              size: 45,
                                            )),
                                ),
                              const SizedBox(width: 8),
                              if (_isMessageBoxVisible && !_isSendingMessage)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: "Message",
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              if (_isMessageBoxVisible &&
                                  _controller.text.isNotEmpty)
                                IconButton(
                                  onPressed: () => _sendCard(_controller.text),
                                  icon: const Icon(Icons.send),
                                  color: Colors.white54,
                                ),
                              if (!_isMessageBoxVisible)
                                Container(
                                  margin: EdgeInsets.only(left: 2),
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 2000),
                                    opacity: _opacity,
                                    child: Row(
                                      children: [
                                        if (!_isLongPressing) ...[
                                          Icon(
                                            Icons.circle_sharp,
                                            color: Color(0xFFA715E9),
                                            size: 6,
                                          ),
                                          SizedBox(width: 2),
                                          TextAnimator(
                                            displayText,
                                            incomingEffect:
                                                WidgetTransitionEffects(
                                                    blur: const Offset(10, 10),
                                                    duration: const Duration(
                                                        milliseconds: 500)),
                                            outgoingEffect:
                                                WidgetTransitionEffects(
                                                    blur: const Offset(10, 10)),
                                            atRestEffect:
                                                WidgetRestingEffects.wave(
                                                    effectStrength: 0.2,
                                                    duration: Duration(
                                                        milliseconds: 750),
                                                    numberOfPlays: 1),
                                            style: TextStyle(
                                                fontFamily: "Original",
                                                color: Colors.white,
                                                fontSize: 15),
                                            textAlign: TextAlign.left,
                                            initialDelay:
                                                const Duration(milliseconds: 0),
                                            spaceDelay: const Duration(
                                                milliseconds: 100),
                                            characterDelay: const Duration(
                                                milliseconds: 10),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isLongPressing)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: screenHeight * 0.4,
                                alignment: Alignment.bottomCenter,
                                child: Lottie.asset(
                                  "assets/animations/All Lottie/Down Ripple/Ripple.json",
                                  width: MediaQuery.of(context).size.width,
                                  height: screenHeight * 0.25,
                                  fit: BoxFit.fill,
                                  repeat: true,
                                  animate: true,
                                  controller: _rippleController,
                                ),
                              ),
                              if (voicetext.isNotEmpty)
                                Positioned(
                                  bottom: screenHeight * 0.08,
                                  left: 16,
                                  right: 16,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: TextAnimator(
                                      voicetext,
                                      incomingEffect: WidgetTransitionEffects
                                          .incomingSlideInFromBottom(),
                                      outgoingEffect: WidgetTransitionEffects
                                          .outgoingSlideOutToBottom(),
                                      atRestEffect: WidgetRestingEffects.wave(
                                          numberOfPlays: 1,
                                          effectStrength: 0.2),
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
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
          ),
        ],
      ),
    );
  }
}

class AnimatedMessageBubble extends StatelessWidget {
  final String message;
  final Alignment alignment;
  final Animation<Offset> animation;
  final AnimationController controller;
  final Color bubbleColor;
  final Color textColor;

  const AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.alignment,
    required this.animation,
    required this.controller,
    required this.bubbleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Align(
          alignment: alignment,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              message,
              style: TextStyle(color: textColor),
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
