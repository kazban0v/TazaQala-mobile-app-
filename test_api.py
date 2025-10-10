#!/usr/bin/env python
import requests

# Тестируем API
print("Тестируем API...")

# Попытка входа
login_data = {
    'username': 'ultraorganizer@gmail.com',
    'password': 'test123'
}

print(f"Пытаемся войти как: {login_data['username']}")

response = requests.post('http://192.168.0.129:8000/custom-admin/api/login/', json=login_data)
print(f"Статус входа: {response.status_code}")
print(f"Ответ входа: {response.json()}")

if response.status_code == 200:
    token = response.json()['token']
    print(f"Получен токен: {token}")

    # Получаем проекты
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    projects_response = requests.get('http://192.168.0.129:8000/custom-admin/api/projects/', headers=headers)
    print(f"Статус проектов: {projects_response.status_code}")
    print(f"Ответ проектов: {projects_response.json()}")

    # Получаем задачи
    tasks_response = requests.get('http://192.168.0.129:8000/custom-admin/api/tasks/', headers=headers)
    print(f"Статус задач: {tasks_response.status_code}")
    print(f"Ответ задач: {tasks_response.json()}")
else:
    print("Ошибка входа!")