import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Hitam pekat
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A0000), // Merah sangat gelap
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Color(0xFFFF1744)), // Merah cerah
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF1744), // Merah cerah
          foregroundColor: Colors.white,
        ),
        checkboxTheme: const CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(Color(0xFFFF1744)),
          checkColor: MaterialStatePropertyAll(Colors.white),
        ),
      ),
      home: const TaskManagerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Task {
  final int id;
  final String title;
  final String priority;
  final String dueDate;
  final String createdAt;
  final String updatedAt;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDone: json['is_done'].toString().toLowerCase() == 'true',
    );
  }
}

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});
  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage>
    with TickerProviderStateMixin {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  List<Task> tasks = [];
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fabAnimation;

  final TextEditingController titleController = TextEditingController();
  String selectedPriority = 'low';
  DateTime? selectedDate;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    fetchTasks();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  List<Task> getTasksByStatus(String status) {
    List<Task> filtered = [];
    switch (status) {
      case 'all':
        filtered = tasks;
        break;
      case 'pending':
        filtered = tasks.where((task) => !task.isDone).toList();
        break;
      case 'completed':
        filtered = tasks.where((task) => task.isDone).toList();
        break;
      case 'priority':
        filtered = tasks.where((task) => task.priority == 'high').toList();
        break;
    }

    filtered.sort((a, b) {
      DateTime aDate = DateTime.parse(a.dueDate);
      DateTime bDate = DateTime.parse(b.dueDate);
      return aDate.compareTo(bDate);
    });

    return filtered;
  }

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      setState(() {
        tasks = jsonData.map((e) => Task.fromJson(e)).toList();
      });
      _cardAnimationController.forward();
    }
  }

  Future<void> addTask() async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    await http.post(
      Uri.parse('$baseUrl/tasks'),
      body: {
        'title': titleController.text,
        'priority': selectedPriority,
        'due_date': selectedDate!.toIso8601String().split('T')[0],
      },
    );
    titleController.clear();
    selectedDate = null;
    selectedPriority = 'low';
    fetchTasks();
  }

  Future<void> editTask(Task task) async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      body: {
        'title': titleController.text,
        'priority': selectedPriority,
        'due_date': selectedDate!.toIso8601String().split('T')[0],
        'is_done': task.isDone.toString(),
      },
    );
    titleController.clear();
    selectedDate = null;
    selectedPriority = 'low';
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    fetchTasks();
  }

  Future<void> updateTaskStatus(Task task, bool newStatus) async {
    await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      body: {
        'title': task.title,
        'priority': task.priority,
        'due_date': task.dueDate,
        'is_done': newStatus.toString(),
      },
    );
    fetchTasks();
  }

  String formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return raw;
    }
  }

  void showTaskDialog({Task? taskToEdit}) {
    if (taskToEdit != null) {
      titleController.text = taskToEdit.title;
      selectedPriority = taskToEdit.priority;
      selectedDate = DateTime.parse(taskToEdit.dueDate);
    } else {
      titleController.clear();
      selectedPriority = 'low';
      selectedDate = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A0000), // Merah sangat gelap
                Color(0xFF0D0D0D), // Hitam pekat
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                taskToEdit == null ? 'Buat Tugas Baru' : 'Edit Tugas',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF1744),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF555555)),
                ),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.title, color: Color(0xFFFF1744)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF555555)),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedPriority,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  items: [
                    {
                      'value': 'low',
                      'label': 'Rendah',
                      'icon': Icons.keyboard_arrow_down,
                    },
                    {
                      'value': 'medium',
                      'label': 'Sedang',
                      'icon': Icons.remove,
                    },
                    {
                      'value': 'high',
                      'label': 'Tinggi',
                      'icon': Icons.keyboard_arrow_up,
                    },
                  ].map((item) {
                    return DropdownMenuItem(
                      value: item['value'] as String,
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: const Color(0xFFFF1744),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPriority = value!),
                  decoration: const InputDecoration(
                    labelText: 'Tingkat Prioritas',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.flag, color: Color(0xFFFF1744)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFFF1744),
                            surface: Color(0xFF2A2A2A),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF555555)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFFF1744)),
                      const SizedBox(width: 16),
                      Text(
                        selectedDate == null
                            ? 'Pilih Tanggal Deadline'
                            : 'Deadline: ${selectedDate.toString().split(' ')[0]}',
                        style: TextStyle(
                          color: selectedDate == null ? Colors.grey : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (taskToEdit == null) {
                      addTask();
                    } else {
                      editTask(taskToEdit);
                    }
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1744),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    taskToEdit == null ? 'Simpan Tugas' : 'Update Tugas',
                    style: const TextStyle(
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
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF1744);
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.horizontal_rule;
      case 'low':
      default:
        return Icons.low_priority;
    }
  }

  Widget buildTaskCard(Task task, int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            50 * (1 - _cardAnimationController.value) * (index + 1),
          ),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 8,
                shadowColor: const Color(0xFFFF1744).withOpacity(0.3),
                color: task.isDone 
                    ? const Color(0xFF2A2A2A) 
                    : const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: task.isDone 
                        ? Colors.grey.withOpacity(0.3)
                        : const Color(0xFFFF1744).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => showTaskDialog(taskToEdit: task),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: task.isDone
                            ? [
                                const Color(0xFF2A2A2A),
                                const Color(0xFF1A1A1A),
                              ]
                            : [
                                const Color(0xFF1A1A1A),
                                const Color(0xFF0D0D0D),
                              ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => updateTaskStatus(task, !task.isDone),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: task.isDone 
                                          ? const Color(0xFFFF1744) 
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    color: task.isDone 
                                        ? const Color(0xFFFF1744) 
                                        : Colors.transparent,
                                  ),
                                  child: task.isDone
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isDone 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                    color: task.isDone 
                                        ? Colors.grey 
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                color: const Color(0xFF2A2A2A),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, color: Color(0xFFFF1744)),
                                        const SizedBox(width: 8),
                                        const Text('Edit', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => showTaskDialog(taskToEdit: task),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete, color: Colors.red),
                                        const SizedBox(width: 8),
                                        const Text('Hapus', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    onTap: () => deleteTask(task.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getPriorityColor(task.priority).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: getPriorityColor(task.priority),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      getPriorityIcon(task.priority),
                                      size: 16,
                                      color: getPriorityColor(task.priority),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.priority.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: getPriorityColor(task.priority),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate,
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dibuat: ${formatDateTime(task.createdAt)}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTaskList(String status) {
    final taskList = getTasksByStatus(status);

    if (taskList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'all'
                  ? Icons.task_alt
                  : status == 'pending'
                  ? Icons.pending_actions
                  : status == 'completed'
                  ? Icons.check_circle
                  : Icons.priority_high,
              size: 80,
              color: const Color(0xFFFF1744).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              status == 'all'
                  ? 'Belum ada tugas'
                  : status == 'pending'
                  ? 'Tidak ada tugas tertunda'
                  : status == 'completed'
                  ? 'Belum ada tugas selesai'
                  : 'Tidak ada tugas prioritas tinggi',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => buildTaskCard(taskList[index], index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0000), // Merah sangat gelap
              Color(0xFF0D0D0D), // Hitam pekat
            ],
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0000).withOpacity(0.8),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40), // Top spacing
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                        children: [
                          ...List.generate(4, (index) {
                            final destinations = [
                              {'icon': Icons.list, 'label': 'Semua'},
                              {'icon': Icons.pending, 'label': 'Tertunda'},
                              {'icon': Icons.check_circle, 'label': 'Selesai'},
                              {'icon': Icons.priority_high, 'label': 'Prioritas'},
                            ];
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    _tabController.index = index;
                                  });
                                  _cardAnimationController.reset();
                                  _cardAnimationController.forward();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: selectedIndex == index 
                                        ? const Color(0xFFFF1744).withOpacity(0.2)
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        destinations[index]['icon'] as IconData,
                                        color: selectedIndex == index 
                                            ? const Color(0xFFFF1744)
                                            : Colors.grey,
                                        size: selectedIndex == index ? 32 : 28,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        destinations[index]['label'] as String,
                                        style: TextStyle(
                                          color: selectedIndex == index 
                                              ? const Color(0xFFFF1744)
                                              : Colors.grey,
                                          fontSize: 10,
                                          fontWeight: selectedIndex == index 
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40), // Bottom spacing
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              color: const Color(0xFFFF1744).withOpacity(0.3),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  buildTaskList('all'),
                  buildTaskList('pending'),
                  buildTaskList('completed'),
                  buildTaskList('priority'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => showTaskDialog(),
              backgroundColor: const Color(0xFFFF1744),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Tugas Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
