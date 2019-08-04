/++
 + various utilities
 +/
import std.conv;
import core.time;
import std.datetime.systime;
import std.datetime.date:DateTimeException;

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
