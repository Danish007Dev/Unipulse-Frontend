import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/semester_model.dart';
import 'fac_dashboard_provider.dart';
import 'fac_post_tile.dart';



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
    // Initialize the provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the first build
      if (mounted) {
        // This will safely load the data
        provider = Provider.of<FacultyDashboardProvider>(context, listen: false);
        provider.initDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold and AppBar have been removed.
    // The AppShell now provides them.
    return Consumer<FacultyDashboardProvider>(
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
                            // Load more posts when reaching the end, but avoid
                            // calling during build by using Future.microtask
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
    );
    // The FloatingActionButton has been moved to the AppShell.
  }
}








