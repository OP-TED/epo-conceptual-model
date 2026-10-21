$implPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation'
$outPath  = 'c:\Users\pasarni\work\epo-conceptual-model\elements_without_status.csv'

$xmlFiles = Get-ChildItem -Path $implPath -Recurse -Filter '*.xml' |
    Where-Object { $_.DirectoryName -match 'xmi_conceptual_model' -and $_.Name -ne 'ePO_core (1).xml' }

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($f in $xmlFiles) {
    $module = $f.Directory.Parent.Name
    $lines  = [System.IO.File]::ReadAllLines($f.FullName)
    $n      = $lines.Length

    $i = 0
    while ($i -lt $n) {
        $line = $lines[$i]
        # Detect start of an <element xmi:idref ... xmi:type="uml:Class|uml:Enumeration|..." ...>
        if ($line -match '<element xmi:idref="([^"]+)"[^>]*xmi:type="([^"]+)"[^>]*name="([^"]+)"') {
            $elId   = $Matches[1]
            $elType = $Matches[2]
            $elName = $Matches[3]

            # Only care about modelling elements (Class, Enumeration, DataType, Interface)
            if ($elType -match 'uml:(Class|Enumeration|DataType|Interface)') {
                # Scan forward to find </element>, track whether epo:status tag appears
                $hasStatus = $false
                $j = $i + 1
                while ($j -lt $n -and $lines[$j] -notmatch '</element>') {
                    if ($lines[$j] -match 'name="epo:status"') { $hasStatus = $true; break }
                    $j++
                }
                if (-not $hasStatus) {
                    $results.Add([PSCustomObject]@{
                        Module  = $module
                        File    = $f.Name
                        'xmi:id'   = $elId
                        'xmi:type' = $elType
                        Name    = $elName
                    })
                }
                $i = $j  # skip to end of element block
            }
        }
        $i++
    }
}

# Find DataType names that appear in more than one module and remove them
$dupDataTypeNames = $results | Where-Object { $_.'xmi:type' -eq 'uml:DataType' } |
    Group-Object Name | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }

$filtered = $results | Where-Object {
    $_.'xmi:type' -ne 'uml:Enumeration' -and
    -not ($_.'xmi:type' -eq 'uml:DataType' -and $dupDataTypeNames -contains $_.Name)
}

$filtered | Export-Csv $outPath -NoTypeInformation
Write-Host "Done. Total elements without epo:status (after dedup): $($filtered.Count)"
$filtered | Group-Object Module | Sort-Object Name | ForEach-Object {
    Write-Host ("  " + $_.Name + ": " + $_.Count)
}
