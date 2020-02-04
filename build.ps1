#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter()]
    [switch] $DownloadRamMap,

    [Parameter()]
    [switch] $CompileExecutable,

    [Parameter()]
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import modules
try { Import-Module SmartLogging } catch { Install-Module SmartLogging -Scope CurrentUser -Force; Import-Module SmartLogging }
try { Import-Module Execution } catch { Install-Module Execution -Scope CurrentUser -Force; Import-Module Execution }

Set-ScriptArgs $MyInvocation.BoundParameters $MyInvocation.UnboundArguments

# Invoke-SelfElevation

function Get-FileFromUrl([string] $name, [string] $url) {
    Log info "Download '$name' from '$url'..."

    $fileName = [System.IO.FileInfo]::new($url).Name
    $downloadedFile = Join-Path $env:TEMP $fileName

    Invoke-WebRequest -Uri $url -Method Get -OutFile $downloadedFile -UseBasicParsing

    Log trace "Saved to '$downloadedFile'."
    return $downloadedFile
}

function New-DirectoryIfNotExists([string] $directory) {
    if (-not (Test-Path $directory -PathType Container)) {
        Log trace "Directory '$directory' not exists. Create it..."
        New-Item -Path $directory -ItemType Directory -Force:$Force.IsPresent > $null
    }
}

try {
    # Code goes here

    $outputDir = Join-Path $PSScriptRoot '_build'

    if ($DownloadRamMap) {
        $ramMapDownloadUrl = 'https://live.sysinternals.com/RAMMap.exe'
        $ramMapFileName = [System.IO.FileInfo]::new($ramMapDownloadUrl).Name
        New-DirectoryIfNotExists $outputDir

        $ramMapDestination = Join-Path $outputDir $ramMapFileName
        if ((Test-Path -Path $ramMapDestination) -and -not $Force.IsPresent) {
            Log info "'$ramMapDestination' already exists."
        } else {
            $ramMapFile = Get-FileFromUrl -name 'RAMMap' -url $ramMapDownloadUrl
            Move-Item -Path $ramMapFile -Destination $ramMapDestination -Force:$Force.IsPresent
            Log info "Download complete: '$ramMapDestination'"
        }
    }

    if ($CompileExecutable) {
        $ahkDownloadUrl = 'https://www.autohotkey.com/download/ahk.zip'
        $ahkPath = Join-Path  $outputDir 'ahk'
        New-DirectoryIfNotExists $ahkPath

        $ahkCompilerFile = Join-Path $ahkPath 'Compiler/Ahk2Exe.exe'
        $ahkBinaryFileName = if ([Environment]::Is64BitOperatingSystem) { 'Unicode 64-bit.bin' } else { 'Unicode 32-bit.bin' }
        $ahkBinaryFile = Join-Path $ahkPath "Compiler/$ahkBinaryFileName"

        if ((Test-Path -Path $ahkCompilerFile) -and (Test-Path -Path $ahkBinaryFile) -and -not $Force.IsPresent) {
            Log info 'AutoHotKey compiler  already exists.'
        } else {
            $ahkFile = Get-FileFromUrl -name 'AutoHotKey' -url $ahkDownloadUrl
            Expand-Archive -Path $ahkFile -DestinationPath $ahkPath -Force:$Force.IsPresent
            Log info "Download complete: '$ahkPath'"
        }

        $ahkSrcFile = Join-Path $PSScriptRoot 'src/rammap-cleanup.ahk'
        $ahkSrcFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($ahkSrcFile)
        $exeFile = Join-Path $outputDir "$ahkSrcFileNameWithoutExtension.exe"

        Start-NativeExecution $ahkCompilerFile /in "$ahkSrcFile" /out "$exeFile" /bin $ahkBinaryFile /mpress 1 /cp 65001

        Log info "Compilation complete: '$exeFile'"
    }

    Log info "Successfully"
    Exit-WithAndWaitOnExplorer 0
} catch {
    Log error "Something went wrong: $_"
    Log trace "Exception: $($_.Exception)"
    Log trace "StackTrace: $($_.ScriptStackTrace)"
    Exit-WithAndWaitOnExplorer 1
} finally {
    # Cleanup goes here
}