BEGIN{
	nybbles=3
	opcode["nop"]=0
	opcode["shift"]=1
	opcode["neg"]=2
	opcode["not"]=3
	opcode["return"]=4
	opcode["snz"]=5
	opcode["add"]=6
	opcode["and"]=7
	opcode["fetch"]=8
	opcode["store"]=9
	opcode["swap"]=10
	opcode["drop"]=11
	opcode["call"]=12
	opcode["push"]=13
	opcode["extend"]=14
	opcode["jump"]=15
	for (i = 0; i < 256; i++) chrnum[ sprintf("%c", i) ] = i
	ilc=0
	dlc=0
	FS = "[ \t\n]+"
	pass = 1
}

function evaluate( expr, first ) {
	
	first = substr( expr, 1, 1 )
	if( first == "@" ) return evaluate( substr( expr, 2 )) - ilc
	if( first ~ /[-+0-9]/ ) return strtonum( expr )
	if( expr == "." ) return ilc
	if( expr == ".." ) return dlc
	if( expr in symtab) return symtab[ expr ]
	if( pass == 2 ) { 
		print "Symbol", expr, "on line",
			FNR, "is undefined" >"/dev/stderr"
		exit(1)
	}
	return 0
}

function maskarg( arg, nybble, lastop, modulus, minarg, maxarg ) {

	modulus = 16^(nybbles-nybble)
	if( pass == 2 ) {
		if( lastop == "jump" ) {	# arg is signed
			minarg = -modulus/2
			maxarg = modulus/2-1
		} else {			# arg is unsigned
			minarg = 0
			maxarg = modulus-1
		}
		if( arg < minarg || arg > maxarg ) {
			print "Argument out of range on line", FNR,
				$0 >"/dev/stderr"
			exit( 1 )
		}
	}	

	return ( arg % modulus + modulus ) % modulus
}

/##PASS2##/{pass = 2; next}

# Comments and blank lines

/^#/{if( pass == 2 ) print; next}
/^\s*$/{if( pass == 2 ) print; next}

# Symbol definitions

$2=="="{ 
	val = evaluate($3)
	if( $1 == "." ) ilc = val
	else if( $1 == ".." ) dlc = val
	else symtab[$1]=val
	
	if( pass == 2 ) {
		printf "D %0*X\t%s\n", nybbles, val, $0
	}

	next 
}

# Scalars

$2=="data"{
	here = dlc++
	if( $1 ) symtab[$1]=here
	
	data = evaluate( $3 )

	if( pass == 2 ) {
		printf "D %0*X %0*X %s\n", nybbles, here, nybbles, data, $0
	}
	next
}
	
# Strings

$2=="string"{
	here = dlc++
	if( $1 ) symtab[$1]=here
	
	match( $0, /[ \t]+string[ \t]/ )
	str = substr( $0, RSTART + RLENGTH)
	len = length( str )

	if( pass == 2 ) {
		printf "D %0*X %0*X %s\n",
			nybbles, here, nybbles, len, $0
	}
	
	for( i = 1; i <= len; i += 1 ) {
		here = dlc++
		if( pass == 2 ) {
			chr = substr( str, i, 1 )
			printf "D %0*X %0*X %s\n",
			nybbles, here, nybbles, chrnum[ chr ], chr
		}
	}
	next
}

# Program lines

{
	here = ilc++
	if( $1 ) symtab[$1]=here
	inst = 0
	for( i=0; i<nybbles; ++i ){
		token = $(i+2)
		if( token in opcode ) {
			inst = inst * 16 + opcode[ token]
			lastop = token
		}
		else if( length(token) == 0 ) break
		else if( token ~ /#/ ) break
		else{
			inst = inst * 16^(3-i) + maskarg( evaluate( token ), i, lastop )
			break
		}
	}
	
	if( pass == 2 ) {
		printf "I %0*X %0*X %s\n", nybbles, here, nybbles, inst, $0
	}
	next
}

END{
	print "# Symbol Table"
	asorti( symtab, syms )
	for( i in syms ) print syms[i], "=", symtab[syms[i]]
	if( pass == 1 ) print "##PASS2##"
}
