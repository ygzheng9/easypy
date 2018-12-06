# -*- coding: utf-8 -*-
import numpy as np
import codecs


def parseFile():
    # Trump's speeches here: https://github.com/ryanmcdermott/trump-speeches
    trump = codecs.open('speeches.txt', 'r', encoding='utf8').read()
    corpus = trump.split()
    return corpus


def make_pairs(words):
    '''
    相邻的两个词，组成一个 pair
    '''
    for i in range(len(words)-1):
        yield (words[i], words[i+1])


def buildDict(words):
    pairs = make_pairs(words)
    word_dict = {}

    # key 是 第一个词，value 是一个 list，里面是 第一个词 所有的 后一个词；
    for word_1, word_2 in pairs:
        if word_1 in word_dict.keys():
            word_dict[word_1].append(word_2)
        else:
            word_dict[word_1] = [word_2]

    return word_dict


def mocks(allWords, dicts):
    first_word = np.random.choice(allWords)

    # 开头词要一个大写的，全小写的不行
    while first_word.islower():
        first_word = np.random.choice(allWords)

    chain = [first_word]

    n_words = 50

    # 随机从后一个词列表中，取一个
    for _ in range(n_words):
        chain.append(np.random.choice(dicts[chain[-1]]))

    return ' '.join(chain)


corpus = parseFile()
word_dict = buildDict(corpus)
message = mocks(corpus, word_dict)

print(message)
