
from pyecharts import options as opts
from pyecharts.charts import WordCloud

from parsetext import read_lines, split_words


def wordcloud_base(words_list):
    words = [(elem['name'], elem['count']) for elem in words_list]

    c = (
        WordCloud()
        .add('', words, word_size_range=[10, 1000])
        .set_global_opts(title_opts=opts.TitleOpts(title='关键字分析'))
    )
    return c


if __name__ == "__main__":
    lines = read_lines()

    words_list = split_words(lines)

    t = wordcloud_base(words_list)

    t.render()

    print('done.')
