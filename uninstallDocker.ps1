docker swarm leave --force
docker ps --quiet | ForEach-Object {docker stop $_}
docker system prune --volumes --all
Uninstall-Package -Name docker -ProviderName DockerMsftProvider
Uninstall-Module -Name DockerMsftProvider
Get-HNSNetwork | Remove-HNSNetwork
Get-ContainerNetwork | Remove-ContainerNetwork
Remove-Item "C:\ProgramData\Docker" -Recurse
Remove-Item "C:\Docker" -Recurse
Restart-Computer -Force