## Library interface

This is a specification for writing a STPUID library.

### Data types

We manipulate four high-level data types:

 - Millisecond time stamps, counting from 1970-01-01T00:00:00Z, as integers
 - Date slugs, encoding the former into 8 b36 digits, as strings
 - Random digit slugs, which are four random base36 digits, as strings
 - 12-characters IDs, with the 14-character variant (two dashes added)

All string types should be kept in lower case at all times.
The base 36 digits are, in order: `0123456789abcdefghijklmnopqrstuvwxyz`.

The defined functions follow:

### Functions

`getDateSlug(msts)` encodes a millisecond timestamp into a date slug

`getRandomDigits()` produces four random b36 digits

`getID(msts, format)` which produces IDs or their 14-chars variant

All functions should be, if possible, set within their own common `stpuid`
namespace (or an equivalent in the language of choice).
Do respect local language conventions.

### Default values

If a default value is allowed for the timestamp, then it should be
978307200000, which corresponds to 2001-01-01T00:00:00Z.

If a default value is allowed for the format (whether or not to add separator
dashes to produced IDs), then it should be default produce 12-characters
separator-less IDs.

### Optional functions

These functions are not core to the functionality, but are either necessary to
palliate missing language features, or convenient to have. It is not mandatory
for them to be implemented; but if they are, then make sure they follow this
interface.

`base36(integer)` returns the base 36 string representation of a given integer,
big-endian, with no padding.

`getMilliseconds(iso date)` accepts a date and returns its equivalent in number
of milliseconds since 1970-01-01T00:00:00Z.
This function is specified to take an "iso date", but ideally it should be able
to take as input either the local language's date type or a ISO 8601 string.

`getDate(epoch as msts, msts)` returns the date represented by the given msts
(as milliseconds since the given epoch), either as the local language's date
type (if it has one), or as an ISO 8601 string.

`getPrettyTimeDelta(msts)` returns a date delta, either as the local language's
time delta type (if it has one), or as a string.


`getTimeDelta(msts epoch, date slug or ID)` returns the time elapsed, in
milliseconds, between the given epoch (a millisecond timestamp) and the given
date slug, 12-chars ID, or 14-chars ID. It should include enough logic to
distinguish between the three possible types for the second input.
This function is essentially the invert of `getDateSlug(...)`.

`validateID(stpuid, optional epoch as msts)` analyses an ID by:
 - checking whether it is properly formatted
 - (if the epoch has been given) checking whether it is within the allowed date
   range for this epoch.
How it signals those things (ie by return value, exceptions, etc) is left to
implementation.
