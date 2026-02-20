import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/saved_colleges_list/saved_colleges_list_bloc.dart';
import 'package:careers/bloc/saved_colleges_list/saved_colleges_list_event.dart';
import 'package:careers/bloc/saved_colleges_list/saved_colleges_list_state.dart';
import 'package:careers/screens/admission/widgets/college_card.dart';
import 'package:careers/shimmer/college_card_shimmer.dart';
import 'package:go_router/go_router.dart';

class SavedCollegesPage extends StatefulWidget {
  const SavedCollegesPage({super.key});

  @override
  State<SavedCollegesPage> createState() => _SavedCollegesPageState();
}

class _SavedCollegesPageState extends State<SavedCollegesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch saved colleges when page loads
    context.read<SavedCollegesListBloc>().add(FetchSavedCollegesList());
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.headerGradientStart,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Saved Colleges',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.headerGradientStart,
                AppColors.headerGradientMiddle,
                AppColors.headerGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocBuilder<SavedCollegesListBloc, SavedCollegesListState>(
        builder: (context, state) {
          if (state is SavedCollegesListLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(Responsive.w(4)),
              itemCount: 6,
              itemBuilder: (context, index) => const CollegeCardShimmer(),
            );
          }

          if (state is SavedCollegesListError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: Responsive.w(15),
                      color: AppColors.error,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SavedCollegesListBloc>().add(FetchSavedCollegesList());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(6),
                          vertical: Responsive.h(1.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.w(2)),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SavedCollegesListEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: Responsive.w(20),
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      'No Saved Colleges',
                      style: TextStyle(
                        fontSize: Responsive.sp(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(1)),
                    Text(
                      'Start saving colleges to view them here',
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SavedCollegesListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SavedCollegesListBloc>().add(RefreshSavedCollegesList());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: EdgeInsets.all(Responsive.w(4)),
                itemCount: state.colleges.length,
                itemBuilder: (context, index) {
                  return CollegeCard(college: state.colleges[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}