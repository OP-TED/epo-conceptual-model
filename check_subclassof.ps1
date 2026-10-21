$xmlPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\ePO_core.xml'
$implPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation'

# --- Build id->name map from ePO_core.xml ---
$idToName = @{}
$xmlLines = [System.IO.File]::ReadAllLines($xmlPath)
foreach ($line in $xmlLines) {
    if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"') { $idToName[$Matches[1]] = $Matches[2] }
    elseif ($line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') { $idToName[$Matches[2]] = $Matches[1] }
}

# --- Build name->id map (reverse, epo: prefix) ---
$nameToId = @{}
foreach ($k in $idToName.Keys) { $nameToId[$idToName[$k]] = $k }

# --- Build set of generalization pairs (sourceId|targetId) from ePO_core.xml ---
# Also map genId -> sourceId and genId -> targetId
$genPairs = @{}   # "sourceId|targetId" -> genId
$currentClassId = $null
foreach ($line in $xmlLines) {
    if ($line -match 'xmi:type="uml:Class".*xmi:id="([^"]+)"') { $currentClassId = $Matches[1] }
    if ($line -match 'xmi:type="uml:Generalization".*xmi:id="([^"]+)".*general="([^"]+)"') {
        $genId = $Matches[1]; $targetId = $Matches[2]
        if ($currentClassId) { $genPairs["$currentClassId|$targetId"] = $genId }
    }
}

# --- Collect all subClassOf statements from owl_ontology non-restrictions TTL files ---
$ttlFiles = Get-ChildItem -Path $implPath -Recurse -Filter '*.ttl' |
    Where-Object { $_.DirectoryName -match 'owl_ontology' -and $_.Name -notmatch 'restrictions' }

# Parse TTL: track current subject, collect (subject, object) for rdfs:subClassOf
# Handle both single-line and multi-line (comma continuation)
$allPairs = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($f in $ttlFiles) {
    $lines = [System.IO.File]::ReadAllLines($f.FullName)
    $subject = $null
    $inSubClassOf = $false
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $t = $lines[$i].Trim()
        # New subject declaration
        if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') { $subject = $Matches[1]; $inSubClassOf = $false }
        # subClassOf line - extract all objects on same line
        if ($t -match 'rdfs:subClassOf\s+(.+)') {
            $inSubClassOf = $true
            $rest = $Matches[1]
            # split by comma, strip trailing ; or ,
            foreach ($part in ($rest -split ',')) {
                $obj = ($part -replace '[;,\s]+$','').Trim()
                if ($obj -and $obj -ne '') {
                    $allPairs.Add([PSCustomObject]@{ File=$f.Name; Subject=$subject; Object=$obj })
                }
            }
            # if line ends with ; it's done, if ends with , next line continues
            if ($rest -match ';\s*$') { $inSubClassOf = $false }
        } elseif ($inSubClassOf -and $t -match '^([:\w][^\s,;]+)') {
            $obj = ($Matches[1] -replace '[;,]+$','').Trim()
            if ($obj) { $allPairs.Add([PSCustomObject]@{ File=$f.Name; Subject=$subject; Object=$obj }) }
            if ($t -match ';\s*$') { $inSubClassOf = $false }
        } elseif ($inSubClassOf -and $t -notmatch '^[:\w]') {
            $inSubClassOf = $false
        }
    }
}

Write-Host "Total rdfs:subClassOf statements collected: $($allPairs.Count)"

# --- For each TTL pair, resolve to epo names and look up in ePO_core.xml generalizations ---
# TTL uses : for epo namespace, prefix:Name for others
function TtlToEpo($name) {
    if ($name -match '^:(.+)$') { return 'epo:' + $Matches[1] }
    return $name
}

$missing = [System.Collections.Generic.List[PSCustomObject]]::new()
$found = 0

foreach ($pair in $allPairs) {
    $srcName = TtlToEpo $pair.Subject
    $tgtName = TtlToEpo $pair.Object
    $srcId = if ($nameToId.ContainsKey($srcName)) { $nameToId[$srcName] } else { $null }
    $tgtId = if ($nameToId.ContainsKey($tgtName)) { $nameToId[$tgtName] } else { $null }

    if ($srcId -and $tgtId) {
        if ($genPairs.ContainsKey("$srcId|$tgtId")) {
            $found++
        } else {
            $missing.Add([PSCustomObject]@{
                File    = $pair.File
                Subject = $srcName
                Object  = $tgtName
            })
        }
    } else {
        # IDs not found in ePO_core.xml - external class or not in core
        $missing.Add([PSCustomObject]@{
            File    = $pair.File
            Subject = $srcName
            Object  = $tgtName
        })
    }
}

Write-Host "Matched to generalization in ePO_core.xml: $found"
Write-Host "No matching generalization found: $($missing.Count)"
Write-Host ""
Write-Host "=== MISSING GENERALIZATIONS ==="
$missing | Sort-Object Subject,Object | ForEach-Object {
    Write-Host ("  [" + $_.File + "] " + $_.Subject + " -> " + $_.Object)
}
