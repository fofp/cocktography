#/***********************************************************************************\
#|*                Cocktography Example v8=D by Bang Ding Ow                        *|
#\***********************************************************************************/

package require cocktography 1.0

set testString "This is a test"

#enchode returns a list of enchoded lines
set wangs [::cocktography::enchode $testString] 

#if there's only one line, we can dechode it directly
set dewanged [::cocktography::dechode [lindex $wangs 0]]
puts "Input: $testString Enchoded: $wangs dechoded: $dewanged"


# This is likely how it would be implemented in the real world for message transmission.
set test {}
set testString "This is a longer test. You can tell it's longer because of the way it is. This simulates real text."
set dongs [::cocktography::enchode $testString] 
foreach dong $dongs {
    #This simulates sending an enchoded message.
	puts "Line: $dong"

	#This simulates receiving an enchoded message. 
	append test " " $dong
}

set dechoded [::cocktography::dechode $test]
puts "Dechoded message: $dechoded"




