import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tick_ticker/widgets/notification_service.dart';

class NotificationDebugScreen extends StatefulWidget {
  @override
  _NotificationDebugScreenState createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  List<String> debugLogs = [];
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkPendingNotifications();
  }

  Future<void> _checkPendingNotifications() async {
    try {
      final pending = await NotificationService().getPendingNotifications();
      setState(() {
        pendingCount = pending.length;
        debugLogs.clear();
        debugLogs.add('📊 Total pending notifications: ${pending.length}');
        
        for (final notification in pending) {
          debugLogs.add('🔔 ID: ${notification.id}, Title: ${notification.title}');
        }
      });
    } catch (e) {
      setState(() {
        debugLogs.add('❌ Error checking pending: $e');
      });
    }
  }

  Future<void> _testNotification() async {
    try {
      await NotificationService().showTestNotification();
      setState(() {
        debugLogs.add('✅ Test notification sent at ${DateTime.now()}');
      });
    } catch (e) {
      setState(() {
        debugLogs.add('❌ Test notification failed: $e');
      });
    }
  }

  Future<void> _scheduleTestAlarm() async {
    try {
      final futureTime = DateTime.now().add(Duration(minutes: 1));
      await NotificationService().scheduleTaskNotification(
        id: 'test_alarm_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Alarm',
        dueDate: futureTime,
        isNote: false,
      );
      setState(() {
        debugLogs.add('✅ Test alarm scheduled for ${futureTime.toString()}');
      });
      _checkPendingNotifications();
    } catch (e) {
      setState(() {
        debugLogs.add('❌ Test alarm scheduling failed: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Debug',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Status',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Pending Notifications: $pendingCount'),
                    Text('Current Time: ${DateTime.now().toString()}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testNotification,
                    child: Text('Test Now'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _scheduleTestAlarm,
                    child: Text('Test 1min Alarm'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkPendingNotifications,
                    child: Text('Refresh Status'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        debugLogs.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Clear Logs'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Debug Logs
            Text(
              'Debug Logs:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: debugLogs.isEmpty
                    ? Text(
                        'No logs yet...',
                        style: GoogleFonts.robotoMono(color: Colors.grey),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: debugLogs.map((log) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: GoogleFonts.robotoMono(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}