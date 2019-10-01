import os


def print_files(path):
    lsdir = os.listdir(path)
    dirs = [i for i in lsdir if os.path.isdir(os.path.join(path, i))]
    if dirs:
        for i in dirs:
            print_files(os.path.join(path, i))
    files = [i for i in lsdir if os.path.isfile(os.path.join(path, i))]
    for f in files:
        print(os.path.join(path, f))


print_files("..")
