from django.db import models;
from django.contrib.auth.models import User;
from django.core.urlresolvers import reverse;

import string;
import random;


class UUIDField(models.CharField):
	def __init__(self, *args, **kwargs):
		kwargs["max_length"] = kwargs.get("max_length", 8);
		kwargs["blank"] = True;
		super(UUIDField, self).__init__(*args, **kwargs);



	def pre_save(self, modelInstance, add):
		if (add):
			value = str("".join(random.choice(string.ascii_lowercase + string.ascii_uppercase + string.digits) for x in range(self.max_length)));
			setattr(modelInstance, self.attname, value);
			return value;
		else:
			return super(models.CharField, self).pre_save(modelInstance, add);





PLAIN_TEXT = "pt";
LUA = "lua";
CPP = "cpp";
JAVASCRIPT = "js";
COFFEESCRIPT = "coffee"

LANGUAGE_CHOICES = (
	(PLAIN_TEXT, "Plain Text"),
	(LUA, "Lua"),
	(CPP, "C++"),
	(JAVASCRIPT, "JavaScript"),
	(COFFEESCRIPT, "CoffeeScript")
);


class Snippet(models.Model):
	uuid = UUIDField(primary_key = True, db_index = True, editable = False, max_length = 8);
	user = models.ForeignKey(User, related_name = "snippets", db_index = True, null = True, blank = True);
	title = models.CharField(max_length = 255, db_index = True, blank = True);
	language = models.CharField(max_length = 6, choices = LANGUAGE_CHOICES, default = PLAIN_TEXT);
	date = models.DateTimeField(db_index = True, auto_now_add = True);
	content = models.TextField();



	def getTitle(self):
		return self.title if len(self.title) != 0 else "Untitled";


	def getUsername(self):
		return self.user.username if self.user is not None else "Anonymous";


	# @permalink
	def getAbsoluteUrl(self):
		return reverse("snippit:view-snippet", args = [self.uuid]);

	absoluteUrl = property(getAbsoluteUrl);



	def __unicode__(self):
		return str(self.uuid);