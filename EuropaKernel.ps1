param (
	[Parameter(Mandatory=$false)] [string]$option="help"
 )
 
 
 	$isDockerRunning = Get-Service Docker
	
	if($isDockerRunning.Status -eq "Stopped"){
		"Docker is stopped. Starting Docker now."
		Start-Service Docker
		$isDockerStarted = Get-Service Docker
		if($isDockerStarted.Status -eq "Running"){
			"Docker service is now running."
			Get-Service Docker
			Get-Process "*docker*"
		}else{
			Write-Error "Check to see if Docker is installed. If it is start the docker service with poswershell: Start-Service Docker"
		}
		
	}
 
 $currentUser=$env:UserName
 $isValidDir = Test-Path -Path "C:\\Users\\$currentUser\\AppData\\tmp"

 if($isValidDir -eq $False){
	 "Creating log file directory: "
	 New-Item -Path "C:\\Users\\$currentUser\\AppData\\" -Name "tmp" -ItemType "directory"
 }


If($option -eq 'install'){
	Start-Job -Name "installEuropa" -ScriptBlock {
		$currentUser=$env:UserName
		
		 $isValidFile = Test-Path -Path "C:\\Users\\$currentUser\\AppData\\tmp\\EropaKerenel_Install.log"
		 if($isValidFile -eq $False){
			 "Creating log file: "
			 New-Item -Path "C:\\Users\\$currentUser\\AppData\\tmp\\" -Name "EropaKerenel_Install.log" -ItemType "file"
		 }
		
		docker login -u uaeuropakernel -p dckr_pat_CTk1JIlJLVYmOpqg-1TkaLb59o0 2>>C:\\Users\\$currentUser\\AppData\\tmp\\EropaKerenel_Install.log
		docker pull uaeuropakernel/europakernel:europa-beta 2>>C:\\Users\\$currentUser\\AppData\\tmp\\EropaKerenel_Install.log
		# Change this to the proper .ipynb repo 
		$repoUrl="https://github.com/cbechie-UA/c-notebook-files.git"
		docker create -p 8888:8888 --name=europa-beta --env repoUrl=$repoUrl uaeuropakernel/europakernel:europa-beta
	} | Receive-Job -AutoRemoveJob -Wait 
}ElseIf($option -eq 'run'){
	Start-Job -Name "runEuropa" -ScriptBlock {
		Write-Host "To access the Europa Kernel go to: https://localhost:8888" -ForegroundColor Green
		echo "Europa Kernel Loading..."
		docker start -a -i europa-beta
	} | Receive-Job -AutoRemoveJob -Wait 
}ElseIf($option -eq 'help'){
	echo ""
	echo " install - Install Europa Kernel."
	echo "     run - Run Europa Kernel."
	echo "download - Download assignment files after container shutdown."
	echo ""
	echo " Install: .\EuropaKernel.ps1 install"
	echo "     Run: .\EuropaKernel.ps1 run"
	echo "Download: .\EuropaKernel.ps1 download"
	echo ""
}ElseIf($option -eq 'download'){	
	Start-Job -Name "downloadHWAfterShutdown" -ScriptBlock {
		$currentUser=$env:UserName
		$folder="C:\\Users\\"+$currentUser+"\\Desktop"
		$file_name_tail = Get-Date -UFormat "%s"
		$downloadPath = "$folder\\Europa_Assignments_$file_name_tail\\"
		mkdir $downloadPath
		If(Test-Path -Path $downloadPath) {
			docker cp europa-beta:C:\\data\\notebooks\\ $downloadPath
			echo ""
			echo "Download complete" 
			echo "Files saved to $downloadPath"
		}Else{
			$host.UI.WriteErrorLine("Error occured: could not find download folder $downloadPath for $currentUser account.")
			$host.UI.WriteErrorLine("Please use the following command in the CLI to download the files:")
			$host.UI.WriteErrorLine("docker cp Europa-Beta:C:\\data\\notebooks\\ <destination_path>")
		}
	} | Receive-Job -AutoRemoveJob -Wait
}Else{
	echo ""
	echo " install - Install Europa Kernel."
	echo "     run - Run Europa Kernel."
	echo "    help - Helpful information."
	echo "download - Download assignment files after container shutdown."
	echo "Example: .\EuropaKernel.ps1 help"
	echo ""
}
