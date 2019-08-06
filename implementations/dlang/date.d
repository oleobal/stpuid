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
	return "date <ISO date | msecs timestamp | date slug | STPUID>\n        [-o output] [-e epoch] [-h|--help] (for converting dates)";
}

string getHelpText()
{
	string[string] options = [
		"-o|--output": `The output format. One of `~to!string(acceptableDateFormats)~`; "iso" is the default, except if the input is iso, in which case the default is "ms"`,
		"-e|--epoch": "Use the given epoch instead of 1970-01-01T00:00:00.000Z; can be either ISO or milliseconds since the default epoch",
		"-eo|--epoch-out": "Use the given epoch for outputting the result; same format as --epoch; it defaults to 0, except if the output is ISO, in which case it defaults to the given epoch",
		"-h|--help": "This help",
	];
	
	return
`Short & Trivial Practically Unique Identifier date tool
Usage: stpuid `~getHelpUsage()~` 

Parameters:
 input: either:
   - an ISO 8601 date to be converted
   - a millisecond timestamp counting from the epoch
   - a STPUID date slug

Options:
`~getFormattedOptions(options);
}


/++
 + assumed to be called from stpuid.d:main(...)
 +/
int handle(string[] args)
{
	string input = "";
	long inputMs = 0;
	long epoch=0; 
	long epochOut=0; 
	bool epochOutIsDefault=true;
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
		else if (arg.among!("-eo", "--epoch-out"))
		{
			try
			{
				epochOut = to!long(args[i+1]);
			}
			catch (ConvException e)
			{
				try
				{
					epochOut = getMilliseconds(args[i+1]);
				}
				catch (DateTimeException e)
				{
					stderr.writeln("Unintelligible input: "~args[i+1]);
					return 1;
				}
			}
			epochOutIsDefault=false;
			i++;
		}
		

		else // input
		{
			input = arg;
			inType = DateFormat.iso;
			
			if (input.length == 8 || input.length == 9)
				inType = DateFormat.slug;
				
			if (input.length == 12)
			{
				input = arg[0..8];
				inType = DateFormat.slug;
			}
			if (input.length == 14)
			{
				input = arg[0..9];
				inType = DateFormat.slug;
			}
			
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
			if (epochOutIsDefault)
				epochOut = epoch;
			writeln(getDate(epochOut, inputMs).toISOExtString());
		break;
		case DateFormat.ms:
			writeln(inputMs-epochOut);
		break;
		case DateFormat.slug:
			writeln(getDateSlug(inputMs-epochOut));
		break;
	}
	
	
	return 0;
}
