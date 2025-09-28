import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../FeedUpApp/providers/cs_data_provider.dart';
import '../../FeedUpApp/widgets/research_update_card.dart';
import '../../utils/logger.dart';
import 'fac_research_service.dart';

class FacultyResearchScreen extends StatefulWidget {
  const FacultyResearchScreen({Key? key}) : super(key: key);

  @override
  State<FacultyResearchScreen> createState() => _FacultyResearchScreenState();
}

class _FacultyResearchScreenState extends State<FacultyResearchScreen> {
  final _searchController = TextEditingController();
  List<String> _facultyMajors = [];
  
  @override
  void initState() {
    super.initState();
    _loadFacultyMajors();
    _initializeData();
  }

  // Update the _loadFacultyMajors method in FacultyResearchScreen:

void _loadFacultyMajors() async {
  try {
    final majors = await FacultyService.getFacultyMajors();
    setState(() {
      _facultyMajors = majors;
    });
    
    // Refresh research after loading majors
    if (majors.isNotEmpty) {
      _fetchFilteredResearch();
    }
  } catch (e) {
    appLogger.e('Error loading faculty majors: $e');
    // Handle error - maybe show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load your majors. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch research updates and filter by faculty majors
      _fetchFilteredResearch();
    });
  }

  void _fetchFilteredResearch() {
    final provider = context.read<CSDataProvider>();
    
    // If faculty has majors, filter by them
    if (_facultyMajors.isNotEmpty) {
      // Use the first major as primary filter
      // You can enhance this logic to handle multiple majors
      provider.setResearchCategory(_facultyMajors.first);
    }
    
    provider.fetchResearchUpdates(refresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research for My Majors'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchFilteredResearch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Faculty majors display
          if (_facultyMajors.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Majors:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _facultyMajors.map((major) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        major,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) => TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search research in your field...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.setResearchSearch(null);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      provider.setResearchSearch(value.isEmpty ? null : value);
                    }
                  });
                },
                onSubmitted: (value) {
                  provider.setResearchSearch(value.isEmpty ? null : value);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Research list
          Expanded(
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) {
                // Filter research updates by faculty majors
                final filteredResearch = _filterResearchByMajors(
                  provider.researchUpdates,
                  _facultyMajors,
                );
                
                if (provider.isLoadingResearch && filteredResearch.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.researchError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading research',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.researchError!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchFilteredResearch(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (filteredResearch.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _facultyMajors.isEmpty 
                              ? 'No majors assigned'
                              : 'No research found for your majors',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _facultyMajors.isEmpty 
                              ? 'Contact admin to assign your majors'
                              : 'Research papers matching ${_facultyMajors.join(", ")} will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchFilteredResearch(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async => _fetchFilteredResearch(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredResearch.length + (provider.hasMoreResearch ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredResearch.length) {
                        if (provider.isLoadingResearch) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () => provider.loadMoreResearch(),
                              child: const Text('Load More'),
                            ),
                          );
                        }
                      }
                      
                      return ResearchUpdateCard(
                        research: filteredResearch[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  List<dynamic> _filterResearchByMajors(List<dynamic> allResearch, List<String> majors) {
    if (majors.isEmpty) return [];
    
    return allResearch.where((research) {
      final category = research.category?.toLowerCase() ?? '';
      
      // Check if research category matches any of the faculty's majors
      return majors.any((major) => 
        category.contains(major.toLowerCase()) ||
        major.toLowerCase().contains(category)
      );
    }).toList();
  }
}