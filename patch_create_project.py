#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Patch to make start_date and end_date optional in project creation"""

import re

# Read the file
with open('custom_admin/views.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Find and replace the post method in OrganizerProjectsAPIView
old_code = r"""    def post\(self, request\):
        if not request\.user\.is_organizer or not request\.user\.is_approved:
            return Response\(\{'error': 'Not authorized'\}, status=status\.HTTP_403_FORBIDDEN\)

        try:
            title = request\.data\.get\('title'\)
            description = request\.data\.get\('description'\)
            city = request\.data\.get\('city'\)
            start_date = request\.data\.get\('start_date'\)
            end_date = request\.data\.get\('end_date'\)
            volunteer_type = request\.data\.get\('volunteer_type', 'any'\)

            if not all\(\[title, description, city, start_date, end_date\]\):
                return Response\(\{'error': 'Missing required fields'\}, status=status\.HTTP_400_BAD_REQUEST\)

            project = Project\.objects\.create\(
                title=title,
                description=description,
                city=city,
                start_date=start_date,
                end_date=end_date,
                volunteer_type=volunteer_type,
                creator=request\.user,
                status='pending'
            \)

            return Response\(\{
                'id': project\.id,
                'title': project\.title,
                'description': project\.description,
                'city': project\.city,
                'status': project\.status,
                'volunteer_count': 0,
                'task_count': 0,
                'created_at': project\.created_at\.isoformat\(\)
            \}, status=status\.HTTP_201_CREATED\)
        except Exception as e:
            return Response\(\{'error': str\(e\)\}, status=status\.HTTP_500_INTERNAL_SERVER_ERROR\)"""

new_code = """    def post(self, request):
        if not request.user.is_organizer or not request.user.is_approved:
            return Response({'error': 'Not authorized'}, status=status.HTTP_403_FORBIDDEN)

        try:
            from datetime import datetime, timedelta

            title = request.data.get('title')
            description = request.data.get('description')
            city = request.data.get('city')
            start_date = request.data.get('start_date')
            end_date = request.data.get('end_date')
            volunteer_type = request.data.get('volunteer_type', 'any')
            latitude = request.data.get('latitude')
            longitude = request.data.get('longitude')

            if not all([title, description, city]):
                return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)

            # Use default dates if not provided
            if not start_date:
                start_date = datetime.now().date()
            if not end_date:
                end_date = (datetime.now() + timedelta(days=30)).date()

            project = Project.objects.create(
                title=title,
                description=description,
                city=city,
                start_date=start_date,
                end_date=end_date,
                volunteer_type=volunteer_type,
                creator=request.user,
                status='pending'
            )

            # Add location if provided
            if latitude and longitude:
                project.latitude = float(latitude)
                project.longitude = float(longitude)
                project.save()

            return Response({
                'id': project.id,
                'title': project.title,
                'description': project.description,
                'city': project.city,
                'status': project.status,
                'volunteer_count': 0,
                'task_count': 0,
                'created_at': project.created_at.isoformat()
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)"""

# Apply the replacement
content = re.sub(old_code, new_code, content, flags=re.MULTILINE | re.DOTALL)

# Write back
with open('custom_admin/views.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Patch applied!")
print("- Made start_date and end_date optional (use defaults if not provided)")
print("- Added support for latitude/longitude")