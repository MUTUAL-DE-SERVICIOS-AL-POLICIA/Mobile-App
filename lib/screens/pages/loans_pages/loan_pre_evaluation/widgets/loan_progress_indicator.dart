import 'package:flutter/material.dart';

class LoanProgressIndicator extends StatelessWidget {
  final int currentStep;

  const LoanProgressIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff419388),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStep(
            stepNumber: 1,
            label: 'Modalidad',
            icon: Icons.list_alt,
            isActive: currentStep == 1,
            isCompleted: currentStep > 1,
          ),
          _buildConnector(isCompleted: currentStep > 1),
          _buildStep(
            stepNumber: 2,
            label: 'Cálculo',
            icon: Icons.calculate,
            isActive: currentStep == 2,
            isCompleted: currentStep > 2,
          ),
          _buildConnector(isCompleted: currentStep > 2),
          _buildStep(
            stepNumber: 3,
            label: 'Documentos',
            icon: Icons.description,
            isActive: currentStep == 3,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    final StepColors colors = _getStepColors(isActive, isCompleted);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.borderColor,
              width: 2.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                    weight: 700,
                  )
                : Icon(
                    icon,
                    color: colors.iconColor,
                    size: 18,
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: colors.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  StepColors _getStepColors(bool isActive, bool isCompleted) {
    if (isCompleted) {
      return StepColors(
        backgroundColor: Colors.transparent,
        borderColor: Colors.white,
        iconColor: Colors.white,
        textColor: Colors.white,
        shadowColor: Colors.transparent,
      );
    }

    if (isActive) {
      return StepColors(
        backgroundColor: Colors.transparent,
        borderColor: Colors.white,
        iconColor: Colors.white,
        textColor: Colors.white,
        shadowColor: Colors.transparent,
      );
    }

    return StepColors(
      backgroundColor: Colors.transparent,
      borderColor: Colors.white.withOpacity(0.5),
      iconColor: Colors.white.withOpacity(0.5),
      textColor: Colors.white.withOpacity(0.5),
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      width: 36,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// === CLASE DE COLORES PARA LOS PASOS ===

class StepColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color shadowColor;

  StepColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.shadowColor,
  });
}