import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cs_data_provider.dart';
import '../widgets/conference_card.dart';
import '../widgets/conference_filter_bottom_sheet.dart';

class CSConferencesScreen extends StatefulWidget {
  const CSConferencesScreen({Key? key}) : super(key: key);

  @override
  State<CSConferencesScreen> createState() => _CSConferencesScreenState();
}

class _CSConferencesScreenState extends State<CSConferencesScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CSDataProvider>();
      if (provider.conferences.isEmpty && !provider.isLoadingConferences) {
        provider.fetchConferences();
      }
    });
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
        title: const Text('CS Conferences'),
        actions: [
          // ALWAYS show filter icon in app bar
          Consumer<CSDataProvider>(
            builder: (context, provider, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (provider.hasActiveConferenceFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CSDataProvider>().refreshConferences(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) => TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conferences...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.setConferenceSearch(null);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      provider.setConferenceSearch(value.isEmpty ? null : value);
                    }
                  });
                },
                onSubmitted: (value) {
                  provider.setConferenceSearch(value.isEmpty ? null : value);
                },
              ),
            ),
          ),
          
          // Filter controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) => Column(
                children: [
                  // Show past conferences toggle
                  Row(
                    children: [
                      const Text('Show past conferences'),
                      const Spacer(),
                      Switch(
                        value: provider.showPastConferences,
                        onChanged: provider.togglePastConferences,
                      ),
                    ],
                  ),
                  
                  // Active filters summary
                  if (provider.hasActiveConferenceFilters) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.getConferenceFilterSummary(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.resetConferenceFilters(),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Conference list
          Expanded(
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingConferences && provider.conferences.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.conferenceError != null) {
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
                          'Error loading conferences',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.conferenceError!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // ALWAYS show both buttons in error state
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => provider.refreshConferences(),
                              child: const Text('Retry'),
                            ),
                            if (provider.hasActiveConferenceFilters) ...[
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () => provider.resetConferenceFilters(),
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.conferences.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.hasActiveConferenceFilters 
                              ? 'No conferences match your filters'
                              : 'No conferences found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.hasActiveConferenceFilters 
                              ? 'Try adjusting your search criteria or location/topic filters'
                              : 'Pull to refresh or check back later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // ALWAYS show both buttons in empty state
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => provider.refreshConferences(),
                              child: const Text('Refresh'),
                            ),
                            if (provider.hasActiveConferenceFilters) ...[
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {
                                  // Clear search field too
                                  _searchController.clear();
                                  provider.resetConferenceFilters();
                                },
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => provider.refreshConferences(),
                  child: ListView.builder(
                    itemCount: provider.conferences.length + (provider.hasMoreConferences ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.conferences.length) {
                        if (provider.isLoadingConferences) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () => provider.loadMoreConferences(),
                              child: const Text('Load More'),
                            ),
                          );
                        }
                      }
                      
                      return ConferenceCard(
                        conference: provider.conferences[index],
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
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const ConferenceFilterBottomSheet(),
    );
  }
}