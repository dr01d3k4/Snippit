from django.conf.urls import patterns, include, url;
from django.core.urlresolvers import reverse;
from django.http import HttpResponseRedirect;



from django.contrib import admin;
admin.autodiscover();



def snippitRedirect(request):
	return HttpResponseRedirect("/snippit/");



urlpatterns = patterns("",
	url(r"^admin/", include(admin.site.urls)),
	url(r"^snippit/", include("snippit.urls", namespace = "snippit")),
	url(r"^/?$", snippitRedirect)
);



import settings;
if (settings.DEBUG):
	urlpatterns += patterns("django.views.static", (r"media/(?P<path>.*)", "serve", {"document_root": settings.MEDIA_ROOT}), );