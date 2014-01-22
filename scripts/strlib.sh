# String library which can 
# be used in shell scripts
strlen()
{
    echo $1 |awk '{printf("%d\n",length($0))}'
}

substr()
{
    echo | awk "{printf(\"%s\n\", substr(\"$1\",$2,$3))}"
}

index()
{
    echo | awk "{printf(\"%d\n\", index(\"$1\",\"$2\"))}"
}

match()
{
    echo |awk "{match(\"$1\",\"$2\");printf(\"%d %d\n\",RSTART, RLENGTH)}"
}

tolower()
{
    echo |awk "{printf(\"%s\n\",tolower(\"$1\"))}"
}

toupper()
{
    echo |awk "{printf(\"%s\n\",toupper(\"$1\"))}"
}

sub()
{
    echo |awk "{v=\"$3\";sub(\"$1\",\"$2\",v);print v}"
}

gsub()
{
    echo |awk "{v=\"$3\";gsub(\"$1\",\"$2\",v);print v}"
}

matched()
{
    _minfo=`match "$1" "$2"`
    _start=`echo $_minfo |awk '{print $1}'`
    _len=`echo $_minfo |awk '{print $2}'`
    if [ $_len -lt 1 ]; then
	echo
    else
	substr "$1" "$_start" "$_len"
    fi
}