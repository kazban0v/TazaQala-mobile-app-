#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Add volunteer type badge to Flutter UI"""

# 1. Add import to volunteer_page.dart
with open('lib/volunteer_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if 'widgets/volunteer_type_badge.dart' not in content:
    content = content.replace(
        "import 'providers/volunteer_tasks_provider.dart';",
        "import 'providers/volunteer_tasks_provider.dart';\nimport 'widgets/volunteer_type_badge.dart';"
    )

# 2. Add badge after project title in project card
old_title_section = '''                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),'''

new_title_section = '''                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      VolunteerTypeBadge(
                        volunteerTypeString: project.volunteerType,
                        showLabel: false,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  VolunteerTypeBadge(
                    volunteerTypeString: project.volunteerType,
                    showLabel: true,
                    size: 20,
                  ),
                  const SizedBox(height: 12),'''

content = content.replace(old_title_section, new_title_section)

with open('lib/volunteer_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('OK: Added volunteer type badge to volunteer_page.dart')

# 3. Add same to organizer_page.dart
with open('lib/organizer_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if 'widgets/volunteer_type_badge.dart' not in content:
    # Find last import and add after it
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.startswith('import ') and not lines[i+1].startswith('import'):
            lines.insert(i+1, "import 'widgets/volunteer_type_badge.dart';")
            break
    content = '\n'.join(lines)

with open('lib/organizer_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('OK: Added import to organizer_page.dart')
