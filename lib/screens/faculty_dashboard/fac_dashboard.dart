import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/semester_model.dart';
import 'fac_dashboard_provider.dart';
import 'fac_post_tile.dart';
import 'faculty_research_screen.dart';

String _toRoman(String number) {
  final numerals = {
    1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V',
    6: 'VI', 7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X',
    11: 'XI', 12: 'XII'
  };
  final parsed = int.tryParse(number);
  return parsed != null ? (numerals[parsed] ?? number) : number;
}

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  late FacultyDashboardProvider provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider = Provider.of<FacultyDashboardProvider>(context, listen: false);
        provider.initDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add the burger menu
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Consumer<FacultyDashboardProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Course?>(
                        isExpanded: true,
                        value: provider.selectedCourse,
                        hint: const Text('Select Course'),
                        items: [
                          const DropdownMenuItem<Course?>(
                            value: null,
                            child: Text('All Courses'),
                          ),
                          ...provider.courses.map((course) {
                            return DropdownMenuItem(
                              value: course,
                              child: Text(course.name),
                            );
                          })
                        ],
                        onChanged: (value) {
                          provider.selectCourse(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<Semester?>(
                        isExpanded: true,
                        value: provider.selectedSemester,
                        hint: const Text('Select Semester'),
                        items: [
                          const DropdownMenuItem<Semester?>(
                            value: null,
                            child: Text('All Semesters'),
                          ),
                          ...provider.semesters.map((semester) {
                            return DropdownMenuItem(
                              value: semester,
                              child: Text(_toRoman(semester.name)),
                            );
                          })
                        ],
                        onChanged: provider.selectedCourse == null
                            ? null
                            : (value) {
                                provider.selectSemester(value);
                              },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchPosts(refresh: true),
                  child: provider.posts.isEmpty && provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < provider.posts.length) {
                              return PostTile(
                                post: provider.posts[index],
                                onDelete: () => provider.deletePost(
                                  context,
                                  provider.posts[index].id,
                                ),
                              );
                            } else if (!provider.isLoading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  provider.fetchPosts();
                                }
                              });
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 16),
                Text(
                  'Faculty Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Already on dashboard, no navigation needed
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('Research for My Majors'),
            subtitle: const Text('View research papers in your field'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FacultyResearchScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('My Posts'),
            subtitle: const Text('Manage your course posts'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Already on posts section
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            subtitle: const Text('View engagement statistics'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoonDialog(context, 'Analytics');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            subtitle: const Text('Configure preferences'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoonDialog(context, 'Settings');
            },
          ),
          
          const Spacer(),
          
          // Footer
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'UniPulse Faculty Portal',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature'),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}








