import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/course_fee/course_fee_bloc.dart';
import 'package:careers/bloc/course_fee/course_fee_event.dart';
import 'package:careers/bloc/course_fee/course_fee_state.dart';
import 'package:careers/data/models/course_fee_model.dart';
import 'package:careers/data/repositories/course_fee_repository.dart';

class CourseFeeSheet extends StatelessWidget {
  final String courseId;
  final String courseName;
  final CourseFeeRepository repository;

  const CourseFeeSheet({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.repository,
  });

  static Future<void> show(
      BuildContext context, {
        required String courseId,
        required String courseName,
        required CourseFeeRepository repository,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CourseFeeBloc(repository)..add(FetchCourseFee(courseId)),
        child: CourseFeeSheet(
          courseId: courseId,
          courseName: courseName,
          repository: repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.w(6)),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              Expanded(
                child: BlocBuilder<CourseFeeBloc, CourseFeeState>(
                  builder: (context, state) {
                    if (state is CourseFeeLoading) {
                      return _buildLoading();
                    }
                    if (state is CourseFeeError) {
                      return _buildError(state.message);
                    }
                    if (state is CourseFeeLoaded) {
                      return _buildContent(
                          state.data, scrollController, context);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(5),
        Responsive.h(1),
        Responsive.w(5),
        Responsive.h(2),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.w(6)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(2.5)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Responsive.w(3)),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: Responsive.w(5.5),
            ),
          ),
          SizedBox(width: Responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Structure',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  courseName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(Responsive.w(1.5)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: Responsive.w(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: Responsive.h(2)),
          Text(
            'Fetching fee details...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: Responsive.sp(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: Responsive.w(15), color: AppColors.textSecondary),
            SizedBox(height: Responsive.h(2)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: Responsive.sp(14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      CourseFeeModel data,
      ScrollController scrollController,
      BuildContext context,
      ) {
    if (data.feeStructures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded,
                size: Responsive.w(15), color: AppColors.textSecondary),
            SizedBox(height: Responsive.h(2)),
            Text(
              'No fee structure available',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(4),
        Responsive.h(2),
        Responsive.w(4),
        Responsive.h(4),
      ),
      itemCount: data.feeStructures.length,
      itemBuilder: (context, index) {
        return _buildFeeCard(data.feeStructures[index], index);
      },
    );
  }

  Widget _buildFeeCard(FeeStructure fee, int index) {
    final color = _feeTypeColor(fee.feeType);
    final icon = _feeTypeIcon(fee.feeType);
    final label = _capitalize(fee.feeType);
    final modeLabel = _capitalize(fee.feeMode);
    final formattedTotal = _formatAmount(fee.totalAmount);

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(2)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: Responsive.w(3),
            offset: Offset(0, Responsive.h(0.4)),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(4),
              vertical: Responsive.h(1.75),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Responsive.w(4)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(2.5)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                  ),
                  child: Icon(icon, color: color, size: Responsive.w(5.5)),
                ),
                SizedBox(width: Responsive.w(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label Quota',
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$modeLabel basis',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Total badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(3),
                    vertical: Responsive.h(0.75),
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(Responsive.w(2)),
                  ),
                  child: Text(
                    '₹$formattedTotal',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Breakdown rows
          Padding(
            padding: EdgeInsets.all(Responsive.w(4)),
            child: Column(
              children: [
                ...fee.breakdowns.asMap().entries.map((entry) {
                  final i = entry.key;
                  final breakdown = entry.value;
                  final isLast = i == fee.breakdowns.length - 1;
                  return Column(
                    children: [
                      _buildBreakdownRow(breakdown, color),
                      if (!isLast)
                        Divider(
                          height: Responsive.h(2),
                          color: Colors.grey.shade100,
                          thickness: 1,
                        ),
                    ],
                  );
                }),

                // Total row
                Container(
                  margin: EdgeInsets.only(top: Responsive.h(1.5)),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(4),
                    vertical: Responsive.h(1.25),
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(Responsive.w(2.5)),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.summarize_rounded,
                              size: Responsive.w(4), color: color),
                          SizedBox(width: Responsive.w(2)),
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹$formattedTotal',
                        style: TextStyle(
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w800,
                          color: color,
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
    );
  }

  Widget _buildBreakdownRow(FeeBreakdown breakdown, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: Responsive.w(1.5),
              height: Responsive.w(1.5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: Responsive.w(2.5)),
            Text(
              _capitalize(breakdown.label),
              style: TextStyle(
                fontSize: Responsive.sp(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          '₹${_formatAmount(breakdown.amount)}',
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _feeTypeColor(String feeType) {
    switch (feeType.toLowerCase()) {
      case 'government':
        return const Color(0xFF2E7D32); // green
      case 'management':
        return const Color(0xFF1565C0); // blue
      case 'nri':
        return const Color(0xFFE65100); // orange
      case 'minority':
        return const Color(0xFF6A1B9A); // purple
      default:
        return AppColors.primary;
    }
  }

  IconData _feeTypeIcon(String feeType) {
    switch (feeType.toLowerCase()) {
      case 'government':
        return Icons.account_balance_rounded;
      case 'management':
        return Icons.business_center_rounded;
      case 'nri':
        return Icons.flight_rounded;
      case 'minority':
        return Icons.diversity_3_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map((w) => w.isNotEmpty
        ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  String _formatAmount(String amount) {
    try {
      final double value = double.parse(amount);
      if (value >= 100000) {
        return '${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 2)}L';
      } else if (value >= 1000) {
        final formatted = value.toStringAsFixed(0);
        // Add comma: e.g. 70000 → 70,000
        final result = StringBuffer();
        int count = 0;
        for (int i = formatted.length - 1; i >= 0; i--) {
          if (count > 0 && count % 3 == 0) result.write(',');
          result.write(formatted[i]);
          count++;
        }
        return result.toString().split('').reversed.join('');
      }
      return value.toStringAsFixed(0);
    } catch (_) {
      return amount;
    }
  }
}