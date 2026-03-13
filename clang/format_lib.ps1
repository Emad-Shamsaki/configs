[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Directories = @("lib", "serivce_layer")
)

$workspaceRoot = Split-Path -Parent $PSCommandPath
$styleFile = Join-Path $workspaceRoot ".clang-format"
$filePatterns = @("*.c", "*.cpp", "*.h", "*.hpp")

function Get-ClangFormatPath {
    $command = Get-Command "clang-format" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $vscodeExtensions = Join-Path $env:USERPROFILE ".vscode\extensions"
    if (Test-Path $vscodeExtensions) {
        $bundledClang = Get-ChildItem -Path $vscodeExtensions -Recurse -Filter "clang-format.exe" -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName

        if ($bundledClang) {
            return $bundledClang
        }
    }

    throw "clang-format.exe was not found. Install clang-format or make sure the VS Code C/C++ extension is installed."
}

function Resolve-TargetDirectory {
    param(
        [string]$Directory
    )

    $candidate = $Directory
    if ($candidate -eq "service_layer") {
        $misspelledDirectory = Join-Path $workspaceRoot "serivce_layer"
        if (Test-Path $misspelledDirectory) {
            $candidate = "serivce_layer"
        }
    }

    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path $workspaceRoot $candidate
    }

    if (-not (Test-Path $candidate)) {
        throw "Directory not found: $Directory"
    }

    return (Resolve-Path $candidate).Path
}

if (-not (Test-Path $styleFile)) {
    Write-Error "Error: .clang-format not found at $styleFile"
    exit 1
}

try {
    $clangPath = Get-ClangFormatPath
}
catch {
    Write-Error $_
    exit 1
}

$resolvedDirectories = foreach ($directory in $Directories) {
    Resolve-TargetDirectory -Directory $directory
}

$files = foreach ($directory in $resolvedDirectories) {
    Get-ChildItem -Path $directory -File -Recurse -Include $filePatterns
}

$files = $files | Sort-Object FullName -Unique

if (-not $files) {
    Write-Host "No matching files found."
    exit 0
}

Write-Host "Using clang-format: $clangPath"
Write-Host "Using style file: $styleFile"
Write-Host "Formatting directories:"
$resolvedDirectories | ForEach-Object { Write-Host " - $_" }

foreach ($file in $files) {
    if ($PSCmdlet.ShouldProcess($file.FullName, "Format file")) {
        Write-Host "Formatting: $($file.FullName)"
        & $clangPath -i -style=file $file.FullName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "clang-format failed for $($file.FullName)"
            exit $LASTEXITCODE
        }
    }
}

Write-Host "Done."
