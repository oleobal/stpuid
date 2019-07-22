#!/usr/bin/env python3
"""
python 3 implementation
"""
from datetime import datetime
from typing import *
from functools import singledispatch
import random



def base36(inp : int) -> str:
	digits="0123456789abcdefghijklmnopqrstuvwxyz"
	return ((inp == 0) and digits[0]) or (base36(inp // 36).lstrip(digits[0]) + digits[inp % 36])

def getDateStr(msTimestamp: int) -> str:
	res = base36(msTimestamp)
	while len(res) < 8:
		res = "0"+res
	res=res[:8]
	
	return res[:6][::-1] + res[6:]

@singledispatch
def getMilliseconds(isotime: datetime) -> int :
	return 0

@getMilliseconds.register(str)
def _(isotime) -> int :
	epoch = datetime.fromisoformat(isotime)
	return getMilliseconds(epoch)

@getMilliseconds.register(datetime)
def _(isotime) -> int :
	return int(isotime.timestamp()) * 1000 + (isotime.microsecond//1000)

def getRandomSuffix():
	digits="0123456789abcdefghijklmnopqrstuvwxyz"
	try:
		r = random.SystemRandom()
		return r.choice(digits)+r.choice(digits)+r.choice(digits)+r.choice(digits)
	except NotImplementedError as e:
		# FIXME
		raise e

def getID(epoch=0, addSeparator=False):	
	"""
	Default epoch on 1970-01-01 leaves only half the date range for
	use by the program
	"""
	time = getMilliseconds(datetime.now()) - epoch
	res = getDateStr(time)+getRandomSuffix()
	if addSeparator:
		res = res[:4]+"-"+res[4:8]+"-"+res[8:]
	return res
	

# demo
if __name__ == "__main__":
	print(getID(0))
