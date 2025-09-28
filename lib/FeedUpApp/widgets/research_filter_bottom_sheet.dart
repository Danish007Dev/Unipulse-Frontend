import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cs_data_provider.dart';

class ResearchFilterBottomSheet extends StatefulWidget {
  const ResearchFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<ResearchFilterBottomSheet> createState() => _ResearchFilterBottomSheetState();
}

class _ResearchFilterBottomSheetState extends State<ResearchFilterBottomSheet> {
  late TextEditingController _categoryController;
  late TextEditingController _institutionController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CSDataProvider>();
    _categoryController = TextEditingController(text: provider.researchCategory ?? '');
    _institutionController = TextEditingController(text: provider.researchInstitution ?? '');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Filter Research',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category filter
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Category',
              hintText: 'E.g., AI, ML, Cybersecurity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.category),
            ),
            onChanged: (value) {
              // Real-time update
              context.read<CSDataProvider>().setResearchCategory(
                value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Institution filter
          TextField(
            controller: _institutionController,
            decoration: InputDecoration(
              labelText: 'Institution',
              hintText: 'E.g., MIT, Stanford',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.school),
            ),
            onChanged: (value) {
              // Real-time update
              context.read<CSDataProvider>().setResearchInstitution(
                value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Recent days filter
          Consumer<CSDataProvider>(
            builder: (context, provider, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Publications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.recentDays == null,
                      onSelected: (_) => provider.setRecentDays(null),
                    ),
                    FilterChip(
                      label: const Text('7 days'),
                      selected: provider.recentDays == 7,
                      onSelected: (_) => provider.setRecentDays(7),
                    ),
                    FilterChip(
                      label: const Text('30 days'),
                      selected: provider.recentDays == 30,
                      onSelected: (_) => provider.setRecentDays(30),
                    ),
                    FilterChip(
                      label: const Text('90 days'),
                      selected: provider.recentDays == 90,
                      onSelected: (_) => provider.setRecentDays(90),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CSDataProvider>().resetResearchFilters();
                    _categoryController.clear();
                    _institutionController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('RESET'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}