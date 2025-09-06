import 'package:flutter/material.dart';
import '../models/conference.dart';
import '../models/research_update.dart';
import '../services/cs_data_service.dart';
import '../../utils/logger.dart';

class CSDataProvider extends ChangeNotifier {
  List<Conference> _conferences = [];
  List<ResearchUpdate> _researchUpdates = [];
  
  bool _isLoadingConferences = false;
  bool _isLoadingResearch = false;
  bool _isLoadingFilterOptions = false;
  
  String? _conferenceError;
  String? _researchError;
  
  // Conference filters
  String? _conferenceSearch;
  String? _conferenceLocation;
  String? _conferenceTopic;
  bool _showPastConferences = false;
  
  // Research filters
  String? _researchSearch;
  String? _researchCategory;
  String? _researchInstitution;
  int? _recentDays;
  
  // Filter options
  Map<String, List<String>> _filterOptions = {};
  
  // Pagination support
  int _conferencePage = 1;
  int _researchPage = 1;
  bool _hasMoreConferences = true;
  bool _hasMoreResearch = true;
  int _totalConferences = 0;
  int _totalResearch = 0;

  // Getters
  List<Conference> get conferences => _conferences;
  List<ResearchUpdate> get researchUpdates => _researchUpdates;
  bool get isLoadingConferences => _isLoadingConferences;
  bool get isLoadingResearch => _isLoadingResearch;
  bool get isLoadingFilterOptions => _isLoadingFilterOptions;
  bool get showPastConferences => _showPastConferences;
  Map<String, List<String>> get filterOptions => _filterOptions;
  
  String? get conferenceError => _conferenceError;
  String? get researchError => _researchError;
  
  // Pagination getters
  bool get hasMoreConferences => _hasMoreConferences;
  bool get hasMoreResearch => _hasMoreResearch;
  int get totalConferences => _totalConferences;
  int get totalResearch => _totalResearch;
  
  // Current filter values
  String? get conferenceSearch => _conferenceSearch;
  String? get conferenceLocation => _conferenceLocation;
  String? get conferenceTopic => _conferenceTopic;
  String? get researchSearch => _researchSearch;
  String? get researchCategory => _researchCategory;
  String? get researchInstitution => _researchInstitution;
  int? get recentDays => _recentDays;

  // Conference filter methods
  void setConferenceSearch(String? query) {
    if (_conferenceSearch != query) {
      _conferenceSearch = query?.trim().isEmpty == true ? null : query?.trim();
      _resetConferencePagination();
      fetchConferences(refresh: true);
    }
  }
  
  void setConferenceLocation(String? location) {
    if (_conferenceLocation != location) {
      _conferenceLocation = location?.trim().isEmpty == true ? null : location?.trim();
      _resetConferencePagination();
      fetchConferences(refresh: true);
    }
  }
  
  void setConferenceTopic(String? topic) {
    if (_conferenceTopic != topic) {
      _conferenceTopic = topic?.trim().isEmpty == true ? null : topic?.trim();
      _resetConferencePagination();
      fetchConferences(refresh: true);
    }
  }
  
  void togglePastConferences(bool show) {
    if (_showPastConferences != show) {
      _showPastConferences = show;
      _resetConferencePagination();
      fetchConferences(refresh: true);
    }
  }
  
  // Research filter methods
  void setResearchSearch(String? query) {
    if (_researchSearch != query) {
      _researchSearch = query?.trim().isEmpty == true ? null : query?.trim();
      _resetResearchPagination();
      fetchResearchUpdates(refresh: true);
    }
  }
  
  void setResearchCategory(String? category) {
    if (_researchCategory != category) {
      _researchCategory = category?.trim().isEmpty == true ? null : category?.trim();
      _resetResearchPagination();
      fetchResearchUpdates(refresh: true);
    }
  }
  
  void setResearchInstitution(String? institution) {
    if (_researchInstitution != institution) {
      _researchInstitution = institution?.trim().isEmpty == true ? null : institution?.trim();
      _resetResearchPagination();
      fetchResearchUpdates(refresh: true);
    }
  }

  void setRecentDays(int? days) {
    if (_recentDays != days) {
      _recentDays = days;
      _resetResearchPagination();
      fetchResearchUpdates(refresh: true);
    }
  }

  // Pagination helpers
  void _resetConferencePagination() {
    _conferencePage = 1;
    _hasMoreConferences = true;
    _totalConferences = 0;
  }

