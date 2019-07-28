/++
 + The text user interface (for command line use)
 +/
import stpuid;
static import info;

import std.stdio;
import std.conv;
import core.time;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import std.algorithm.comparison;
import std.math:pow;

string getHelpText()
{
	return 
`Short & Trivial Practically Unique Identifier generator
Usage: stpuid [epoch] [-s|--separator] [-h|--help]
       stpuid `~info.getHelpUsage()~` 

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

	
	args = args[1..$];
	

	if (args.length > 0 && args[0] == "info")
	{
		return info.handle(args[1..$]);
	}
	
	else
	{
		return handle(args);
	}
	
	return 0;
}


int handle(string[] args)
{
	bool epochIsDefault = true;
	long epoch=978307200000; // 2001-01-01T00:00:00Z
	bool addSeparator=false;
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
		stderr.writeln("Warning: used 2001-01-01 as default epoch. -h for info");
	if (getMilliseconds(Clock.currTime) < epoch)
	{
		stderr.writeln("Warning: epoch is in the future (produced garbage ID)");
		return 100;
	}
	
	if (getMilliseconds(Clock.currTime) - epoch > pow(to!long(36),8))
	{
		stderr.writeln("Warning: epoch is too far in the past\n(produced potentially duplicate ID)");
		return 100;
	}
	return 0;
}
