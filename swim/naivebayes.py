# Author: Krishnamurthy Koduvayur Viswanathan

# https://ebiquity.umbc.edu/blogger/2010/12/07/naive-bayes-classifier-in-50-lines/

# from __future__ import division
import collections
import math


class Model:
    def __init__(self, arffFile):
        self.trainingFile = arffFile

        # 训练集中的每一个记录
        self.featureVectors = []  # contains all the values and the label as the last entry

        # all feature names and their possible values (including the class label)
        # 特性清单
        self.featureNameList = []  # this is to maintain the order of features as in the arff
        # 每个特性的特性值，key=特性名称，value=该特性的特性值列表
        self.features = {}

        # contains tuples of the form: key = (label, feature_name, feature_value), value: 出现的次数
        # 训练集中，(最终分类，特性名，特性值) 对应的数量
        # 如果在训练集中没出现，则默认为 1；这是平滑算法；
        self.featureCounts = collections.defaultdict(lambda: 1)

        # 训练集中，每个分类的总数量；
        self.labelCounts = collections.defaultdict(
            lambda: 0)  # these will be smoothed later

    def GetValues(self):
        """
        解析输入文件，特性清单，每个特性的可能值清单，每条数据
        """
        file = open(self.trainingFile, 'r')
        for line in file:
            if line[0] != '@':  # start of actual data
                self.featureVectors.append(line.strip().lower().split(','))
            else:  # feature definitions
                if line.strip().lower().find('@data') == -1 and (not line.lower().startswith('@relation')):
                    # line: @ATTRIBUTE outlook {sunny, overcast, rain}
                    feaName = line.strip().split()[1]
                    self.featureNameList.append(feaName)

                    allValStr = line[line.find('{')+1: line.find('}')]
                    self.features[feaName] = allValStr.strip().split(',')
        file.close()

    def TrainClassifier(self):
        """
        训练模型：也即：统计训练集中的个数：
        1. 每一类的总个数，需要平滑处理，也即：都同样加上所有特性的特性值个数；
        2. 每个 特性值，在每一类下出现的个数；
        """
        for fv in self.featureVectors:
            # fv: Sunny,Hot,High,Weak,No
            # 最后一列是 class
            classType = fv[-1]

            # 这一类的总数
            self.labelCounts[classType] += 1  # udpate count of the label

            # 这一类，特性，特性值
            for counter in range(0, len(fv)-1):
                self.featureCounts[(
                    classType, self.featureNameList[counter], fv[counter])] += 1

        # increase label counts (smoothing). remember that the last feature is actually the label
        # 平滑：
        # 方法0：只要加 1 ；但是，从结果来看，即使是训练集，不对的比例也高30%，所以 加1 不合适；
        # smoothingAddon = 1

        # 方法1：因为最后是比较相对大小，所以这里可以直接使用 所有特性的特性值个数，包括最终分类的；
        # featureValueCounts = [len(self.features[key]) for key in self.features]
        # smoothingAddon = sum(featureValueCounts)

        # 方法2
        # labelCounts 是每一类的个数，在平滑算法中，需要加上 各个feature 的可能值的个数；这个数对所有分类都是一样的；
        # 各个feature的可能值，在 features 中; featurelist 的最后一个是 分类（arff文件的格式要求）
        smoothingAddon = 0
        for feature in self.featureNameList[:-1]:
            smoothingAddon += len(self.features[feature])

        for label in self.labelCounts:
            self.labelCounts[label] += smoothingAddon

    # featureVector is a simple list like the ones that we use to train
    def Classify(self, featureVector):
        """
        取出每个特性值，在每个分类下的概率（条件概率），做连乘，再乘上这个分类的全概率，取大的分类；

        """
        probabilityPerLabel = {}
        for label in self.labelCounts:
            logProb = 0
            # label 是分类，在训练集中，该分类的总数
            labelCount = self.labelCounts[label]

            #  计算：每个特性值，在每个分类下的条件概率
            for idx, featureValue in enumerate(featureVector):
                #  取得 特性名，因为训练集处理后的 key=(类型，特性名，特性值)
                featureName = self.featureNameList[idx]

                # 把连乘转换成 log 的连加
                # 分子：这个特性出现的次数；分母：这个分类的次数；商：条件概率
                logProb += math.log(self.featureCounts[(
                    label, featureName, featureValue)]/labelCount)

            # 计算：这一类的全概率；
            # 分子：这一类的个数；分母：所有类的总个数，也即全集个数；
            # sum(self.labelCounts.values()) 对所有 label 都一样，所以在比大小时，可以忽略
            labelProb = labelCount / sum(self.labelCounts.values())

            # 计算：每一类全概率 * 每一特性的在这类下的条件概率
            # 方法1：
            # probabilityPerLabel[label] = labelProb * math.exp(logProb)

            # 方法2：直接用 log 比大小即可，不需要再转换回去；
            probabilityPerLabel[label] = math.log(labelProb) + logProb

        print(probabilityPerLabel)
        return max(probabilityPerLabel, key=lambda classLabel: probabilityPerLabel[classLabel])

    def TestClassifier(self, arffFile):
        file = open(arffFile, 'r')
        for line in file:
            if line[0] != '@':
                vector = line.strip().lower().split(',')
                print("classifier: " + self.Classify(vector) +
                      " given " + vector[-1])


if __name__ == "__main__":
    model = Model("./tennis.arff")
    model.GetValues()
    model.TrainClassifier()
    model.TestClassifier("./tennis.arff")
