<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd xsl dc fn"
    xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:functx="http://www.functx.com" xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:vann="http://purl.org/vocab/vann/"
    version="3.0">

    <!-- a set of prefix-baseURI definitions -->
    <xsl:variable name="namespacePrefixes" select="fn:doc('namespaces.xml')"/>

    <!-- a mapping between UML atomic types to XSD datatypes  -->
    <xsl:variable name="umlDataTypesMapping" select="fn:doc('umlToXsdDataTypes.xml')"/>

    <!-- XSD datatypes that conform to OWL2 requirements   -->
    <xsl:variable name="xsdAndRdfDataTypes" select="fn:doc('xsdAndRdfDataTypes.xml')"/>
    
    <!--    Generate reused classes, attributes and connectors-->
    <xsl:variable name="internalModelPrefixesList" select="('epo', 'epo-not', 'epo-ord', 'epo-cat', 'epo-con', 'epo-ful', 'epo-sub', 'epo-inv', 'epo-acc')"/>
    
    <xsl:variable name="ignoredPrefixesList" select="('at-voc', 'at-voc-new')"/>

    <xsl:variable name="elementDefinitionXpath" select="'properties/@documentation'"/>
    <xsl:variable name="attributeDefinitionXpath" select="'documentation/@value'"/>
    <xsl:variable name="connectorDefinitionXpath" select="'documentation/@value'"/>
    <xsl:variable name="wgApprovalTagKey" select="'skos:historyNote'"/>
    <xsl:variable name="btgTagKey" select="'skos:editorialNote'"/>

    <!-- URIs list of UML versions supported by model2owl -->
    <xsl:variable name="supportedUmlVersions"
        select="('http://www.omg.org/spec/UML/20131001',
            'https://www.omg.org/spec/UML/20131001',
            'http://www.omg.org/spec/UML/20161101',
            'https://www.omg.org/spec/UML/20161101'
        )"/>

    

</xsl:stylesheet>