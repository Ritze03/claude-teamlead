# Install the teamlead skill + worker agents into the Claude Code config dir.
$ErrorActionPreference = "Stop"

$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }
$Src = $PSScriptRoot

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "agents"), (Join-Path $ClaudeDir "skills") | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $Src "agents\*")        -Destination (Join-Path $ClaudeDir "agents")

# Clean overwrite: drop any previously-installed teamlead skill so renamed or
# removed files don't linger, then copy the current version in fresh.
$TeamleadDest = Join-Path $ClaudeDir "skills\teamlead"
if (Test-Path $TeamleadDest) { Remove-Item -Recurse -Force $TeamleadDest }
Copy-Item -Recurse -Force -Path (Join-Path $Src "skills\teamlead") -Destination (Join-Path $ClaudeDir "skills")

Write-Host "✅ Installed teamlead skill + 6 worker agents into $ClaudeDir"
Write-Host "   Restart Claude Code, then run /teamlead"
