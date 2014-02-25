from django import forms;
from django.contrib.auth.models import User;
from snippit.models import Snippet, LANGUAGE_CHOICES;



class SnippetForm(forms.ModelForm):
	title = forms.CharField(help_text = "Title", required = False);
	content = forms.CharField(help_text = "Content", widget = forms.Textarea());
	language = forms.ChoiceField(help_text = "Language", choices = LANGUAGE_CHOICES);



	class Meta:
		model = Snippet;
		fields = ["title", "content", "language"];