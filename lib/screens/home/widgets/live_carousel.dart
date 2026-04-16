import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_bloc.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_event.dart';
import 'package:careers/bloc/career_guidance_banner/career_guidance_banner_state.dart';
import 'package:careers/bloc/career_guidance_register/career_guidance_register_bloc.dart';
import 'package:careers/bloc/career_guidance_register/career_guidance_register_event.dart';
import 'package:careers/bloc/career_guidance_register/career_guidance_register_state.dart';
import 'package:careers/data/models/career_guidance_banner_model.dart';
import 'package:careers/utils/validators/form_validators.dart';
import 'package:careers/utils/app_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class LiveCarousel extends StatefulWidget {
  const LiveCarousel({super.key});

  @override
  State<LiveCarousel> createState() => _LiveCarouselState();
}

class _LiveCarouselState extends State<LiveCarousel> {
  final PageController _pageController = PageController();
  int _current = 0;
  Timer? _timer;

  void _startTimer(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      final next = _pageController.page!.round() + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showRegisterSheet(CareerGuidanceBannerModel banner) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      AppNotifier.show(context, 'No internet connection. Please try again.');
      return;
    }

    if (!mounted) return;

    final bannerBloc = context.read<CareerGuidanceBannerBloc>();
    final registerBloc = context.read<CareerGuidanceRegisterBloc>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bannerBloc),
          BlocProvider.value(value: registerBloc),
        ],
        child: _RegisterSheet(banner: banner),
      ),
    );

    registerBloc.add(ResetCareerGuidanceRegistration());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CareerGuidanceBannerBloc, CareerGuidanceBannerState>(
      listener: (context, state) {
        if (state is CareerGuidanceBannerLoaded) {
          _startTimer(state.banners.length);
        }
      },
      builder: (context, state) {
        if (state is CareerGuidanceBannerLoading ||
            state is CareerGuidanceBannerInitial) {
          return _buildShimmer();
        }

        if (state is CareerGuidanceBannerError) {
          return _buildError(context);
        }

        if (state is CareerGuidanceBannerLoaded && state.banners.isNotEmpty) {
          final banners = state.banners;
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 2.8, // wide card, adjust between 2.5–3.0 to taste
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: null, // infinite scroll
                  onPageChanged: (i) => setState(() => _current = i % banners.length),
                  itemBuilder: (_, i) => _buildBannerItem(banners[i % banners.length]),
                ),
              ),
              SizedBox(height: Responsive.h(1)),
              if (banners.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _current == i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _current == i
                            ? AppColors.teal1
                            : AppColors.teal1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
      child: Center(
        child: GestureDetector(
          onTap: () => context
              .read<CareerGuidanceBannerBloc>()
              .add(FetchCareerGuidanceBanners()),
          child: Text(
            'Could not load live classes. Tap to retry.',
            style: TextStyle(
              fontSize: Responsive.sp(12),
              color: AppColors.teal1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        child: AspectRatio(
        aspectRatio: 2.8,
        child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(Responsive.w(4)),
        ),
      ),),
    );
  }

  Widget _buildBannerItem(CareerGuidanceBannerModel data) {
    return GestureDetector(
      onTap: () => _showRegisterSheet(data),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Responsive.w(5)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Responsive.w(4)),
          border: Border.all(
            color: AppColors.teal1.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal1.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: full-height image with LIVE badge ──────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Responsive.w(4)),
                bottomLeft: Radius.circular(Responsive.w(4)),
              ),
              child: SizedBox(
                width: Responsive.w(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.teal1.withOpacity(0.08),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.teal1,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.teal1.withOpacity(0.08),
                        child: Icon(Icons.person_rounded,
                            color: AppColors.teal1, size: Responsive.w(10)),
                      ),
                    ),
                    // LIVE badge at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(vertical: Responsive.h(0.4)),
                        color: const Color(0xFFE53935),
                        child: Text(
                          'LIVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.sp(8),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Right: info + button ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(3.5),
                  vertical: Responsive.h(1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Instructor
                    Row(
                      children: [
                        Icon(Icons.person_rounded,
                            size: Responsive.w(3.5),
                            color: AppColors.teal1),
                        SizedBox(width: Responsive.w(1)),
                        Expanded(
                          child: Text(
                            data.instructorName,
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.teal1,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Class name
                    Text(
                      data.name,
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.teal1, AppColors.teal2],
                          ),
                          borderRadius: BorderRadius.circular(Responsive.w(2)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showRegisterSheet(data),
                            borderRadius:
                            BorderRadius.circular(Responsive.w(2)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Responsive.h(0.9)),
                              child: Text(
                                'Register',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Responsive.sp(12),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
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
    );
  }
}

// ── Registration Bottom Sheet ─────────────────────────────────────────────────
class _RegisterSheet extends StatefulWidget {
  final CareerGuidanceBannerModel banner;
  const _RegisterSheet({required this.banner});

  @override
  State<_RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<_RegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _formatTime(String time) {
    // Converts "09:42:00" → "09:42 AM/PM"
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CareerGuidanceRegisterBloc>().add(
      SubmitCareerGuidanceRegistration(
        bannerId: widget.banner.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final banner = widget.banner;

    return BlocConsumer<CareerGuidanceRegisterBloc,
        CareerGuidanceRegisterState>(
      listener: (context, state) {
        if (state is CareerGuidanceRegisterSuccess) {
          Navigator.pop(context);
          AppNotifier.show(
              context, 'Registered! Meeting link sent to your email.');
        } else if (state is CareerGuidanceRegisterError) {
          // Close the sheet first, then show the message on the page behind
          Navigator.pop(context);
          AppNotifier.show(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is CareerGuidanceRegisterLoading;

        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.w(6))),
            ),
            padding: EdgeInsets.fromLTRB(
              Responsive.w(5),
              Responsive.h(2.5),
              Responsive.w(5),
              Responsive.h(3),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: Responsive.w(10),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),

                    // ── Class name ──────────────────────────────────
                    Text(
                      banner.name,
                      style: TextStyle(
                        fontSize: Responsive.sp(17),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: Responsive.h(0.6)),

                    Text(
                      '👤  ${banner.instructorName}',
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Responsive.h(1.5)),

                    // ── Info chips (date, time) ───────────────────
                    Wrap(
                      spacing: Responsive.w(2),
                      runSpacing: Responsive.h(0.8),
                      children: [
                        _infoChip(
                          icon: Icons.calendar_today_rounded,
                          label: banner.eventDate,
                        ),
                        _infoChip(
                          icon: Icons.access_time_rounded,
                          label:
                          '${_formatTime(banner.startTime)} – ${_formatTime(banner.endTime)}',
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(1.5)),

                    // ── Description ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.w(3.5)),
                      decoration: BoxDecoration(
                        color: AppColors.teal1.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.teal1.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        banner.description,
                        style: TextStyle(
                          fontSize: Responsive.sp(12.5),
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),

                    SizedBox(height: Responsive.h(2.5)),

                    // ── Divider ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(2)),
                          child: Text(
                            'Fill in to register',
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                      ],
                    ),
                    SizedBox(height: Responsive.h(2)),

                    // ── Form fields ──────────────────────────────────
                    _buildField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          FormValidators.required(v, field: 'Name'),
                      enabled: !isLoading,
                    ),
                    SizedBox(height: Responsive.h(1.8)),

                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.email,
                      enabled: !isLoading,
                    ),
                    SizedBox(height: Responsive.h(1.8)),

                    _buildField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      hint: '10-digit phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: FormValidators.phone,
                      enabled: !isLoading,
                      inputFormatters: [ // ADD these lines
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    SizedBox(height: Responsive.h(3)),

                    // ── Submit button ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal1,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          AppColors.teal1.withOpacity(0.6),
                          padding: EdgeInsets.symmetric(
                              vertical: Responsive.h(1.8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: Responsive.w(5),
                          width: Responsive.w(5),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Register Now',
                          style: TextStyle(
                            fontSize: Responsive.sp(15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(3),
        vertical: Responsive.h(0.5),
      ),
      decoration: BoxDecoration(
        color: AppColors.teal1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.w(3.5), color: AppColors.teal1),
          SizedBox(width: Responsive.w(1.5)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(11),
              color: AppColors.teal1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
        Icon(icon, color: AppColors.teal1, size: Responsive.w(5)),
        filled: true,
        fillColor: AppColors.teal1.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.teal1.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.teal1.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.teal1, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: Responsive.sp(13),
        ),
      ),
    );
  }
}