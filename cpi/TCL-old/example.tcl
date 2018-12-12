#/***********************************************************************************\
#|*                Cocktography Example v8=D by Bang Ding Ow                        *|
#\***********************************************************************************/

package require cocktography 1.1

set testString "This is a test"

#enchode returns a list, the first element is the number of strokes, the rest are the enchoded lines
set wangs [::cocktography::enchode $testString] 

#An enchoded message should start with ::cocktography::start and end with ::cocktography::stop
if {[string first $::cocktography::start $wangs] && [string last $::cocktography::stop $wangs]} {
#if there's only one line, we can dechode it directly
set dewanged [::cocktography::dechode [lindex $wangs 1]]

puts "Input: $testString Enchoded: $wangs dechoded: [lindex $dewanged 1]"
}


# This is likely how it would be implemented in the real world for message transmission.
set test {}
set testString "This is a longer test. You can tell it's longer because of the way it is. This simulates real text."

# Enchode returns a list, each element is a line ready for transmission.
# Here, we're using 4 strokes 
set dongs [::cocktography::enchode $testString 2] 

puts "This message has [lindex $dongs 0] strokes:"
set dongers [lrange $dongs 1 [llength $dongs]] 
foreach dong $dongers {
    #This simulates sending an enchoded message.
	puts "Line: $dong"

	#This simulates receiving an enchoded message. 
	#
	#Proper message handling should expect to see a message come in as:
	#
	#::cocktography::start message ::cocktography::stop
	#
	# OR the following format
	# 
	#::cocktography::start message ::cocktography::cont
	#::cocktography::mark message ::cocktography::cont  <-- any number of these between start and stop
	#::cocktography::mark message ::cocktography::stop
	
	append test " " $dong
}

set dechoded [::cocktography::dechode $test]

#dechode returns a list, the first element is the number of strokes, the second is the dechoded text
puts "Strokes: [lindex $dechoded 0] Text: [lindex $dechoded 1]"


set dechoded {}
set test {}
set dongs {}
#this is the same thing, but shows the auto-destroker in action. 
set testString "This is a bit smaller"

set dongs [::cocktography::enchode $testString 15]
puts "This message requested 15 strokes but got [lindex $dongs 0]"
set dongers [lrange $dongs 1 [llength $dongs]] 
foreach dong $dongers {
	append test " " $dong
}
set dechoded [::cocktography::dechode $test]
puts "Strokes: [lindex $dechoded 0] Text: [lindex $dechoded 1]"




