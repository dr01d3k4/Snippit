from django.shortcuts import render;
from django.views.generic.base import View;
from snippit.models import Snippet;
from snippit.forms import SnippetForm;
from django.core.urlresolvers import reverse;
from django.http import HttpResponseRedirect;



class Index(View):
	def get(self, request):
		context = { };
		context["snippetForm"] = SnippetForm();
		context["recentSnippets"] = Snippet.objects.order_by("date");

		return render(request, "snippit/index.html", context);



class NewSnippet(View):
	def post(self, request):
		snippetForm = SnippetForm(data = request.POST);
		snippet = snippetForm.save();
		return HttpResponseRedirect(snippet.absoluteUrl);



class ViewSnippet(View):
	def get(self, request, snippetId = ""):
		snippet = None;
		try:
			snippet = Snippet.objects.get(uuid = snippetId)
		except (Snippet.DoesNotExist):
			pass;

		context = { };
		context["snippet"] = snippet;
		return render(request, "snippit/view_snippet.html", context);