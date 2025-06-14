import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF0F8F7),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
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

class _TaskManagerPageState extends State<TaskManagerPage> with TickerProviderStateMixin {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  List<Task> tasks = [];
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  String selectedPriority = 'low';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    }
  }

  Future<void> addTask() async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    await http.post(Uri.parse('$baseUrl/tasks'), body: {
      'title': titleController.text,
      'priority': selectedPriority,
      'due_date': selectedDate!.toIso8601String().split('T')[0],
    });
    titleController.clear();
    selectedDate = null;
    selectedPriority = 'low';
    fetchTasks();
  }

  Future<void> editTask(Task task) async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    await http.put(Uri.parse('$baseUrl/tasks/${task.id}'), body: {
      'title': titleController.text,
      'priority': selectedPriority,
      'due_date': selectedDate!.toIso8601String().split('T')[0],
      'is_done': task.isDone.toString(),
    });
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
    await http.put(Uri.parse('$baseUrl/tasks/${task.id}'), body: {
      'title': task.title,
      'priority': task.priority,
      'due_date': task.dueDate,
      'is_done': newStatus.toString(),
    });
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
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    color: Colors.grey[300],
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
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.title, color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: [
                    {'value': 'low', 'label': 'Rendah', 'icon': Icons.keyboard_arrow_down},
                    {'value': 'medium', 'label': 'Sedang', 'icon': Icons.remove},
                    {'value': 'high', 'label': 'Tinggi', 'icon': Icons.keyboard_arrow_up},
                  ].map((item) {
                    return DropdownMenuItem(
                      value: item['value'] as String,
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(item['label'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPriority = value!),
                  decoration: const InputDecoration(
                    labelText: 'Tingkat Prioritas',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.flag, color: Colors.teal),
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
                          colorScheme: const ColorScheme.light(
                            primary: Colors.teal,
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
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.teal),
                      const SizedBox(width: 16),
                      Text(
                        selectedDate == null
                            ? 'Pilih Tanggal Deadline'
                            : 'Deadline: ${selectedDate.toString().split(' ')[0]}',
                        style: TextStyle(
                          color: selectedDate == null ? Colors.grey[600] : Colors.black,
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
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    taskToEdit == null ? 'Simpan Tugas' : 'Update Tugas',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        return Colors.red[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'low':
      default:
        return Colors.green[100]!;
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

  Widget buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: task.isDone ? Colors.grey[100] : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showTaskDialog(taskToEdit: task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => updateTaskStatus(task, !task.isDone),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isDone ? Colors.teal : Colors.grey,
                            width: 2,
                          ),
                          color: task.isDone ? Colors.teal : Colors.transparent,
                        ),
                        child: task.isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
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
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text('Edit'),
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
                              const Text('Hapus'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getPriorityColor(task.priority),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getPriorityIcon(task.priority),
                            size: 16,
                            color: task.priority == 'high'
                                ? Colors.red[700]
                                : task.priority == 'medium'
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: task.priority == 'high'
                                  ? Colors.red[700]
                                  : task.priority == 'medium'
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dibuat: ${formatDateTime(task.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
              status == 'all' ? Icons.task_alt :
              status == 'pending' ? Icons.pending_actions :
              status == 'completed' ? Icons.check_circle :
              Icons.priority_high,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              status == 'all' ? 'Belum ada tugas' :
              status == 'pending' ? 'Tidak ada tugas tertunda' :
              status == 'completed' ? 'Belum ada tugas selesai' :
              'Tidak ada tugas prioritas tinggi',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => buildTaskCard(taskList[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.tealAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'Semua'),
                Tab(icon: Icon(Icons.pending), text: 'Tertunda'),
                Tab(icon: Icon(Icons.check_circle), text: 'Selesai'),
                Tab(icon: Icon(Icons.priority_high), text: 'Prioritas'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            buildTaskList('all'),
            buildTaskList('pending'),
            buildTaskList('completed'),
            buildTaskList('priority'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tugas Baru'),
      ),
    );
  }
}