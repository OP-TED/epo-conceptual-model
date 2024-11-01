<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math xd xsl uml xmi umldi dc fn"
    xmlns:uml="http://www.omg.org/spec/UML/20131001"
    xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
    xmlns:umldi="http://www.omg.org/spec/UML/20131001/UMLDI"
    xmlns:dc="http://www.omg.org/spec/UML/20131001/UMLDC" xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:f="http://https://github.com/costezki/model2owl#" version="3.0">
    
    <xsl:import href="../common/utils.xsl"/>
    <xsl:import href="../common/metadata-utils.xsl"/>


    <xd:doc>
        <xd:desc>Testing all classes and attributes</xd:desc>
    </xd:doc>
    <xsl:template name="elementMetadataChecks">
        <xsl:param name="eaObjType" as="xs:string"/>
        <xsl:variable name="elements" select="root()//element[@xmi:type = $eaObjType]"/>
        <xsl:for-each select="$elements">
            <xsl:variable name="elementName" select="f:getElementName(.)"/>
            <xsl:variable name="classChecks" as="item()*">
                    <xsl:call-template name="wgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="btgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="externalTermDefLink">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="classAttributeChecks" as="item()*">
                <xsl:variable name="attributes" select="attributes/attribute"/>
                <xsl:for-each select="$attributes">
                    <xsl:call-template name="wgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="./@name"/>
                        <xsl:with-param name="objType" select="'Attribute'"/>
                    </xsl:call-template>
                    <xsl:call-template name="btgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="./@name"/>
                        <xsl:with-param name="objType" select="'Attribute'"/>
                    </xsl:call-template>
                    <xsl:call-template name="externalTermDefLink">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="./@name"/>
                        <xsl:with-param name="objType" select="'Attribute'"/>
                    </xsl:call-template>
                </xsl:for-each>
                
            </xsl:variable>
            <xsl:if test="boolean($classChecks) or boolean($classAttributeChecks)">
                <h2 id="{$elementName}">
                    <xsl:value-of select="$elementName"/>
                </h2>
                <section>
                    <xsl:if test="boolean($classChecks)">
                        <dl>
                            <xsl:copy-of select="$classChecks"/>
                        </dl>
                    </xsl:if>
                    <xsl:if test="boolean($classAttributeChecks)">
                        <xsl:copy-of select="$classAttributeChecks"/>
                    </xsl:if>
                </section>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xd:doc>
        <xd:desc>Testing connectors</xd:desc>
    </xd:doc>
    <xsl:template name="connectorMetadataChecks">
        <xsl:param name="eaObjType" as="xs:string"/>
        <xsl:variable name="connectors" select="root()//connectors/connector[./properties/@ea_type = $eaObjType]"/>
        <xsl:for-each select="$connectors">
            <xsl:variable name="connectorDisplayName" select="f:getConnectorName(.)"/>
            <xsl:variable name="connectorName" select="./target/role/@name"/>
            <xsl:variable name="connectorChecks" as="item()*">
                    <xsl:call-template name="wgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="btgMetadata">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="externalTermDefLink">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>                
            </xsl:variable>
            <xsl:if test="boolean($connectorChecks)">
                <h2>
                    <xsl:value-of select="$connectorDisplayName"/>
                </h2>
                <dl>
                    <xsl:copy-of select="$connectorChecks"/>
                </dl>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            Verifies that an object definition does not contain WG approval
            metadata.
        </xd:desc>
        <xd:param name="class"/>
    </xd:doc>
    <xsl:template name="wgMetadata">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="definition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
            <xsl:sequence
                select="
                    if (fn:boolean($definition) and f:hasWgApprovalMetadata($definition))
                    then
                        f:generateFailureMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'WG approval metadata found in the term definition.')
                        )
                    else
                        f:generateSuccessMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'The term definition does not contain WG approval metadata.')
                        )
                    "
            />
    </xsl:template>

    <xd:doc>
        <xd:desc>
        </xd:desc>
        <xd:param name="obj"/>
    </xd:doc>
    <xsl:template name="btgMetadata">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
            <xsl:sequence
                select="
                    if (fn:boolean($originalDefinition) and f:hasBtgTermIdMetadata($originalDefinition))
                    then
                        f:generateFailureMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'eForms (BT/BG identifier) metadata found in the ther definition. ')
                        )
                    else
                        f:generateSuccessMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'The term definition does not contain eForms (BT/BG identifier) metadata. ')
                        )"
            />
    </xsl:template>

    <xd:doc>
        <xd:desc>
            Checks if existing definition was replaced by a link pointing to original definition
            of the given external term.
        </xd:desc>
        <xd:param name="originalElement"/>
        <xd:param name="changedElement"/>
    </xd:doc>
    <xsl:template name="externalTermDefLink">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="ignoredPrefixesList" select="('at-voc', 'at-voc-new')"/>
        <xsl:variable name="termPrefix" select="fn:substring-before($objName, ':')"/>
        <xsl:variable name="isExternalTerm" as="xs:boolean"
            select="not($termPrefix = $internalModelPrefixesList or $termPrefix = $ignoredPrefixesList)"
        />
        <xsl:if test="$isExternalTerm">
            <xsl:variable name="definition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
                <xsl:sequence
                    select="
                        if (f:hasExtDefinitionMetadata($definition))
                        then
                            f:generateSuccessMessage(
                                fn:concat(
                                    f:genTermInfoByObjType($objName, $objType),
                                    'The definition of the external term contain an URL pointing to the term original definition. ')
                            )
                        else
                            f:generateFailureMessage(
                                fn:concat(
                                    f:genTermInfoByObjType($objName, $objType),
                                    'The definition of the external term does not contain an URL pointing to the term original definition. ')
                            )"
                />  
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>