
import jieba

# 从 dump.txt 中读取信息，进行分词处理


def read_lines():
    # define an empty list
    lines = []

    # open file and read the content in a list
    with open('dump.txt', 'r') as f:
        for line in f:
            if (len(line.strip()) == 0):
                continue

            # add item to the list
            lines.append(line)

    print('read complete. {} lines'.format(len(lines)))
    return lines


def split_words(lines):
    words_list = []

    for line in lines:
        words = jieba.lcut(line, cut_all=False)
        words_list = words_list + words

    # 对词进行过滤
    ignores = load_ignores()
    remains = [w for w in words_list if w not in ignores]

    remains = [w for w in remains if len(w.strip()) > 1]
    remains = [w for w in remains if not is_number(w)]

    myset = set(remains)
    count_list = [
        {'name': item, 'count': remains.count(item)} for item in myset]

    sorted_list = sorted(count_list, key=lambda x: x['count'], reverse=True)

    return sorted_list


def load_ignores():
    # define an empty list
    lines = []

    # open file and read the content in a list
    with open('ignores.txt', 'r') as f:
        for line in f:
            # add item to the list
            lines.append(line)

    lines = [l.strip('\n') for l in lines]

    print('read ignores. {} lines'.format(len(lines)))
    return set(lines)


def is_number(n):
    is_number = True
    try:
        num = float(n)
        # check for "nan" floats
        is_number = num == num   # or use `math.isnan(num)`
    except ValueError:
        is_number = False
    return is_number


def parse_all():
    lines = read_lines()
    return split_words(lines)


if __name__ == "__main__":
    # parse_all()
    # print('done.')

    ignores = load_ignores()
    print(ignores)

    w = '重庆'
    b = w not in ignores
    print(b)
