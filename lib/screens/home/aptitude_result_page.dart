import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class AptitudeResultPage extends StatefulWidget {
  final Map<String, int> scores;
  final List<String> topCareers;

  const AptitudeResultPage({
    super.key,
    required this.scores,
    required this.topCareers,
  });

  @override
  State<AptitudeResultPage> createState() => _AptitudeResultPageState();
}

class _AptitudeResultPageState extends State<AptitudeResultPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _barsAnimController;
  late Animation<double> _headerScaleAnim;
  late Animation<double> _headerFadeAnim;

  final Map<String, IconData> careerIcons = {
    "Technology": Icons.computer_rounded,
    "Medical": Icons.medical_services_rounded,
    "Arts": Icons.palette_rounded,
    "Commerce": Icons.business_center_rounded,
  };

  final Map<String, Color> careerColors = {
    "Technology": AppColors.teal2,
    "Medical": AppColors.error,
    "Arts": AppColors.accent,
    "Commerce": AppColors.warning,
  };

  final Map<String, List<String>> careerSuggestions = {
    "Technology": [
      "Software Developer",
      "Data Scientist",
      "Cybersecurity Analyst",
      "AI/ML Engineer",
      "Web Developer",
      "Cloud Architect",
    ],
    "Medical": [
      "Doctor",
      "Nurse",
      "Pharmacist",
      "Medical Researcher",
      "Physiotherapist",
      "Psychologist",
    ],
    "Arts": [
      "Graphic Designer",
      "Content Writer",
      "Video Editor",
      "UI/UX Designer",
      "Animator",
      "Photographer",
    ],
    "Commerce": [
      "Chartered Accountant",
      "Business Analyst",
      "Marketing Manager",
      "Financial Advisor",
      "Entrepreneur",
      "HR Manager",
    ],
  };

  final Map<String, String> careerDescriptions = {
    "Technology": "You have a strong analytical mindset and enjoy solving complex problems through innovation and technology.",
    "Medical": "You have a caring nature and are passionate about helping others and making a difference in people's health and well-being.",
    "Arts": "You have a creative spirit and excel at expressing ideas through various artistic mediums and innovative thinking.",
    "Commerce": "You have strong organizational and leadership skills, with a keen interest in business, finance, and management.",
  };

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _barsAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutBack),
    );
    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _barsAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _barsAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // Sort scores to show in descending order
    final sortedScores = widget.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textOnPrimary,
          onPressed: () => context.go('/dashboard?tab=0'),
        ),
        title: const Text(
          "Your Results",
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(5),
                vertical: Responsive.h(4),
              ),
              child: FadeTransition(
                opacity: _headerFadeAnim,
                child: ScaleTransition(
                  scale: _headerScaleAnim,
                  child: Column(
                    children: [
                      // Show multiple icons if tie
                      if (widget.topCareers.length == 1)
                        Container(
                          width: Responsive.w(20),
                          height: Responsive.w(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.2),
                                blurRadius: Responsive.w(4),
                                offset: Offset(0, Responsive.h(1)),
                              ),
                            ],
                          ),
                          child: Icon(
                            careerIcons[widget.topCareers.first],
                            size: Responsive.w(10),
                            color: careerColors[widget.topCareers.first],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.topCareers.map((career) {
                            return Container(
                              width: Responsive.w(15),
                              height: Responsive.w(15),
                              margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.2),
                                    blurRadius: Responsive.w(3),
                                    offset: Offset(0, Responsive.h(0.5)),
                                  ),
                                ],
                              ),
                              child: Icon(
                                careerIcons[career],
                                size: Responsive.w(7),
                                color: careerColors[career],
                              ),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        widget.topCareers.length == 1 ? "Your Top Match" : "Your Top Matches (Tie!)",
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: Responsive.h(1)),
                      Text(
                        widget.topCareers.join(" & "),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.sp(widget.topCareers.length == 1 ? 32 : 26),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      SizedBox(height: Responsive.h(1)),
                      Text(
                        "${widget.scores[widget.topCareers.first]}% Match",
                        style: TextStyle(
                          fontSize: Responsive.sp(18),
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(Responsive.w(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _buildSection(
                    title: "What This Means",
                    child: widget.topCareers.length == 1
                        ? Text(
                      careerDescriptions[widget.topCareers.first] ?? "",
                      style: TextStyle(
                        fontSize: Responsive.sp(15),
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You have equal aptitude for multiple fields! This shows versatility in your interests and skills.",
                          style: TextStyle(
                            fontSize: Responsive.sp(15),
                            color: AppColors.textSecondary,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Responsive.h(1.5)),
                        ...widget.topCareers.map((career) => Padding(
                          padding: EdgeInsets.only(bottom: Responsive.h(1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                careerIcons[career],
                                size: Responsive.w(5),
                                color: careerColors[career],
                              ),
                              SizedBox(width: Responsive.w(2)),
                              Expanded(
                                child: Text(
                                  "${career}: ${careerDescriptions[career]}",
                                  style: TextStyle(
                                    fontSize: Responsive.sp(14),
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.h(3)),

                  // Score Breakdown
                  _buildSection(
                    title: "Your Score Breakdown",
                    child: Column(
                      children: sortedScores.map((entry) {
                        return _buildScoreBar(
                          entry.key,
                          entry.value,
                          careerColors[entry.key]!,
                          careerIcons[entry.key]!,
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: Responsive.h(3)),

                  // Career Suggestions
                  _buildSection(
                    title: "Recommended Careers",
                    child: widget.topCareers.length == 1
                        ? Wrap(
                      spacing: Responsive.w(2),
                      runSpacing: Responsive.h(1),
                      children: (careerSuggestions[widget.topCareers.first] ?? [])
                          .map((career) => _buildCareerChip(career, widget.topCareers.first))
                          .toList(),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.topCareers.map((topCareer) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  careerIcons[topCareer],
                                  size: Responsive.w(5),
                                  color: careerColors[topCareer],
                                ),
                                SizedBox(width: Responsive.w(2)),
                                Text(
                                  topCareer,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(15),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.h(1)),
                            Wrap(
                              spacing: Responsive.w(2),
                              runSpacing: Responsive.h(1),
                              children: (careerSuggestions[topCareer] ?? [])
                                  .map((career) => _buildCareerChip(career, topCareer))
                                  .toList(),
                            ),
                            if (topCareer != widget.topCareers.last)
                              SizedBox(height: Responsive.h(2)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: Responsive.h(3)),

                  // Next Steps
                  _buildSection(
                    title: "Next Steps",
                    child: Column(
                      children: [
                        _buildNextStepCard(
                          Icons.explore_rounded,
                          "Explore Careers",
                          "Browse detailed career profiles and requirements",
                          AppColors.teal2,
                          onTap: () {
                            context.go('/dashboard?tab=1'); // Navigate to Careers tab
                          },
                        ),
                        SizedBox(height: Responsive.h(1.5)),
                        _buildNextStepCard(
                          Icons.school_rounded,
                          "View Admissions",
                          "Find colleges and courses for your chosen path",
                          AppColors.tealGreen,
                          onTap: () {
                            context.go('/dashboard?tab=2'); // Navigate to Admissions tab
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.h(3)),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/dashboard?tab=0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.w(3)),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Continue Exploring",
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.h(1.5)),
        child,
      ],
    );
  }

  Widget _buildScoreBar(String career, int score, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _barsAnimController,
      builder: (context, child) {
        final animValue = Curves.easeOutCubic.transform(_barsAnimController.value);
        return Container(
          margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: Responsive.w(5), color: color),
                  SizedBox(width: Responsive.w(2)),
                  Text(
                    career,
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "$score%",
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(0.8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.w(2)),
                child: LinearProgressIndicator(
                  value: (score / 100) * animValue,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: Responsive.h(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCareerChip(String career, String careerField) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(3),
        vertical: Responsive.h(1),
      ),
      decoration: BoxDecoration(
        color: careerColors[careerField]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Responsive.w(5)),
        border: Border.all(
          color: careerColors[careerField]!.withOpacity(0.3),
        ),
      ),
      child: Text(
        career,
        style: TextStyle(
          fontSize: Responsive.sp(13),
          color: careerColors[careerField],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNextStepCard(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(3)),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(3)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: Responsive.w(2),
            offset: Offset(0, Responsive.h(0.3)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(4)),
        child: Row(
          children: [
            Container(
              width: Responsive.w(12),
              height: Responsive.w(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Responsive.w(2.5)),
              ),
              child: Icon(icon, color: color, size: Responsive.w(6)),
            ),
            SizedBox(width: Responsive.w(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.h(0.3)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.iconLight,
              size: Responsive.w(4),
            ),
          ],
        ),
      ),),
    );
  }
}