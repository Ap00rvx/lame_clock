import 'dart:math';

enum MathOperation { addition, subtraction, multiplication, division }

class MathProblem {
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int correctAnswer;

  const MathProblem({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
  });

  String get operationSymbol {
    switch (operation) {
      case MathOperation.addition:
        return '+';
      case MathOperation.subtraction:
        return '-';
      case MathOperation.multiplication:
        return '×';
      case MathOperation.division:
        return '÷';
    }
  }

  String get problemText {
    return '$operand1 $operationSymbol $operand2 = ?';
  }

  bool isCorrectAnswer(int answer) {
    return answer == correctAnswer;
  }

  static MathProblem generate({MathOperation? preferredOperation}) {
    final random = Random();
    final operations = MathOperation.values;
    final operation =
        preferredOperation ?? operations[random.nextInt(operations.length)];

    int operand1, operand2, correctAnswer;

    switch (operation) {
      case MathOperation.addition:
        operand1 = random.nextInt(50) + 1; // 1-50
        operand2 = random.nextInt(50) + 1; // 1-50
        correctAnswer = operand1 + operand2;
        break;

      case MathOperation.subtraction:
        operand1 = random.nextInt(50) + 20; // 20-69
        operand2 = random.nextInt(operand1); // 0 to operand1-1
        correctAnswer = operand1 - operand2;
        break;

      case MathOperation.multiplication:
        operand1 = random.nextInt(12) + 1; // 1-12
        operand2 = random.nextInt(12) + 1; // 1-12
        correctAnswer = operand1 * operand2;
        break;

      case MathOperation.division:
        // Generate multiplication first, then reverse for division
        final factor1 = random.nextInt(12) + 1; // 1-12
        final factor2 = random.nextInt(12) + 1; // 1-12
        correctAnswer = factor1;
        operand1 = factor1 * factor2;
        operand2 = factor2;
        break;
    }

    return MathProblem(
      operand1: operand1,
      operand2: operand2,
      operation: operation,
      correctAnswer: correctAnswer,
    );
  }

  static List<MathProblem> generateMultiple(int count) {
    return List.generate(count, (index) => MathProblem.generate());
  }
}
