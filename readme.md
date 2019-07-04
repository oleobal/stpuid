### UUID

This when a unique identifier is needed, but actually good UUIDs like [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) are too long. In particular when the identifiers need to be human-readable.

In many cases, people simply slice off a portion of the UUID, however this is undesireable because UUIDs typically have fields, and it is possible to outright amputate one.

In these cases, it would be better to use a relatively simple to implement UUID format, that would make a lot of assumption about how safe its environment is, rather than attempt to be bullet-proof.

#### Design

The first step is notating the UUID in base 36, using the full alphanumeric range but no special characters or uppercase variants. In base 36, we encode ~5.17 bits per characters (BPC), which means the RFC 4122 (128 bits) is still 25 characters, so further steps need be taken; that is to say, some information has to go.

RFC 4122 has essentially two fields, date and 'node', which can be a variety of things but can generally be manipulated as a random number. We will start by dropping the variant field (3 bits) and version number (4 bits).

Date in RFC 4122 is a 60-bits count of nanoseconds since the gregorian reformation in the 16th century. In addition, a 'clock sequence' 14-bits field helps to handle cases where the clock might be the same, such as two machines not being synchronized or time being adjusted backwards.

In base 36, we can fit 41 bits of information in 8 characters. This is enough for ~69.7 years of counting milliseconds. Counting nanoseconds is not feasible (only ~24 days), neither is only using 7 characters (~2 years in milliseconds). Users will need to establish an epoch before using the id.

Clock collisions are handled by adding four characters (~20.68 bits) of randomness, reducing the chance of collision to 1.68 million to one. Although, like RFC 4122, it'd be possible to enhance this field by replacing some randomness with identifying/distinctifying information, if available. Do be careful to avoid seeding the random number generator with only the system clock !

Finally, in order to more easily distinguish between IDs, we establish a particular notation: the eight characters for time are notated backwards, followed by the four random characters.

To make reading the UUID easier, it is possible to separate it into three groups with a separator (I recommend a dash `-`)

Examples: `e48c-1c10-g8ec`, `vfvg2c10xo77`


#### Assumptions

We live in a low-intensity environment, where UUIDs are not generated often, and the risk of collision is thus rare.

Our machines are managed (typically, by a cloud provider), ensuring time conflicts are basically not a problem.

The software will be relevant for less than the ~70 years the UUIDs are good for.

#### Generation algorithm

Determine an epoch, and construct a way to get millisecond values from it. For instance, retrieve its value compared to the Unix epoch and substract it from current-time values compared to the Unix epoch.

When a UUID is requested:

1. Generate a millisecond timestamp compared to your epoch
2. Convert it to base 36 and prefix it with zeroes to get to 8 characters.
3. Write the 8 characters backwards, and add four random characters at the end
4. (optional) add separators (dashes) separating the string in 3 groups of 4 characters.