  void _resetResearchPagination() {
    _researchPage = 1;
    _hasMoreResearch = true;
    _totalResearch = 0;
  }

  // Fetch data methods with pagination support
  Future<void> fetchConferences({bool refresh = false, bool loadMore = false}) async {
    if (loadMore && !_hasMoreConferences) return;
    if (_isLoadingConferences) return;

    if (refresh || (!loadMore && _conferencePage == 1)) {
      _resetConferencePagination();
      _conferences.clear();
    }

    _isLoadingConferences = true;
    _conferenceError = null;
    notifyListeners();

    try {
      appLogger.d('Fetching conferences - Page: $_conferencePage, Refresh: $refresh, LoadMore: $loadMore');
      
      final result = await CSDataService.fetchConferencesPaginated(
        showPast: _showPastConferences,
        search: _conferenceSearch,
        location: _conferenceLocation,
        topic: _conferenceTopic,
        page: _conferencePage,
        pageSize: 20,
      );

      final List<Conference> newConferences = result['results'] as List<Conference>;
      _totalConferences = result['count'] as int;
      _hasMoreConferences = result['hasNext'] as bool;

      if (refresh || _conferencePage == 1) {
        _conferences = newConferences;
      } else {
        _conferences.addAll(newConferences);
      }

      if (loadMore && _hasMoreConferences) {
        _conferencePage++;
      }

      appLogger.i('Successfully loaded ${newConferences.length} conferences. Total: ${_conferences.length}');
    } catch (e) {
      _conferenceError = 'Failed to load conferences: ${e.toString()}';
      appLogger.e('Error fetching conferences: $e');
      if (refresh || _conferencePage == 1) {
        _conferences = [];
      }
    } finally {
      _isLoadingConferences = false;
      notifyListeners();
    }
  }

  Future<void> fetchResearchUpdates({bool refresh = false, bool loadMore = false}) async {
    if (loadMore && !_hasMoreResearch) return;
    if (_isLoadingResearch) return;

    if (refresh || (!loadMore && _researchPage == 1)) {
      _resetResearchPagination();
      _researchUpdates.clear();
    }

    _isLoadingResearch = true;
    _researchError = null;
    notifyListeners();

    try {
      appLogger.d('Fetching research updates - Page: $_researchPage, Refresh: $refresh, LoadMore: $loadMore');
      
      final result = await CSDataService.fetchResearchUpdatesPaginated(
        search: _researchSearch,
        category: _researchCategory,
        institution: _researchInstitution,
        recentDays: _recentDays,
        page: _researchPage,
        pageSize: 20,
      );

      final List<ResearchUpdate> newResearch = result['results'] as List<ResearchUpdate>;
      _totalResearch = result['count'] as int;
      _hasMoreResearch = result['hasNext'] as bool;

      if (refresh || _researchPage == 1) {
        _researchUpdates = newResearch;
      } else {
        _researchUpdates.addAll(newResearch);
      }

      if (loadMore && _hasMoreResearch) {
        _researchPage++;
      }

      appLogger.i('Successfully loaded ${newResearch.length} research updates. Total: ${_researchUpdates.length}');
    } catch (e) {
      _researchError = 'Failed to load research updates: ${e.toString()}';
      appLogger.e('Error fetching research updates: $e');
      if (refresh || _researchPage == 1) {
        _researchUpdates = [];
      }
    } finally {
      _isLoadingResearch = false;
      notifyListeners();
    }
  }

  // Load more data methods
  Future<void> loadMoreConferences() async {
    await fetchConferences(loadMore: true);
  }

  Future<void> loadMoreResearch() async {
    await fetchResearchUpdates(loadMore: true);
  }

  // Refresh methods
  Future<void> refreshConferences() async {
    await fetchConferences(refresh: true);
  }

