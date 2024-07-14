import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('진행도'),
        backgroundColor: Color(0xFFF0DEF3),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFF0DEF3),
              borderRadius: BorderRadius.circular(10.0),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '진행상황 보기',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '학습한 챕터 수',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '평가 점수 (100점 기준)',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '75',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  '학습하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.book, color: Colors.blue),
                    title: Text('챕터 1. 기본 인사'),
                    subtitle: Text('50% 완료했어요!'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.sports_soccer, color: Colors.green),
                    title: Text('챕터 2. 스포츠'),
                    subtitle: Text('75% 완료했어요!'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.fastfood, color: Colors.red),
                    title: Text('챕터 3. 음식'),
                    subtitle: Text('25% 완료했어요!'),
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF9714AF),
                  ),
                  child: Text('평가하기'),
                ),
                SizedBox(height: 16.0),
                Text(
                  '평가하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.book, color: Colors.blue),
                    title: Text('챕터 1. 기본 인사'),
                    subtitle: Text('50% 완료했어요!'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.sports_soccer, color: Colors.green),
                    title: Text('챕터 2. 스포츠'),
                    subtitle: Text('75% 완료했어요!'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.fastfood, color: Colors.red),
                    title: Text('챕터 3. 음식'),
                    subtitle: Text('25% 완료했어요!'),
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF9714AF),
                  ),
                  child: Text('평가하기'),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF0DEF3),
    );
  }
}