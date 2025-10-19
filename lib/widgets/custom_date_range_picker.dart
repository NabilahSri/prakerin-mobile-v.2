import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:mobile_prakerin/core/constants/colors.dart';
import 'package:mobile_prakerin/widgets/custom_button.dart';

class CustomDateRangePicker extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final Function(DateTimeRange) onDateRangeSelected;

  const CustomDateRangePicker({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey500.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Rentang Tanggal',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ),
            Expanded(
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.range,
                  lastDate: DateTime.now(),
                  selectedDayHighlightColor: AppColors.accent2,
                  weekdayLabels: [
                    'Min',
                    'Sen',
                    'Sel',
                    'Rab',
                    'Kam',
                    'Jum',
                    'Sab'
                  ],
                  controlsHeight: MediaQuery.of(context).size.height * 0.06,
                  controlsTextStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: selectedDateRange != null
                    ? [selectedDateRange!.start, selectedDateRange!.end]
                    : [
                        DateTime.now().subtract(const Duration(days: 7)),
                        DateTime.now()
                      ],
                onValueChanged: (dates) {
                  if (dates.length == 2) {
                    onDateRangeSelected(DateTimeRange(
                      start: dates[0],
                      end: dates[1],
                    ));
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: CustomButton(
                text: 'Terapkan',
                backgroundColor: AppColors.primaryDark,
                color: AppColors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
