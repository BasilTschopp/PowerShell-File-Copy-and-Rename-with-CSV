# Basic Variables
$csvFile           = "input.csv"
$csvColumnPath     = "Path"
$csvColumnRename   = "Rename"
$csvArray          = Import-Csv -Path $csvFile
$TargetFolder      = "target folder"

# Microsoft Windows Filename Length Limitation
$MaxFileNameLength = 255 

# Check if the target folder exists and if not create it
if (!(Test-Path -Path $TargetFolder)) {
    New-Item -ItemType Directory -Path $TargetFolder | Out-Null
    Write-Host "Folder $TargetFolder created"
}

foreach ($Row in $csvArray) {

    # Check if the path is absolute and if not create it
    if ([System.IO.Path]::IsPathRooted($Row.$csvColumnPath)) {
        $SourceFilePath = $Row.$csvColumnPath
    } else {      
        $SourceFilePath = Join-Path -Path $PSScriptRoot -ChildPath $Row.$csvColumnPath
    }

    # Extract the file extension 
    $FileExtension = [System.IO.Path]::GetExtension($SourceFilePath)

    # Create the new file name by replacing invalid characters with underscores
    $NewFileName = ($Row.$csvColumnRename -replace '[<>:"/\\|?*]', '_') + $FileExtension

    # Check if the maximum filename length is reached and if so truncate the filename           
    if ($NewFileName.Length -gt $MaxFileNameLength) {
        $MaxBaseNameLength = $MaxFileNameLength - $FileExtension.Length
        $SanitizedFileName = $SanitizedFileName.Substring(0, $MaxBaseNameLength)
        $NewFileName = $SanitizedFileName + $FileExtension
        Write-Host "File name too long, truncated to: $NewFileName"
    }

    $DestinationFilePath = Join-Path -Path $TargetFolder -ChildPath $NewFileName

    # Copy the file if the file path exists
    if (Test-Path -Path $SourceFilePath) {        
        Copy-Item -Path $SourceFilePath -Destination $DestinationFilePath -Force
        Write-Host "Copied: $NewFileName"
    } else {
        Write-Host "File not found: $SourceFilePath"
    }
}

Read-Host "Press Enter to exit"