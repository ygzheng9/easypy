#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from random import randrange

from flask import Flask, render_template

from pyecharts import options as opts
from pyecharts.charts import Bar

from jinja2 import Markup, Environment, FileSystemLoader

from pyecharts.globals import CurrentConfig
# 关于 CurrentConfig，可参考 [基本使用-全局变量]
CurrentConfig.GLOBAL_ENV = Environment(loader=FileSystemLoader("./templates"))

app = Flask(__name__)


def bar_base():
    c = (
        Bar()
        .add_xaxis(["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"])
        .add_yaxis("商家A", [randrange(0, 100) for _ in range(6)])
        .add_yaxis("商家B", [randrange(0, 100) for _ in range(6)])
        .set_global_opts(title_opts=opts.TitleOpts(title="Bar-基本示例", subtitle="我是副标题"))
    )
    return c


@app.route("/simple")
def simple():
    c = bar_base()
    return Markup(c.render_embed())


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/barChart")
def get_bar_chart():
    c = bar_base()
    return c.dump_options_with_quotes()


if __name__ == "__main__":
    app.run()
