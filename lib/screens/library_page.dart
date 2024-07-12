import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Learning'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Stored Vocabularies'),
            _buildSubTitle('You can store up to 3 words'),
            _buildVocabularyItem('감사합니다', 'Thank you'),
            _buildVocabularyItem('여보세요', 'Hello on phone'),
            _buildVocabularyItem('사랑해요', 'I love you'),
            SizedBox(height: 20),
            _buildSectionTitle('Stored Sentence Cards'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
            SizedBox(height: 20),
            _buildSectionTitle('Stored Sentence Cards'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
            _buildSentenceCard('Recent Sentences', 'Try pronouncing these sentences to improve your speaking skills.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildVocabularyItem(String word, String meaning) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Text('abc', style: TextStyle(color: Colors.black)),
      ),
      title: Text('Word: $word'),
      subtitle: Text('Meaning: $meaning'),
    );
  }

  Widget _buildSentenceCard(String title, String description) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey[200],
          child: Center(
            child: Text('Image', style: TextStyle(color: Colors.black)),
          ),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTag('Speaking'),
                SizedBox(width: 5),
                _buildTag('Accent'),
              ],
            ),
            SizedBox(height: 5),
            Text(description),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}