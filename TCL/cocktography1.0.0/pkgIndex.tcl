if {![package vsatisfies [package provide Tcl] 8.0]} {return}
package ifneeded cocktography 1.0 [list source [file join $dir cocktography.tcl]]