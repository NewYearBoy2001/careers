import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/location/location_bloc.dart';
import 'package:careers/bloc/location/location_event.dart';
import 'package:careers/bloc/location/location_state.dart';
import 'package:careers/data/models/location_model.dart';

class LocationFilterSheet extends StatefulWidget {
  final int? selectedStateId;
  final String? selectedStateName;
  final int? selectedDistrictId;
  final String? selectedDistrictName;

  const LocationFilterSheet({
    super.key,
    this.selectedStateId,
    this.selectedStateName,
    this.selectedDistrictId,
    this.selectedDistrictName,
  });

  @override
  State<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends State<LocationFilterSheet> {
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    // Trigger fetch of states when sheet opens
    context.read<LocationBloc>().add(const FetchStates());
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final List<StateModel> states = _getStates(state);
        final List<DistrictModel> districts = _getDistricts(state);
        final bool isLoadingDistricts = state is DistrictsLoading;
        final bool isLoadingStates = state is StatesLoading;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.w(5)),
            ),
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
                      onPressed: () => setState(() {
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

              if (isLoadingStates)
                Center(
                  child: SizedBox(
                    width: Responsive.w(5),
                    height: Responsive.w(5),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.tealDark,
                    ),
                  ),
                )
              else if (state is LocationError)
                Center(
                  child: Column(
                    children: [
                      Text(state.message,
                          style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () =>
                            context.read<LocationBloc>().add(const FetchStates()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: Responsive.w(2),
                  runSpacing: Responsive.h(1),
                  children: states.map((state) {
                    final isSelected = _selectedState?.id == state.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedState = isSelected ? null : state;
                          _selectedDistrict = null;
                        });
                        if (!isSelected) {
                          context
                              .read<LocationBloc>()
                              .add(FetchDistricts(state.id));
                        }
                      },
                      child: _buildChip(state.name, isSelected),
                    );
                  }).toList(),
                ),

              // Districts section
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
                    if (isLoadingDistricts)
                      Center(
                        child: SizedBox(
                          width: Responsive.w(5),
                          height: Responsive.w(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.tealDark,
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: Responsive.h(22)),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: Responsive.w(2),
                            runSpacing: Responsive.h(1),
                            children: districts.map((district) {
                              final isSelected =
                                  _selectedDistrict?.id == district.id;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedDistrict =
                                  isSelected ? null : district;
                                }),
                                child: _buildChip(district.name, isSelected),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.h(3)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop({
                    'stateId': _selectedState?.id,
                    'stateName': _selectedState?.name,
                    'districtId': _selectedDistrict?.id,
                    'districtName': _selectedDistrict?.name,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(1.75)),
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
      },
    );
  }

  List<StateModel> _getStates(LocationState state) {
    if (state is StatesLoaded) return state.states;
    if (state is DistrictsLoading) return state.states;
    if (state is DistrictsLoaded) return state.states;
    return [];
  }

  List<DistrictModel> _getDistricts(LocationState state) {
    if (state is DistrictsLoaded) return state.districts;
    return [];
  }

  Widget _buildChip(String label, bool isSelected) {
    return AnimatedContainer(
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
            color: AppColors.headerGradientStart.withOpacity(0.3),
            blurRadius: Responsive.w(2),
            offset: Offset(0, Responsive.h(0.3)),
          ),
        ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(13),
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}