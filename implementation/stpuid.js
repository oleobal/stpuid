var stpuid = {}

stpuid.getDateStr = function(msTimestamp)
{
	var res = msTimestamp.toString(36);
	while (res.length < 8)
		res = "0" + res;
	res = res.substring(0,9);
	
	return res.substring(0,6).split("").reverse().join("")+res.substring(6);
}

stpuid.getMilliseconds = function(date)
{
	if (typeof date == "string")
		var date = Date.parse(date);
	return date.getTime();
}

stpuid.getRandomSuffix = function()
{
	var ri = function(max) {
		return Math.floor(Math.random() * Math.floor(max));
	  }
	var digits="0123456789abcdefghijklmnopqrstuvwxyz";
	return digits[ri(digits.length)] + digits[ri(digits.length)] + digits[ri(digits.length)] + digits[ri(digits.length)];
}

stpuid.getID = function(epoch, addSeparator)
{
	if (typeof epoch === "undefined")
		epoch = 978307200000; // 2001-01-01T00:00:00.000Z
	if (typeof addSeparator === "undefined")
		addSeparator = false;
	
	var time = Date.now() - epoch
	
	var res = this.getDateStr(time) + this.getRandomSuffix();
	
	if (addSeparator)
		res = res.substring(0,4) + "-" + res.substring(4,8) + "-"+ res.substring(8);
	return res;
}
