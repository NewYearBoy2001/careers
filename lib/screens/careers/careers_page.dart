import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careers/constants/app_colors.dart';
import './widgets/career_card.dart';
import './widgets/career_header.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:go_router/go_router.dart';

class CareersPage extends StatefulWidget {
  final String currentEducation;

  const CareersPage({
    super.key,
    required this.currentEducation,
  });

  @override
  State<CareersPage> createState() => _CareersPageState();
}

class _CareersPageState extends State<CareersPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _cardsAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  int _currentBannerIndex = 0;

  // Search related
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<String> _bannerImages = [
    'assets/images/career.jpg',
    'assets/images/careergrowth.jpg',
    'assets/images/collegeandcareerready.jpg',
  ];

  final Map<String, List<Map<String, dynamic>>> _careerPaths = {
    '8th': [
      {'title': 'Prepare for 9th', 'icon': Icons.school, 'subjects': 'Continue general education', 'color': AppColors.info},
    ],
    '9th': [
      {'title': 'Prepare for 10th', 'icon': Icons.school, 'subjects': 'Focus on board exam preparation', 'color': AppColors.info},
    ],
    '10th': [{
      'title': '+1 / +2 – Biology Science',
      'icon': Icons.biotech,
      'subjects': 'Physics, Chemistry, Biology',
      'color': AppColors.success,
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'description':
      '+1 / +2 Biology Science is ideal for students aiming for medical and life science careers. It focuses on core science subjects with practical knowledge.',
      'careerOptions': [
        'Doctor',
        'Dentist',
        'Pharmacist',
        'Biotechnologist',
        'Physiotherapist',
        'Veterinarian'
      ],
      'entranceExams': ['NEET', 'AIIMS', 'JIPMER'],
      'thumbnail': 'https://picsum.photos/800/450',
    },
      {
        'title': '+1 / +2 – Computer Science',
        'icon': Icons.computer,
        'subjects': 'Physics, Chemistry, Mathematics, Computer Science',
        'color': AppColors.primary,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
        '+1 / +2 Computer Science stream suits students interested in technology, programming, and engineering-related careers.',
        'careerOptions': [
          'Software Developer',
          'Data Scientist',
          'AI Engineer',
          'Cybersecurity Expert',
          'Game Developer'
        ],
        'entranceExams': ['JEE Main', 'JEE Advanced', 'BITSAT', 'State Engineering Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': '+1 / +2 – Humanities',
        'icon': Icons.menu_book,
        'subjects': 'History, Political Science, Psychology, Sociology',
        'color': AppColors.accent,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
        '+1 / +2 Humanities focuses on social sciences and arts, suitable for careers in law, public service, education, and media.',
        'careerOptions': [
          'Civil Servant',
          'Lawyer',
          'Psychologist',
          'Journalist',
          'Social Worker',
          'Teacher'
        ],
        'entranceExams': ['CLAT', 'UPSC', 'State PSC', 'BA Entrance Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': '10th',
        'icon': Icons.school,
        'subjects': 'Mathematics, Science, Social Science, Languages',
        'color': AppColors.info,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
        '10th standard builds a strong academic foundation and helps students choose the right stream for higher studies.',
        'careerOptions': [
          'Higher Secondary Education',
          'ITI',
          'Polytechnic',
          'Skill-Based Courses'
        ],
        'entranceExams': ['School Board Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': 'ITI',
        'icon': Icons.build,
        'subjects': 'Technical & Trade-Based Practical Training',
        'color': AppColors.warning,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description':
        'ITI provides hands-on technical training for students interested in skilled trades and early job opportunities.',
        'careerOptions': [
          'Electrician',
          'Fitter',
          'Welder',
          'Mechanic',
          'Technician'
        ],
        'entranceExams': ['ITI Admission Tests', 'Merit-Based Admission'],
        'thumbnail': 'https://picsum.photos/800/450',
      },

    ],
    '11th': [
      {'title': 'Focus on Stream', 'icon': Icons.school, 'subjects': 'Continue your chosen stream', 'color': AppColors.info},
    ],
    '12th': [
      {
        'title': 'Engineering',
        'icon': Icons.engineering,
        'subjects': 'B.Tech, B.E in various specializations',
        'color': AppColors.primary,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'description': 'Engineering offers diverse specializations in technology and innovation.',
        'careerOptions': ['Software Engineer', 'Mechanical Engineer', 'Civil Engineer', 'Electrical Engineer'],
        'entranceExams': ['JEE Main', 'JEE Advanced', 'BITSAT'],
        'thumbnail': 'https://picsum.photos/800/451',
      },
      {
        'title': 'Medical',
        'icon': Icons.local_hospital,
        'subjects': 'MBBS, BDS, BAMS, Nursing',
        'color': AppColors.error,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'description': 'Medical field focuses on healthcare and saving lives.',
        'careerOptions': ['Doctor', 'Surgeon', 'Dentist', 'Nurse'],
        'entranceExams': ['NEET', 'AIIMS'],
        'thumbnail': 'https://picsum.photos/800/452',
      },
      {
        'title': 'Commerce',
        'icon': Icons.account_balance,
        'subjects': 'CA, B.Com, BBA, Economics',
        'color': AppColors.warning,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'description': 'Commerce stream prepares for business and finance careers.',
        'careerOptions': ['Chartered Accountant', 'Investment Banker', 'Entrepreneur'],
        'entranceExams': ['CA Foundation', 'CS Foundation'],
        'thumbnail': 'https://picsum.photos/800/453',
      },
      {
        'title': 'Law',
        'icon': Icons.gavel,
        'subjects': 'LLB, BA LLB (5 years)',
        'color': AppColors.info,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'description': 'Law education for aspiring legal professionals.',
        'careerOptions': ['Lawyer', 'Judge', 'Legal Advisor'],
        'entranceExams': ['CLAT', 'LSAT'],
        'thumbnail': 'https://picsum.photos/800/454',
      },
      {
        'title': 'Design',
        'icon': Icons.brush,
        'subjects': 'Fashion, Interior, Graphic Design',
        'color': AppColors.accent,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'description': 'Creative design fields for artistic minds.',
        'careerOptions': ['Fashion Designer', 'Interior Designer', 'Graphic Designer'],
        'entranceExams': ['NIFT', 'NID', 'CEED'],
        'thumbnail': 'https://picsum.photos/800/455',
      },
    ],
    'Undergraduate': [
      {'title': 'Postgraduate Programs', 'icon': Icons.school, 'subjects': 'Masters, MBA, MTech, MSc', 'color': AppColors.primary},
      {'title': 'Professional Courses', 'icon': Icons.work, 'subjects': 'Certifications, Specialized Training', 'color': AppColors.success},
    ],
    'Postgraduate': [
      {'title': 'PhD Programs', 'icon': Icons.school, 'subjects': 'Doctoral studies and research', 'color': AppColors.primary},
      {'title': 'Career Opportunities', 'icon': Icons.work, 'subjects': 'Jobs, Entrepreneurship', 'color': AppColors.success},
    ],
    '8th Grade': [
      {'title': 'Prepare for 9th', 'icon': Icons.school, 'subjects': 'Continue general education', 'color': AppColors.info},
    ],
    '9th Grade': [
      {'title': 'Prepare for 10th', 'icon': Icons.school, 'subjects': 'Focus on board exam preparation', 'color': AppColors.info},
    ],
    '10th Grade': [
      {
        'title': 'Biology Science',
        'icon': Icons.biotech,
        'subjects': 'Physics, Chemistry, Biology - Path to Medical & Life Sciences',
        'color': AppColors.success,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description': 'Biology Science stream opens doors to medical, pharmaceutical, and life sciences careers. Students study Physics, Chemistry, and Biology in depth.',
        'careerOptions': ['Doctor', 'Dentist', 'Pharmacist', 'Biotechnologist', 'Physiotherapist', 'Veterinarian'],
        'entranceExams': ['NEET', 'AIIMS', 'JIPMER'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': 'Computer Science',
        'icon': Icons.computer,
        'subjects': 'Physics, Chemistry, Mathematics, Computer Science',
        'color': AppColors.primary,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description': 'Computer Science stream is perfect for students interested in technology, programming, and innovation. Combines science with computing skills.',
        'careerOptions': ['Software Developer', 'Data Scientist', 'AI Engineer', 'Cybersecurity Expert', 'Game Developer'],
        'entranceExams': ['JEE Main', 'JEE Advanced', 'BITSAT', 'State Engineering Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': 'Commerce',
        'icon': Icons.business,
        'subjects': 'Accountancy, Business Studies, Economics, Mathematics',
        'color': AppColors.warning,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description': 'Commerce stream prepares students for careers in business, finance, and economics. Focus on accounting, business management, and economic principles.',
        'careerOptions': ['Chartered Accountant', 'Company Secretary', 'Investment Banker', 'Entrepreneur', 'Financial Analyst'],
        'entranceExams': ['CA Foundation', 'CS Foundation', 'CLAT', 'BBA Entrance Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
      {
        'title': 'Humanities',
        'icon': Icons.menu_book,
        'subjects': 'History, Political Science, Psychology, Sociology',
        'color': AppColors.accent,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'description': 'Humanities stream explores human society, culture, and behavior. Ideal for students interested in social sciences, law, and public service.',
        'careerOptions': ['Civil Servant', 'Lawyer', 'Psychologist', 'Journalist', 'Social Worker', 'Teacher'],
        'entranceExams': ['CLAT', 'UPSC', 'State PSC', 'BA Entrance Exams'],
        'thumbnail': 'https://picsum.photos/800/450',
      },
    ],
    '11th Grade': [
      {'title': 'Focus on Stream', 'icon': Icons.school, 'subjects': 'Continue your chosen stream', 'color': AppColors.info},
    ],
    '12th Grade': [
      {
        'title': 'Engineering',
        'icon': Icons.engineering,
        'subjects': 'B.Tech, B.E in various specializations',
        'color': AppColors.primary,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'description': 'Engineering offers diverse specializations in technology and innovation.',
        'careerOptions': ['Software Engineer', 'Mechanical Engineer', 'Civil Engineer', 'Electrical Engineer'],
        'entranceExams': ['JEE Main', 'JEE Advanced', 'BITSAT'],
        'thumbnail': 'https://picsum.photos/800/451',
      },
      {
        'title': 'Medical',
        'icon': Icons.local_hospital,
        'subjects': 'MBBS, BDS, BAMS, Nursing',
        'color': AppColors.error,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'description': 'Medical field focuses on healthcare and saving lives.',
        'careerOptions': ['Doctor', 'Surgeon', 'Dentist', 'Nurse'],
        'entranceExams': ['NEET', 'AIIMS'],
        'thumbnail': 'https://picsum.photos/800/452',
      },
      {
        'title': 'Commerce',
        'icon': Icons.account_balance,
        'subjects': 'CA, B.Com, BBA, Economics',
        'color': AppColors.warning,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'description': 'Commerce stream prepares for business and finance careers.',
        'careerOptions': ['Chartered Accountant', 'Investment Banker', 'Entrepreneur'],
        'entranceExams': ['CA Foundation', 'CS Foundation'],
        'thumbnail': 'https://picsum.photos/800/453',
      },
      {
        'title': 'Law',
        'icon': Icons.gavel,
        'subjects': 'LLB, BA LLB (5 years)',
        'color': AppColors.info,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'description': 'Law education for aspiring legal professionals.',
        'careerOptions': ['Lawyer', 'Judge', 'Legal Advisor'],
        'entranceExams': ['CLAT', 'LSAT'],
        'thumbnail': 'https://picsum.photos/800/454',
      },
      {
        'title': 'Design',
        'icon': Icons.brush,
        'subjects': 'Fashion, Interior, Graphic Design',
        'color': AppColors.accent,
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'description': 'Creative design fields for artistic minds.',
        'careerOptions': ['Fashion Designer', 'Interior Designer', 'Graphic Designer'],
        'entranceExams': ['NIFT', 'NID', 'CEED'],
        'thumbnail': 'https://picsum.photos/800/455',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic));

    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimController.forward();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _cardsAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _getAllCourses()
          .where((course) =>
      course['title'].toString().toLowerCase().contains(query) ||
          course['subjects'].toString().toLowerCase().contains(query) ||
          (course['description']?.toString().toLowerCase().contains(query) ?? false) ||
          (course['careerOptions']?.any((career) =>
              career.toString().toLowerCase().contains(query)) ?? false))
          .toList();
    });
  }

  List<Map<String, dynamic>> _getAllCourses() {
    List<Map<String, dynamic>> allCourses = [];
    _careerPaths.forEach((key, value) {
      allCourses.addAll(value.where((course) =>
      course['videoUrl'] != null || course['description'] != null));
    });
    return allCourses;
  }

  void _navigateToCourseDetail(Map<String, dynamic> courseData) {
    context.push('/course-detail', extra: courseData);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: Responsive.sp(20),
          ),
          SizedBox(width: Responsive.w(3)),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: Responsive.sp(15),
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search careers',
                hintStyle: TextStyle(
                  fontSize: Responsive.sp(15),
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),

                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: Responsive.h(1.5)),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: Responsive.sp(20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final paths = _careerPaths[widget.currentEducation] ?? [];
    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Animated Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: Responsive.h(4)),
              child: FadeTransition(
                opacity: _headerFadeAnim,
                child: SlideTransition(
                  position: _headerSlideAnim,
                  child: const CareerHeader(),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: Responsive.h(0.3), bottom: Responsive.h(1)),
              child: _buildSearchBar(),
            ),
          ),

          // Show search results or regular content
          if (_isSearching) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Responsive.w(5), Responsive.h(2), Responsive.w(5), 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Container(
                      width: Responsive.w(0.75),
                      height: Responsive.h(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: Responsive.w(2.5)),
                    Text(
                      'Search Results (${_searchResults.length})',
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_searchResults.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: Responsive.sp(64),
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        'No careers found',
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: Responsive.h(1)),
                      Text(
                        'Try searching with different keywords',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(Responsive.w(5)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return CareerCard(
                        path: _searchResults[index],
                        index: index,
                        onTap: () => _navigateToCourseDetail(_searchResults[index]),
                      );
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              ),
          ] else ...[
            // Carousel Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Responsive.w(5), Responsive.h(0.5), Responsive.w(5), 0),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: Responsive.h(20),
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.easeInOutCubic,
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                      ),
                      items: _bannerImages.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Responsive.w(4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Responsive.w(4)),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary,
                                            AppColors.accent,
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              size: Responsive.sp(48),
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                            SizedBox(height: Responsive.h(1.5)),
                                            Text(
                                              'Discover Your Future',
                                              style: TextStyle(
                                                fontSize: Responsive.sp(18),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white.withOpacity(0.95),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: Responsive.h(0.8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _bannerImages.asMap().entries.map((entry) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentBannerIndex == entry.key ? Responsive.w(6) : Responsive.w(2),
                          height: Responsive.h(1),
                          margin: EdgeInsets.symmetric(horizontal: Responsive.w(1)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentBannerIndex == entry.key
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Career Paths Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Responsive.w(5), Responsive.h(1), Responsive.w(5), 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Container(
                      width: Responsive.w(0.75),
                      height: Responsive.h(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(Responsive.w(0.5)),
                      ),
                    ),
                    SizedBox(width: Responsive.w(2.5)),
                    Text(
                      'Next Career Path',
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Career Cards
            SliverPadding(
              padding: EdgeInsets.all(Responsive.w(3)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return AnimatedBuilder(
                      animation: _cardsAnimController,
                      builder: (context, child) {
                        final delay = index * 0.08;
                        final animValue = Curves.easeOutCubic.transform(
                          (_cardsAnimController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
                        );

                        return Opacity(
                          opacity: animValue,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - animValue)),
                            child: child,
                          ),
                        );
                      },
                      child: CareerCard(
                        path: paths[index],
                        index: index,
                        onTap: () => _navigateToCourseDetail(paths[index]),
                      ),
                    );
                  },
                  childCount: paths.length,
                ),
              ),
            ),
          ],
        ],
    );
  }
}