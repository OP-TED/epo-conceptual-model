$implPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation'

$modules = @(
    @{ Name='ePO_core';      Ttl='ePO_core\owl_ontology\ePO_core.ttl';           Xml='ePO_core\xmi_conceptual_model\ePO_core.xml' },
    @{ Name='eAccess';       Ttl='eAccess\owl_ontology\eAccess.ttl';             Xml='eAccess\xmi_conceptual_model\eAccess.xml' },
    @{ Name='eAwarding';     Ttl='eAwarding\owl_ontology\eAwarding.ttl';         Xml='eAwarding\xmi_conceptual_model\eAwarding.xml' },
    @{ Name='eCatalogue';    Ttl='eCatalogue\owl_ontology\eCatalogue.ttl';       Xml='eCatalogue\xmi_conceptual_model\eCatalogue.xml' },
    @{ Name='eContract';     Ttl='eContract\owl_ontology\eContract.ttl';         Xml='eContract\xmi_conceptual_model\eContract.xml' },
    @{ Name='eEvaluation';   Ttl='eEvaluation\owl_ontology\eEvaluation.ttl';     Xml='eEvaluation\xmi_conceptual_model\eEvaluation.xml' },
    @{ Name='eFulfilment';   Ttl='eFulfilment\owl_ontology\eFulfilment.ttl';     Xml='eFulfilment\xmi_conceptual_model\eFulfilment.xml' },
    @{ Name='eInvoicing';    Ttl='eInvoicing\owl_ontology\eInvoicing.ttl';       Xml='eInvoicing\xmi_conceptual_model\eInvoicing.xml' },
    @{ Name='eNotice';       Ttl='eNotice\owl_ontology\eNotice.ttl';             Xml='eNotice\xmi_conceptual_model\eNotice.xml' },
    @{ Name='eOrdering';     Ttl='eOrdering\owl_ontology\eOrdering.ttl';         Xml='eOrdering\xmi_conceptual_model\eOrdering.xml' },
    @{ Name='ePayment';      Ttl='ePayment\owl_ontology\ePayment.ttl';           Xml='ePayment\xmi_conceptual_model\ePayment.xml' },
    @{ Name='eQualification';Ttl='eQualification\owl_ontology\eQualification.ttl';Xml='eQualification\xmi_conceptual_model\eQualification.xml' },
    @{ Name='eRequest';      Ttl='eRequest\owl_ontology\eRequest.ttl';           Xml='eRequest\xmi_conceptual_model\eRequest.xml' },
    @{ Name='eSubmission';   Ttl='eSubmission\owl_ontology\eSubmission.ttl';     Xml='eSubmission\xmi_conceptual_model\eSubmission.xml' }
)

function Get-IdNameMap($path) {
    $map = @{}
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"') { $map[$Matches[1]] = $Matches[2] }
        elseif ($line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') { $map[$Matches[2]] = $Matches[1] }
    }
    return $map
}

function Get-GenPairs($path) {
    $pairs = @{}
    $curId = $null
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if ($line -match 'xmi:type="uml:Class".*xmi:id="([^"]+)"') { $curId = $Matches[1] }
        if ($line -match 'xmi:type="uml:Generalization".*xmi:id="[^"]+".*general="([^"]+)"') {
            if ($curId) { $pairs["$curId|$($Matches[1])"] = $true }
        }
    }
    return $pairs
}

function Get-TtlPairs($path) {
    $pairs = [System.Collections.Generic.List[PSCustomObject]]::new()
    $subject = $null; $inSub = $false
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        $t = $line.Trim()
        if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') { $subject = $Matches[1]; $inSub = $false }
        if ($t -match 'rdfs:subClassOf\s+(.+)') {
            $inSub = $true
            foreach ($part in ($Matches[1] -split ',')) {
                $obj = ($part -replace '[;,\s]+$','').Trim()
                if ($obj) { $pairs.Add([PSCustomObject]@{ S=$subject; O=$obj }) }
            }
            if ($Matches[1] -match ';\s*$') { $inSub = $false }
        } elseif ($inSub -and $t -match '^([:\w][^\s,;]+)') {
            $obj = ($Matches[1] -replace '[;,]+$','').Trim()
            if ($obj) { $pairs.Add([PSCustomObject]@{ S=$subject; O=$obj }) }
            if ($t -match ';\s*$') { $inSub = $false }
        } elseif ($inSub -and $t -notmatch '^[:\w]') { $inSub = $false }
    }
    return $pairs
}

function TtlToName($n) { if ($n -match '^:(.+)$') { return 'epo:' + $Matches[1] } return $n }

foreach ($mod in $modules) {
    $ttlPath = Join-Path $implPath $mod.Ttl
    $xmlPath = Join-Path $implPath $mod.Xml

    $idToName = Get-IdNameMap $xmlPath
    $nameToId = @{}; foreach ($k in $idToName.Keys) { $nameToId[$idToName[$k]] = $k }
    $genPairs = Get-GenPairs $xmlPath
    $ttlPairs = Get-TtlPairs $ttlPath

    $found = 0
    $missing = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($p in $ttlPairs) {
        $src = TtlToName $p.S; $tgt = TtlToName $p.O
        $srcId = $nameToId[$src]; $tgtId = $nameToId[$tgt]
        if ($srcId -and $tgtId -and $genPairs.ContainsKey("$srcId|$tgtId")) {
            $found++
        } else {
            $missing.Add([PSCustomObject]@{
                Subject = $src; Object = $tgt
                Note = $(if (-not $srcId) { '[src not in XML]' } elseif (-not $tgtId) { '[tgt not in XML]' } else { '[gen missing]' })
            })
        }
    }

    Write-Host "=== $($mod.Name) ==="
    Write-Host "  rdfs:subClassOf total : $($ttlPairs.Count)"
    Write-Host "  matched to uml:Gen    : $found"
    Write-Host "  missing               : $($missing.Count)"
    if ($missing.Count -gt 0) {
        $missing | Sort-Object Subject,Object | ForEach-Object {
            Write-Host ("    " + $_.Subject + " -> " + $_.Object + "  " + $_.Note)
        }
    }
    Write-Host ""
}
