from django.http import JsonResponse, HttpResponse
import json
import os
import time

data_path = os.path.join(os.path.dirname(__file__), 'data')

def get_custom_bdui_points(request):
	try:
		time.sleep(3)
		with open(os.path.join(data_path, 'bdui_custom_points.json'), 'r', encoding='utf-8') as file:
			data = json.load(file)
		response = JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})
		response['Content-Type'] = 'application/json; charset=utf-8'
		return response
	except FileNotFoundError:
		return HttpResponse('Points not found', status=404)

def get_custom_bdui_point(request, id):
	try:
		time.sleep(3)
		with open(os.path.join(data_path, f'bdui_custom_point.json'), 'r', encoding='utf-8') as file:
			data = json.load(file)
		response = JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})
		response['Content-Type'] = 'application/json; charset=utf-8'
		return response
	except FileNotFoundError:
		return HttpResponse('Point not found', status=404)
