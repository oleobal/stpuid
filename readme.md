### Short & Trivial Practically Unique Identifier

There are situations where an unique identifier is needed, but actually good UUIDs like [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) are too long; in particular when the identifiers need to be human-readable.

In these cases, people might simply slice off a portion of the UUID; however, this is undesireable, because a UUID does not scramble its information equally around its length. That is to say, chopping off three-fourth of it might have unpredictable effects on collision rates.

In these cases, it would be better to use a relatively simple to implement UID format, that would make a lot of assumption about how safe its environment is, rather than attempt to be bullet-proof.

#### Usage

There are a few implementations in the corresponding folder.

The D implementation has a command-line parser, so it can be used as an actual command-line tool. The others are just meant to be libraries.

#### Design

We are looking for an easy-to-read (and distinguish by eye), and thus short ID system. The names should be alphanumeric only and without mixed case, to be easily compatible with various systems.

The first step is notating the ID in base 36, using the full alphanumeric range but no special characters or uppercase variants. In base 36, we encode ~5.17 bits per characters (BPC), which means the RFC 4122 (128 bits) is still 25 characters, so further steps need be taken; that is to say, some information has to go.

RFC 4122 has essentially two fields, date and 'node', which can be a variety of things but can generally be manipulated as a random number. We will start by dropping the other fields: the variant (3 bits) and version number (4 bits).

Date in RFC 4122 is a 60-bits count of nanoseconds since the gregorian reformation in the 16th century. In addition, a 'clock sequence' 14-bits field helps to handle cases where the clock might be the same, such as two machines not being synchronized or time being adjusted backwards.

In base 36, 8 characters give us around ~89.5 years of counting milliseconds. Counting nanoseconds is not feasible (only ~32 days), neither is only using 7 characters (~2.5 years in milliseconds). 90 years of validity is acceptable, as long as users establish an epoch that is right before their usage starts.

Clock collisions are handled by adding four characters (~20.68 bits) of randomness, resulting in a ~1.68 million to one. Although, like RFC 4122, it'd be possible to enhance this field by replacing some randomness with identifying/distinctifying information, if available. Do be careful to avoid seeding the random number generator with only the system clock !

Finally, in order to more easily distinguish between IDs, we establish a particular notation: the first six characters for time are notated backwards (ie little-endian). This is so the first four characters represent a ~4 year slice, changing every ~1.29 second, and thus represent a good rough indicator. The four random digits are appended at the end.

To make reading the ID easier, it is possible to separate it into three groups, using a dash `-` as separator. The point of this (and the previous instruction) is to bring into view the first four digits.

Examples: `e9cu-10js-3gei`, `kc37yjz2h7kd`


#### Assumptions

STPUIDs are expected to be used to distinguish resources within a single system, not across unrelated systems.

We live in a low-intensity environment, where UIDs are not generated often, and the risk of collision is thus rare.

Our machines are managed (typically, by a cloud provider), ensuring time conflicts are basically not a problem.

The software will be relevant for less than the ~90 years the UIDs are good for.

#### Generation algorithm

Determine an epoch, and construct a way to get millisecond values from it. For instance, retrieve its value compared to the Unix epoch and substract it from current-time values compared to the Unix epoch.

When an UID is requested:

1. Generate a millisecond timestamp compared to your epoch
2. Convert it to base 36 and prefix it with zeroes to get to 8 characters.
3. Reverse the order of the first six characters
4. Add four random characters at the end
5. (optional) add separators (dashes) separating the string in 3 groups of 4 characters.
