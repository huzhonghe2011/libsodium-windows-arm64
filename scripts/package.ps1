param(
    [Parameter(Mandatory = $true)]
    [string]$BuildRoot,

    [Parameter(Mandatory = $true)]
    [string]$UpstreamRoot,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [Parameter(Mandatory = $true)]
    [string]$UpstreamRef,

    [Parameter(Mandatory = $true)]
    [string]$UpstreamCommit
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BuildRoot)) {
    throw "Build output does not exist: $BuildRoot"
}

if (-not (Test-Path (Join-Path $UpstreamRoot "LICENSE"))) {
    throw "Upstream LICENSE not found. Refusing to package without license."
}

if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}
New-Item -ItemType Directory -Force $OutputDir | Out-Null

# Copy the Zig install prefix exactly, preserving upstream-generated names.
Copy-Item -Recurse -Force (Join-Path $BuildRoot "*") $OutputDir

# License compliance: preserve the exact upstream license in every package.
Copy-Item -Force (Join-Path $UpstreamRoot "LICENSE") (Join-Path $OutputDir "LICENSE.libsodium")

$zigVersion = (& zig version).Trim()
$buildInfo = @"
Project: libsodium
Upstream repository: https://github.com/jedisct1/libsodium
Requested upstream ref: $UpstreamRef
Resolved upstream commit: $UpstreamCommit
Target: aarch64-windows
Optimization: ReleaseFast
Static library: enabled
Shared library: enabled
Tests: executed natively on Windows ARM64
Zig version: $zigVersion
License file: LICENSE.libsodium
"@

Set-Content -Path (Join-Path $OutputDir "BUILD-INFO.txt") -Value $buildInfo -Encoding UTF8
