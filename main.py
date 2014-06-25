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
    return template("index")

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

@route("/heatmap", method="GET")
@route("/heatmap", method="POST")
def index():
    client = hcsvlab.Client()
    
    words = request.forms.getall("words[]")
    item_list_name = request.forms.get("item_list_name")

    if words and item_list_name:
        [row_words, col_words] = word_frequency.get_collocation_frequency(client, item_list_name, words)
    else:
        [row_words, col_words] = word_frequency.get_collocation_frequency(client, item_list_name)

    row_words= json.dumps(row_words)
    col_words = json.dumps(col_words)
    print row_words
    
    return template('heatmap', 
                    row_words = row_words, 
                    col_words = col_words, 
                    personal_item_list = get_personal_item_lists(client)

                    )


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

@route("/timeline", method="POST")
@route("/timeline", method="GET")
def index():
    client = hcsvlab.Client()

    words = request.forms.getall("words[]")
    item_list_name = request.forms.get("item_list_name")

    word_list = []
    file = open("./static/timeline.tsv", "w")
    file.write("date")
    for word in words:
        file.write("\t" + word)    
        word_list.append(word_frequency.get_word_frequency_per_year(client, word, item_list_name))
    
    #an_list = word_frequency.get_word_frequency_per_year(client,'an', 'cooee list')
    #a_list = word_frequency.get_word_frequency_per_year(client,'a', 'cooee list')
    file.write("\n")

    if not word_list:
        return template('timeline', rows=[], personal_item_list = get_personal_item_lists(client))

    for key in sorted(word_list[0]):
        file.write(key);
        for i in range(len(word_list)):
            file.write("\t" + str(word_list[i][key]))
        file.write("\n")

    file.close()

    file = open("./static/timeline.tsv", "r")
    content = file.read()

    rows = content.split("\n")[:-1]
    

    file.close()
    
    print words
    return template('timeline', rows=rows, personal_item_list = get_personal_item_lists(client))

if __name__ == "__main__":
    # start a server but have it reload any files that
    # are changed
    run(host="localhost", port=8020, reloader=True)

