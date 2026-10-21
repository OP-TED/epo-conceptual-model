$base = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model'
$file1 = "$base\ePO_core.xml"
$file2 = "$base\ePO_core (1).xml"
$out   = "$base\generalizations_comparison.csv"

function Get-Generalizations($path) {
    $result = @{}
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if ($line -match 'uml:Generalization') {
            $id  = if ($line -match 'xmi:id="([^"]+)"')  { $matches[1] } else { '' }
            $gen = if ($line -match 'general="([^"]+)"') { $matches[1] } else { '' }
            if ($id) { $result[$id] = $gen }
        }
    }
    return $result
}

$g1 = Get-Generalizations $file1
$g2 = Get-Generalizations $file2

$allIds = ($g1.Keys + $g2.Keys) | Sort-Object -Unique

$lines = @('xmi:id,general (ePO_core.xml),general (ePO_core (1).xml),Match')
foreach ($id in $allIds) {
    $v1    = if ($g1.ContainsKey($id)) { $g1[$id] } else { '(not present)' }
    $v2    = if ($g2.ContainsKey($id)) { $g2[$id] } else { '(not present)' }
    $match = if ($v1 -eq $v2) { 'YES' } else { 'NO' }
    $lines += "$id,$v1,$v2,$match"
}

[System.IO.File]::WriteAllLines($out, $lines, [System.Text.Encoding]::UTF8)
Write-Host "Done. Rows: $($lines.Count - 1)"
