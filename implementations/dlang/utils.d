/++
 + various utilities
 +/
import std.conv;
import core.time;
import std.datetime.systime;
import std.datetime.date:DateTimeException;
import std.typecons:tuple, Tuple;

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
 + formats option explanations, for help messages
 +/
string getFormattedOptions(string[string] options, uint lineLength=80)
{
	uint maxKeyLength = 0;
	foreach (string k;options.keys)
		if (k.length > maxKeyLength)
			maxKeyLength = to!(uint)(k.length);
	
	maxKeyLength+=2+1+1; // 2 padding left, 1 colon, 1 padding right
	int textLength = lineLength - maxKeyLength;
	string output="";
	
	if (textLength < 40) // separate lines
	{
		textLength = lineLength-2;
		string padding = "  ";
		// TODO
	}
	else
	{
		string padding = "";
		for (int i=0; i<maxKeyLength;i++) // there's probably a better way..
			padding~=" "; //.. but it's not under "12.9 Array operations"
		foreach(string k, v; options)
		{
			auto lines = getLineBrokenText(v, textLength);
			if (lines.length > 0)
			{
				string firstPadding = "";
				for (int i=0; i<maxKeyLength-2-1-1-k.length;i++) //ok, getting stpuid
					firstPadding~=" ";
				
				output~="  "~k~firstPadding~": "~lines[0]~"\n";
				foreach (string t; lines[1..$])
				{
					output~=padding~t~"\n";
				}
			}
			else
				output~="  "~k~": ?\n";
		}
	}
	return output;
}


string[] getLineBrokenText(string text, uint lineLength)
{
	alias Word = Tuple!(string, "text", bool, "isWhitespace");
	
	string addUpLine(ref Word[] line, uint lineLength, bool manualLineFeed)
	{
		// add up line, break if necessary
		auto total = 0;
		auto nbWords = 0;
		foreach(Word word; line)
		{
			if (total + word.text.length < lineLength)
			{
				total+= word.text.length;
				nbWords+=1;
			}
			// TODO special case words with length>lineLength
		}
		string finishedLine = "";
		for (int j=0; j<nbWords; j++)
		{
			if (finishedLine.length > 0 || manualLineFeed  || !line[j].isWhitespace)
				finishedLine~=line[j].text;
			// TODO handle whitespace better
		}
		line = line[nbWords..$];
		return finishedLine;
	}
	
	
	string[] output = [];
	Word[] lineBuf = [];
	
	for (uint i=0; i< text.length; i++)
	{
		if (text[i] == ' ' || text[i] == '\t')
		{
			if (lineBuf.length == 0 || !lineBuf[$-1].isWhitespace)
			{
				lineBuf~=Word("", true);
			}
			lineBuf[$-1].text~=text[i]; 
		}
		else if (text[i] != '\n')
		{
			if (lineBuf.length == 0 || lineBuf[$-1].isWhitespace)
			{
				lineBuf~=Word("", false);
			}
			lineBuf[$-1].text~=text[i]; 
		}
		else
		{
			output ~= addUpLine(lineBuf, lineLength, true);
		}
	}
	
	while(lineBuf.length > 0)
		output ~= addUpLine(lineBuf, lineLength, false);
	
	
	return output;
}