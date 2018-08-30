# Cocktographic Messages

Cocktographic enchoding is a method for encoding arbitrary data for transit
over systems which are capable of expressing US-ASCII code points reliably,
in sequence, between user specified end-points. There is no limit to message
size.

Dechoding is like enchoding, but in reverse. Payload limitations may be
placed by implementors, if all parties involved are in agreement.
However, as [Jon Postel wrote](http://doi.org/10.17487/rfc0761):
> ... implementations should follow a general principle of robustness:
be conservative in what you do, be liberal in what you accept from others.

A cocktographic message consists of a cockchain of cockblocks; that is a
chain of one or more block messages. Each cockblock contains two kontol
chodes: a begin chode and an end chode. These kontol chodes surround one or
more cyphallic chodes. One or more spaces, code point `0x20`, separate chodes.
A valid cockblock consists only of valid chodes separated by spaces.

If the begin kontol chode, the cyphallic chode(s), and the end kontol chode
all fit into a single message of the underlying transport, then the cockchain
consists of a single cockblock, the singleton.

Else the cyphallic chodes must be split into multiple cockblocks. The first
cockblock must be of the initial type and the last cockblock must be of the
final type. Cockblocks in the middle must be of the intermediate type.

Cockchain: `cockblock [cockblock ...]`

Cockblock chode makeup: `begin-kontol cyphallic [cyphallic ...] end-kontol`

The four cockblock types and the kontol chodes for each:

Type | Begin | End
---- | ----- | ---
Singleton | START | STOP
Initial | START | CONT
Intermediate | MARK | CONT
Final | MARK | STOP

The four kontol chodes:

Name | Value
---- | -----
START | `8=wm=D`
STOP | `8=mw=D`
CONT | `8=ww=D`
MARK | `8wmD`

Cockchain size, N | Cockchain cockblock makeup
----------------- | --------------------------
N = 1 | `singleton`
N = 2 | `initial final`
N > 2 | `initial intermediate [intermediate ...] final`

# Modern Cipher

The escape sentinel code point is `0x0F`.  
Base 64 encoding used within is detailed by
[RFC 4648](http://doi.org/10.17487/rfc4648) section 4.  
For base 64 encoded messages to be valid they must:
* Be a length that is an integer multiple of four, and
* Contain only characters from RFC 4648 table 1; however
* The pad character must only exist at the end of a message,
and not in excess.

Note: the escape sentinel does not appear in RFC 4648 table 1.

## Basic Cyphallic Enchoding
1. Prefix payload with escape sentinel
1. Perform 1:1 substitution of payload code points using modern dicktionary

## Stroked Cyphallic Enchoding
1. Prefix payload with escape sentinel
1. For each stroke level:
   - Payload becomes base 64 encoded version of payload
1. Perform 1:1 substitution of payload code points by using modern dicktionary

## Basic Cyphallic Dechoding
1. Perform 1:1 substitution of cyphallic text using modern dicktionary
1. Strip result of any single leading escape sentinel

## Stroked Cyphallic Dechoding
1. Perform 1:1 substitution of cyphallic text using modern dicktionary
1. While result is a valid base 64 message:
   - Result becomes base 64 decoded version of result
1. Strip result of any single leading escape sentinel

## Data URI Enhancement
The [RFC 2397 spec](http://doi.org/10.17487/rfc2397) must be followed, with
the exception of URL encoding. There must be no URL encoding; that is, the
requirement to limit characters to "urlchar" or "uric" is waived. Characters
in the portion of the URI preceding the comma must lie in the ranges
`0x20-0x2B` and `0x2D-0x7E`. This document neither defines which MIME types
are acceptable nor how to process a particular payload.  
The default actions when encountering an unexpected data URI should be:
1. If the data portion is not base 64 encoded, then modify the URI such that
it is base 64 encoded, and that ";base64" precedes the comma before the data
1. Handle the data URI as if it is plain-text

### Enchoding Pre-process
Before normal enchoding:
1. Construct a payload according to terms agreed by all parties involved
1. Prefix the data URI payload with an additional escape sentinel

### Dechoding Post-process
Following normal dechoding:
1. Check for the presence of an additional escape sentinel
1. Strip the additional escape sentinel
1. Process payload according to terms agreed by all parties involved

Note: The base 64 validity requirements otherwise mentioned in this document
do apply to data URI base 64 encoding when used in data URIs.

# Notes

* Stroked enchoding and dechoding with stroke level 0 are equivalent to
basic cyphallic enchoding and dechoding
* There is no American spelling of cyphallic; this is the American spelling

## Historical Cipher

Similar to a 2-stroke modern cyphallic chodec, but without an escape sentinel.

### Cyphallic Enchoding
1. Payload becomes base64 encoded version of payload
1. Payload becomes base64 encoded version of payload
1. Perform 1:1 substitution of payload code points using historical dicktionary

### Cyphallic Dechoding
1. Perform 1:1 substitution of cyphallic text using dicktionary
1. Result becomes base64 decoded version of result
1. Result becomes base64 decoded version of result

## Historical Dicktionary

The historical dicktionary contains only unigrams for printable US-ASCII and
the escape sentinel. The modern dicktionary includes the historical one.
The values covered by both dicktionaries are as follows: `0x0F` and
`0x20-0x7E`.
