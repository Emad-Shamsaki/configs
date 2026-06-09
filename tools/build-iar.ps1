param(
    [ValidateSet("build", "make", "clean", "rebuild")]
    [string]$Action = "build",

    [string]$Project = "$PSScriptRoot\..\EWARM\S18001.ewp",
    [string]$Configuration = "S18001",
    [ValidateSet("errors", "warnings", "info", "all")]
    [string]$LogLevel = "warnings",
    [string]$IarBuild = $env:IARBUILD
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($IarBuild)) {
    $candidates = @(
        "$env:USERPROFILE\iar\common\bin\iarbuild.exe",
        "${env:ProgramFiles}\IAR Systems\Embedded Workbench 9.0\common\bin\iarbuild.exe",
        "${env:ProgramFiles(x86)}\IAR Systems\Embedded Workbench 9.0\common\bin\iarbuild.exe"
    )

    $IarBuild = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

if (-not (Test-Path -LiteralPath $IarBuild)) {
    throw "iarbuild.exe was not found. Set IARBUILD to the full path of iarbuild.exe."
}

if (-not (Test-Path -LiteralPath $Project)) {
    throw "IAR project was not found: $Project"
}

$projectPath = (Resolve-Path -LiteralPath $Project).Path

function Invoke-IarBuild {
    param(
        [string]$Command
    )

    & $IarBuild $projectPath "-$Command" $Configuration "-log" $LogLevel
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

switch ($Action) {
    "build" {
        Invoke-IarBuild "make"
    }
    "make" {
        Invoke-IarBuild "make"
    }
    "rebuild" {
        Invoke-IarBuild "build"
    }
    "clean" {
        Invoke-IarBuild "clean"
    }
    default {
        throw "Unsupported action: $Action"
    }
}
