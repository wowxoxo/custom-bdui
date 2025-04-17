from django.urls import path
from . import views

urlpatterns = [
    path('points', views.get_dsl_points),
    path('points/<int:id>', views.get_dsl_point),
    path("get-csrf-token/", views.get_csrf_token),
    path("fsm/next", views.next_screen),
]
