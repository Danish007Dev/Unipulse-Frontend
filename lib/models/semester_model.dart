class Semester {
  final int id;
  final String name;

  Semester({required this.id, required this.name});

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      name: json['name'],
    );
  }
}


// Nope, **you don’t need to change your `Course` and `Semester` model classes in the frontend**. ✅

// Here’s why:

// - Your **backend is already returning** the `Semester` objects with their numeric `name` values like `"1"`, `"2"`, etc.
// - The frontend `Semester` model properly maps `id` and `name` from the response:
//   ```dart
//   factory Semester.fromJson(Map<String, dynamic> json) {
//     return Semester(
//       id: json['id'],
//       name: json['name'],
//     );
//   }
//   ```
// - Since you're applying **Roman numeral conversion in the UI layer** (in the `DropdownMenuItem` text via `_toRoman()`), there's **no need to store or change that format** in the model itself.

// ### 💡 TL;DR:
// Keep your models clean and raw — use UI formatting (like Roman numerals) **only where needed in widgets**. This separation makes your models reusable elsewhere without format-specific constraints.

// Let me know if you want to add the Roman numeral logic elsewhere (like in post tiles or titles too).