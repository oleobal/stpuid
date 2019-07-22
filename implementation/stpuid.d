import std.stdio;
import std.conv;
import std.string:toLower;
import std.algorithm.comparison;
import std.algorithm.mutation;
import std.math:pow;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import core.time;

import std.random;

string getDateStr(long msTimestamp)
{
	char[] res = to!(char[])(toLower(to!(string)(msTimestamp, 36)));
	while (res.length < 8)
		res = "0"~res;
	res = res[0..8];
	reverse(res[0..6]);
	return to!string(res[0..6] ~ res[6..$]);
}

/**
 * returns four base 36 digits of randomness
 */
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


string getID(long epoch=0, bool addSeparator=false)
{
	long time = getMilliseconds(Clock.currTime()) - epoch;
	string res = getDateStr(time) ~ getRandomSuffix();
	if (addSeparator)
		res = res[0..4] ~"-"~ res[4..8] ~ "-" ~ res[8..$];
	return res;
}




string getHelpText()
{
	return 
`Simple & Trivial Practically Unique Identifier generator
Usage: stpuid [epoch] [-s|--separator] [-h|--help]

Parameters:
 epoch: The starting point for dating the STPUID. IDs are only comparable if
        their epoch is the same, but STPUIDs are only valid for ~90 years,
        meaning default-epoch STPUIDs are only valid to the year ~2060.
        If [epoch] is a number, it is taken as a a number of milliseconds since
        . Else, it is parsed as an extended ISO date.
Options:
 -s|--separator: Add a dash (-) inbetween fields
 -h|--help     : This help

Return values on failure:
 1   Failed argument parsing
 100 Produced UUID is invalid`;
}

int main(string[] args)
{
	bool epochIsDefault = true;
	long epoch=0;
	bool addSeparator=false;
	
	args = args[1..$];
	
	
	foreach (string arg ; args)
	{
		if (arg.among!("-h", "--help"))
		{
			writeln(getHelpText());
			return 0;
		}
		
		if (arg.among!("-s", "--separator"))
		{
			addSeparator=true;
		}
		
		else // epoch
		{
			try
			{
				epoch = to!long(arg);
				epochIsDefault = false;
			}
			catch (ConvException e)
			{
				try
				{
					epoch = getMilliseconds(arg);
					epochIsDefault = false;
				}
				catch (DateTimeException e)
				{
					stderr.writeln("Unintelligible input: "~arg);
					return 1;
				}
			}
		}
	}
	
	
	writeln(getID(epoch, addSeparator));
	
	if (epochIsDefault)
		stderr.writeln("Warning: used 1970-01-01 as default epoch. -h for info");
	if (getMilliseconds(Clock.currTime) < epoch)
	{
		stderr.writeln("Warning: epoch is in the future (produced garbage UUID)");
		return 100;
	}
	
	if (getMilliseconds(Clock.currTime) - epoch > pow(to!long(36),8))
	{
		stderr.writeln("Warning: epoch is too far in the past\n(produced potentially duplicate UUID)");
		return 100;
	}
	
	return 0;
}