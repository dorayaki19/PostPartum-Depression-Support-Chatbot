import 'extractor.dart';

class PPDPredictor {
  final List<String> negKeywords = [
    'overwhelmed', 'exhausted', 'worthless', 'hopeless', 'empty', 'numb',
    'dark', 'cry', 'anxious', 'scared', 'fear', 'trapped', 'alone', 'lonely',
    'burden', 'guilt', 'shame', 'failure', 'useless', 'broken', 'pain'
  ];

  final List<String> posKeywords = [
    'happy', 'joy', 'grateful', 'peaceful', 'content', 'hope', 'love',
    'connected', 'supported', 'calm', 'strong', 'proud', 'better', 'good'
  ];

  final List<String> crisisWords = [
    "kill myself", "want to die", "end my life", 
    "hurt my baby", "harm my baby", "suicide"
  ];

  String cleanText(String text) {
    // Lowercase and remove non-alphabet characters
    String cleaned = text.toLowerCase().replaceAll(RegExp(r"[^a-z\s']"), " ");
    // Collapse extra whitespace
    return cleaned.replaceAll(RegExp(r"\s+"), " ").trim();
  }

  bool detectCrisis(String text) {
    String t = text.toLowerCase();
    return crisisWords.any((word) => t.contains(word));
  }

  HandFeatures calculateHandFeatures(String text) {
    List<String> words = text.split(" ");
    int wc = words.length > 0 ? words.length : 1;

    int negCount = 0;
    int posCount = 0;

    for (var word in words) {
      if (negKeywords.any((k) => word.contains(k))) negCount++;
      if (posKeywords.any((k) => word.contains(k))) posCount++;
    }

    return HandFeatures(
      negKw: negCount,
      posKw: posCount,
      wordCount: wc,
      sentRatio: (posCount - negCount) / wc,
      negPosDiff: negCount - posCount,
    );
  }

  Map<String, dynamic> predict(String text) {
    if (detectCrisis(text)) {
      return {
        "severity": "Severe",
        "epds_score": 30,
        "alert": "CRISIS DETECTED"
      };
    }

    String cleaned = cleanText(text);
    HandFeatures feats = calculateHandFeatures(cleaned);

    // Replicating the EPDS estimate logic
    int epdsScore = ((feats.negKw * 2.5) - (feats.posKw * 2)).toInt();
    epdsScore = epdsScore.clamp(0, 30);

    // Rule-based severity mapping (from existing logic)
    String severity = "Minimal";
    if (epdsScore >= 20) {
      severity = "Severe";
    } else if (epdsScore >= 15) {
      severity = "High";
    } else if (epdsScore >= 10) {
      severity = "Moderate";
    } else if (epdsScore >= 5) {
      severity = "Mild";
    }

    return {
      "severity": severity,
      "epds_score": epdsScore,
      "features": feats.toList(),
    };
  }
}
