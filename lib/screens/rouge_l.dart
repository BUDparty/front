import 'dart:math';

import 'dart:math';

// ROUGE-N 계산 함수
Map<String, double> calculateRougeN(String reference, String candidate, int n) {
  final referenceNGrams = _getNGrams(reference, n);
  final candidateNGrams = _getNGrams(candidate, n);

  final intersection = referenceNGrams.toSet().intersection(candidateNGrams.toSet());
  final union = referenceNGrams.toSet().union(candidateNGrams.toSet());

  final recall = intersection.length / referenceNGrams.length;
  final precision = intersection.length / candidateNGrams.length;
  final f1Score = (2 * recall * precision) / (recall + precision);

  return {
    'recall': recall.isNaN ? 0.0 : recall,
    'precision': precision.isNaN ? 0.0 : precision,
    'f1Score': f1Score.isNaN ? 0.0 : f1Score,
  };
}

// N-그램 추출 함수
List<String> _getNGrams(String text, int n) {
  final words = text.split(' ');
  final nGrams = <String>[];

  for (var i = 0; i < words.length - n + 1; i++) {
    nGrams.add(words.sublist(i, i + n).join(' '));
  }

  return nGrams;
}

// ROUGE-L 계산 함수
Map<String, double> calculateRougeL(String reference, String candidate) {
  final lcsLength = _longestCommonSubsequence(reference, candidate).length;
  final recall = lcsLength / reference.split(' ').length;
  final precision = lcsLength / candidate.split(' ').length;
  final f1Score = (2 * recall * precision) / (recall + precision);

  return {
    'recall': recall.isNaN ? 0.0 : recall,
    'precision': precision.isNaN ? 0.0 : precision,
    'f1Score': f1Score.isNaN ? 0.0 : f1Score,
  };
}

// Longest Common Subsequence (LCS) 추출 함수
List<String> _longestCommonSubsequence(String reference, String candidate) {
  final referenceWords = reference.split(' ');
  final candidateWords = candidate.split(' ');

  final lcsTable = List.generate(
    referenceWords.length + 1,
        (_) => List<int>.filled(candidateWords.length + 1, 0),
  );

  for (var i = 1; i <= referenceWords.length; i++) {
    for (var j = 1; j <= candidateWords.length; j++) {
      if (referenceWords[i - 1] == candidateWords[j - 1]) {
        lcsTable[i][j] = lcsTable[i - 1][j - 1] + 1;
      } else {
        lcsTable[i][j] = max(lcsTable[i - 1][j], lcsTable[i][j - 1]);
      }
    }
  }

  final lcs = <String>[];
  var i = referenceWords.length;
  var j = candidateWords.length;

  while (i > 0 && j > 0) {
    if (referenceWords[i - 1] == candidateWords[j - 1]) {
      lcs.insert(0, referenceWords[i - 1]);
      i--;
      j--;
    } else if (lcsTable[i - 1][j] > lcsTable[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  return lcs;
}
