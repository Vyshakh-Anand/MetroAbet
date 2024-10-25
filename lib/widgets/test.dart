import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  CustomStepper({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          bool isActive = index == currentStep;
          bool isCompleted = index < currentStep;
          return StepperItem(
            text: steps[index],
            isActive: isActive,
            isCompleted: isCompleted,
            stepNumber: index + 1,
          );
        }),
      ),
    );
  }
}

class StepperItem extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isCompleted;
  final int stepNumber;

  StepperItem({required this.text, this.isActive = false, this.isCompleted = false, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : (isCompleted ? Colors.green : Colors.grey),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 6.0),
        Text(
          text,
          style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Stepper Example')),
      body: Center(
        child: CustomStepper(
          steps: ['Step 1', 'Step 2', 'Step 3', 'Step 4'],
          currentStep: 1, // Current step index (0-based)
        ),
      ),
    ),
  ));
}
