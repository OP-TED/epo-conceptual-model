<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd xsl dc fn"
    xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:functx="http://www.functx.com" xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:vann="http://purl.org/vocab/vann/"
    version="3.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 22, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> lps</xd:p>
            <xd:p>This module defines project level variables and parameters</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:variable name="namespacePrefixes" select="fn:doc('namespaces.xml')"/>
    <xsl:variable name="umlDataTypesMapping" select="fn:doc('umlToXsdDataTypes.xml')"/>
    <xsl:variable name="xsdAndRdfDataTypes" select="fn:doc('xsdAndRdfDataTypes.xml')"/>
    <xsl:variable name="metadataJson" select="fn:json-doc('metadata.json')"/>
    <xsl:variable name="defaultNamespaceInterpretation" select="fn:true()"/>
    <xsl:variable name="base-ontology-uri" select="'http://data.europa.eu/a4g/ontology'"/>
    <xsl:variable name="base-shape-uri" select="'http://data.europa.eu/a4g/data-shape'"/>
    <xsl:variable name="base-restriction-uri" select="$base-ontology-uri"/>
    <xsl:variable name="shapeArtefactURI" select="fn:concat($base-shape-uri,$defaultDelimiter, $moduleReference, '-shape')"/>
    <xsl:variable name="restrictionsArtefactURI" select="fn:concat($base-restriction-uri, $defaultDelimiter, $moduleReference, '-restriction')"/>
    <xsl:variable name="coreArtefactURI" select="fn:concat($base-ontology-uri, $defaultDelimiter, $moduleReference)"/>
    <xsl:variable name="defaultDelimiter" select="'#'"/>
    <xsl:variable name="nodeShapeURIsuffix" select="'Shape'"/>
    <xsl:variable name="acceptableTypesForObjectProperties" select="('epo:Identifier', 'rdfs:Literal')"/>
    <xsl:variable name="controlledListType" select="'epo:Code'"/>
    <xsl:variable name="stereotypeValidOnAttributes" select="()"/>
    <xsl:variable name="stereotypeValidOnObjects" select="()"/>
    <xsl:variable name="stereotypeValidOnGeneralisations" select="('Disjoint', 'Equivalent', 'Complete')"/>
    <xsl:variable name="stereotypeValidOnAssociations" select="()"/>
    <xsl:variable name="stereotypeValidOnDependencies" select="('Disjoint', 'disjoint', 'join')"/>
    <xsl:variable name="stereotypeValidOnClasses" select="('Abstract')"/>
    <xsl:variable name="stereotypeValidOnDatatypes" select="()"/>
    <xsl:variable name="stereotypeValidOnEnumerations" select="()"/>
    <xsl:variable name="stereotypeValidOnPackages" select="()"/>
    <xsl:variable name="abstractClassesStereotypes" select="('Abstract', 'abstract class', 'abstract')"/>
    <xsl:variable name="enableGenerationOfSkosConcept" select="fn:false()"/>
    <xsl:variable name="enableGenerationOfConceptSchemes" select="fn:false()"/>
    <xsl:variable name="cvConstraintLevelProperty" select="'epo:constraintLevel'"/>
    <xsl:variable name="allowedStrings" select="'^[\w\d-_:]+$'"/>
    <xsl:variable name="includedPrefixesList" select="('epo', 'epo-not', 'epo-ord', 'epo-cat', 'epo-con', 'epo-ful','epo-eva','epo-awa','epo-qua','epo-req', 'epo-sub', 'epo-acc', 'epo-inv', 'epo-pay')"/>
    <xsl:variable name="generateReusedConceptsSHACL" select="fn:false()"/>
    <xsl:variable name="generateReusedConceptsOWLcore" select="fn:false()"/>
    <xsl:variable name="generateReusedConceptsOWLrestrictions" select="fn:false()"/>
    <xsl:variable name="generateReusedConceptsGlossary" select="fn:false()"/>
    <xsl:variable name="generateReusedConceptsJSONLDcontext" select="fn:false()"/>
    <xsl:variable name="commentsGeneration" select="fn:false()"/>
    <xsl:variable name="commentProperty" select="'skos:editorialNote'"/>
    <xsl:variable name="usageNoteTagName" select="'skos:note'"/>
    <xsl:variable name="excludedTagNamesList" select="($statusProperty, $cvConstraintLevelProperty)"/>
    <xsl:variable name="mandatoryStatusTagName" select="'cfg:usage'"/>
    <xsl:variable name="referenceTagName" select="'dcterms:references'"/>
    <xsl:variable name="propertyReferenceRespecLabel" select="'Reuse'"/>
    <xsl:variable name="classReferenceRespecLabel" select="'Reference'"/>
    <xsl:variable name="showReferencesInRespec" select="fn:false()"/>
    <xsl:variable name="customTermLabelTagName" select="'skos:prefLabel'"/>
    <xsl:variable name="statusProperty" select="'epo:status'"/>
    <xsl:variable name="validStatusesList" select="('proposed', 'approved', 'implemented')"/>
    <xsl:variable name="excludedElementStatusesList" select="('proposed', 'approved')"/>
    <xsl:variable name="unspecifiedStatusInterpretation" select="'implemented'"/>
    <xsl:variable name="generateObjectsAndRealisations" select="fn:false()"/>
    <xsl:variable name="supportedUmlVersions"
        select="('http://www.omg.org/spec/UML/20131001',
            'https://www.omg.org/spec/UML/20131001',
            'http://www.omg.org/spec/UML/20161101',
            'https://www.omg.org/spec/UML/20161101'
        )"/>
    <xsl:variable name="translatePlainLiteralToStringTypesInSHACL" select="fn:true()"/>
    <xsl:variable name="annotateShaclConceptsWithOntology" select="fn:true()"/>
    <xsl:variable name="moduleReference" select="'not'"/>
    <xsl:variable name="issuedDate" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>

</xsl:stylesheet>
