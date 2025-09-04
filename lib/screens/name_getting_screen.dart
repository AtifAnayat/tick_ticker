import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_ticker/screens/home_screen.dart';

class UserNameScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const UserNameScreen({Key? key, required this.onThemeToggle})
    : super(key: key);

  @override
  _UserNameScreenState createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your name');
      return;
    }

    if (_nameController.text.trim().length < 2) {
      _showErrorDialog('Name must be at least 2 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setBool('first_time_user', false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeScreen(onThemeToggle: widget.onThemeToggle),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
                  .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              HugeIcons.strokeRoundedAlert02,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Oops!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height,
          ),
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color(0xFF0A0A0A),
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                        ]
                      : [
                          Colors.teal[50]!,
                          Colors.teal[100]!,
                          Colors.teal[200]!,
                        ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: IconButton(
                                icon: Icon(
                                  isDark
                                      ? HugeIcons.strokeRoundedSun01
                                      : HugeIcons.strokeRoundedMoon02,
                                  color: isDark
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.teal[600],
                                ),
                                onPressed: widget.onThemeToggle,
                              ),
                            );
                          },
                        ),
                      ),

                      // center content
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.teal,
                                          Colors.tealAccent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(0.3),
                                          blurRadius: 25,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      HugeIcons.strokeRoundedUser,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    'Welcome to',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tick Ticker',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey[800],
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.1)
                                          : Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.3)
                                            : Colors.teal.withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "What's your name?",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "We'd love to personalize your experience",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        TextField(
                                          controller: _nameController,
                                          focusNode: _focusNode,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[800],
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your name',
                                            hintStyle: GoogleFonts.poppins(
                                              color: isDark
                                                  ? Colors.white.withOpacity(
                                                      0.4,
                                                    )
                                                  : Colors.grey[400],
                                            ),
                                            prefixIcon: Icon(
                                              HugeIcons.strokeRoundedUser,
                                              color: isDark
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                  : Colors.teal[600],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.grey[100],
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 14,
                                                  horizontal: 20,
                                                ),
                                          ),
                                          onSubmitted: (_) => _saveName(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ScaleTransition(
                                    scale: _buttonAnimation,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                _buttonController
                                                    .forward()
                                                    .then((_) {
                                                      _buttonController
                                                          .reverse();
                                                      _saveName();
                                                    });
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.teal.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                        child: _isLoading
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Getting Ready...',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Let's Get Started",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    HugeIcons
                                                        .strokeRoundedArrowRight01,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
