import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tick_ticker/models/task_model.dart';
import 'package:tick_ticker/widgets/custom_toast.dart';
import 'package:tick_ticker/widgets/notification_service.dart';
import 'package:toastification/toastification.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final Function(TaskModel) onTaskUpdated;
  final List<String> categories;
  final VoidCallback onThemeToggle;

  const TaskDetailScreen({
    required this.task,
    required this.onTaskUpdated,
    required this.categories,
    required this.onThemeToggle,
    super.key,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  late DateTime? _dueDate;
  late DateTime? _originalDueDate; // Track original due date
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _contentController = TextEditingController(text: widget.task.content);
    _selectedCategory = widget.task.category;
    _dueDate = widget.task.dueDate;
    _originalDueDate = widget.task.dueDate; // Store original
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                    Colors.teal[50]!,
                  ],
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
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit ${widget.task.isNote ? 'Note' : 'Task'}' : widget.task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? HugeIcons.strokeRoundedCheckmarkSquare02 : HugeIcons.strokeRoundedEdit01,
                        color: isDark ? Theme.of(context).colorScheme.secondary : Colors.teal[600],
                      ),
                      onPressed: _isEditing ? _saveTask : () => setState(() => _isEditing = true),
                    ),
                    IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? HugeIcons.strokeRoundedSun01
                            : HugeIcons.strokeRoundedMoon02,
                        color: isDark ? Theme.of(context).colorScheme.secondary : Colors.teal[600],
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_isEditing) ...[
                  _buildViewMode(),
                ] else ...[
                  _buildEditMode(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!widget.task.isNote)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.task.isCompleted ? Colors.green : Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                            color: widget.task.isCompleted ? Colors.green : Colors.transparent,
                          ),
                          child: widget.task.isCompleted
                              ? const Icon(HugeIcons.strokeRoundedCheckmarkCircle02, size: 16, color: Colors.white)
                              : null,
                        ),
                      if (!widget.task.isNote) const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.task.isCompleted
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                    : Colors.grey[500])
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[800]),
                            decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationThickness: widget.task.isCompleted && Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                            decorationColor: widget.task.isCompleted && Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.8)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.task.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.task.isNote ? HugeIcons.strokeRoundedNote02 : HugeIcons.strokeRoundedTask01,
                          size: 16,
                          color: _getCategoryColor(widget.task.category),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.task.category} ${widget.task.isNote ? 'Note' : 'Task'}',
                          style: GoogleFonts.poppins(
                            color: _getCategoryColor(widget.task.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.task.content.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.task.content,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    HugeIcons.strokeRoundedCalendar01,
                    'Created',
                    _formatDateTime(widget.task.createdAt),
                  ),
                  if (widget.task.dueDate != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      HugeIcons.strokeRoundedClock01,
                      'Due Date',
                      _formatDateTime(widget.task.dueDate!),
                      color: _getDueDateColor(widget.task.dueDate!),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    HugeIcons.strokeRoundedInformationCircle,
                    'Status',
                    widget.task.isCompleted ? 'Completed' : 'Pending',
                    color: widget.task.isCompleted ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.secondary, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: widget.task.isNote ? 'Note Title' : 'Task Title',
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contentController,
                style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: widget.task.isNote ? 'Note Content' : 'Task Description',
                  labelStyle: GoogleFonts.poppins(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.categories.map((category) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedCategory == category
                                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedCategory == category
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: _selectedCategory == category
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
              if (!widget.task.isNote) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDueDate(),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(HugeIcons.strokeRoundedCalendar01, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            _dueDate == null
                                ? 'Set Due Date (Optional)'
                                : 'Due: ${_formatDateTime(_dueDate!)}',
                            style: GoogleFonts.poppins(
                              color: _dueDate == null
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(HugeIcons.strokeRoundedDelete01, color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _isEditing = false;
                        // Reset fields to original values
                        _titleController.text = widget.task.title;
                        _contentController.text = widget.task.content;
                        _selectedCategory = widget.task.category;
                        _dueDate = widget.task.dueDate;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
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
        title: 'Error',
        description: 'Please enter a title.',
        type: ToastificationType.error,
      );
      return;
    }

    final updatedTask = TaskModel(
      id: widget.task.id,
      title: _titleController.text,
      content: _contentController.text,
      isCompleted: widget.task.isCompleted,
      createdAt: widget.task.createdAt,
      dueDate: _dueDate,
      isNote: widget.task.isNote,
      category: _selectedCategory,
    );

    // Handle notification scheduling/updating
    try {
      String taskIdHash = widget.task.id.hashCode.toString();
      
      // Cancel existing notifications first
      await NotificationService().cancelTaskNotifications(taskIdHash);
      
      // Schedule new notification if conditions are met
      if (_dueDate != null && !widget.task.isNote && _dueDate!.isAfter(DateTime.now())) {
        await NotificationService().scheduleTaskNotification(
          id: taskIdHash,
          title: _titleController.text,
          dueDate: _dueDate!,
          isNote: widget.task.isNote,
        );
        print('Updated notification scheduled for: ${_dueDate!.toString()}');
      }
      
    } catch (e) {
      print('Error handling notifications: $e');
    }

    widget.onTaskUpdated(updatedTask);
    setState(() => _isEditing = false);
    
    CustomToast.show(
      context: context,
      title: 'Success',
      description: '${widget.task.isNote ? 'Note' : 'Task'} updated successfully',
      type: ToastificationType.success,
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
    if (difference <= 3) return Colors.yellow;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}