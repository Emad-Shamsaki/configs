$clangPath = "C:\Users\uie059\.vscode\extensions\ms-vscode.cpptools-1.30.5-win32-x64\LLVM\bin\clang-format.exe"

if (-not (Test-Path $clangPath)) {
    Write-Error "Error: clang-format.exe not found at $clangPath"
    exit 1
}

Write-Host "Starting formatting..."
Get-ChildItem -Path lib -Include *.c,*.cpp,*.h,*.hpp -Recurse | ForEach-Object { 
    Write-Host "Formatting: $($_.Name)"
    & $clangPath -i -style=file $_.FullName 
}
Write-Host "Done."
