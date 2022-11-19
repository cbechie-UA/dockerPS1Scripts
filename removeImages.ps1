$ImageArray = "c58238f40eab"

foreach ($image in $ImageArray){
	docker.exe image rm $image -f
}
