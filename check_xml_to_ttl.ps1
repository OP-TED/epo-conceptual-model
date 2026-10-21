$implPath = 'c:\Users\pasarni\work\epo-conceptual-model\implementation'

$modules = @(
    @{ Name='ePO_core';       Ttl='ePO_core\owl_ontology\ePO_core.ttl';            Xml='ePO_core\xmi_conceptual_model\ePO_core.xml' },
    @{ Name='eAccess';        Ttl='eAccess\owl_ontology\eAccess.ttl';              Xml='eAccess\xmi_conceptual_model\eAccess.xml' },
    @{ Name='eAwarding';      Ttl='eAwarding\owl_ontology\eAwarding.ttl';          Xml='eAwarding\xmi_conceptual_model\eAwarding.xml' },
    @{ Name='eCatalogue';     Ttl='eCatalogue\owl_ontology\eCatalogue.ttl';        Xml='eCatalogue\xmi_conceptual_model\eCatalogue.xml' },
    @{ Name='eContract';      Ttl='eContract\owl_ontology\eContract.ttl';          Xml='eContract\xmi_conceptual_model\eContract.xml' },
    @{ Name='eEvaluation';    Ttl='eEvaluation\owl_ontology\eEvaluation.ttl';      Xml='eEvaluation\xmi_conceptual_model\eEvaluation.xml' },
    @{ Name='eFulfilment';    Ttl='eFulfilment\owl_ontology\eFulfilment.ttl';      Xml='eFulfilment\xmi_conceptual_model\eFulfilment.xml' },
    @{ Name='eInvoicing';     Ttl='eInvoicing\owl_ontology\eInvoicing.ttl';        Xml='eInvoicing\xmi_conceptual_model\eInvoicing.xml' },
    @{ Name='eNotice';        Ttl='eNotice\owl_ontology\eNotice.ttl';              Xml='eNotice\xmi_conceptual_model\eNotice.xml' },
    @{ Name='eOrdering';      Ttl='eOrdering\owl_ontology\eOrdering.ttl';          Xml='eOrdering\xmi_conceptual_model\eOrdering.xml' },
    @{ Name='ePayment';       Ttl='ePayment\owl_ontology\ePayment.ttl';            Xml='ePayment\xmi_conceptual_model\ePayment.xml' },
    @{ Name='eQualification'; Ttl='eQualification\owl_ontology\eQualification.ttl';Xml='eQualification\xmi_conceptual_model\eQualification.xml' },
    @{ Name='eRequest';       Ttl='eRequest\owl_ontology\eRequest.ttl';            Xml='eRequest\xmi_conceptual_model\eRequest.xml' },
    @{ Name='eSubmission';    Ttl='eSubmission\owl_ontology\eSubmission.ttl';      Xml='eSubmission\xmi_conceptual_model\eSubmission.xml' }
)

function Get-IdNameMap($path) {
    $map = @{}
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if ($line -match 'xmi:id="([^"]+)"[^>]*name="([^"]+)"') { $map[$Matches[1]] = $Matches[2] }
        elseif ($line -match 'name="([^"]+)"[^>]*xmi:id="([^"]+)"') { $map[$Matches[2]] = $Matches[1] }
    }
    return $map
}

# Returns list of {SrcName, TgtName} from uml:Generalization elements
function Get-GenList($path, $idToName) {
    $list = [System.Collections.Generic.List[PSCustomObject]]::new()
    $curId = $null
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if ($line -match 'xmi:type="uml:Class".*xmi:id="([^"]+)"') { $curId = $Matches[1] }
        if ($line -match 'xmi:type="uml:Generalization".*general="([^"]+)"') {
            $tgtId = $Matches[1]
            $srcName = if ($idToName.ContainsKey($curId))  { $idToName[$curId]  } else { $null }
            $tgtName = if ($idToName.ContainsKey($tgtId))  { $idToName[$tgtId]  } else { $null }
            $list.Add([PSCustomObject]@{ SrcId=$curId; TgtId=$tgtId; SrcName=$srcName; TgtName=$tgtName })
        }
    }
    return $list
}

# Build set of subClassOf pairs from a TTL file: "subject|object" using epo: names
function Get-TtlPairSet($path) {
    $set = @{}
    $subject = $null; $inSub = $false
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        $t = $line.Trim()
        if ($t -match '^([:\w][^\s]*)\s+a\s+owl:Class') { $subject = $Matches[1]; $inSub = $false }
        if ($t -match 'rdfs:subClassOf\s+(.+)') {
            $inSub = $true
            foreach ($part in ($Matches[1] -split ',')) {
                $obj = ($part -replace '[;,\s]+$','').Trim()
                if ($obj) { $set["$subject|$obj"] = $true }
            }
            if ($Matches[1] -match ';\s*$') { $inSub = $false }
        } elseif ($inSub -and $t -match '^([:\w][^\s,;]+)') {
            $obj = ($Matches[1] -replace '[;,]+$','').Trim()
            if ($obj) { $set["$subject|$obj"] = $true }
            if ($t -match ';\s*$') { $inSub = $false }
        } elseif ($inSub -and $t -notmatch '^[:\w]') { $inSub = $false }
    }
    return $set
}

# Convert any known epo prefix to :Foo for TTL lookup
# Covers epo:, epo-acc:, epo-awa:, epo-cat:, epo-con:, epo-eva:, epo-ful:, epo-inv:, epo-not:, epo-ord:, epo-pay:, epo-qua:, epo-req:, epo-sub:
function EpoToTtl($n) {
    if ($n -match '^epo(?:-[a-z]+)?:(.+)$') { return ':' + $Matches[1] }
    return $n
}

foreach ($mod in $modules) {
    $ttlPath = Join-Path $implPath $mod.Ttl
    $xmlPath = Join-Path $implPath $mod.Xml

    $idToName = Get-IdNameMap $xmlPath
    $gens     = Get-GenList $xmlPath $idToName
    $ttlPairs = Get-TtlPairSet $ttlPath

    $found = 0
    $missing = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($g in $gens) {
        $srcTtl = EpoToTtl $g.SrcName
        $tgtTtl = EpoToTtl $g.TgtName

        # Skip ProxyConnector artefacts
        if ($g.SrcName -eq 'ProxyConnector') { continue }

        # Skip external-to-external: both source and target are non-epo (neither starts with epo or :)
        $srcIsEpo = $g.SrcName -match '^epo(?:-[a-z]+)?:'
        $tgtIsEpo = $g.TgtName -match '^epo(?:-[a-z]+)?:'
        if (-not $srcIsEpo -and -not $tgtIsEpo) { continue }

        $note = ''
        if (-not $g.SrcName) { $note = '[src name unknown]' }
        elseif (-not $g.TgtName) { $note = '[tgt name unknown]' }

        if ($srcTtl -and $tgtTtl -and $ttlPairs.ContainsKey("$srcTtl|$tgtTtl")) {
            $found++
        } else {
            $missing.Add([PSCustomObject]@{
                SrcName = $g.SrcName
                TgtName = $g.TgtName
                Note    = $note
            })
        }
    }

    Write-Host "=== $($mod.Name) ==="
    Write-Host "  uml:Generalization total : $($gens.Count)"
    Write-Host "  matched to subClassOf    : $found"
    Write-Host "  missing                  : $($missing.Count)"
    if ($missing.Count -gt 0) {
        $missing | Sort-Object SrcName,TgtName | ForEach-Object {
            $label = if ($_.Note) { "  $($_.Note)" } else { '' }
            Write-Host ("    " + $_.SrcName + " -> " + $_.TgtName + $label)
        }
    }
    Write-Host ""
}
