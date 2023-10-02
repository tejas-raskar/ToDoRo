import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/utils/utils.dart';

class TimeOptions extends StatelessWidget {
  const TimeOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CupertinoSlidingSegmentedControl<int>(
        children: selectableTime.asMap().map((index, time) {
          return MapEntry(index, Text((int.parse(time) ~/ 60).toString()));
        }),
        onValueChanged: (int? value) {
          // Handle the value change here
        },
      ),
    );

    // double selectedTime = 1500;
    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     children: selectableTime.map((time) {
    //       return Container(
    //         margin: EdgeInsets.only(left: 10),
    //         width: 70,
    //         height: 50,
    //         decoration: BoxDecoration(
    //           border: Border.all(width: 1, color: Colors.white30),
    //           borderRadius: BorderRadius.circular(5)
    //         ),
    //         child: Center(
    //           child: Text(
    //               (int.parse(time) ~/ 60).toString(),
    //             style: TextStyle(fontSize: 25),
    //           ),
    //         ),
    //       );
    //     }).toList(),
    //   ),
    // );
  }
}
