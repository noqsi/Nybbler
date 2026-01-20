BEGIN{
	FS = "[ \t\n]+"
}

function nesterror( ) {
	print "Unexpected " $2 " after " blocktype[blocknest] " on line " FNR >"/dev/stderr"
	exit( 1 )
}

/^#/{next}

$2=="times" {
	print "# " $0
	++blockid	# start a new block
	doblock[++donest] = blockid
	blocktype[++blocknest] = "times"
	print "$" blockid  ".do	=	."
	print $1 "	snz"
	print "	jump	@$" blockid ".done"
	print "	neg not"
	next
}

$2=="do" {
	print "# " $0
	++blockid	# start a new block
	doblock[++donest] = blockid
	blocktype[++blocknest] = "do"
	print "$" blockid  ".do	=	."
	if( $1 ) print $1 "	=	."
	next
}

$2=="repeat" {
	print "# " $0
	print "	jump @$" doblock[donest] ".do"
	print "$" doblock[donest] ".done	=	."
	if( blocktype[blocknest] == "times" ) print "	drop"
	else if( blocktype[blocknest] != "do" ) call nesterror( )
	--donest
	--blocknest
	next
}

$2=="done" {
	print "# " $0
	print "$" doblock[donest] ".done	=	."
	if( blocktype[blocknest] != "times" &&
		blocktype[blocknest] != "do" ) call nesterror( )
	--donest
	--blocknest
	next
}

$2=="break" {
	print "# " $0
	print "	jump	@$" doblock[donest] ".done"
	next
}

$2=="continue" {
	print "# " $0
	print "	jump	@$" doblock[donest] ".do"
	next
}

$2=="if" {
	print "# " $0
	++blockid	# start a new block
	ifblock[++ifnest] = blockid
	blocktype[++blocknest] = "if"
	print $1 "	snz drop"
	print "	jump	@$" blockid ".else"
	next
}

$2=="ifnot" {
	print "# " $0
	++blockid	# start a new block
	ifblock[++ifnest] = blockid
	blocktype[++blocknest] = "if"
	print $1 "	snz drop"
	print "	jump 1"
	print "	jump	@$" blockid ".else"
	next
}


$2=="else" {
	print "# " $0
	blocktype[blocknest] = "else"
	print "	jump	@$" blockid ".endif"
	print "$" ifblock[ifnest] ".else	=	."
	next
}

$2=="endif" {
	print "# " $0
	if( blocktype[blocknest] == "if") # pretend this is the else clause
		print "$" ifblock[ifnest] ".else	=	."
	else if( blocktype[blocknest] == "else")
		print "$" ifblock[ifnest] ".endif	=	."
	else call nesterror( )
	--ifnest
	--blocknest
	next
}


{ print $0 }
