import 'package:flutter/material.dart';
import 'evaluation_learning_page.dart';

class EvaluationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('평가하기'),
    ),
    body: ListView(
    padding: EdgeInsets.all(16.0),
    children: [
    _buildEvaluationItem(context, '챕터 1 : 기본 인사', '유닛 1. 단어 평가하기', '인사 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 1 : 기본 인사', '유닛 2. 문장 평가하기', '인사 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 1 : 기본 인사', '유닛 3. 역량 평가하기', '인사 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 2 : 스포츠', '유닛 1. 단어 평가하기', '운동 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 2 : 스포츠', '유닛 2. 문장 평가하기', '운동 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 2 : 스포츠', '유닛 3. 역량 평가하기', '운동 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 3 : 음식', '유닛 1. 단어 평가하기', '음식 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 3 : 음식', '유닛 2. 문장 평가하기', '음식 | 기본', 'assets/images/sample1.png'),
    _buildEvaluationItem(context, '챕터 3 : 음식', '유닛 3. 역량 평가하기', '음식 | 기본', 'assets/images/sample1.png'),
    ],
    ),
    );
  }

  Widget _buildEvaluationItem(BuildContext context, String chapter, String title, String tags, String imagePath) {
    return Card(
      child: ListTile(
        leading: Image.asset(imagePath, width: 50, height: 50),
        title: Text(title),
        subtitle: Text(tags),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EvaluationLearningPage()),

          );
        },
      ),
    );
  }
}
