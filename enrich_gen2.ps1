$csvPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation\ePO_core\xmi_conceptual_model\generalizations_comparison.csv'
$implPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation'

# Convert "epo:Foo" -> ":Foo", others stay as-is (cccev:Foo, etc.)
function To-TtlName($name) {
    if (-not $name -or $name -eq '' -or $name -eq '(not present)') { return $null }
    if ($name -match '^epo:(.+)$') { return ':' + $Matches[1] }
    return $name
}

# Collect all subClassOf pairs (subject, object) from all TTL files
$pairs = @{}  # key = "subject|object" -> $true

$ttlFiles = Get-ChildItem -Path $implPath -Recurse -Filter '*.ttl'
foreach ($f in $ttlFiles) {
    $lines = [System.IO.File]::ReadAllLines($f.FullName)
    $subject = $null
    foreach ($line in $lines) {
        $t = $line.Trim()
        # New subject: lines like ":ClassName a owl:Class" or "prefix:ClassName a owl:Class"
        if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') {
            $subject = $Matches[1]
        }
        # subClassOf line: "rdfs:subClassOf :Foo ;" or "rdfs:subClassOf :Foo," or continuation "    :Foo ;"
        if ($subject -and $t -match 'rdfs:subClassOf\s+(.+)') {
            $rest = $Matches[1]
            # extract all targets (comma or semicolon separated, strip trailing punctuation)
            $targets = $rest -split ',' | ForEach-Object { ($_ -replace '[;,\s]+$','').Trim() } | Where-Object { $_ -ne '' }
            foreach ($tgt in $targets) {
                $pairs["$subject|$tgt"] = $true
            }
        } elseif ($subject -and $t -match '^([:\w][^\s,;]+)\s*[,;]?\s*$' -and $lines[[array]::IndexOf($lines,$line)-1] -match 'subClassOf') {
            # continuation line after subClassOf with comma
        }
    }
}

# Also handle continuation lines (subClassOf with comma, next line is the extra target)
foreach ($f in $ttlFiles) {
    $lines = [System.IO.File]::ReadAllLines($f.FullName)
    $subject = $null
    $inSubClassOf = $false
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') { $subject = $Matches[1]; $inSubClassOf = $false }
        if ($t -match 'rdfs:subClassOf') { $inSubClassOf = $true }
        elseif ($inSubClassOf -and $t -match '^([:\w][^\s,;]+)') {
            $tgt = ($Matches[1] -replace '[;,]+$','').Trim()
            if ($tgt -and $subject) { $pairs["$subject|$tgt"] = $true }
            if ($t -match ';$') { $inSubClassOf = $false }
        } else { $inSubClassOf = $false }
    }
}

$rows = Import-Csv $csvPath
$out = @()
foreach ($row in $rows) {
    $src  = To-TtlName $row.'source class (ePO_core.xml)'
    $tgt  = To-TtlName $row.'target class (ePO_core.xml)'
    $found = ''
    if ($src -and $tgt) {
        $found = if ($pairs.ContainsKey("$src|$tgt")) { 'YES' } else { 'NO' }
    }
    $obj = [ordered]@{}
    foreach ($prop in $row.PSObject.Properties) { $obj[$prop.Name] = $prop.Value }
    $obj['subClassOf in TTL'] = $found
    $out += [PSCustomObject]$obj
}

$outPath = $csvPath -replace '\.csv$', '_enriched.csv'
$out | Export-Csv $outPath -NoTypeInformation
Write-Host "Done. Pairs collected: $($pairs.Count). Rows: $($out.Count). Written to: $outPath"
