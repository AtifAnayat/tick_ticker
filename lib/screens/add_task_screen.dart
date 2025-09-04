import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tick_ticker/models/task_model.dart';
import 'package:tick_ticker/widgets/custom_toast.dart';
import 'package:tick_ticker/widgets/notification_service.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(TaskModel) onTaskAdded;
  final List<String> categories;

  const AddTaskScreen({
    super.key,
    required this.onTaskAdded,
    required this.categories,
  });

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isNote = false;
  String _selectedCategory = 'Personal';
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color.fromARGB(255, 34, 34, 34),
                        const Color.fromARGB(255, 34, 34, 66),
                        const Color.fromARGB(255, 30, 47, 94),
                      ]
                    : [Colors.grey[50]!, Colors.grey[100]!, Colors.teal[50]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            HugeIcons.strokeRoundedArrowLeft02,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Create New',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isNote = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: !_isNote
                                    ? (isDark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.2)
                                          : Colors.teal[100])
                                    : (isDark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.05)
                                          : Colors.white.withOpacity(0.7)),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: !_isNote
                                      ? (isDark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : Colors.teal[600]!)
                                      : (isDark
                                            ? Colors.grey
                                            : Colors.grey[300]!),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    HugeIcons.strokeRoundedTask01,
                                    color: !_isNote
                                        ? (isDark
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Colors.teal[700])
                                        : (isDark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7)
                                              : Colors.grey[500]),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Todo Task',
                                    style: GoogleFonts.poppins(
                                      color: !_isNote
                                          ? (isDark
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                : Colors.teal[700])
                                          : (isDark
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7)
                                                : Colors.grey[500]),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isNote = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isNote
                                    ? (isDark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.2)
                                          : Colors.teal[100])
                                    : (isDark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.05)
                                          : Colors.white.withOpacity(0.7)),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _isNote
                                      ? (isDark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : Colors.teal[600]!)
                                      : (isDark
                                            ? Colors.grey
                                            : Colors.grey[300]!),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    HugeIcons.strokeRoundedNote02,
                                    color: _isNote
                                        ? (isDark
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Colors.teal[700])
                                        : (isDark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7)
                                              : Colors.grey[500]),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Quick Note',
                                    style: GoogleFonts.poppins(
                                      color: _isNote
                                          ? (isDark
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                : Colors.teal[700])
                                          : (isDark
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7)
                                                : Colors.grey[500]),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                      decoration: InputDecoration(
                        hintText: _isNote ? 'Title' : 'Title',
                        hintStyle: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[400], // ✅ lighter grey hint
                        ),
                        border: InputBorder.none, // ✅ no border at all
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor:
                            Colors.transparent, // ✅ transparent background
                        isDense: true,
                        contentPadding:
                            EdgeInsets.zero, // ✅ text aligns naturally
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _contentController,
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _isNote ? 'Note Content' : 'Task Description',
                        hintStyle: GoogleFonts.raleway(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 50),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.05)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDark
                              ? Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.3)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Category',
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.teal[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: widget.categories.map((category) {
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == category
                                        ? (isDark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.3)
                                              : Colors.teal[100])
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _selectedCategory == category
                                          ? (isDark
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                : Colors.teal[600]!)
                                          : (isDark
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.3)
                                                : Colors.grey[400]!),
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      color: _selectedCategory == category
                                          ? (isDark
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                : Colors.teal[700])
                                          : (isDark
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7)
                                                : Colors.grey[600]),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    if (!_isNote) ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _selectDueDate(),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surface.withOpacity(0.05)
                                : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDark
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.3)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                HugeIcons.strokeRoundedCalendar01,
                                color: isDark
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.teal[600],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  _dueDate == null
                                      ? 'Set Due Date (Optional)'
                                      : 'Due: ${_formatDateTime(_dueDate!)}',
                                  style: GoogleFonts.poppins(
                                    color: _dueDate == null
                                        ? (isDark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7)
                                              : Colors.grey[600])
                                        : (isDark
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : Colors.teal[600]),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (_dueDate != null)
                                GestureDetector(
                                  onTap: () => setState(() => _dueDate = null),
                                  child: const Icon(
                                    HugeIcons.strokeRoundedDelete01,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        child: Text(
                          _isNote ? 'Save Note' : 'Create Task',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: Theme.of(context).colorScheme),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty) {
      CustomToast.show(
        context: context,
        title: 'Missing',
        description: 'Please enter the title.',
        type: ToastificationType.error,
      );
      return;
    }

    final taskId = const Uuid().v4(); // Generate unique ID
    final task = TaskModel(
      id: taskId,
      title: _titleController.text,
      content: _contentController.text,
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: _dueDate,
      isNote: _isNote,
      category: _selectedCategory,
    );

    // 1️⃣ Show immediate creation notification
    try {
      await NotificationService().showTaskCreatedNotification(
        title: _titleController.text,
        isNote: _isNote,
      );
    } catch (e) {
      print('Error showing creation notification: $e');
    }

    // 2️⃣ 🔥 FIXED: Schedule future notification with proper String ID
    if (_dueDate != null && _dueDate!.isAfter(DateTime.now())) {
      try {
        await NotificationService().scheduleTaskNotification(
          id: taskId, // Pass the String ID instead of hashCode
          title: _titleController.text,
          dueDate: _dueDate!,
          isNote: _isNote,
        );
        print('✅ Notification scheduled for: ${_dueDate!.toString()} with task ID: $taskId');
      } catch (e) {
        print('❌ Error scheduling notification: $e');
      }
    }

    widget.onTaskAdded(task);
    CustomToast.show(
      context: context,
      title: 'Success',
      description: _isNote
          ? 'Note saved successfully'
          : 'Task created successfully',
      type: ToastificationType.success,
    );
    Navigator.pop(context);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}