```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø­Ø§Ø³Ø¨Ù',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  void _inputDigit(String digit) {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = digit;
        _waitingForSecondOperand = false;
      });
    } else {
      setState(() {
        _display = _display == '0' ? digit : _display + digit;
      });
    }
  }

  void _inputDecimal() {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = '0.';
        _waitingForSecondOperand = false;
      });
      return;
    }
    if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _performOperation(String op) {
    final double current = double.parse(_display);
    if (_firstOperand != null && !_waitingForSecondOperand) {
      _calculateResult();
    }
    setState(() {
      _firstOperand = current;
      _operator = op;
      _waitingForSecondOperand = true;
      _expression = '$current $op';
    });
  }

  void _calculateResult() {
    if (_firstOperand == null || _operator == null) return;
    final double secondOperand = double.parse(_display);
    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand! * secondOperand;
        break;
      case 'Ã·':
        if (secondOperand == 0) {
          setState(() {
            _display = 'Ø®Ø·Ø£';
            _expression = '';
            _firstOperand = null;
            _operator = null;
            _waitingForSecondOperand = false;
          });
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
      default:
        return;
    }
    setState(() {
      _display = result == result.truncateToDouble()
          ? result.toInt().toString()
          : result.toStringAsFixed(2);
      _expression = '$_firstOperand $_operator $secondOperand =';
      _firstOperand = result;
      _operator = null;
      _waitingForSecondOperand = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _percent() {
    final double value = double.parse(_display) / 100;
    setState(() {
      _display = value.toString();
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  Widget _buildButton(String text, {Color? color, double flex = 1}) {
    final bool isOperator = ['+', '-', 'Ã', 'Ã·', '='].contains(text);
    final bool isClear = text == 'C';
    final bool isBackspace = text == 'â«';
    final bool isPercent = text == '%';
    final bool isSign = text == 'Â±';

    Color buttonColor;
    Color textColor;
    if (isOperator || text == '=') {
      buttonColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (isClear || isBackspace || isPercent || isSign) {
      buttonColor = Theme.of(context).colorScheme.secondaryContainer;
      textColor = Theme.of(context).colorScheme.onSecondaryContainer;
    } else {
      buttonColor = Theme.of(context).colorScheme.surfaceVariant;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilledButton(
          onPressed: () {
            if (isClear) {
              _clear();
            } else if (isBackspace) {
              _backspace();
            } else if (isPercent) {
              _percent();
            } else if (isSign) {
              _toggleSign();
            } else if (isOperator) {
              if (text == '=') {
                _calculateResult();
              } else {
                _performOperation(text);
              }
            } else if (text == '.') {
              _inputDecimal();
            } else {
              _inputDigit(text);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isOperator || text == '=' ? 28 : 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø­Ø§Ø³Ø¨Ù'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _display,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('C', color: Colors.red),
                    _buildButton('Â±'),
                    _buildButton('%'),
                    _buildButton('Ã·'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('Ã'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0', flex: 2),
                    _buildButton('.'),
                    _buildButton('='),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```