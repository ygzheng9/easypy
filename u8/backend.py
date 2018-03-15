import pyodbc
import textwrap
import copy
import xlsxwriter
import json

import dbAccess

from flask import Flask
app = Flask(__name__)

# FLASK_DEBUG=1
# FLASK_APP=hello.py


@app.route("/")
def hello():
    return "Hello World! chagned"


@app.route("/invInfos")
def getInvInfos():
    cursor = dbAccess.setupDB()
    data = dbAccess.getInvInfo(cursor)

    return 'json.dumps(data)'