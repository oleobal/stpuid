/++
 + Short & Trivial Practically Unique Identifier library
 +/
module stpuid;

import std.conv;
import std.string:toLower;
import std.algorithm.comparison;
import std.algorithm.mutation;
import std.algorithm.searching:canFind;
import std.math:pow;

import std.datetime:Duration;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import core.time;

import std.typecons:Nullable;
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


SysTime getDate(long epochMsTime, long msTime)
{
	immutable long total = epochMsTime+msTime;
	immutable long unixTime = total/1000;
	immutable long ms = total%1000;
	long stdTime = unixTimeToStdTime(unixTime);
	stdTime += ms*100_000; // add that number of hnsecs
	// FIXME doesnt' that depend on the SysTime implementation ?
	return SysTime(stdTime);
}

SysTime getDate(long epochMsTime, string slugOrId)
{
	return getDate(epochMsTime, getTimestamp(slugOrId));
}

Duration getTimeDelta(long msTime)
{
	return dur!"msecs"(msTime); // well that was fast. Thanks Phobos.
	// "Thank Phobos" does sound like something a cultist would say though.
}
Duration getTimeDelta(string slugOrId)
{
	return getTimeDelta(getTimestamp(slugOrId));
}


long getTimestamp(string slugOrId)
{
	auto slug = to!(char[])(slugOrId);
	if (slug.length == 12)
		slug = slug[0..8];
	else if (slug.length == 14 || slug.length == 9)
		slug = slug[0..4] ~ slug[5..9];
	
	if (slug.length == 8)
	{
		string allowedChars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		foreach(char c;slug)
			if (!canFind(allowedChars, c))
				throw new Exception("invalid slug or ID: "~slugOrId);
		
		slug = reverse(slug[0..6]) ~ slug[6..8];
		return to!long(slug, 36);
	}
	else
	{
		throw new Exception("invalid slug or ID: "~slugOrId);
	}
}
unittest
{
	import std.exception;
	string[] inputs = [
		`00000000`,
		`zzzzzzzz`,
		`1ftx91ts`,
		`1FTX91TS`,
		`hell-damn-oops`,
		`1234-5678-9abc`,
		`helldamnoops`,
		`123456789abc`
	];
	long[] results = [
		0,
		2821109907455,
		100000000000,
		100000000000,
		813245548991,
		481315894676,
		813245548991,
		481315894676,
	];
	assertThrown!Exception(getTimestamp(""));
	assertThrown!Exception(getTimestamp("short"));
	assertThrown!Exception(getTimestamp("andtoolong"));
	assertThrown!Exception(getTimestamp("thatsthirteen"));
	assertThrown!Exception(getTimestamp("andtherefifteen"));
	assertThrown!Exception(getTimestamp(";nval#id?"));
	
	for (auto i=0; i<inputs.length; i++)
	{
		assert(getTimestamp(inputs[i]) == results[i]);
	}
}



string getID(long epoch=978_307_200_000, bool addSeparator=false)
{
	immutable long time = getMilliseconds(Clock.currTime()) - epoch;
	string res = getDateSlug(time) ~ getRandomSuffix();
	if (addSeparator)
		res = res[0..4] ~"-"~ res[4..8] ~ "-" ~ res[8..$];
	return res;
}





// pretty annoying that I can't just do : Exception{} and get the constructors

/++
 + Signals an improperly-formatted ID
 +/
class FormatException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
/++
 + Signals an ID using an invalid epoch
 +/
abstract class EpochException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
/++
 + Signals that the given epoch is in the future
 +/
class FutureEpochException : EpochException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
/++
 + Signals that the given epoch is too far back the past,
 + which has a strong possibility of creating duplicate IDs
 + (epochs are valid for ~90 years)
 +/
class StaleEpochException : EpochException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}


/++
 + returns true, but throws FormatException if the ID is not properly formatted
 +
 + use the 2-parameter variant if you do have the epoch
 +/
bool validateID(string stpuid)
{
	char[] id = to!(char[])(stpuid);
	if (id.length == 14)
	{
		if (!(id[4] == '-' && id[9] == '-'))
			throw new FormatException("improper separators for a 14-chars ID");
		id = id[0..4] ~ id[5..9] ~ id[10..14];
	}
	
	if (id.length != 12)
		throw new FormatException("improper length");
	
	
	string allowedChars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	foreach(char c;id)
			if (!canFind(allowedChars, c))
				throw new FormatException("invalid character");
	
	
	return true;
}
unittest
{
	// TODO write tests
}

/++
 + checks whether an epoch is valid right now
 + throws:
 +  - FutureEpochException if the epoch is in the future
 +  - StaleEpochException if the epoch is too far in the past
 +/ 
bool validateEpoch(long epochMsTime)
{
	auto now = getMilliseconds(Clock.currTime);
	if (now < epochMsTime)
		throw new FutureEpochException("epoch is in the future");
	if (now - epochMsTime > pow(to!long(36),8))
		throw new StaleEpochException("epoch is too far in the past");

	return true;
}


/+
void main(string[] args)
{
	import std.stdio;
	writeln(getID());
}
+/

