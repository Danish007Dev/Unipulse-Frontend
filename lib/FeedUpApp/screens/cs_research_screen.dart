import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cs_data_provider.dart';
import '../widgets/research_update_card.dart';
import '../widgets/research_filter_bottom_sheet.dart';

class CSResearchScreen extends StatefulWidget {
  const CSResearchScreen({Key? key}) : super(key: key);

  @override
  State<CSResearchScreen> createState() => _CSResearchScreenState();
}

class _CSResearchScreenState extends State<CSResearchScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CSDataProvider>();
      if (provider.researchUpdates.isEmpty && !provider.isLoadingResearch) {
        provider.fetchResearchUpdates();
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
        title: const Text('CS Research'),
        actions: [
          // ALWAYS show filter icon in app bar
          Consumer<CSDataProvider>(
            builder: (context, provider, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (provider.hasActiveResearchFilters)
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
            onPressed: () => context.read<CSDataProvider>().refreshResearch(),
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
                  hintText: 'Search research...',
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
          
          // Active filters summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) => provider.hasActiveResearchFilters
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
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
                              provider.getResearchFilterSummary(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.resetResearchFilters(),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          
          // Research updates list
          Expanded(
            child: Consumer<CSDataProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingResearch && provider.researchUpdates.isEmpty) {
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
                        // ALWAYS show both buttons in error state
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => provider.refreshResearch(),
                              child: const Text('Retry'),
                            ),
                            if (provider.hasActiveResearchFilters) ...[
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () => provider.resetResearchFilters(),
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.researchUpdates.isEmpty) {
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
                          provider.hasActiveResearchFilters 
                              ? 'No research matches your filters'
                              : 'No research updates found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.hasActiveResearchFilters 
                              ? 'Try adjusting your search, category, institution, or date filters'
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
                              onPressed: () => provider.refreshResearch(),
                              child: const Text('Refresh'),
                            ),
                            if (provider.hasActiveResearchFilters) ...[
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {
                                  // Clear search field too
                                  _searchController.clear();
                                  provider.resetResearchFilters();
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
                  onRefresh: () => provider.refreshResearch(),
                  child: ListView.builder(
                    itemCount: provider.researchUpdates.length + (provider.hasMoreResearch ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.researchUpdates.length) {
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
                        research: provider.researchUpdates[index],
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
      builder: (context) => const ResearchFilterBottomSheet(),
    );
  }
}