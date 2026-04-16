$ErrorActionPreference = 'Stop'
$pattern = 'fontFamily\s*:\s*(["''])\s*''?SF Pro Text''?\s*\1'
$replacement = 'fontFamily: AmityTextStyle.fontFamily'
$files = git grep -l -E "fontFamily.*SF Pro Text|SF Pro Text.*fontFamily" -- . | Where-Object { $_ -ne 'lib/v4/core/styles.dart' -and $_ -ne './lib/v4/core/styles.dart' }
$changed = @()
foreach ($file in $files) {
  $fullPath = (Resolve-Path $file).Path
  $bytes = [System.IO.File]::ReadAllBytes($fullPath)
  $encoding = $null
  $bomLen = 0
  if ($bytes.Length -ge 4 -and $bytes[0] -eq 0x00 -and $bytes[1] -eq 0x00 -and $bytes[2] -eq 0xFE -and $bytes[3] -eq 0xFF) { $encoding = [System.Text.Encoding]::GetEncoding(12001); $bomLen = 4 }
  elseif ($bytes.Length -ge 4 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE -and $bytes[2] -eq 0x00 -and $bytes[3] -eq 0x00) { $encoding = [System.Text.Encoding]::UTF32; $bomLen = 4 }
  elseif ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $encoding = New-Object System.Text.UTF8Encoding($true); $bomLen = 3 }
  elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { $encoding = [System.Text.Encoding]::BigEndianUnicode; $bomLen = 2 }
  elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { $encoding = [System.Text.Encoding]::Unicode; $bomLen = 2 }
  else { $encoding = New-Object System.Text.UTF8Encoding($false); $bomLen = 0 }

  $text = $encoding.GetString($bytes, $bomLen, $bytes.Length - $bomLen)
  $newText = [regex]::Replace($text, $pattern, $replacement)
  if ($newText -ne $text) {
    $outBytes = $encoding.GetBytes($newText)
    if ($bomLen -gt 0) {
      $preamble = $encoding.GetPreamble()
      if ($preamble.Length -gt 0) { $outBytes = $preamble + $outBytes }
    }
    [System.IO.File]::WriteAllBytes($fullPath, $outBytes)
    $changed += $file
  }
}
Write-Output 'Changed files:'
if ($changed.Count -gt 0) { $changed } else { '(none)' }
Write-Output ''
Write-Output 'Final grep:'
git grep -n -E "fontFamily.*SF Pro Text|SF Pro Text.*fontFamily" -- .
