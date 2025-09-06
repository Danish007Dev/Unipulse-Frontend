import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cs_data_provider.dart';

class ConferenceFilterBottomSheet extends StatefulWidget {
  const ConferenceFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<ConferenceFilterBottomSheet> createState() => _ConferenceFilterBottomSheetState();
}

class _ConferenceFilterBottomSheetState extends State<ConferenceFilterBottomSheet> {
  late TextEditingController _locationController;
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CSDataProvider>();
    _locationController = TextEditingController(text: provider.conferenceLocation ?? '');
    _topicController = TextEditingController(text: provider.conferenceTopic ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    _topicController.dispose();
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
                'Filter Conferences',
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
          
          // Location filter
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'E.g., New York, Online',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.location_on),
            ),
            onChanged: (value) {
              // Real-time update
              context.read<CSDataProvider>().setConferenceLocation(
                value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Topic filter
          TextField(
            controller: _topicController,
            decoration: InputDecoration(
              labelText: 'Topic',
              hintText: 'E.g., AI, Cybersecurity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              prefixIcon: const Icon(Icons.tag),
            ),
            onChanged: (value) {
              // Real-time update
              context.read<CSDataProvider>().setConferenceTopic(
                value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CSDataProvider>().resetConferenceFilters();
                    _locationController.clear();
                    _topicController.clear();
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