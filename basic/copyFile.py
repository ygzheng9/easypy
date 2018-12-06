inFile = "1.pdf"
outFile = "2.pdf"

with open(inFile, 'rb') as f:
    with open(outFile, 'wb') as w:
        for line in f.readlines():
            w.write(line)

print('done.')