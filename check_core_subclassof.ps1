$xmlPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\ePO_core.xml'
$ttlPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\owl_ontology\ePO_core.ttl'

# Build id->name and name->id maps from ePO_core.xml
$idToName = @{}
foreach ($line in [System.IO.File]::ReadAllLines($xmlPath)) {
    if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"') { $idToName[$Matches[1]] = $Matches[2] }
    elseif ($line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') { $idToName[$Matches[2]] = $Matches[1] }
}
$nameToId = @{}
foreach ($k in $idToName.Keys) { $nameToId[$idToName[$k]] = $k }

# Build generalization pairs (sourceId|targetId) from ePO_core.xml
$genPairs = @{}
$currentClassId = $null
foreach ($line in [System.IO.File]::ReadAllLines($xmlPath)) {
    if ($line -match 'xmi:type="uml:Class".*xmi:id="([^"]+)"') { $currentClassId = $Matches[1] }
    if ($line -match 'xmi:type="uml:Generalization".*xmi:id="([^"]+)".*general="([^"]+)"') {
        if ($currentClassId) { $genPairs["$currentClassId|$($Matches[2])"] = $Matches[1] }
    }
}

# Parse ePO_core.ttl for all rdfs:subClassOf statements
$pairs = [System.Collections.Generic.List[PSCustomObject]]::new()
$subject = $null
$inSubClassOf = $false
foreach ($line in [System.IO.File]::ReadAllLines($ttlPath)) {
    $t = $line.Trim()
    if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') { $subject = $Matches[1]; $inSubClassOf = $false }
    if ($t -match 'rdfs:subClassOf\s+(.+)') {
        $inSubClassOf = $true
        foreach ($part in ($Matches[1] -split ',')) {
            $obj = ($part -replace '[;,\s]+$','').Trim()
            if ($obj) { $pairs.Add([PSCustomObject]@{ Subject=$subject; Object=$obj }) }
        }
        if ($Matches[1] -match ';\s*$') { $inSubClassOf = $false }
    } elseif ($inSubClassOf -and $t -match '^([:\w][^\s,;]+)') {
        $obj = ($Matches[1] -replace '[;,]+$','').Trim()
        if ($obj) { $pairs.Add([PSCustomObject]@{ Subject=$subject; Object=$obj }) }
        if ($t -match ';\s*$') { $inSubClassOf = $false }
    } elseif ($inSubClassOf -and $t -notmatch '^[:\w]') { $inSubClassOf = $false }
}

Write-Host "Total rdfs:subClassOf in ePO_core.ttl: $($pairs.Count)"

# Match each pair to a generalization in ePO_core.xml
function TtlToEpo($n) { if ($n -match '^:(.+)$') { return 'epo:' + $Matches[1] } return $n }

$found = 0
$missing = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($p in $pairs) {
    $src = TtlToEpo $p.Subject
    $tgt = TtlToEpo $p.Object
    $srcId = $nameToId[$src]
    $tgtId = $nameToId[$tgt]
    if ($srcId -and $tgtId -and $genPairs.ContainsKey("$srcId|$tgtId")) {
        $found++
    } else {
        $missing.Add([PSCustomObject]@{ Subject=$src; Object=$tgt; SrcIdFound=($null -ne $srcId); TgtIdFound=($null -ne $tgtId) })
    }
}

Write-Host "Matched to uml:Generalization: $found"
Write-Host "Missing: $($missing.Count)"
Write-Host ""
$missing | Sort-Object Subject,Object | ForEach-Object {
    $note = ''
    if (-not $_.SrcIdFound) { $note += ' [src not in XML]' }
    if (-not $_.TgtIdFound) { $note += ' [tgt not in XML]' }
    Write-Host ("  " + $_.Subject + " -> " + $_.Object + $note)
}
