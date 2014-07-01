#!/usr/bin/env python
from bottle import template, request, redirect, route, post, run, static_file



# Procedure to handle the home page /
@route("/")
def index():
    return template("<b> Wow its working </b>")



if __name__ == "__main__":
	# start a server but have it reload any files that
	# are changed
	run(host="localhost", port=8080, reloader=True)
