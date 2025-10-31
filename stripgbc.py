import sys

out = open(sys.argv[2], 'wb')
buf = bytes()
with open(sys.argv[1], 'rb') as f:
    f.read(256) # skip to $0100
    rest = f.read()
    out.write(rest)
