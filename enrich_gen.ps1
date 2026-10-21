$file1 = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\ePO_core.xml'
$file2 = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\ePO_core (1).xml'
$csvIn = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\generalizations_comparison.csv'
$csvOut = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\generalizations_comparison.csv'

# Build id->name map from both files
function Get-IdNameMap($path) {
    $map = @{}
    $lines = [System.IO.File]::ReadAllLines($path)
    foreach ($line in $lines) {
        if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"' -or $line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') {
            if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"') {
                $map[$Matches[1]] = $Matches[2]
            } elseif ($line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') {
                $map[$Matches[2]] = $Matches[1]
            }
        }
    }
    return $map
}

# Build generalization id -> source (child) class id from a file
# Generalizations are nested inside packagedElement (the child class)
function Get-GenSourceMap($path) {
    $map = @{}
    $lines = [System.IO.File]::ReadAllLines($path)
    $currentClassId = $null
    foreach ($line in $lines) {
        if ($line -match 'xmi:type="uml:Class".*xmi:id="([^"]+)"') {
            $currentClassId = $Matches[1]
        }
        if ($line -match 'xmi:type="uml:Generalization".*xmi:id="([^"]+)"') {
            $genId = $Matches[1]
            $map[$genId] = $currentClassId
        }
    }
    return $map
}

$map1 = Get-IdNameMap $file1
$map2 = Get-IdNameMap $file2
$src1 = Get-GenSourceMap $file1
$src2 = Get-GenSourceMap $file2

# Merge maps: prefer file1 name, fallback to file2
$allMap = @{}
foreach ($k in $map2.Keys) { $allMap[$k] = $map2[$k] }
foreach ($k in $map1.Keys) { $allMap[$k] = $map1[$k] }

function Resolve($id, $map) {
    if (-not $id -or $id -eq '') { return '' }
    if ($map.ContainsKey($id)) { return $map[$id] }
    return $id
}

$rows = Import-Csv $csvIn
$out = @()
foreach ($row in $rows) {
    $genId = $row.'xmi:id'
    $g1 = $row.'general (ePO_core.xml)'
    $g2 = $row.'general (ePO_core (1).xml)'

    # source: the child class that owns this generalization
    $srcId1 = if ($src1.ContainsKey($genId)) { $src1[$genId] } else { '' }
    $srcId2 = if ($src2.ContainsKey($genId)) { $src2[$genId] } else { '' }

    $out += [PSCustomObject]@{
        'xmi:id' = $genId
        'source class (ePO_core.xml)' = Resolve $srcId1 $allMap
        'general (ePO_core.xml)' = $g1
        'target class (ePO_core.xml)' = Resolve $g1 $allMap
        'source class (ePO_core (1).xml)' = Resolve $srcId2 $allMap
        'general (ePO_core (1).xml)' = $g2
        'target class (ePO_core (1).xml)' = Resolve $g2 $allMap
        'Match' = $row.Match
    }
}

$out | Export-Csv $csvOut -NoTypeInformation
Write-Host "Done. Rows: $($out.Count)"
