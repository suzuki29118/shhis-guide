param(
    [string]$ModeAJson,
    [string]$ModeBJson,
    [string]$Message = "update SHHis guide data"
)

$script = Join-Path $PSScriptRoot "publish.ps1"

if ($ModeAJson -and $ModeBJson) {
    & $script -ModeAJson $ModeAJson -ModeBJson $ModeBJson -Message $Message
} else {
    & $script -Message $Message
}
