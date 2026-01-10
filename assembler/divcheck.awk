{
	dividend = $1
	divisor = $2
	quotient = $3
	remainder = $4
	
	if( dividend != divisor * quotient + remainder ) {
		print "Error:", $0
		errors += 1
	}
	
	if( quotient > maxq ) maxq = quotient
	if( remainder > maxr ) maxr = remainder
}

END{
	print "Tests:", NR
	print "Errors:", errors + 0
	print "Maximum quotient:", maxq
	print "Maximum remainder:", maxr
	
	if( errors ) exit( 1 )
}
