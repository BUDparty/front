import 'package:flutter/material.dart';
import '../models/models.dart';

class AccentLearningResultPage extends StatelessWidget {
  final double progress;
  final List<AppSentence> sentences;
  final int chapterId;

  AccentLearningResultPage({
    required this.progress,
    required this.sentences,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF3FA),
      appBar: AppBar(
        title: Text('Accent Learning Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chapter $chapterId', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Progress: ${progress.toStringAsFixed(2)}%', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sentences.length,
                itemBuilder: (context, index) {
                  final sentence = sentences[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        sentence.koreanSentence,
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        sentence.northKoreanSentence,
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        sentence.isCorrect ? Icons.check_circle : Icons.error,
                        color: sentence.isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