  Future<void> refreshResearch() async {
    await fetchResearchUpdates(refresh: true);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      refreshConferences(),
      refreshResearch(),
    ]);
  }

  // Load filter options using the new service methods
  Future<void> loadFilterOptions() async {
    if (_isLoadingFilterOptions) return;

    _isLoadingFilterOptions = true;
    notifyListeners();

    try {
      appLogger.d('Loading filter options');
      _filterOptions = await CSDataService.getAllFilterOptions();
      appLogger.i('Successfully loaded filter options: ${_filterOptions.keys}');
    } catch (e) {
      appLogger.e('Error loading filter options: $e');
      // Keep existing filter options or use empty map
      _filterOptions = _filterOptions.isEmpty ? {} : _filterOptions;
    } finally {
      _isLoadingFilterOptions = false;
      notifyListeners();
    }
  }

  // Get specific filter options
  List<String> get availableLocations => _filterOptions['locations'] ?? [];
  List<String> get availableTopics => _filterOptions['topics'] ?? [];
  List<String> get availableCategories => _filterOptions['categories'] ?? [];
  List<String> get availableInstitutions => _filterOptions['institutions'] ?? [];

  // Clear all filters
  void resetConferenceFilters() {
    _conferenceSearch = null;
    _conferenceLocation = null;
    _conferenceTopic = null;
    _showPastConferences = false;
    _resetConferencePagination();
    fetchConferences(refresh: true);
  }

  void resetResearchFilters() {
    _researchSearch = null;
    _researchCategory = null;
    _researchInstitution = null;
    _recentDays = null;
    _resetResearchPagination();
    fetchResearchUpdates(refresh: true);
  }

  void resetAllFilters() {
    resetConferenceFilters();
    resetResearchFilters();
  }

  // Check if any filters are active
  bool get hasActiveConferenceFilters {
    return _conferenceSearch != null ||
           _conferenceLocation != null ||
           _conferenceTopic != null ||
           _showPastConferences;
  }

  bool get hasActiveResearchFilters {
    return _researchSearch != null ||
           _researchCategory != null ||
           _researchInstitution != null ||
           _recentDays != null;
  }

  bool get hasActiveFilters {
    return hasActiveConferenceFilters || hasActiveResearchFilters;
  }

  // Get filter summary
  String getConferenceFilterSummary() {
    final List<String> activeFilters = [];
    
    if (_conferenceSearch != null) activeFilters.add('Search: "$_conferenceSearch"');
    if (_conferenceLocation != null) activeFilters.add('Location: "$_conferenceLocation"');
    if (_conferenceTopic != null) activeFilters.add('Topic: "$_conferenceTopic"');
    if (_showPastConferences) activeFilters.add('Including past events');
    
    return activeFilters.isEmpty ? 'No filters active' : activeFilters.join(', ');
  }

  String getResearchFilterSummary() {
    final List<String> activeFilters = [];
    
    if (_researchSearch != null) activeFilters.add('Search: "$_researchSearch"');
    if (_researchCategory != null) activeFilters.add('Category: "$_researchCategory"');
    if (_researchInstitution != null) activeFilters.add('Institution: "$_researchInstitution"');
    if (_recentDays != null) activeFilters.add('Recent: ${_recentDays} days');
    
    return activeFilters.isEmpty ? 'No filters active' : activeFilters.join(', ');
  }
  
  // Initialize with better error handling
  Future<void> initialize() async {
    appLogger.d('Initializing CS Data Provider');
    
    _isLoadingConferences = true;
    _isLoadingResearch = true;
    _isLoadingFilterOptions = true;
    notifyListeners();

    try {
      // Load filter options first, then data
      await loadFilterOptions();
      
      // Load data in parallel
      await Future.wait([
        fetchConferences(refresh: true),
        fetchResearchUpdates(refresh: true),
      ]);
      
      appLogger.i('CS Data Provider initialized successfully');
    } catch (e) {
      appLogger.e('Error initializing CS data: $e');
    } finally {
      _isLoadingConferences = false;
      _isLoadingResearch = false;
      _isLoadingFilterOptions = false;
      notifyListeners();
    }
  }

  // Dispose method for cleanup
  @override
  void dispose() {
    appLogger.d('Disposing CS Data Provider');
    super.dispose();
  }

  // Search suggestions (can be used for autocomplete)
  List<String> getLocationSuggestions(String query) {
    if (query.isEmpty) return availableLocations.take(5).toList();
    
    return availableLocations
        .where((location) => location.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  List<String> getTopicSuggestions(String query) {
    if (query.isEmpty) return availableTopics.take(5).toList();
    
    return availableTopics
        .where((topic) => topic.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  List<String> getCategorySuggestions(String query) {
    if (query.isEmpty) return availableCategories.take(5).toList();
    
    return availableCategories
        .where((category) => category.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  List<String> getInstitutionSuggestions(String query) {
    if (query.isEmpty) return availableInstitutions.take(5).toList();
    
    return availableInstitutions
        .where((institution) => institution.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}