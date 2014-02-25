from django.conf.urls import patterns, include, url;
from snippit import views;
from django.core.urlresolvers import reverse;
from django.http import HttpResponseRedirect;



def indexRedirect(request):
	return HttpResponseRedirect(reverse("snippit:index"));




urlpatterns = patterns("",
	url(r"^index/$", views.Index.as_view(), name = "index"),
	url(r"^login/$", views.Index.as_view(), name = "login"),
	url(r"^new-snippet/$", views.NewSnippet.as_view(), name = "new-snippet"),
	url(r"^view-snippet/(?P<snippetId>.+?)/$", views.ViewSnippet.as_view(), name = "view-snippet"),
	url(r"^view-snippet/$", views.ViewSnippet.as_view(), name = "view-snippet"),
	url(r"^/?$", indexRedirect)
);