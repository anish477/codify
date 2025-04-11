import 'package:flutter/material.dart';



class LessonCompletedPage extends StatefulWidget {
  final int pointsEarned;
  final String lessonId;
  final Duration timeToComplete;
  final double accuracy;

  const LessonCompletedPage({
    super.key,
    required this.pointsEarned,
    required this.lessonId,
    required this.timeToComplete,
    required this.accuracy
  });

  @override
  State<LessonCompletedPage> createState() => _LessonCompletedPageState();
}

class _LessonCompletedPageState extends State<LessonCompletedPage> {
  

  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              const SizedBox(height: 70),



              // Title Text
              Text(
                "Lesson Completed !",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle Text
              Text(
                "Congrats !",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 70),

              // Stats Boxes Row
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStatBox(
                    title: "TOTAL XP",
                    value: widget.pointsEarned.toString(),
                    icon: Icons.bolt,
                    iconColor: Color(0xFFFFC300),
                    backgroundColor: Color(0xFFFF8020),
                    titleColor: Color(0xFFFFFFFF),
                    valueColor: Colors.black87,
                  ),

                  _buildStatBox(
                    title: "TIME",
                    value: _formatDuration(widget.timeToComplete),
                    icon: Icons.timer,
                    iconColor:Color(0xFF14D4F4),
                    backgroundColor: Color(0xFF1CB0f6),
                    titleColor: Color(0xFFFFFFFF),
                    valueColor: Colors.black87,
                  ),
                  _buildStatBox(
                    title: "ACCURACY",
                    value: "${widget.accuracy.toStringAsFixed(0)}%",
                    icon: Icons.check_circle_outline,
                    iconColor: Color(0xFF8EE000),
                    backgroundColor: Color(0xFF7AC70C),
                    titleColor: Color(0xFFFFFFFF),
                    valueColor: Colors.black87,
                  ),
                ],
              ),


              const SizedBox(height: 90,),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1cb0f6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(


        children: [

            Text(
              title,
              style: TextStyle(
                color: titleColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w900
                ,
              ),
            ),

          const SizedBox(height: 10),
          Card(

            child: SizedBox(
              height: 100,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: iconColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 18,
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
    );
  }
}