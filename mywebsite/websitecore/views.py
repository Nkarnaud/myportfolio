from django.shortcuts import render
from django.views.generic.base import TemplateView

# Create your views here.


class HomeTemplateView(TemplateView):
    template_name = 'core/home.html'

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)

        return render(request, 'core/home.html', context=context)
