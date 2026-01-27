import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/data/models/college_model.dart';
import 'package:go_router/go_router.dart';

class CollegeCard extends StatelessWidget {
  final CollegeModel college;

  const CollegeCard({
    super.key,
    required this.college,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(0.8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(2.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/college-details', extra: college.id);
          },
          borderRadius: BorderRadius.circular(Responsive.w(3.5)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(2.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        college.name,
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(2),
                        vertical: Responsive.h(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Responsive.w(1.8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.primary,
                            size: Responsive.sp(14),
                          ),
                          SizedBox(width: Responsive.w(1)),
                          Text(
                            college.rating,
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(0.6)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: Responsive.sp(14),
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: Responsive.w(1)),
                    Expanded(
                      child: Text(
                        college.location,
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(0.7)),
                Text(
                  college.courses,
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(0.7)),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: Responsive.w(1)),
                    Icon(
                      Icons.arrow_forward,
                      size: Responsive.sp(14),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}