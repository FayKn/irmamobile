param(
  [string]$inPath = "assets/simple-icons/data/simple-icons.json",
  [string]$outPath = "assets/simple-icons/data/simple-icons-fmt.json"
)

if (-not (Test-Path $inPath))
{
  write-Output "Input file not found: $inPath"

  write-Output "Updating git submodules...."
  git submodule update

  if (-not (Test-Path $inPath))
  {
    Write-Error "Input file still not found: $inPath after updating submodules; did you run this script before?"
    exit 1
  }
}


$data = Get-Content -Raw -Encoding utf8 $inPath | ConvertFrom-Json

$map = [ordered]@{ }
foreach ($item in $data)
{
  if ($null -eq $item.title)
  {
    continue
  }
  $key = $item.title.ToLowerInvariant().Trim()
  $map[$key] = $item.hex
}

$map | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 $outPath

Write-Output "Wrote $outPath"
