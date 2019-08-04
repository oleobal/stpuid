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
        their epoch is the same.
Options:
 -h|--help     : This help`;
}

string getApproximateHumanDuration(Duration d)
{
	long days;
	int hours;
	int minutes;
	int seconds;
	
	d.split!("days", "hours", "minutes", "seconds")(days, hours, minutes, seconds);
	
	if (days > 730)
	{
		auto years = 0;
		auto months = 0;
		while (days > 365)
		{
			years++;
			days-=365;
		}
		while (days > 30)
		{
			months++;
			days-=30;
		}
		if (days>=15)
			months++;
		string result = to!string(years)~" years";
		if (months>0)
			result~=", "~to!string(months)~" months";
		return result;
	}
	
	if (days == 1)
	{
		days = 0;
		hours+=24;
	}
	if (days == 0)
	{
		if (hours==1)
		{
			hours= 0;
			minutes+=60;
		}
		if (hours == 0)
		{
			if (minutes == 1)
			{
				minutes = 0;
				seconds+=60;
			}
		}
	}
	string result = "";
	if (days != 0)
		result ~= to!string(days)~" days";
	if (hours != 0)
	{
		if (result.length != 0)
			result~=", ";
		result ~= to!string(hours)~" hours";
	}
	if (minutes != 0)
	{
		if (result.length != 0)
			result~=", ";
		result ~= to!string(minutes)~" minutes";
	}
	if (seconds != 0)
	{
		if (result.length != 0)
			result~=", ";
		result ~= to!string(seconds)~" seconds";
	}
	if (result.length == 0)
		result = "just an instant";
	return result;
}


/++
 + assumed to be called from stpuid.d:main(...)
 +/
int handle(string[] args)
{
	string id="";
	bool epochIsDefault = true;
	long epoch=978_307_200_000; // 2001-01-01T00:00:00Z

	if (args.length == 0)
	{
		writeln("Validate and get info on already produced STPUIDs\nUsage: stpuid "~getHelpUsage());
		return 1;
	}
	
	foreach (string arg ; args)
	{
		if (arg.among!("-h", "--help"))
		{
			writeln(getHelpText());
			return 0;
		}
		

		else // id or epoch
		{
			if (id == "") // id
			{
				id = arg;
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
	}
	
	
	if (id.length > 9 || id.length < 8) // ie not a date slug
	{
		try
		{
			validateID(id);
		}
		catch (Exception e)
		{
			writeln("Invalid ID: "~e.msg);
			return 100;
		}
	}
	auto ts = getTimestamp(id);
	auto d = getTimeDelta(ts);
	
	writeln("Timestamp: ",ts," (approx. ",getApproximateHumanDuration(d),")");
	
	
	if (!epochIsDefault)
	{
		auto date = getDate(epoch, ts);
		writeln("Created: ", date.toISOExtString(),
		//" (Timestamp: ",getMilliseconds(date),")",
		" (approx. ", getApproximateHumanDuration(Clock.currTime()-date), " ago)");
	}
	
	return 0;
}
