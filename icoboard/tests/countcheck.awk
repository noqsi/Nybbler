{
	if( NR <= 2048 ) expect = NR - 1
	else expect = NR - 4097
	
	if( $1 != expect ) {
		print "Expected:", expect, "but saw", $1
		exit(1)
	}
}

END {
	if( NR != 4096 ) {
		print "Expected 4096 results but saw", NR
		exit( 1 )
	}
	print "12 bit signed counting, decimal output OK"
}
