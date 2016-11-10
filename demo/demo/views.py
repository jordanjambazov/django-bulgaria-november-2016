from django.http import HttpResponse


def divide(request, a, b):
    return HttpResponse(str(float(a) / float(b)))
