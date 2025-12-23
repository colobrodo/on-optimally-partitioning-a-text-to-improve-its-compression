for ipefile in *.ipe; do
	name=${ipefile%.*}
	echo "Rendering $ipefile"
	iperender -svg $ipefile $name.svg
done
