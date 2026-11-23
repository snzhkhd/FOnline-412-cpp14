param(
    [string]$AnalysisDirectory = (Join-Path $PSScriptRoot 'build/analysis')
)

$ErrorActionPreference = 'Stop'
$reports = @(Get-ChildItem -LiteralPath $AnalysisDirectory -Recurse -File -Filter '*.nativecodeanalysis.xml')
if ($reports.Count -eq 0) {
    throw 'No MSVC analysis reports found. Run analyze_code.bat first.'
}

$repoPrefix = $PSScriptRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$memoryWarnings = @(6386, 6385, 6201, 6011, 28182, 6001, 6054)
$findings = @{}

foreach ($report in $reports) {
    $xml = [xml](Get-Content -LiteralPath $report.FullName -Raw -Encoding UTF8)
    foreach ($defect in $xml.SelectNodes('/DEFECTS/DEFECT')) {
        $code = [int]$defect.DEFECTCODE
        $file = Join-Path ([string]$defect.SFA.FILEPATH) ([string]$defect.SFA.FILENAME)
        if ($file.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            $file = $file.Substring($repoPrefix.Length)
        }
        $line = [int]$defect.SFA.LINE
        $column = [int]$defect.SFA.COLUMN
        $key = "$code|${file}|${line}|$column"
        if ($findings.ContainsKey($key)) {
            continue
        }

        # Engine files live directly under Source. Put bundled libraries and SDK headers last.
        $priority = 3
        if ($file -match '^Source[\\/][^\\/]+$') {
            $priority = 2
            if ($code -in $memoryWarnings) {
                $priority = 1
            }
        }
        $findings[$key] = [pscustomobject]@{
            Priority = $priority
            RuleOrder = [array]::IndexOf($memoryWarnings, $code)
            Code = "C$code"
            File = $file
            Line = $line
            Column = $column
            Description = [string]$defect.DESCRIPTION
        }
    }
}

$ordered = @($findings.Values | Sort-Object Priority, RuleOrder, Code, File, Line, Column)
$csv = Join-Path $AnalysisDirectory 'findings.csv'
if ($ordered.Count -gt 0) {
    $ordered | Select-Object Priority, Code, File, Line, Column, Description | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
} else {
    '"Priority","Code","File","Line","Column","Description"' | Set-Content -LiteralPath $csv -Encoding UTF8
}

$first = @($ordered | Where-Object Priority -eq 1)
Write-Host "$($ordered.Count) unique warnings; $($first.Count) memory-related warnings in engine code."
$first | Select-Object -First 15 | ForEach-Object {
    Write-Host ('  {0}  {1}:{2}:{3}' -f $_.Code, $_.File, $_.Line, $_.Column)
}
Write-Host "Sorted report: $csv"
