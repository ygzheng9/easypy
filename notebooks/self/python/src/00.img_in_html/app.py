from io import BytesIO
from flask import Flask, render_template, send_file, make_response
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
plt.style.use('ggplot')


app = Flask(__name__)


@app.route('/donut_pie_chart/')
def donut_pie_chart():
    courses = 'Computer Science', 'Statisics', 'Physics', 'Economics', 'Calculus'
    students = [48, 43, 37, 83, 45]
    pie_color = ("red", "green", "orange", "cyan", "blue")
    explode = (0.05, 0.05, 0.05, 0.05, 0.05)
    fig, ax = plt.subplots()
    ax.pie(students, colors=pie_color, labels=courses, autopct='%1.1f%%',
           startangle=90, pctdistance=0.85, explode=explode)
    inner_circle = plt.Circle((0, 0), 0.70, fc='white')
    fig = plt.gcf()
    fig.gca().add_artist(inner_circle)
    ax.axis('equal')
    ax.set_title("Course Attendance\n", fontsize=24)
    plt.tight_layout()
    canvas = FigureCanvas(fig)
    img = BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='image/png')


@app.route('/bar_graph/')
def bar_graph():
    motality = [1000000, 800000, 300000, 2000000]
    year = ['2014', '2015', '2016', '2017']
    fig, ax = plt.subplots()
    labels = np.array(year)
    y_pos = np.arange(len(labels))
    x_pos = np.array(motality)
    ax.bar(y_pos, motality, color=['r', 'g', 'y',
                                   'b'], align='center', edgecolor='green')
    plt.xticks(y_pos, labels)
    plt.ylabel('Population', fontsize=20)
    plt.xlabel('Year', fontsize=20)
    ax.set_title('Motality rate', fontsize=24)
    canvas = FigureCanvas(fig)
    img = BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='image/png')


@app.route('/tri_surface_graph/')
def tri_surface_graph():
    n_angles = 36
    n_radii = 8
    radii = np.linspace(0.125, 1.0, n_radii)
    angles = np.linspace(0, 2*np.pi, n_angles, endpoint=False)
    angles = np.repeat(angles[..., np.newaxis], n_radii, axis=1)
    x = np.append(0, (radii*np.cos(angles)).flatten())
    y = np.append(0, (radii*np.sin(angles)).flatten())
    z = np.sin(-x*y)
    fig = plt.figure(figsize=(9, 6))
    ax = fig.gca(projection='3d')
    ax.plot_trisurf(x, y, z, color='blue', linewidth=0.2)
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    canvas = FigureCanvas(fig)
    img = BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='image/png')


@app.route('/data_frame_visualization/')
def data_frame_visualization():
    fig, ax = plt.subplots()
    df = pd.read_csv(
        "https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master/csv/quantreg/gasprice.csv")
    time = df['time']
    gasprice = df['value']
    plt.plot(time, gasprice, color='orange')
    plt.xlabel("Time (Year)")
    plt.ylabel("Gas Price")
    plt.title("Time Series of US Gasoline Prices ")
    canvas = FigureCanvas(fig)
    img = BytesIO()
    fig.savefig(img)
    img.seek(0)
    return send_file(img, mimetype='image/png')


@app.route('/')
def index():
    return render_template("index.html")


@app.route('/analysis')
def analysis():
    return render_template("analysis.html")


@app.route('/data_frame_analysis')
def data_frame_analysis():
    return render_template("data_frame_analysis.html")


if __name__ == '__main__':
    app.run(debug=True)
