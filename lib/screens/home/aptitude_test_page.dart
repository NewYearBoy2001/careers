import 'package:flutter/material.dart';
import '../../data/aptitude_questions.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class AptitudeTestPage extends StatefulWidget {
  const AptitudeTestPage({super.key});

  @override
  State<AptitudeTestPage> createState() => _AptitudeTestPageState();
}

class _AptitudeTestPageState extends State<AptitudeTestPage> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, double> scores = {
    "Technology": 0.0,
    "Medical": 0.0,
    "Arts": 0.0,
    "Commerce": 0.0,
  };

  List<String> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void selectOption(String career, String optionText) {
    scores[career] = scores[career]! + 1;
    selectedAnswers.add(optionText);

    if (currentIndex < aptitudeQuestions.length - 1) {
      _animController.reset();
      setState(() => currentIndex++);
      _animController.forward();
    } else {
      showResult();
    }
  }

  void goBack() {
    if (currentIndex > 0) {
      final lastQuestion = aptitudeQuestions[currentIndex - 1];
      final lastAnswer = selectedAnswers.removeLast();

      // Find which career was selected and subtract score
      for (var option in lastQuestion["options"]) {
        if (option["text"] == lastAnswer) {
          scores[option["career"]] = scores[option["career"]]! - 1;
          break;
        }
      }

      _animController.reset();
      setState(() => currentIndex--);
      _animController.forward();
    }
  }

  void showResult() {
    final totalQuestions = aptitudeQuestions.length;
    final percentageScores = scores.map(
          (key, value) => MapEntry(key, ((value / totalQuestions) * 100).round()),
    );

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final topCareers = scores.entries
        .where((entry) => entry.value == maxScore)
        .map((e) => e.key)
        .toList();

    // Store results in a way that can be passed to next route
    context.go('/aptitude-result', extra: {
      'scores': percentageScores,
      'topCareers': topCareers,
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final question = aptitudeQuestions[currentIndex];
    final progress = (currentIndex + 1) / aptitudeQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: currentIndex > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textOnPrimary,
          onPressed: goBack,
        )
            : IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textOnPrimary,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Career Aptitude Test",
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Responsive.h(0.5)),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal3),
            minHeight: Responsive.h(0.5),
          ),
        ),
      ),
      body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.w(5)),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question counter
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(3),
                            vertical: Responsive.h(0.8),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.teal1, AppColors.teal2],
                            ),
                            borderRadius: BorderRadius.circular(Responsive.w(2)),
                          ),
                          child: Text(
                            "Question ${currentIndex + 1} of ${aptitudeQuestions.length}",
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: Responsive.sp(13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(height: Responsive.h(3)),

                        // Question text
                        Text(
                          question["question"],
                          style: TextStyle(
                            fontSize: Responsive.sp(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: Responsive.h(4)),

                        // Options
                        ...List.generate(
                          question["options"].length,
                              (index) {
                            final option = question["options"][index];
                            return _buildOptionCard(
                              option["text"],
                              option["career"],
                              index,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom info
            Container(
              padding: EdgeInsets.all(Responsive.w(4)),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: Responsive.w(3),
                    offset: Offset(0, -Responsive.h(0.5)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textSecondary,
                    size: Responsive.w(5),
                  ),
                  SizedBox(width: Responsive.w(2)),
                  Expanded(
                    child: Text(
                      "Choose the option that best describes you",
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
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

  Widget _buildOptionCard(String text, String career, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.w(3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: Responsive.w(2),
              offset: Offset(0, Responsive.h(0.3)),
            ),
          ],
        ),
        child: Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(Responsive.w(3)),
          child: InkWell(
            onTap: () => selectOption(career, text),
            borderRadius: BorderRadius.circular(Responsive.w(3)),
            child: Container(
              padding: EdgeInsets.all(Responsive.w(4)),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(Responsive.w(3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: Responsive.w(10),
                    height: Responsive.w(10),
                    decoration: BoxDecoration(
                      color: AppColors.teal1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.w(2)),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.w(3)),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.iconLight,
                    size: Responsive.w(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}