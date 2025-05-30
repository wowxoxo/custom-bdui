from django.http import JsonResponse, HttpResponse
import json
import os
from .dsl_builder import Screen
from .components import Container, Text, Button, Image, Checkbox
from .fsm_manager import fsm_manager
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
import time
from .config import WEBVIEW_URLS

data_path = os.path.join(os.path.dirname(__file__), 'data')

def build_screen(flow: str, state: str) -> Screen:
	screen = Screen(screen_id=f"{flow}.{state}")
	main_container = Container(orientation="vertical", padding=15)

	if flow == "registration":
		if state == "need_register":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/key.png", width=168, height=180, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(Text("Зарегистрируйтесь в приложении «CoolApp»", font_size=22, bold=True, alignment="center"))
			main_container.add_child(Text("Первичная регистрация необходима для работы в приложении", font_size=16, alignment="center", padding_top=10))
			# TODO: remove, check button with image
			# main_container.add_child(
			#	 Container(orientation="vertical", padding_top=20).add_child(
			#		 Button(image_uri="https://wowxoxo.github.io/coolapp-auth-form/copy.png", action="request", event="tap_register", background_color="#E6F0FA", border_radius=10, width=24)
			#	 )
			# )
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Зарегистрироваться", action="request", event="tap_register", bottomAligned=True, background_color="#1E90FF", border_radius=10, full_width=True, margin_right=10, padding=15, color='#ffffff')
				)
			)
		elif state == "auth":
			main_container.add_child(Text("Загрузка авторизации...", font_size=16))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Webview", action="webview", uri="https://wowxoxo.github.io/coolapp-auth-form")
				)
			)
		elif state == "services":
			main_container.add_child(Text("Доступные услуги", font_size=22, bold=True, alignment="center"))
			main_container.add_child(Text("Выберите услугу для продолжения", font_size=16, alignment="center"))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(
					text="Услуга №1",
					action="request",
					event="select_service1",
					font_size=18,
					color="#ffffff",
					background_color="#1E90FF",
				)
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Button(
					text="Услуга №2",
					action="request",
					event="select_service2",
					font_size=18,
					color="#ffffff",
					background_color="#ff0000",
				)
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Button(text="Все услуги (+скрытые)", color="ffffff",
					 action="webview", uri=WEBVIEW_URLS["services"])
				)
			)

		elif state == "not_enough_rights":
			main_container.add_child(Text("Недостаточно прав", font_size=22, bold=True))
			main_container.add_child(Text("Невозможно продолжить работу", font_size=16))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Попробовать снова", color="#ffffff", action="request", event="tap_register", bottomAligned=True)
				)
			)
	elif flow == "service-one":
		if state == "get":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/get-doc.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(Text("Получить услугу №1", font_size=22, bold=True, alignment="center"))
			main_container.add_child(Text("Услуга доступна без дополнительных условий. Для получения услуги потребуется посетить один из центров обслуживания", font_size=16, alignment="center", padding_top=10))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Получить", action="request", event="continue",
					bottomAligned=True, background_color="#1E90FF", border_radius=10, full_width=True, margin_right=10, padding=15, color='#ffffff'
					)
				)
			)
		elif state == "service-center-visit":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/walking.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(Text("Посетить центр обслуживания", font_size=22, bold=True, alignment="center"))
			main_container.add_child(Text("Чтобы получить услугу, посетите МФЦ или банк. С собой возьмите паспорт РФ", font_size=16, alignment="center"))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Выбрать адрес", action="request", event="select-address",
					bottomAligned=True, background_color="#1E90FF", border_radius=10, full_width=True, margin_right=10, padding=15, color='#ffffff'
					)
				)
			)
		elif state == "points-list":
			main_container.add_child(Text("Центры обслуживания", font_size=22, bold=True))
			main_container.add_child(Text("Инвестиционный Банк «ВЕСТА» (ООО)", font_size=16, padding_top=10))
			main_container.add_child(Text("119071, Москва регион, Москва город, Ленинский проспект улица, 15а дом, д. 15а", font_size=18))
			main_container.add_child(Text("15а", font_size=14))
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Button(text="Выбрать", action="request", event="select-point", target="point1", color="#ffffff")
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Text("АО Райффайзенбанк, дополнительный офис", font_size=18)
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Text("119071, Москва регион, Москва город, Ленинский проспект улица, 15а дом, д. 15а", font_size=16)
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Button(text="Выбрать", action="request", event="select-point", target="point2", color="#ffffff")
				)
			)
		elif state == "point-details":
			main_container.add_child(Text("Дополнительный международный офис «Прайм» АКБ «ФОРА-БАНК»", font_size=22, bold=True))
			# main_container.add_child(
			# 	Container(orientation="vertical", padding_top=10).add_child(
			# 		Text("Адрес", font_size=16, bold=True)
			# 	)
			# )
			main_container.add_child(
				Container(orientation="vertical", padding_top=10).add_child(
					Text("Адрес", font_size=16, bold=True)
				).add_child(
					Text("119071, Москва регион, Москва город, Ленинский проспект улица, д. 15а", font_size=14, padding_top=5)
				).add_child(
					Text("Контакты", font_size=16, bold=True, padding_top=10)
				).add_child(
					Text(
						text="7 863 438-28-00",
						font_size=14,
						color="#007AFF",
						action="tel",
						tel="78634382800",
						padding_top=5
					)
				).add_child(
					Text("Режим работы", font_size=16, bold=True, padding_top=10)
				).add_child(
					Text("В будние дни с 10:00 до 17:00, в выходные с 10:00 до 13:00", font_size=14, padding_top=5)
				).add_child(
					Text("Особенности услуги", font_size=16, bold=True, padding_top=10)
				).add_child(
					Text("• Обслуживание физических лиц\n• Регистрация учётной записи\n• Регистрация биометрии", font_size=14, padding_top=5)
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Проложить маршрут", color="#ffffff", action="request", event="continue-route")
				)
			)

	elif flow == "service-two":
		if state == "temporarily-unavailable":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/phone-error.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(Text("Услуга временно недоступна", font_size=22, bold=True, alignment="center", padding_top=20))
			main_container.add_child(Text("Попробуйте снова позже", font_size=16, alignment="center", padding_top=10))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Попробовать снова", color="#ffffff", action="request", event="retry", bottomAligned=True)
				)
			)
		elif state == "unavailable":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/phone-error.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(Text("Услуга недоступна", font_size=22, bold=True, alignment="center", padding_top=20))
			main_container.add_child(Text("Данная услуга недоступна в вашем регионе", font_size=16, alignment="center", padding_top=10))
		elif state == "get":
			main_container.add_child(Text("Получить услугу №2", font_size=22, bold=True))
			main_container.add_child(Text("Услуга №2: Начало", font_size=16))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Продолжить", action="request", event="continue", color="#ffffff")
				)
			)
		elif state == "details":
			main_container.add_child(Text("Детали услуги №2", font_size=22, bold=True))
			main_container.add_child(Text("Информация об услуге №2", font_size=16))
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(text="Завершить", action="request", event="complete")
				)
			)

	elif flow == "service-three":
		if state == "intro":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/get-doc.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(
				Text("Получить услугу №3", font_size=24, bold=True, color="#000000", alignment="center", padding_top=20)
			)
			main_container.add_child(
				Text(
					"Услуга доступна без дополнительных условий",
					font_size=16,
					color="#666666",
					alignment="center",
					padding_top=10
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=30).add_child(
					Button(
						text="Продолжить",
						action="request",
						event="continue",
						background_color="#007AFF",
						color="#FFFFFF",
						border_radius=8,
						padding=12,
						full_width=True
					)
				)
			)
		elif state == "docs-accept":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/doc-with-glasses.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(
				Text("Ознакомьтесь с условиями", font_size=24, bold=True, color="#000000", alignment="center", padding_top=20)
			)
			main_container.add_child(
				Text(
					"Для получения услуги подтвердите условия и примите пользовательское соглашение.",
					font_size=16,
					color="#666666",
					alignment="center",
					padding_top=10
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=30).add_child(
					# Checkbox(label="Подтверждаю ознакомление с условиями и принимаю пользовательское соглашение", event="accept-docs", color="#007AFF")
					Checkbox(label="Я принимаю условия", action="toggle", target="continue-button")
				)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=20).add_child(
					Button(
						text="Продолжить",
						action="request",
						event="accept-docs",
						target="continue-button",
						background_color="#1E90FF",
						color="#ffffff",
						disabled=True
					)
				)
			)
		elif state == "final":
			main_container.add_child(
				Image(uri="https://wowxoxo.github.io/coolapp-auth-form/green-doc.png", width=295, height=184, margin_top=20, margin_bottom=20)
			)
			main_container.add_child(
				Text("Услуга получена", font_size=24, bold=True, color="#000000", alignment="center", padding_top=20)
			)
			main_container.add_child(
				Text("Теперь услуга работает для вас", font_size=16, color="#666666", alignment="center", padding_top=10)
			)
			main_container.add_child(
				Container(orientation="vertical", padding_top=30).add_child(
					Button(
						text="К услугам",
						action="request",
						event="finish",
						background_color="#007AFF",
						color="#FFFFFF",
						border_radius=8,
						padding=12,
						full_width=True
					)
				)
			)

	screen.add_component(main_container)
	return screen

