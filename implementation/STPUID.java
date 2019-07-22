import java.util.Random;
import java.util.Date;
import java.text.DateFormat;
import java.text.ParseException;

/**
 * Short & Trivial Practically Unique Identifier
 *
 * Good for low-requirements uses (less than one naming
 * per second, typically, across a system with consistent
 * time) where human readability is important
 *
 * Use STPUID.getID
 */
public class STPUID
{
	// all caps to respect the convention set by java.util.UUID
	
	
	public static String getDateStr(long msTimestamp)
	{
		String res = Long.toString(msTimestamp, 36);
		
		while (res.length() < 8)
			res = "0"+res;
		res=res.substring(0,8);
		
		return new StringBuilder(res.substring(0,6)).reverse().toString() + res.substring(6);
	}

	public static String getRandomSuffix()
	{
		String digits="0123456789abcdefghijklmnopqrstuvwxyz";
		Random r = new Random();
		return ""
		      +digits.charAt(r.nextInt(digits.length()))
		      +digits.charAt(r.nextInt(digits.length()))
		      +digits.charAt(r.nextInt(digits.length()))
		      +digits.charAt(r.nextInt(digits.length()));
	}
	
	public static long getMilliseconds(Date date)
	{
		return date.getTime(); // defined by standard to be milliseconds
	}
	public static long getMilliseconds(String date) throws ParseException
	{
		DateFormat df = DateFormat.getDateInstance();
		return getMilliseconds(df.parse(date));
	}

	/**
	 * get a STPUID
	 * epoch: the starting point for this ID, in milliseconds since
	 *        1970-01-01T00:00:00.000Z
	 *        Keep it consistent across your IDs !
	 *        Should be in milliseconds, you can use STPUID.getMilliseconds(..)
	 *        to get one.
	 *
	 * addSeparator: Add dashes (-) imbetween fields
	 */
	public static String getID(long epoch, Boolean addSeparator)
	{
		long time = (long)System.currentTimeMillis() - epoch;
		String res = getDateStr(time) + getRandomSuffix();
		if (addSeparator)
			res = res.substring(0,4)
			 +"-"+res.substring(4,8)
			 +"-"+res.substring(8);
		return res;
	}
	
	public static String getID(long epoch)
	{
		return getID(epoch, false);
	}
	/// Epoch set to 0 (1970-01-01T00:00:00.000Z)
	public static String getID(Boolean addSeparator)
	{
		return getID(0, addSeparator);
	}
	/// Epoch set to 0 (1970-01-01T00:00:00.000Z)
	public static String getID()
	{
		return getID(0, false);
	}
	
	
	// demo purposes
	public static void main(String[] args)
	{
		System.out.println(getID());
	}
}