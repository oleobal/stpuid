/++
 + Short & Trivial Practically Unique Identifier library
 +/
module stpuid;

import std.conv;
import std.string:toLower;
import std.algorithm.comparison;
import std.algorithm.mutation;
import std.math:pow;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import core.time;

import std.random;

string getDateSlug(long msTimestamp)
{
	char[] res = to!(char[])(toLower(to!(string)(msTimestamp, 36)));
	while (res.length < 8)
		res = "0"~res;
	res = res[0..8];
	reverse(res[0..6]);
	return to!string(res[0..6] ~ res[6..$]);
}

/++
 + returns four base 36 digits of randomness
 +/
string getRandomSuffix()
{
	auto digits="0123456789abcdefghijklmnopqrstuvwxyz";
	// sorry, I'm too stupid to get std.random.choice to work
	return to!string(digits[uniform(0,$)])
	      ~to!string(digits[uniform(0,$)])
	      ~to!string(digits[uniform(0,$)])
	      ~to!string(digits[uniform(0,$)]);
}


long getMilliseconds(SysTime time)
{
	return time.toUnixTime()*1000 + time.fracSecs.split!("msecs")().msecs;
}

long getMilliseconds(string time)
{
	return getMilliseconds(SysTime.fromISOExtString(time));
}


string getID(long epoch=978307200000, bool addSeparator=false)
{
	long time = getMilliseconds(Clock.currTime()) - epoch;
	string res = getDateSlug(time) ~ getRandomSuffix();
	if (addSeparator)
		res = res[0..4] ~"-"~ res[4..8] ~ "-" ~ res[8..$];
	return res;
}

/+
void main(string[] args)
{
	import std.stdio;
	writeln(getID());
}
+/

