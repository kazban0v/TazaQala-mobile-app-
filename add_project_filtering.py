#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Add project filtering by volunteer type to Flutter app"""

# Add filtering state and UI to volunteer_page.dart
with open('lib/volunteer_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add filter state variable after _selectedIndex
old_state = '''class _VolunteerPageState extends State<VolunteerPage> {
    int _selectedIndex = 0;'''

new_state = '''class _VolunteerPageState extends State<VolunteerPage> {
    int _selectedIndex = 0;
    String? _selectedFilter; // null = all, 'social', 'environmental', 'cultural' '''

content = content.replace(old_state, new_state)

# 2. Add filter chips UI before the projects list
# Find the _buildProjectsTab method and add filter chips
old_projects_tab = '''  Widget _buildProjectsTab() {
    final projectsProvider = context.watch<VolunteerProjectsProvider>();

    if (projectsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }'''

new_projects_tab = '''  Widget _buildProjectsTab() {
    final projectsProvider = context.watch<VolunteerProjectsProvider>();

    if (projectsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filter
    final filteredProjects = _selectedFilter == null
        ? projectsProvider.projects
        : projectsProvider.projects.where((p) => p.volunteerType == _selectedFilter).toList();'''

content = content.replace(old_projects_tab, new_projects_tab)

# 3. Update empty state check
content = content.replace(
    'if (projectsProvider.projects.isEmpty) {',
    'if (filteredProjects.isEmpty && _selectedFilter == null) {'
)

# 4. Update ListView.builder to use filtered projects
content = content.replace(
    'itemCount: projectsProvider.projects.length,',
    'itemCount: filteredProjects.length,'
)

content = content.replace(
    'final project = projectsProvider.projects[index];',
    'final project = filteredProjects[index];'
)

# 5. Add filter chips before ListView - wrap RefreshIndicator in Column
old_refresh = '''    return RefreshIndicator(
      onRefresh: projectsProvider.loadProjects,
      child: ListView.builder('''

new_refresh = '''    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Социальная помощь'),
                  selected: _selectedFilter == 'social',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'social' : null;
                    });
                  },
                  selectedColor: const Color(0xFFE91E63).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFFE91E63),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Экологические'),
                  selected: _selectedFilter == 'environmental',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'environmental' : null;
                    });
                  },
                  selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Культурные'),
                  selected: _selectedFilter == 'cultural',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'cultural' : null;
                    });
                  },
                  selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),
        ),
        // Empty state if filtered and no results
        if (filteredProjects.isEmpty && _selectedFilter != null)
          const Expanded(
            child: Center(
              child: Text('Нет проектов данного типа'),
            ),
          ),
        // Projects list
        if (filteredProjects.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: projectsProvider.loadProjects,
              child: ListView.builder('''

content = content.replace(old_refresh, new_refresh)

# 6. Close the new Expanded and Column widgets
# Find the closing of RefreshIndicator and update it
old_close = '''      ),
    );
  }

  Widget _buildTasksTab() {'''

new_close = '''              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTasksTab() {'''

content = content.replace(old_close, new_close)

with open('lib/volunteer_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('OK: Added project filtering to volunteer_page.dart')
