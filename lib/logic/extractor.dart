class HandFeatures {
  final int negKw;
  final int posKw;
  final int helpKw;
  final int negations;
  final int intensifiers;
  final int firstPerson;
  final int wordCount;
  final double sentRatio;
  final int negPosDiff;

  HandFeatures({
    required this.negKw,
    required this.posKw,
    this.helpKw = 0,
    this.negations = 0,
    this.intensifiers = 0,
    this.firstPerson = 0,
    required this.wordCount,
    required this.sentRatio,
    required this.negPosDiff,
  });

  // Converts features to a list for model input
  List<double> toList() {
    return [
      negKw.toDouble(),
      posKw.toDouble(),
      helpKw.toDouble(),
      negations.toDouble(),
      intensifiers.toDouble(),
      firstPerson.toDouble(),
      wordCount.toDouble(),
      sentRatio,
      negPosDiff.toDouble(),
    ];
  }
}