def get_dsl_points(request):
	return HttpResponse('Points not found', status=404)
	# try:
	#	 with open(os.path.join(data_path, 'dsl_points.json'), 'r', encoding='utf-8') as file:
	#		 data = json.load(file)
	#	 response = JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})
	#	 response['Content-Type'] = 'application/json; charset=utf-8'
	#	 return response
	# except FileNotFoundError:
	#	 return HttpResponse('Points not found', status=404)

def get_dsl_point(request, id):
	screen = Screen(screen_id="office_detail_screen")

	main_container = Container(orientation="vertical", padding=15)

	main_container.add_child(Text("Дополнительный международный офис\n«Прайм» АКБ «ФОРА-БАНК»", font_size=22, color="#000000", alignment="left", bold=True))

	address_container = Container(orientation="vertical", padding_top=30, padding_bottom=10)
	address_container.add_child(Text("Адрес", font_size=15, color="#566379", alignment="left"))
	main_container.add_child(address_container)
	main_container.add_child(Text("119071, Москва регион, Москва город, Ленинский проспект улица, 15а дом, д. 15а", font_size=16, color="#1D1D1D", alignment="left"))

	contacts_container = Container(orientation="vertical", padding_top=30, padding_bottom=10)
	contacts_container.add_child(Text("Контакты", font_size=15, color="#566379", alignment="left"))
	main_container.add_child(contacts_container)
	main_container.add_child(Text("+7 863 438-28-00", font_size=18, color="#1E90FF", alignment="left"))

	working_hours_container = Container(orientation="vertical", padding_top=30, padding_bottom=10)
	working_hours_container.add_child(Text("Режим работы", font_size=15, color="#566379", alignment="left"))
	main_container.add_child(working_hours_container)
	main_container.add_child(Text("пн-пт с 10:00 до 19:00, сб с 10:00 до 17:00, вск — выходной", font_size=16, color="#000000", alignment="left"))

	services_container = Container(orientation="vertical", padding_top=30, padding_bottom=0)
	services_container.add_child(Text("Оказываемые услуги", font_size=15, color="#566379", alignment="left"))
	main_container.add_child(services_container)

	services_list = Container(orientation="vertical", padding=10)
	services_list.add_child(Container(orientation="vertical", padding_bottom=10, padding_left=-5).add_child(Text("• Обслуживание физических лиц", font_size=16, color="#000000", alignment="left")))
	services_list.add_child(Container(orientation="vertical", padding_bottom=10, padding_left=-5).add_child(Text("• Регистрация учётной записи", font_size=16, color="#000000", alignment="left")))
	services_list.add_child(Container(orientation="vertical", padding_bottom=10, padding_left=-5).add_child(Text("• Регистрация биометрии", font_size=16, color="#000000", alignment="left")))
	services_list.add_child(Container(orientation="vertical", padding_bottom=10, padding_left=-5).add_child(Text("• Удаление учётной записи", font_size=16, color="#000000", alignment="left")))
	services_list.add_child(Container(orientation="vertical", padding_bottom=10, padding_left=-5).add_child(Text("• Восстановление личности", font_size=16, color="#000000", alignment="left")))

	main_container.add_child(services_list)

	comment_container = Container(orientation="vertical", padding_top=10, padding_bottom=10)
	comment_container.add_child(Text("Комментарий", font_size=15, color="#566379", alignment="left"))
	main_container.add_child(comment_container)
	main_container.add_child(Text("Прием только по вопросам учётной записи в ЕСИА, установления отдельных жизненно важных выплат и срочных выплат по линии ПФР, заблаговременной работы с лицами, выходящими на пенсию", font_size=16, color="#000000", alignment="left"))

	screen.add_component(main_container)

	response_data = screen.to_dict()

	response = JsonResponse(response_data, safe=False, json_dumps_params={'ensure_ascii': False})
	response['Content-Type'] = 'application/json; charset=utf-8'
	return response

