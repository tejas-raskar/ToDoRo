import 'package:flutter/material.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 3.2,
              height: 170,
              child: Center(
                child: Text("25", style: TextStyle(fontSize: 70),)
              ),
            ),
            const Text(":", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),),
            Container(
              width: MediaQuery.of(context).size.width / 3.2,
              height: 170,
              child: Center(
                  child: Text("00", style: TextStyle(fontSize: 70),)
              ),
            ),
          ],
        )
      ],
    );
  }
}
