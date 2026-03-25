import 'package:flutter/material.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/data/location_data.dart';

class LocationFilterSheet extends StatefulWidget {
  final String? selectedState;
  final String? selectedDistrict;

  const LocationFilterSheet({
    super.key,
    this.selectedState,
    this.selectedDistrict,
  });

  @override
  State<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends State<LocationFilterSheet> {
  String? _selectedState;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.selectedState;
    _selectedDistrict = widget.selectedDistrict;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final districts =
    _selectedState != null ? LocationData.districtsOf(_selectedState!) : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(Responsive.w(5))),
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(5),
        Responsive.h(2),
        Responsive.w(5),
        MediaQuery.of(context).padding.bottom + Responsive.h(2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: Responsive.w(10),
              height: Responsive.h(0.5),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Responsive.w(1)),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(2)),

          // Title + Clear
          Row(
            children: [
              Text(
                'Filter by Location',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_selectedState != null || _selectedDistrict != null)
                TextButton(
                  onPressed: () =>
                      setState(() {
                        _selectedState = null;
                        _selectedDistrict = null;
                      }),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Responsive.h(2)),

          // State label
          Text(
            'STATE',
            style: TextStyle(
              fontSize: Responsive.sp(11),
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Responsive.h(1)),

          // State chips
          Wrap(
            spacing: Responsive.w(2),
            runSpacing: Responsive.h(1),
            children: LocationData.states.map((state) {
              final isSelected = _selectedState == state;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedState = isSelected ? null : state;
                  _selectedDistrict = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(4),
                    vertical: Responsive.h(1),
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [
                        AppColors.headerGradientStart,
                        AppColors.headerGradientEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected ? null : AppColors.white,
                    borderRadius: BorderRadius.circular(Responsive.w(6)),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.textSecondary.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppColors.headerGradientStart
                            .withOpacity(0.3),
                        blurRadius: Responsive.w(2),
                        offset: Offset(0, Responsive.h(0.3)),
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    state,
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      fontWeight: FontWeight.w600,
                      color:
                      isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Districts — animate in when state is selected
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _selectedState == null
                ? const SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.h(2.5)),
                Text(
                  'DISTRICT',
                  style: TextStyle(
                    fontSize: Responsive.sp(11),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: Responsive.h(1)),
                ConstrainedBox(
                  constraints:
                  BoxConstraints(maxHeight: Responsive.h(22)),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: Responsive.w(2),
                      runSpacing: Responsive.h(1),
                      children: districts.map((district) {
                        final isSelected = _selectedDistrict == district;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDistrict =
                            isSelected ? null : district;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(3.5),
                              vertical: Responsive.h(0.9),
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                colors: [
                                  AppColors.headerGradientStart,
                                  AppColors.headerGradientEnd,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                              color: isSelected ? null : AppColors.white,
                              borderRadius:
                              BorderRadius.circular(Responsive.w(5)),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.textSecondary
                                    .withOpacity(0.2),
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: AppColors
                                      .headerGradientStart
                                      .withOpacity(0.3),
                                  blurRadius: Responsive.w(2),
                                  offset:
                                  Offset(0, Responsive.h(0.3)),
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              district,
                              style: TextStyle(
                                fontSize: Responsive.sp(12),
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.h(3)),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'state': _selectedState,
                'district': _selectedDistrict,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                EdgeInsets.symmetric(vertical: Responsive.h(1.75)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.w(3)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}