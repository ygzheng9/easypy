from flask import Flask, render_template
from flask.json import jsonify

from parsetext import parse_all

app = Flask(__name__)


@app.route("/word")
def index():
    return render_template('wordcloud.html')


@app.route("/api/data/words")
def words_count():
    return jsonify(parse_all())

    # dummy = [{'name': '哈哈', 'count': 30},
    #          {'name': '我们', 'count': 20},
    #          {'name': '你说', 'count': 10},
    #          {'name': '不知道', 'count': 20},
    #          ]
    # return jsonify(dummy)


if __name__ == "__main__":
    app.run()
