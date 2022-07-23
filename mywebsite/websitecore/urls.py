from django.urls.conf import path

from websitecore.views import (
    HomeTemplateView,
    AboutTemplateView
)

urlpatterns = [
    path('', HomeTemplateView.as_view(), name='home'),
    path('about/', AboutTemplateView.as_view(), name='about')
]
