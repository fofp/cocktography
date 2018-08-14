#/***********************************************************************************\
#|*                Cocktography Example v8=D by Bang Ding Ow                        *|
#\***********************************************************************************/

package require cocktography 1.0

set testString "This is a test"

#enchode returns a list of enchoded lines
set wangs [::cocktography::enchode $testString] 

#An enchoded message should start with ::cocktography::start and end with ::cocktography::stop
if {[string first $::cocktography::start $wangs] && [string last $::cocktography::stop $wangs]} {
#if there's only one line, we can dechode it directly
set dewanged [::cocktography::dechode [lindex $wangs 0]]
puts "Input: $testString Enchoded: $wangs dechoded: $dewanged"
}


# This is likely how it would be implemented in the real world for message transmission.
set test {}
set testString "This is a longer test. You can tell it's longer because of the way it is. This simulates real text."
set dongs [::cocktography::enchode $testString] 
foreach dong $dongs {
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
puts "Dechoded message: $dechoded"




