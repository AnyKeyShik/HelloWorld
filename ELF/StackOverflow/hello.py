# python3 hello.py

import os
import stat

f = open('hello', 'wb')

ar = "7F 45 4C 46 01 01 01 00 00 00 00 00 00 00 00 00 02 00 03 00 01 00 00 00 54 80 04 08 34 00 00 00 00 00 00 00 00 00 00 00 34 00 20 00 01 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 80 04 08 00 80 04 08 74 00 00 00 74 00 00 00 05 00 00 00 00 10 00 00 B0 04 31 DB 43 B9 69 80 04 08 31 D2 B2 0C CD 80 31 C0 40 CD 80 48 65 6C 6C 6F 20 77 6F 72 6C 64 0A".split(' ')

f.write(bytearray(int(i, 16) for i in ar))
f.close()

st = os.stat('hello')
os.chmod('hello', st.st_mode | stat.S_IEXEC)
