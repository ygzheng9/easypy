from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import LinearRegression
import pandas as pd


def linearReg():
    """
    预测具体的分数
    """
    # import dataset
    data = pd.read_csv('quiz.csv', delimiter=",")

    # 注意：csv 的表头中的 空格
    used_features = ["LastScore", "Hours"]
    target = "Score"

    x = data[used_features].values
    scores = data[target].values

    x_train = x[:11]
    x_test = x[11:]

    y_train = scores[:11]
    y_test = scores[11:]

    regr = LinearRegression()
    regr.fit(x_train, y_train)
    y_predict = regr.predict(x_test)

    print(y_predict)


def logisticReg():
    """
    预测：能不能通过考试 1/0
    """
    # import dataset
    data = pd.read_csv('quiz.csv', delimiter=",")

    # 注意：csv 的表头中的 空格
    used_features = ["LastScore", "Hours"]
    target = "Score"

    x = data[used_features].values
    scores = data[target].values

    x_train = x[:11]
    x_test = x[11:]

    # 逻辑回归，只需要两个状态
    passed = [1 if s >= 60 else 0 for s in scores]

    y_train = passed[:11]
    # y_test = passed[11:]

    classifier = LogisticRegression(C=1e5)
    classifier.fit(x_train, y_train)

    y_predict = classifier.predict(x_test)
    print(y_predict)


def logisticReg2():
    """
    多个状态预测：不及格，及格，优秀
    """
    # import dataset
    data = pd.read_csv('quiz.csv', delimiter=",")

    # 注意：csv 的表头中的 空格
    used_features = ["LastScore", "Hours"]
    target = "Score"

    x = data[used_features].values
    scores = data[target].values

    x_train = x[:11]
    x_test = x[11:]

    # 逻辑回归，状态有 三个值
    passed = [2 if s >= 85 else 1 if s >= 60 else 0 for s in scores]

    y_train = passed[:11]
    # y_test = passed[11:]

    classifier = LogisticRegression(C=1e5)
    classifier.fit(x_train, y_train)

    y_predict = classifier.predict(x_test)
    print(y_predict)
