import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cs_data_provider.dart';
import '../widgets/conference_card.dart';
import '../widgets/research_update_card.dart';
import '../widgets/conference_filter_bottom_sheet.dart';
import '../widgets/research_filter_bottom_sheet.dart';
import '../../services/auth_provider.dart';
import '../../FeedUpApp/auth/feedup_auth_provider.dart';
import '../../widgets/login_prompt_widget.dart';

class CSHubScreen extends StatefulWidget {
  const CSHubScreen({Key? key}) : super(key: key);

  @override
  State<CSHubScreen> createState() => _CSHubScreenState();
}

class _CSHubScreenState extends State<CSHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize data on screen load only if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uniPulseAuth = context.read<AuthProvider>();
      final feedUpAuth = context.read<FeedUpAuthProvider>();
      
      final isAuthenticated = uniPulseAuth.isAuthenticated || feedUpAuth.isFeedUpUserAuthenticated;
      
      if (isAuthenticated) {
        context.read<CSDataProvider>().initialize();
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final uniPulseAuth = context.watch<AuthProvider>();
    final feedUpAuth = context.watch<FeedUpAuthProvider>();
    
    final isAuthenticated = uniPulseAuth.isAuthenticated || feedUpAuth.isFeedUpUserAuthenticated;
    
    // If not authenticated, show login prompt
    if (!isAuthenticated) {
      return const LoginPromptWidget(
        message: 'Log in to access CS Hub with conferences and research updates.',
      );
    }
    
    // Authenticated UI
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search CS Hub...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        if (_tabController.index == 0) {
                          context.read<CSDataProvider>().setConferenceSearch(null);
                        } else {
                          context.read<CSDataProvider>().setResearchSearch(null);
                        }
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) {
              if (_tabController.index == 0) {
                context.read<CSDataProvider>().setConferenceSearch(value);
              } else {
                context.read<CSDataProvider>().setResearchSearch(value);
              }
            },
          ),
        ),
        
        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Conferences'),
            Tab(text: 'Research'),
          ],
          onTap: (_) {
            // Clear search when switching tabs
            _searchController.clear();
          },
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Conferences tab
              _buildConferencesTab(context.watch<CSDataProvider>()),
              
              // Research tab
              _buildResearchTab(context.watch<CSDataProvider>()),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildConferencesTab(CSDataProvider provider) {
    if (provider.isLoadingConferences) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.conferences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No conferences found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchConferences,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Filter options row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              const Text('Show past:'),
              Switch(
                value: provider.showPastConferences,
                onChanged: provider.togglePastConferences,
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showConferenceFilterBottomSheet(context),
                    tooltip: 'Filter conferences',
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
            ],
          ),
        ),
        
        // Conference list
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.fetchConferences,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: provider.conferences.length,
              itemBuilder: (context, index) {
                return ConferenceCard(
                  conference: provider.conferences[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildResearchTab(CSDataProvider provider) {
    if (provider.isLoadingResearch) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.researchUpdates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No research updates found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchResearchUpdates,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showResearchFilterBottomSheet(context),
                    tooltip: 'Filter research',
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
            ],
          ),
        ),
        
        // Research list
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.fetchResearchUpdates,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: provider.researchUpdates.length,
              itemBuilder: (context, index) {
                return ResearchUpdateCard(
                  research: provider.researchUpdates[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  void _showConferenceFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const ConferenceFilterBottomSheet(),
    );
  }
  
  void _showResearchFilterBottomSheet(BuildContext context) {
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