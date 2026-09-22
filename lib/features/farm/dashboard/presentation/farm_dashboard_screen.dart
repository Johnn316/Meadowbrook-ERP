import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class FarmDashboardScreen extends StatefulWidget {
  const FarmDashboardScreen({super.key});

  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
  final Map<String, dynamic> _farmStats = {
    'totalAcreage': 847,
    'activecrops': 6,
    'livestock': 234,
    'pendingTasks': 12,
  };

  final List<Map<String, dynamic>> _crops = [
    {
      'name': 'Winter Wheat',
      'acreage': 240,
      'stage': 'Tillering',
      'health': 92,
      'color': 0xFFE9A825,
    },
    {
      'name': 'Maize',
      'acreage': 180,
      'stage': 'V8 Stage',
      'health': 88,
      'color': 0xFF52B788,
    },
    {
      'name': 'Soybeans',
      'acreage': 120,
      'stage': 'R3 Pod Set',
      'health': 95,
      'color': 0xFF4895EF,
    },
    {
      'name': 'Tea',
      'acreage': 307,
      'stage': '2nd Cutting',
      'health': 91,
      'color': 0xFF2D6A4F,
    },
  ];

  final List<Map<String, dynamic>> _livestock = [
    {'type': 'Cattle', 'count': 145, 'health': 98, 'icon': '🐄'},
    {'type': 'Sheep', 'count': 67, 'health': 95, 'icon': '🐑'},
    {'type': 'Chickens', 'count': 320, 'health': 100, 'icon': '🐔'},
    {'type': 'Pigs', 'count': 42, 'health': 97, 'icon': '🐖'},
  ];

  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Irrigate North Field', 'time': '6:00 AM', 'done': true},
    {'title': 'Feed livestock', 'time': '7:30 AM', 'done': true},
    {'title': 'Check fence line - East', 'time': '10:00 AM', 'done': false},
    {'title': 'Equipment maintenance', 'time': '2:00 PM', 'done': false},
    {'title': 'Soil testing - South Field', 'time': '3:30 PM', 'done': false},
  ];

  final List<Map<String, dynamic>> _weather = [
    {'day': 'Mon', 'temp': 72, 'icon': Icons.wb_sunny},
    {'day': 'Tue', 'temp': 68, 'icon': Icons.cloud},
    {'day': 'Wed', 'temp': 65, 'icon': Icons.grain},
    {'day': 'Thu', 'temp': 70, 'icon': Icons.wb_cloudy},
    {'day': 'Fri', 'temp': 74, 'icon': Icons.wb_sunny},
    {'day': 'Sat', 'temp': 71, 'icon': Icons.cloud},
    {'day': 'Sun', 'temp': 63, 'icon': Icons.grain},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFarmHeader(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildWeatherSection(),
              const SizedBox(height: 20),
              _buildSectionTitle('Crop Health Index'),
              const SizedBox(height: 10),
              _buildCropHealth(),
              const SizedBox(height: 20),
              _buildSectionTitle('Livestock Summary'),
              const SizedBox(height: 10),
              _buildLivestockGrid(),
              const SizedBox(height: 20),
              _buildSectionTitle("Today's Tasks"),
              const SizedBox(height: 10),
              _buildTasksList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }

  Widget _buildFarmHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meadowbrook Farm',
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kenya • ${_farmStats['totalAcreage']} acres',
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.thermostat,
                      color: Colors.white70, size: 16),
                  Text(
                    '72°F',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Partly Cloudy',
                style: GoogleFonts.lato(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {
        'label': 'Acreage',
        'value': '${_farmStats['totalAcreage']}',
        'unit': 'acres',
        'icon': Icons.landscape,
        'color': AppColors.primary,
      },
      {
        'label': 'Crops',
        'value': '${_farmStats['activecrops']}',
        'unit': 'varieties',
        'icon': Icons.grass,
        'color': AppColors.success,
      },
      {
        'label': 'Livestock',
        'value': '${_farmStats['livestock']}',
        'unit': 'head',
        'icon': Icons.pets,
        'color': AppColors.secondary,
      },
      {
        'label': 'Tasks',
        'value': '${_farmStats['pendingTasks']}',
        'unit': 'pending',
        'icon': Icons.task_alt,
        'color': AppColors.info,
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stat['icon'] as IconData,
                    color: stat['color'] as Color, size: 20),
                const SizedBox(height: 6),
                Text(
                  stat['value'] as String,
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  stat['unit'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('7-Day Forecast'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weather.map((w) {
              return Column(
                children: [
                  Text(
                    w['day'],
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(w['icon'] as IconData,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    '${w['temp']}°',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCropHealth() {
    return Column(
      children: _crops.map((crop) {
        final color = Color(crop['color'] as int);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          crop['name'],
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${crop['health']}% health',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${crop['stage']} • ${crop['acreage']} acres',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (crop['health'] as int) / 100,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLivestockGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _livestock.length,
      itemBuilder: (context, index) {
        final animal = _livestock[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                animal['icon'],
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      animal['type'],
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${animal['count']} head',
                      style: GoogleFonts.lato(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            size: 10, color: AppColors.success),
                        const SizedBox(width: 2),
                        Text(
                          '${animal['health']}%',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: _tasks.map((task) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Checkbox(
              value: task['done'] as bool,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => task['done'] = val);
              },
            ),
            title: Text(
              task['title'],
              style: GoogleFonts.lato(
                decoration: task['done'] as bool
                    ? TextDecoration.lineThrough
                    : null,
                color: task['done'] as bool
                    ? AppColors.textLight
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              task['time'],
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final taskController = TextEditingController();
    final timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Task',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                hintText: 'Task description',
                prefixIcon: Icon(Icons.task_alt_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                hintText: 'Time (e.g. 9:00 AM)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    _tasks.add({
                      'title': taskController.text,
                      'time': timeController.text,
                      'done': false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}