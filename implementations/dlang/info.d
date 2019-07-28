/++
 + `info` analyses previously-produced STPUIDs
 +/
module info;

import stpuid;

import std.stdio;
import std.conv;
import core.time;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import std.algorithm.comparison;


string getHelpUsage()
{
	return "info <id> [epoch] [-h|--help] (for examining existing IDs)";
}

string getHelpText()
{
	return
`Short & Trivial Practically Unique Identifier analyser
Usage: stpuid `~info.getHelpUsage()~` 

Parameters:
    id: the STPUID to analyse. It can also be a date slug.
 epoch: The starting point for dating the STPUID. IDs are only comparable if
        their epoch is the same. Defaults to 2001-01-01T00:00:00Z.
Options:
 -h|--help     : This help`;
}

/++
 + assumed to be called from stpuid.d:main(...)
 +/
int handle(string[] args)
{
	bool epochIsDefault = true;
	long epoch=978307200000; // 2001-01-01T00:00:00Z

	if (args.length == 0)
	{
		writeln("Analyse already produced STPUIDs\nUsage: stpuid "~getHelpUsage());
		return 1;
	}
	
	foreach (string arg ; args)
	{
		if (arg.among!("-h", "--help"))
		{
			writeln(getHelpText());
			return 0;
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
	
	
	writeln("TODO add function call;");
	
	if (epochIsDefault)
		stderr.writeln("Warning: used 2001-01-01 as default epoch. -h for info");
	
	return 0;
}
