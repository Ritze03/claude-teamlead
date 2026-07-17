# Install the teamlead skill + worker agents into the Claude Code config dir.
$ErrorActionPreference = "Stop"

$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }
$Src = $PSScriptRoot

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "agents"), (Join-Path $ClaudeDir "skills") | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $Src "agents\*")        -Destination (Join-Path $ClaudeDir "agents")
Copy-Item -Recurse -Force -Path (Join-Path $Src "skills\teamlead") -Destination (Join-Path $ClaudeDir "skills")

Write-Host "✅ Installed teamlead skill + 3 worker agents into $ClaudeDir"
Write-Host "   Restart Claude Code, then run /teamlead"
