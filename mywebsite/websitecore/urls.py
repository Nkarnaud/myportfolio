from django.urls.conf import path

from websitecore.views import (
    HomeTemplateView
)

urlpatterns = [
    path('', HomeTemplateView.as_view(), name='home'),
]
