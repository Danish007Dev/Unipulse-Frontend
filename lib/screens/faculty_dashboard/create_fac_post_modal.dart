import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/toast_util.dart';
import 'primary_button.dart';
import 'fac_post_model.dart';
import 'fac_dashboard_provider.dart';

class CreateFacPostModal extends StatefulWidget {
  const CreateFacPostModal({super.key});

  @override
  State<CreateFacPostModal> createState() => _CreateFacPostModalState();
}

class _CreateFacPostModalState extends State<CreateFacPostModal> {
  final TextEditingController _contentController = TextEditingController();
  PlatformFile? _selectedFile;

  bool _isSubmitting = false;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      final file = result.files.first;
      
      // Extra safety: check file extension
      // 🔵 Re-declare the allowed extensions INSIDE the function
      const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
      final extension = file.extension?.toLowerCase();
      if (extension == null || !allowedExtensions.contains(extension)) {
      showToast('Unsupported file type selected.');
      return;
      }

      if (file.size > 10 * 1024 * 1024) {
        showToast('File too large. Max 10MB.');
        return;
      }
      setState(() {
        _selectedFile = file;
      });
    }
  }

  // Update file type detection

// Helper method to determine file type
bool isImageFile(String? extension) {
  if (extension == null) return false;
  return ['jpg', 'jpeg', 'png', 'gif'].contains(extension.toLowerCase());
}

bool isDocumentFile(String? extension) {
  if (extension == null) return false;
  return ['pdf', 'doc', 'docx', 'txt'].contains(extension.toLowerCase());
}

  void _submitPost() async {
    final content = _contentController.text.trim();
    final provider = context.read<FacultyDashboardProvider>();

    if (content.isEmpty && _selectedFile == null) {
      showToast('Please enter content or attach a file.');
      return;
    }
    if (provider.selectedCourse == null || provider.selectedSemester == null) {
      showToast('Select both course and semester.');
      return;
    }

    setState(() => _isSubmitting = true);

    // Get file extension
    String? extension = _selectedFile?.path != null 
        ? _selectedFile!.path!.split('.').last
        : null;
    
    // Check file type and assign to appropriate field
    PlatformFile? documentFile;
    PlatformFile? imageFile;
    
    if (_selectedFile != null) {
      if (isDocumentFile(extension)) {
        documentFile = _selectedFile;
      } else if (isImageFile(extension)) {
        imageFile = _selectedFile;
      } else {
        showToast('Unsupported file type. Please use images (jpg, png) or documents (pdf, doc).');
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final post = PostCreateData(
      content: content,
      courseId: provider.selectedCourse!.id,
      semesterId: provider.selectedSemester!.id,
      document: documentFile,
      image: imageFile,
    );

    final success = await provider.createPost(post);
    setState(() => _isSubmitting = false);

    if (success && context.mounted) {
      Navigator.pop(context);
      showToast('Post created successfully!');
    } else {
      showToast('Failed to create post. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FacultyDashboardProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            value: provider.selectedCourse,
            hint: const Text('Select Course'),
            items: provider.courses
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (val) => provider.selectCourse(val),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: provider.selectedSemester,
            hint: const Text('Select Semester'),
            items: provider.semesters
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (val) => provider.selectSemester(val),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write something...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

        //Row modifications 
        // Feature | How it looks/works
        // Rounded "chip" shape | Like a pill (borderRadius: 20)
        // Shadow | Subtle floating effect
        // File icon | Small 📄 icon before filename
        // Clean clear button | ❌ on the right to remove the file
        // Ellipsis | Long filenames get safely trimmed

         Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile == null ? 'Attach File' : 'Change File'),
            ),
            const SizedBox(width: 8),
            if (_selectedFile != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.3 * 255).toInt()),//30% opac
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFile!.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFile = null;
                          });
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: _isSubmitting ? null : _submitPost,
            label: _isSubmitting ? 'Posting...' : 'Send',
          ),
        ],
      ),
    );
  }
}


// You're sending the same file both as document and image every time.
// This will create duplicate uploads even if it's just a PDF or only an image.

// ✅ Suggested fix:

// If the file is an image (jpg, jpeg, png), assign it to image

// If it's a document (pdf, doc, docx), assign it to document

// Leave the other as null










// //import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_app/screens/faculty_dashboard/fac_dashboard_provider.dart';
// import 'fac_post_model.dart'; // Ensure this exists
// import 'package:provider/provider.dart';

// class CreatePostModal extends StatefulWidget {
//   const CreatePostModal({super.key});

//   @override
//   _CreatePostModalState createState() => _CreatePostModalState();
// }

// class _CreatePostModalState extends State<CreatePostModal> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   //File? _pickedFile;
//   PlatformFile? _pickedFile;

//   int? _selectedCourseId;
//   int? _selectedSemesterId;
//   bool _isSubmitting = false;

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _pickedFile = result.files.single;
//       });
//     }
//   }

//   Future<void> _submitPost() async {
//     if (!_formKey.currentState!.validate() || _selectedCourseId == null || _selectedSemesterId == null) return;

//     setState(() => _isSubmitting = true);

//     final postData = PostCreateData(
//       title: _titleController.text.trim(),
//       content: _descriptionController.text.trim(),
//       courseId: _selectedCourseId!,
//       semesterId: _selectedSemesterId!,
//       file: _pickedFile,
//     );

//     final provider = Provider.of<FacultyDashboardProvider>(context, listen: false);
//     final success = await provider.createPost(postData);

//     setState(() => _isSubmitting = false);

//     if (success) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Post created successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('❌ Failed to create post')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postProvider = Provider.of<FacultyDashboardProvider>(context);
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16, right: 16, top: 24,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Create Post", style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: "Title"),
//                 validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(labelText: "Description"),
//                 maxLines: 3,
//                 validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<int>(
//                 value: _selectedCourseId,
//                 items: postProvider.courses.map((course) {
//                   return DropdownMenuItem(
//                     value: course.id,
//                     child: Text(course.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => _selectedCourseId = value),
//                 decoration: const InputDecoration(labelText: "Course"),
//                 validator: (val) => val == null ? "Select course" : null,
//               ),
//               DropdownButtonFormField<int>(
//                 value: _selectedSemesterId,
//                 items: postProvider.semesters.map((sem) {
//                   return DropdownMenuItem(
//                     value: sem.id,
//                     child: Text(sem.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => _selectedSemesterId = value),
//                 decoration: const InputDecoration(labelText: "Semester"),
//                 validator: (val) => val == null ? "Select semester" : null,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _pickFile,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text("Attach File"),
//                   ),
//                   const SizedBox(width: 10),
//                   if (_pickedFile != null)
//                     Expanded(
//                       child: Text(
//                         //_pickedFile!.path.split('/').last,
//                         _pickedFile!.name,  //Even better: PlatformFile already has a name property that gives you the file name without needing to split the path:
//                         style: const TextStyle(fontSize: 12),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               _isSubmitting
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _submitPost,
//                       child: const Text("Post"),
//                     ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
