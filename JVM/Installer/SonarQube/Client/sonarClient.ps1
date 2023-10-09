$folderPosition="C:"
$folderName="Sonar"

$odcOutFolder="report"

$configText =  
@"
token={0}
sonar.url={1}
odc.scanner.home={1}
odc.report.out={2}
scanner.path={3}
odc.java.home={4}
"@

$odcUrl="https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip"
$sonarLocalScannerUrl="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-windows.zip"
$nodeUrl="https://nodejs.org/dist/v18.18.0/node-v18.18.0-x64.msi"
$javaUrl="https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip"

function Download-Archive{
    param($url, $dest, $archiveName, $outFolder)

    Invoke-WebRequest -Uri $url -OutFile "$dest\$archiveName"
    Expand-Archive -Force -LiteralPath "$dest\$archiveName" -DestinationPath "$dest\$outFolder"
    Remove-Item -LiteralPath "$dest\$archiveName"
}

function Download-Installer{
    param($url, $dest, $fileName)
    Invoke-WebRequest -Uri $url -OutFile "$dest\$fileName"
    Start-Process -Wait "$dest\$fileName"
    Remove-Item -LiteralPath "$dest\$fileName"
}

function Print{
    param($msg)
    Write-Host -Foreground green $msg
}


$taskCompleted = $false

try{
    $fullPath = "$folderPosition\$folderName"
    $token = Read-Host "Specify the token associated with your SonarQube account"

    New-Item -Force -Path $folderPosition -Name $folderName -ItemType Directory | Out-Null
    
    Print "Installing OWASP dependecy check..."
    Download-Archive $odcUrl $fullPath "odc.zip"
    New-Item -Force -Path $fullPath -Name $odcOutFolder -ItemType Directory | Out-Null

    Print "Installing SonarQube local scanner..."
    Download-Archive $sonarLocalScannerUrl $fullPath "sonar-scanner.zip"

    Print "Installing Java JDK..."
    Download-Archive $javaUrl $fullPath "java.zip"
  
    Print "Installing NodeJs..."
    Download-Installer $nodeUrl $fullPath "nodejs.msi"
    
    Print "All components installed. Creating configuration file..."
    $odcPath = Get-ChildItem $fullPath -Filter dependency-check.bat -Recurse | % { $_.FullName }
    $sonarPath = Get-ChildItem $fullPath -Filter sonar-scanner.bat -Recurse | % { $_.FullName }
    $jdkPath = $(Get-ChildItem $fullPath -Filter jdk-* -Directory -Recurse | % { $_.FullName })+"\bin"

    $configText -f $token, $odcPath, $odcOutFolder, $sonarPath, $jdkPath | Out-File -FilePath $fullPath\sonar.properties

    Print "Configuring environment..."
    [Environment]::SetEnvironmentVariable("JAVACMD", $jdkPath+"\java.exe", "User")

    Print "Updating local vulnerabilities database..."
    cmd.exe /c "$odcPath --updateonly"
    
    Print "All Done!"
    $taskCompleted = $true
}
catch{
    Write-Host -Foreground Red -Background Black ($Error[0])
}
finally{
    if(-not $taskCompleted){
        Remove-Item -LiteralPath "$folderPosition\$folderName\*.zip" -Force
        Remove-Item -LiteralPath "$folderPosition\$folderName\*.msi" -Force
        Remove-Item -LiteralPath "$folderPosition\$folderName\*.conf" -Force

        Stop-Process -Name "java"
        $dataFolder = $(Get-ChildItem "$folderPosition\$folderName" -Filter owasp* -Directory -Recurse | % { $_.FullName }) + "\data"
        Remove-Item -LiteralPath $dataFolder -Force
   }
}