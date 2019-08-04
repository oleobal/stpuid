/++
 + `ms` converts ISO dates into ms timestamps and vice versa
 +/

import stpuid;
import utils;

import std.stdio;
import std.conv;
import core.time;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import std.algorithm.comparison;

immutable string[] acceptableDateFormats = ["iso", "ms", "slug"];
enum DateFormat { iso, ms, slug };

string getHelpUsage()
{
	return "date <ISO date | msecs timestamp | date slug>\n        [-o output] [-e epoch] [-h|--help] (for converting dates)";
}

string getHelpText()
{
	return
`Short & Trivial Practically Unique Identifier date tool
Usage: stpuid `~getHelpUsage()~` 

Parameters:
 input: either:
   - an ISO 8601 date to be converted
   - a millisecond timestamp counting from the epoch
   - a STPUID date slug

Options:
 -o|--output : The output format. One of `~to!string(acceptableDateFormats)~`
               "iso" is the default, except if the input is iso, in which case
               the default is "ms"
 -e|--epoch  : Use the given epoch instead of 1970-01-01T00:00:00.000Z
               can be either ISO or milliseconds since the default epoch
 -h|--help   : This help`;
}


/++
 + assumed to be called from stpuid.d:main(...)
 +/
int handle(string[] args)
{
	string input = "";
	long inputMs = 0;
	long epoch=0; 
	DateFormat inType;
	DateFormat outType = DateFormat.iso;

	if (args.length == 0)
	{
		writeln("Convert between date formats\nUsage: stpuid "~getHelpUsage());
		return 1;
	}
	
	string arg;
	for (int i=0; i<args.length; i++)
	{
		arg = args[i];
		if (arg.among!("-h", "--help"))
		{
			writeln(getHelpText());
			return 0;
		}
		
		else if (arg.among!("-o", "--output"))
		{
			string outf = args[i+1];
			
			if (args[i+1] == "iso")
				outType = DateFormat.iso;
			else if (args[i+1] == "ms")
				outType = DateFormat.ms;
			else if (args[i+1] == "slug")
				outType = DateFormat.slug;
			else
			{
				stderr.writeln("Output date format must be one of ", acceptableDateFormats);
				return 1;
			}
			i++;
		}
		
		else if (arg.among!("-e", "--epoch"))
		{
			try
			{
				epoch = to!long(args[i+1]);
			}
			catch (ConvException e)
			{
				try
				{
					epoch = getMilliseconds(args[i+1]);
				}
				catch (DateTimeException e)
				{
					stderr.writeln("Unintelligible input: "~args[i+1]);
					return 1;
				}
			}
			i++;
		}
		

		else // input
		{
			input = arg;
			inType = DateFormat.iso;
			
			if (input.length == 8 || input.length == 9)
				inType = DateFormat.slug;
			
			try
			{
				inputMs = to!long(input);
				inType = DateFormat.ms;
			}
			catch (ConvException e)
			{
				if (inType == DateFormat.iso)
				{
					inputMs = getMilliseconds(arg);
					outType = DateFormat.ms;
				}
				else if (inType == DateFormat.slug)
					inputMs = getTimestamp(input);
			}
		}
	}
	
	
	final switch (outType)
	{
		case DateFormat.iso:
			writeln(getDate(epoch, inputMs).toISOExtString());
		break;
		case DateFormat.ms:
			writeln(inputMs-epoch);
		break;
		case DateFormat.slug:
			writeln(getDateSlug(inputMs-epoch));
		break;
	}
	
	
	return 0;
}
