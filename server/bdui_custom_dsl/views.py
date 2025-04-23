from django.http import JsonResponse, HttpResponse
import json
import os
from .dsl_builder import Screen
from .components import Container, Text, Button, Image
from .fsm_manager import fsm_manager
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.csrf import csrf_exempt

data_path = os.path.join(os.path.dirname(__file__), 'data')

def get_dsl_points(request):
	return HttpResponse('Points not found', status=404)
	# try:
	# 	with open(os.path.join(data_path, 'dsl_points.json'), 'r', encoding='utf-8') as file:
	# 		data = json.load(file)
	# 	response = JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})
	# 	response['Content-Type'] = 'application/json; charset=utf-8'
	# 	return response
	# except FileNotFoundError:
	# 	return HttpResponse('Points not found', status=404)

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

    fsm = fsm_manager.get_or_create_fsm(user_id)
    if not fsm.trigger_event(event):
        return JsonResponse({"error": f"Invalid event {event} for state {fsm.get_state()}"}, status=400)

    state = fsm.get_state()
    screen = Screen(screen_id=state)
    main_container = Container(orientation="vertical", padding=15)

    if state == "need_register":
        main_container.add_child(
            Image(uri="https://wowxoxo.github.io/coolapp-auth-form/key.png", width=168, height=180)
        )
        main_container.add_child(Text("Зарегистрируйтесь в приложении «CoolApp»", font_size=22, bold=True, alignment="center"))
        main_container.add_child(Text("Первичная регистрация необходима для работы в приложении", font_size=16, alignment="center", padding_top=10))
        main_container.add_child(
            Container(orientation="vertical", padding_top=20).add_child(
                Button(text="Зарегистрироваться", action="request", event="tap_register", bottomAligned=True)
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
        main_container.add_child(Text("Доступные услуги", font_size=22, bold=True))
        main_container.add_child(Text("Выберите услугу для продолжения", font_size=16))
        main_container.add_child(
            Container(orientation="vertical", padding_top=20).add_child(
                Button(text="Услуга №1", action="request", event="select_service1")
            )
        )
        main_container.add_child(
            Container(orientation="vertical", padding_top=10).add_child(
                Button(text="Услуга №2", action="request", event="select_service2")
            )
        )
    elif state == "not_enough_rights":
        main_container.add_child(Text("Недостаточно прав", font_size=22, bold=True))
        main_container.add_child(Text("Невозможно продолжить работу", font_size=16))
        main_container.add_child(
            Container(orientation="vertical", padding_top=20).add_child(
                Button(text="Попробовать снова", action="request", event="tap_register")
            )
        )

    screen.add_component(main_container)
    response_data = screen.to_dict()
    response_data["deeplink"] = f"coolapp://{state}"

    return JsonResponse(response_data, safe=False, json_dumps_params={"ensure_ascii": False})