@ensure_csrf_cookie
def get_csrf_token(request):
	return JsonResponse({"message": "CSRF cookie set"})

@csrf_exempt
def next_screen(request):
	if request.method != "POST":
		return HttpResponse("Method not allowed", status=405)

	try:
		data = json.loads(request.body)
	except json.JSONDecodeError:
		return HttpResponse("Invalid JSON", status=400)

	user_id = data.get("user_id", "default_user")
	event = data.get("event", "")
	flow = data.get("flow", "registration")

	fsm = fsm_manager.get_or_create_fsm(user_id, flow)
	if not fsm.trigger_event(event):
		return JsonResponse({"error": f"Invalid event {event} for state {fsm.get_state()}"}, status=400)
	
	time.sleep(3)

	state = fsm.get_state()

	screen = build_screen(flow, state)
	response_data = screen.to_dict()
	# response_data["deeplink"] = f"coolapp://{state}"
	response_data["deeplink"] = f"coolapp://{flow}.{state}"

	return JsonResponse(response_data, safe=False, json_dumps_params={"ensure_ascii": False})

@csrf_exempt
def current_state(request):
	if request.method != "POST":
		return HttpResponse("Method not allowed", status=405)

	try:
		data = json.loads(request.body)
	except json.JSONDecodeError:
		return HttpResponse("Invalid JSON", status=400)

	user_id = data.get("user_id", "test_user")
	flow = data.get("flow", "registration")
	
	fsm = fsm_manager.get_or_create_fsm(user_id, flow)
	state = fsm.get_state()
	
	time.sleep(3)

	screen = build_screen(flow, state)
	response_data = screen.to_dict()
	response_data["deeplink"] = f"coolapp://{flow}.{state}"

	return JsonResponse(response_data, safe=False, json_dumps_params={"ensure_ascii": False})