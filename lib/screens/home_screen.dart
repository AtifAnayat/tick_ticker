import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_ticker/models/task_model.dart';
import 'package:tick_ticker/widgets/custom_toast.dart';
import 'package:tick_ticker/widgets/notification_service.dart';
import 'package:toastification/toastification.dart';

import 'add_task_screen.dart';
import 'task_detail_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  VoidCallback onThemeToggle;
  HomeScreen({super.key, required this.onThemeToggle});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<TaskModel> tasks = [];
  List<TaskModel> filteredTasks = [];
  String selectedFilter = 'All';
  final Set<String> _shownAlarms = {};
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  Timer? _alarmTimer;
  String userName = '';

  final List<String> categories = [
    'Work',
    'Personal',
    'Study',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _loadUserName();
    _loadTasks();
    _startAlarmTimer();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? '';
    });
  }

  void _startAlarmTimer() {
    _alarmTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkForDueTasks();
    });
  }

  void _checkForDueTasks() {
    final now = DateTime.now();
    for (final task in tasks) {
      if (task.dueDate != null &&
          !task.isCompleted &&
          !_shownAlarms.contains(task.id)) {
        final diff = task.dueDate!.difference(now).inMinutes;

        if (diff <= 10 && diff > 0) {
          _showAlarmNotification(task);
          _shownAlarms.add(task.id);
        }
      }
    }
  }

  void _showAlarmNotification(TaskModel task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alarm, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Task Due!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Don't forget to complete it on time!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Dismiss',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: open task detail or mark complete
              Navigator.pop(context);
            },
            child: Text(
              'View Task',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _alarmTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      tasks = tasksJson
          .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
          .toList();
      _filterTasks();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _filterTasks() {
    setState(() {
      switch (selectedFilter) {
        case 'Notes':
          filteredTasks = tasks.where((task) => task.isNote).toList();
          break;
        case 'Todos':
          filteredTasks = tasks.where((task) => !task.isNote).toList();
          break;
        case 'Completed':
          filteredTasks = tasks.where((task) => task.isCompleted).toList();
          break;
        case 'Pending':
          filteredTasks = tasks
              .where((task) => !task.isCompleted && !task.isNote)
              .toList();
          break;
        default:
          filteredTasks = List.from(tasks);
      }
      filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void _addTask(TaskModel task) {
    setState(() {
      tasks.add(task);
      _filterTasks();
    });
    _saveTasks();
  }

  // 🔥 FIXED: Update task method with notification rescheduling
  void _updateTask(TaskModel updatedTask) {
    setState(() {
      int index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        final oldTask = tasks[index];
        tasks[index] = updatedTask;
        _filterTasks();
        
        // 🔥 FIXED: Reschedule notifications if task is updated
        _handleTaskUpdateNotifications(oldTask, updatedTask);
      }
    });
    _saveTasks();
  }

  // 🔥 NEW: Handle notification updates when task is modified
  Future<void> _handleTaskUpdateNotifications(TaskModel oldTask, TaskModel updatedTask) async {
    try {
      // Cancel old notifications
      await NotificationService().cancelTaskNotifications(oldTask.id);
      
      // Schedule new notifications if:
      // 1. Task is not completed
      // 2. Task is not a note (or is a note with due date)
      // 3. Has a due date
      // 4. Due date is in the future
      if (!updatedTask.isCompleted && 
          updatedTask.dueDate != null && 
          updatedTask.dueDate!.isAfter(DateTime.now())) {
        
        await NotificationService().scheduleTaskNotification(
          id: updatedTask.id,
          title: updatedTask.title,
          dueDate: updatedTask.dueDate!,
          isNote: updatedTask.isNote,
        );
        
        print('✅ Rescheduled notifications for updated task: ${updatedTask.title}');
      }
    } catch (e) {
      print('❌ Error handling task update notifications: $e');
    }
  }

  // 🔥 FIXED: Delete task method with proper notification cleanup
  void _deleteTask(String id) {
    // Cancel notifications before deleting
    NotificationService().cancelTaskNotifications(id);
    
    setState(() {
      tasks.removeWhere((task) => task.id == id);
      _filterTasks();
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF16213E)]
                : [Colors.grey[50]!, Colors.grey[100]!, Colors.teal[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              _buildFilterChips(),
              const SizedBox(height: 10),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            _fabController.forward().then((_) => _fabController.reverse());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(
                  onTaskAdded: _addTask,
                  categories: categories,
                ),
              ),
            );
          },
          elevation: 8,
          child: Icon(
            HugeIcons.strokeRoundedPlusSign,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: Image.asset('assets/animations/clock.png', scale: 10),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user name if available, otherwise show "Tick Ticker"
              Text(
                userName.isNotEmpty ? 'Hi, $userName' : 'Tick Ticker',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _getGreeting(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Spacer(),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surface.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDark
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.3)
                        : Colors.teal.withOpacity(0.3),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateTime.now().day.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.teal[600],
                      ),
                    ),
                    Text(
                      _getMonthName(DateTime.now().month),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? HugeIcons.strokeRoundedSun01
                      : HugeIcons.strokeRoundedMoon02,
                  color: isDark
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.teal[600],
                ),
                onPressed: widget.onThemeToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Notes', 'Todos', 'Pending', 'Completed'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = selectedFilter == filter;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: FilterChip(
                  checkmarkColor: isDark ? Colors.black : Colors.white,
                  label: Text(
                    filter,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey[700]),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedFilter = filter;
                      _filterTasks();
                    });
                  },
                  showCheckmark: false,
                  backgroundColor: isDark
                      ? Theme.of(context).colorScheme.surface.withOpacity(0.1)
                      : Colors.white.withOpacity(0.7),
                  selectedColor: isDark
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.teal[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isSelected
                          ? (isDark
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.teal[600]!)
                          : (isDark ? Colors.grey : Colors.grey[300]!),
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalTasks = tasks.where((t) => !t.isNote).length;
    final completedTasks = tasks
        .where((t) => t.isCompleted && !t.isNote)
        .length;
    final totalNotes = tasks.where((t) => t.isNote).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
              : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Tasks',
            totalTasks.toString(),
            HugeIcons.strokeRoundedTask02,
            Colors.blue,
          ),
          _buildStatItem(
            'Completed',
            completedTasks.toString(),
            HugeIcons.strokeRoundedCheckmarkCircle02,
            Colors.green,
          ),
          _buildStatItem(
            'Notes',
            totalNotes.toString(),
            HugeIcons.strokeRoundedNote02,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            SizedBox(
              child: Lottie.asset(
                height: 150,
                width: 150,
                'assets/animations/empty.json',
              ),
            ),
            Text(
              "No task/notes found",
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(filteredTasks[index]);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(HugeIcons.strokeRoundedDelete01, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteTask(task.id);
        CustomToast.show(
          context: context,
          title: 'Success',
          description: 'Task Has been deleted.',
          type: ToastificationType.success,
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task,
                onTaskUpdated: _updateTask,
                categories: categories,
                onThemeToggle: widget.onThemeToggle,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? Colors.green.withOpacity(isDark ? 0.1 : 0.15)
                : isDark
                ? Theme.of(context).colorScheme.surface.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: task.isCompleted
                  ? Colors.green.withOpacity(isDark ? 0.3 : 0.4)
                  : isDark
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                  : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? (task.isCompleted
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary)
                          .withOpacity(0.1)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!task.isNote)
                    GestureDetector(
                      onTap: () {
                        final updatedTask = TaskModel(
                          id: task.id,
                          title: task.title,
                          content: task.content,
                          isCompleted: !task.isCompleted,
                          createdAt: task.createdAt,
                          dueDate: task.dueDate,
                          isNote: task.isNote,
                          category: task.category,
                        );
                        _updateTask(updatedTask);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted
                                ? Colors.green
                                : (isDark
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.teal[600]!),
                            width: 2,
                          ),
                          color: task.isCompleted
                              ? Colors.green
                              : Colors.transparent,
                        ),
                        child: task.isCompleted
                            ? Icon(
                                HugeIcons.strokeRoundedTick01,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  if (!task.isNote) SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? (isDark
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6)
                                  : Colors.grey[500])
                            : (isDark ? Colors.white : Colors.grey[800]),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.red,
                        decorationThickness: 2,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  _buildCategoryChip(task.category),
                ],
              ),
              if (task.content.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(
                  task.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.isNote
                            ? HugeIcons.strokeRoundedNote02
                            : HugeIcons.strokeRoundedTask01,
                        size: 20,
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.7)
                            : Colors.teal[600]!.withOpacity(0.8),
                      ),
                      SizedBox(width: 5),
                      Text(
                        _formatDate(task.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  if (task.dueDate != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDueDateColor(
                          task.dueDate!,
                        ).withOpacity(isDark ? 0.2 : 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Due: ${_formatDate(task.dueDate!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getDueDateColor(task.dueDate!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(category);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: isDark ? categoryColor : categoryColor.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Study':
        return Colors.purple;
      case 'Health':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return Colors.red;
    if (difference == 0) return Colors.orange;
    if (difference <= 3) return Colors.amber;
    return Colors.green;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}