import 'dart:math';

class AIAnalysisResult {
  final bool isAnomaly;
  final String level; // 'NORMAL', 'MODERATE', 'CRITICAL'
  final String title;
  final String message;
  final double deviationPercentage;
  final double confidence;
  final List<String> possibleCauses;
  final List<String> recommendedActions;

  AIAnalysisResult({
    required this.isAnomaly,
    required this.level,
    required this.title,
    required this.message,
    required this.deviationPercentage,
    required this.confidence,
    required this.possibleCauses,
    required this.recommendedActions,
  });
}

class AIOcrScanResult {
  final int detectedReading;
  final double confidence;
  final String meterType; // 'Digital Electronic' or 'Electromechanical Dial'
  final String serialNumberDetected;
  final String? imagePath;
  final bool isTamperDetected;

  AIOcrScanResult({
    required this.detectedReading,
    required this.confidence,
    required this.meterType,
    required this.serialNumberDetected,
    this.imagePath,
    this.isTamperDetected = false,
  });
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Analyzes a newly entered reading against the previous reading and baseline usage.
  AIAnalysisResult analyzeReading({
    required int currentReading,
    required int previousReading,
    required int historicalAverageUsage,
    String meterId = 'MM-04218',
  }) {
    final consumption = currentReading - previousReading;

    // 1. Negative Reading Check (Fault / Rollover / Typing Error)
    if (consumption < 0) {
      return AIAnalysisResult(
        isAnomaly: true,
        level: 'CRITICAL',
        title: 'Negative Consumption Detected',
        message: 'The entered reading ($currentReading kWh) is lower than previous reading ($previousReading kWh).',
        deviationPercentage: -100.0,
        confidence: 0.99,
        possibleCauses: [
          'Typographical error during manual digit entry.',
          'Physical meter dial has rolled over beyond 99,999 kWh.',
          'Meter was recently replaced by utility maintenance team.',
          'Wrong meter serial inspected.'
        ],
        recommendedActions: [
          'Verify the 5-digit counter on the physical meter display again.',
          'Check if utility replacement sticker is present on meter casing.',
          'If genuine rollover or replacement, report to supervisor before submission.'
        ],
      );
    }

    // 2. Sudden Surge / Large Consumption Spike Check
    final double baseline = historicalAverageUsage > 0 ? historicalAverageUsage.toDouble() : 300.0;
    final double deviation = ((consumption - baseline) / baseline) * 100.0;

    if (consumption > 1000 || deviation > 80.0) {
      final isExtreme = consumption > 1200 || deviation > 150.0;
      return AIAnalysisResult(
        isAnomaly: true,
        level: isExtreme ? 'CRITICAL' : 'MODERATE',
        title: isExtreme ? 'Extreme Surge Alert (+${deviation.toStringAsFixed(0)}%)' : 'High Usage Spike (+${deviation.toStringAsFixed(0)}%)',
        message: 'Consumption of $consumption kWh is significantly higher than monthly average of ${baseline.toInt()} kWh.',
        deviationPercentage: deviation,
        confidence: 0.94,
        possibleCauses: [
          'High load appliance (heavy A/C, electric EV charging, pool pump).',
          'Internal wiring insulation leakage / earth leakage.',
          'Transposed or misread digits (e.g. 15820 entered instead of 15720).',
          'Unauthorized commercial / industrial usage on domestic tariff line.'
        ],
        recommendedActions: [
          'Recheck the physical meter display number carefully.',
          'Capture a clear photo of the meter for cloud audit verification.',
          'Add a note in the observation box if heavy equipment is visibly active.'
        ],
      );
    }

    // 3. Sudden Zero Consumption or Abnormal Drop
    if (consumption == 0 && baseline > 50) {
      return AIAnalysisResult(
        isAnomaly: true,
        level: 'MODERATE',
        title: 'Zero Consumption Recorded',
        message: 'Recorded consumption is 0 kWh despite active service connection.',
        deviationPercentage: -100.0,
        confidence: 0.91,
        possibleCauses: [
          'Premises closed / unoccupied during billing cycle.',
          'Meter mechanism stuck or digital microcontroller frozen.',
          'Meter bypass or service tap tampering.'
        ],
        recommendedActions: [
          'Confirm if premises is currently occupied.',
          'Inspect meter LED indicator pulse or rotating disk.',
          'Check that meter wire seals are intact.'
        ],
      );
    }

    // 4. Normal Usage
    return AIAnalysisResult(
      isAnomaly: false,
      level: 'NORMAL',
      title: 'Consumption Verified',
      message: 'Consumption of $consumption kWh is within expected seasonal range ($baseline kWh typical).',
      deviationPercentage: deviation,
      confidence: 0.98,
      possibleCauses: ['Normal domestic consumption pattern.'],
      recommendedActions: ['Proceed with submission.'],
    );
  }

