import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/semester_model.dart';
import 'create_fac_post_modal.dart';
import 'fac_dashboard_provider.dart';
import 'fac_post_tile.dart';
import '../../widgets/logout_button.dart';



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
  
  void _openCreatePostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateFacPostModal(),
    );
  }
  
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        actions: const [LogoutButton()],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePostModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/course_model.dart';
// import '../../models/semester_model.dart';
// import 'create_fac_post_modal.dart';
// import 'fac_dashboard_provider.dart';
// import 'fac_post_tile.dart';
// import '../../widgets/logout_button.dart';

// String _toRoman(String number) {
//   final numerals = {
//     1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V',
//     6: 'VI', 7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X',
//     11: 'XI', 12: 'XII'
//   };
//   final parsed = int.tryParse(number);
//   return parsed != null ? (numerals[parsed] ?? number) : number;
// }

// class FacultyDashboardScreen extends StatelessWidget {
//   const FacultyDashboardScreen({Key? key}) : super(key: key);

//   void _openCreatePostModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => const CreateFacPostModal(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => FacultyDashboardProvider(),
//       child: Consumer<FacultyDashboardProvider>(
//         builder: (context, provider, _) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Faculty Dashboard'),
//               actions: const [LogoutButton()],
//             ),
//             body: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButton<Course?>(
//                           isExpanded: true,
//                           value: provider.selectedCourse,
//                           hint: const Text('Select Course'),
//                           items: [
//                             const DropdownMenuItem<Course?>(
//                               value: null,
//                               child: Text('All Courses'),
//                             ),
//                             ...provider.courses.map((course) {
//                               return DropdownMenuItem(
//                                 value: course,
//                                 child: Text(course.name),
//                               );
//                             })
//                           ],
//                           onChanged: (value) {
//                             provider.selectCourse(value);
//                             provider.fetchPosts(refresh: true);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: DropdownButton<Semester?>(
//                           isExpanded: true,
//                           value: provider.selectedSemester,
//                           hint: const Text('Select Semester'),
//                           items: [
//                             const DropdownMenuItem<Semester?>(
//                               value: null,
//                               child: Text('All Semesters'),
//                             ),
//                             ...provider.semesters.map((semester) {
//                               return DropdownMenuItem(
//                                 value: semester,
//                                 child: Text(_toRoman(semester.name)),
//                               );
//                             })
//                           ],
//                           onChanged: provider.selectedCourse == null
//                               ? null
//                               : (value) {
//                                   provider.selectSemester(value);
//                                   provider.fetchPosts(refresh: true);
//                                 },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: () => provider.fetchPosts(refresh: true),
//                     child: ListView.builder(
//                       itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index < provider.posts.length) {
//                           return PostTile(post: provider.posts[index],
//                           onDelete: () => provider.deletePost(context,provider.posts[index].id),
//                           );
//                         } else {
//                           provider.fetchPosts();
//                           return const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () => _openCreatePostModal(context),
//               child: const Icon(Icons.add),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:flutter_app/widgets/logout_button.dart';
// import 'package:provider/provider.dart';
// import '../../models/course_model.dart';
// import '../../models/semester_model.dart';
// //import 'fac_post_model.dart';
// import 'fac_dashboard_provider.dart';
// import 'create_fac_post_modal.dart';
// import 'fac_post_tile.dart';
// //import '../../widgets/logout_button.dart';


// String _toRoman(String number) { //Helper Function for Roman Numerals
//   final numerals = {
//     1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V',
//     6: 'VI', 7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X',
//     11: 'XI', 12: 'XII'
//   };

//   final parsed = int.tryParse(number);
//   return parsed != null ? (numerals[parsed] ?? number) : number;
// }

// class FacultyDashboardScreen extends StatelessWidget {
//   const FacultyDashboardScreen({Key? key}) : super(key: key);

//   void _openCreatePostModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => const CreateFacPostModal(),
//     );
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => FacultyDashboardProvider(),
//       child: Consumer<FacultyDashboardProvider>(
//         builder: (context, provider, _) {
//           return Scaffold(
//             //automaticallyImplyLeading: false,
//             appBar: AppBar(title: const Text('Faculty Dashboard')
//             , actions: [LogoutButton()]
//             ),
//             body: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButton<Course>(
//                           isExpanded: true,
//                           hint: const Text('Select Course'),
//                           value: provider.selectedCourse,
//                           items: provider.courses
//                               .map((c) => DropdownMenuItem(
//                                     value: c,
//                                     child: Text(c.name),
//                                   ))
//                               .toList(),
//                           onChanged: provider.selectCourse,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: provider.selectedCourse == null
//                             ?  IgnorePointer(
//                                 child: DropdownButton<Semester>(
//                                   isExpanded: true,
//                                   hint: Text('Select Course First'),
//                                   items: [],
//                                   onChanged: null,
//                                 ),
//                               )
//                             : provider.semesters.isEmpty
//                                 ? const Center(child: CircularProgressIndicator())
//                                 : DropdownButton<Semester>(
//                                     isExpanded: true,
//                                     hint: const Text('Select Semester'),
//                                     value: provider.selectedSemester,
//                                     items: provider.semesters.map((s) {
//                                       return DropdownMenuItem(
//                                         value: s,
//                                         child: Text(_toRoman(s.name)),
//                                       );
//                                     }).toList(),
//                                     onChanged: provider.selectSemester,
//                                   ),
//                       ),

                      
//                     ],
//                   ),
//                 ),
                
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: () => provider.fetchPosts(refresh: true),
//                     child: ListView.builder(
//                       itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index < provider.posts.length) {
//                           return PostTile(post: provider.posts[index]);
//                         } else {
//                           // Load more
//                           provider.fetchPosts();
//                           return const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () => _openCreatePostModal(context),
//               child: const Icon(Icons.add),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'fac_post_model.dart'; 

// class PostTile extends StatelessWidget {
//   final Post post;
//   final VoidCallback onDelete;

//   const PostTile({
//     Key? key,
//     required this.post,
//     required this.onDelete,
//   }) : super(key: key);

//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Post'),
//         content: const Text('Are you sure you want to delete this post?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               onDelete(); // Call deletion callback
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     post.content,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _confirmDelete(context),
//                   tooltip: 'Delete Post',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               post.createdAt.toLocal().toString(), // Format if needed
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








