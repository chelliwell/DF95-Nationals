<#
.SYNOPSIS
    Convert an Excel-generated (HMS) HTML file from Windows-1252 to UTF-8.

.EXAMPLE
    .\ConvertToUtf8.ps1 -InputFile "Results.htm"

    Converts Results.htm in place.

.EXAMPLE
    .\ConvertToUtf8.ps1 `
        -InputFile "Results.htm" `
        -OutputFile "..\Git\DF95-Nationals\index.html"

    Reads Results.htm and writes a UTF-8 version to index.html.
#>

#
# At DOS prompt:
# C:\Users\Colin.LINCOLNAD\Documents\LRSC Results\DF95Nats2026\git> powershell .\ConvertHmsHtml.ps1 -inputfile ..\test.html -outputfile git\index.html
#
# git add index.html
# git commit -m "Updated results"
# git push
#

param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [string]$OutputFile
)

# Resolve input path
$InputPath = (Resolve-Path $InputFile).Path

# Default output = overwrite input
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputPath = $InputPath
}
elseif ([System.IO.Path]::IsPathRooted($OutputFile)) {
    $OutputPath = $OutputFile
}
else {
    $OutputPath = Join-Path (Split-Path $InputPath -Parent) $OutputFile
}

Write-Host ""
Write-Host "Input : $InputPath"
Write-Host "Output: $OutputPath"

# Ensure output directory exists
$OutDir = Split-Path $OutputPath -Parent
if (!(Test-Path $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
}

# Encodings
$cp1252 = [System.Text.Encoding]::GetEncoding(1252)
$utf8   = New-Object System.Text.UTF8Encoding($false)

# Read file as bytes
$bytes = [System.IO.File]::ReadAllBytes($InputPath)

# Decode using Windows-1252
$text = $cp1252.GetString($bytes)

# Change HTML charset declaration
$text = $text -replace 'charset=windows-1252', 'charset=utf-8'

# ------------------------------------------------------------------
# Place any other tweaks here, for example:
#
# $text = $text -replace 'Old Text','New Text'
#
# etc.
# ------------------------------------------------------------------

# Write UTF-8 without BOM
[System.IO.File]::WriteAllText($OutputPath, $text, $utf8)

Write-Host "Converted Windows-1252 -> UTF-8"
Write-Host "Done."
