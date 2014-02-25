from django.contrib import admin;
from snippit.models import Snippet;



class SnippetAdmin(admin.ModelAdmin):
	readonly_fields = ("uuid", );
	list_display = ("uuid", "user", "title", "language", "date", "content");
	fields = ("uuid", "user", "title", "language", "content");
admin.site.register(Snippet, SnippetAdmin);