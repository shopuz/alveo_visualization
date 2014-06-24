#!/usr/bin/env python
from bottle import template, request, redirect, route, post, run, static_file
import sys
sys.path.append('/Users/surendrashrestha/Projects/pyhcsvlab')
import hcsvlab
import word_frequency
import json

@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='./static')

def get_shared_item_lists(client):
    
    lists = client.get_item_lists()
    return lists['shared']

def get_personal_item_lists(client):
    
    lists = client.get_item_lists()
    return lists['own']

# Procedure to handle the home page /
@route("/")
def index():
    return template("test")

@route("/wordcloud")
def index():
    
    client = hcsvlab.Client()
    
    wordfrequency = word_frequency.get_word_frequency_table(client)
    
    words = [word[0] for word in wordfrequency]
    word_dict = dict(wordfrequency)
    words =json.dumps(words)
    word_dict = json.dumps(word_dict)
    #words = ""
    
    #print words
    
    return template('wordcloud', 
                    words=words, 
                    word_dict=word_dict, 
                    shared_item_list = get_shared_item_lists(client),
                    personal_item_list = get_personal_item_lists(client)

                    )

@route("/heatmap")
def index():
    client = hcsvlab.Client()
    [row_words, col_words] = word_frequency.get_collocation_frequency(client)

    row_words= json.dumps(row_words)
    col_words = json.dumps(col_words)

    return template('heatmap', row_words = row_words, col_words = col_words)


@route("/visualise", method='POST')
def index():
    client = hcsvlab.Client()
    item_list_name = str(request.json['item_list_name'])
    
    wordfrequency = word_frequency.get_word_frequency_table(client, item_list_name)
    #wordfrequency = wordfrequency[0:10]
    words = [word[0] for word in wordfrequency]
    word_dict = dict(wordfrequency)
    words =json.dumps(words)
    word_dict = json.dumps(word_dict)
    
    #print item_list_name
    #return { "list" : item_list_name}
    return {"words": words, "word_dict": word_dict}

@route("/timeline")
def index():
    client = hcsvlab.Client()
    the_list = word_frequency.get_word_frequency_per_year(client,'the', 'cooee list')
    an_list = word_frequency.get_word_frequency_per_year(client,'an', 'cooee list')
    a_list = word_frequency.get_word_frequency_per_year(client,'a', 'cooee list')
    file = open("./static/timeline.tsv", "w")
    file.write("date\tthe\tan\ta\n")

    for key in sorted(the_list):
        file.write(key + "\t" + str(the_list[key]) + "\t" + str(an_list[key]) + "\t" + str(a_list[key]) + "\n")

    file.close()

    return template('timeline')

if __name__ == "__main__":
    # start a server but have it reload any files that
    # are changed
    run(host="localhost", port=8010, reloader=True)

