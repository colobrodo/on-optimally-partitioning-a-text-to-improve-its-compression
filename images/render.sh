for ipefile in *.ipe; do
	name=${ipefile%.*}
	echo $name
	echo $ipefile
	iperender -svg $ipefile $name.svg
done
