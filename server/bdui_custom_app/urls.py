from django.urls import path
from . import views

urlpatterns = [
    path('points', views.get_custom_bdui_points),
    path('points/<int:id>', views.get_custom_bdui_point),
]
