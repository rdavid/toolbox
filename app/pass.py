#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import base64
import click
import pyperclip
import pyotp
import os
import sys
from subprocess import Popen, PIPE
from configobj import ConfigObj

TOP = 'PARAMS'
CFG = sys.argv[1]

if __name__ == '__main__':
    if not os.path.isfile(CFG):
        print("Unable to find configuration file %s." % CFG)
        sys.exit(1)
    cfg = ConfigObj(CFG)
    fil = cfg[TOP]['shared']
    if not os.path.isfile(fil):
        print("Unable to find shared configuration file %s." % fil)
        sys.exit(1)
    shr = ConfigObj(fil)
    sec = cfg[TOP]['secret']
    pin = cfg[TOP]['pin']
    cnt = int(shr[TOP]['counter'])
    otp = pyotp.HOTP(sec)
    res = r"%s%s" % (pin, int(otp.at(cnt)))
    pyperclip.copy(res)
    if click.confirm('Do you want to increase the counter?', default=True):
        cnt += 1
        shr[TOP]['counter'] = cnt
        shr.write()
        print("The counter is set to %s." % str(cnt))