  /// AI Meter OCR Digit Recognition Simulation with image analysis
  Future<AIOcrScanResult> scanMeterOcr({
    String? imagePath,
    int? baselinePreviousReading,
  }) async {
    // Simulate AI inference latency (computer vision on-device neural model)
    await Future.delayed(const Duration(milliseconds: 1400));

    final prev = baselinePreviousReading ?? 15700;
    // Generate realistic increment (e.g. 120 to 180 kWh added)
    final randomAdd = 110 + Random().nextInt(75);
    final simulatedDetected = prev + randomAdd;

    return AIOcrScanResult(
      detectedReading: simulatedDetected,
      confidence: 0.984,
      meterType: 'Digital Single Phase (CEB Standard)',
      serialNumberDetected: 'CEB-MM-04218',
      imagePath: imagePath,
      isTamperDetected: false,
    );
  }

  /// Field Copilot Q&A
  String getCopilotAnswer(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('err') || lower.contains('error')) {
      return 'CEB & LECO Digital Meter Error Codes:\n'
          '• Err-01: Reverse energy flow detected (Solar Net Metering miswiring or tampering).\n'
          '• Err-02: Microcontroller battery low (RTC backup failing).\n'
          '• Err-03: Neutral line disconnected or bypass loop.\n'
          'Action: Take a photo and flag for Inspection Team.';
    }

    if (lower.contains('seal') || lower.contains('tamper') || lower.contains('broken')) {
      return 'Tampering / Seal Protocol:\n'
          '1. Never break or touch remaining seals.\n'
          '2. Take clear close-up photos of the terminal cover and optical port.\n'
          '3. Enter current reading accurately.\n'
          '4. Select "Potential Anomaly / Seal Damaged" in notes.\n'
          '5. Notify Homagama Area Depot Supervisor immediately.';
    }

    if (lower.contains('tariff') || lower.contains('slab') || lower.contains('bill')) {
      return 'CEB Domestic Tariff Structure (Sample Reference):\n'
          '• 0 - 30 kWh: Base lifeline rate\n'
          '• 31 - 60 kWh: Subsidized tier\n'
          '• 61 - 90 kWh: Standard tier\n'
          '• 91 - 120 kWh: Tier 3\n'
          '• 121 - 180 kWh: Tier 4\n'
          '• Above 180 kWh: Peak rate + Fixed charge\n'
          'Fuel adjustment charges & SSCL taxes apply on official bills.';
    }

    if (lower.contains('dog') || lower.contains('inaccessible') || lower.contains('closed')) {
      return 'Inaccessible Premises Procedure:\n'
          'If the gate is locked or meter is inaccessible due to an unrestrained dog:\n'
          '• Mark assignment note as "Premises Inaccessible".\n'
          '• Leave a standard CEB visiting card / reading request slip.\n'
          '• Move to next stop to keep route schedule on time.';
    }

    return 'MeterMind AI Field Assistant: For Homagama Area route MR001, remember to verify cumulative whole numbers. If any customer reading exceeds +50% surge, capture a photo before saving.';
  }
}
