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

    <!-- Original file that the updated one will be compared to -->
    <xsl:param name="changedXmiFilePath"/>
    <xsl:variable name="changedXmiFile" select="
        if (boolean($changedXmiFilePath)) then
            fn:doc($changedXmiFilePath)
        else fn:error(xs:QName('missing-parameter'), 'changedXmiFilePath is not given.')
    "/>

    <xd:doc>
        <xd:desc>Testing all classes and attributes</xd:desc>
    </xd:doc>
    <xsl:template name="elementMetadataChecks">
        <xsl:param name="eaObjType" as="xs:string"/>
        <xsl:variable name="elements" select="root()//element[@xmi:type = $eaObjType]"/>
        <xsl:for-each select="$elements">
            <xsl:variable name="elementName" select="f:getElementName(.)"/>
            <xsl:variable name="elementChecks" as="item()*">
                    <xsl:call-template name="elementExistence">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="wgMetadataTransferred">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="btgMetadataTransferred">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="externalTermDefLinkProvided">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$elementName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="classAttributeChecks" as="item()*">
                <xsl:if test="not($eaObjType = 'uml:Enumeration')">
                    <xsl:variable name="attributes" select="attributes/attribute"/>
                    <xsl:for-each select="$attributes">
                        <xsl:call-template name="elementExistence">
                            <xsl:with-param name="obj" select="."/>
                            <xsl:with-param name="objName" select="./@name"/>
                            <xsl:with-param name="objType" select="'Attribute'"/>
                        </xsl:call-template>
                        <xsl:call-template name="wgMetadataTransferred">
                            <xsl:with-param name="obj" select="."/>
                            <xsl:with-param name="objName" select="./@name"/>
                            <xsl:with-param name="objType" select="'Attribute'"/>
                        </xsl:call-template>
                        <xsl:call-template name="btgMetadataTransferred">
                            <xsl:with-param name="obj" select="."/>
                            <xsl:with-param name="objName" select="./@name"/>
                            <xsl:with-param name="objType" select="'Attribute'"/>
                        </xsl:call-template>
                        <xsl:call-template name="externalTermDefLinkProvided">
                            <xsl:with-param name="obj" select="."/>
                            <xsl:with-param name="objName" select="./@name"/>
                            <xsl:with-param name="objType" select="'Attribute'"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
            </xsl:variable>
            
            <xsl:if test="boolean($elementChecks) or boolean($classAttributeChecks)">
                <h2 id="{$elementName}">
                    <xsl:value-of select="$elementName"/>
                </h2>
                <section>
                    <xsl:if test="boolean($elementChecks)">
                        <dl>
                            <xsl:copy-of select="$elementChecks"/>
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
                    <xsl:call-template name="elementExistence">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="wgMetadataTransferred">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="btgMetadataTransferred">
                        <xsl:with-param name="obj" select="."/>
                        <xsl:with-param name="objName" select="$connectorName"/>
                        <xsl:with-param name="objType" select="$eaObjType"/>
                    </xsl:call-template>
                    <xsl:call-template name="externalTermDefLinkProvided">
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
        </xd:desc>
        <xd:param name="obj"/>
        <xd:param name="objName"/>
        <xd:param name="objType"/>
    </xd:doc>
    <xsl:template name="elementExistence">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>

        <xsl:variable name="objInChangedFile" as="node()" select="f:getEquivalentObject($obj, $objType, $changedXmiFile)"/>
        <xsl:sequence
            select="
                if (fn:boolean($objInChangedFile))
                then
                    f:generateSuccessMessage(
                        fn:concat(
                            f:genTermInfoByObjType($objName, $objType),
                            'The object was found in the changed file.')
                    )
                else
                    f:generateFailureMessage(
                        fn:concat(
                            f:genTermInfoByObjType($objName, $objType),
                            'The object cannot be found. It must have been either removed or renamed.')
                    )"
        />
    
    </xsl:template>

    <xd:doc>
        <xd:desc>
        </xd:desc>
        <xd:param name="class"/>
    </xd:doc>
    <xsl:template name="wgMetadataTransferred">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
        <xsl:if test="fn:boolean($originalDefinition) and f:hasWgApprovalMetadata($originalDefinition)">
            <xsl:variable name="changedObj" as="node()" select="f:getEquivalentObject($obj, $objType, $changedXmiFile)"/>
            <xsl:sequence
                select="
                    if (f:isWgMetadataTransferred($obj, $changedObj, $objType))
                    then
                        f:generateSuccessMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'WG approval metadata was modified correctly.')
                        )
                    else
                        f:generateFailureMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'WG approval metadata was not modified correctly.')
                        )"
            />
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
        </xd:desc>
        <xd:param name="obj"/>
    </xd:doc>
    <xsl:template name="btgMetadataTransferred">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
        <xsl:if test="fn:boolean($originalDefinition) and f:hasBtgTermIdMetadata($originalDefinition)">
            <xsl:variable name="changedObj" as="node()" select="f:getEquivalentObject($obj, $objType, $changedXmiFile)"/>
            <xsl:sequence
                select="
                    if (f:isBtgMetadataTransferred($obj, $changedObj, $objType))
                    then
                        f:generateSuccessMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'eForms (BT/BG identifier) metadata was modified correctly. ')
                        )
                    else
                        f:generateFailureMessage(
                            fn:concat(
                                f:genTermInfoByObjType($objName, $objType),
                                'eForms (BT/BG identifier) metadata was not modified correctly. ')
                        )"
            />
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            Generic template for checking if:
            1. WG approval is not in definition anymore
            2. WG approval is set as a tag and the date specified in the value matches the original one
        </xd:desc>
        <xd:param name="originalElement"/>
        <xd:param name="changedElement"/>
    </xd:doc>
    <xsl:function name="f:isWgMetadataTransferred" as="xs:boolean">
        <xsl:param name="originalObj"/>
        <xsl:param name="changedObj"/>
        <xsl:param name="objType"/>
        <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($originalObj, $objType)"/>
        <xsl:variable name="changedDefinition" as="xs:string*" select="f:getDefinitionByObjType($changedObj, $objType)"/>

        <xsl:variable name="wgTagValue" select="f:getTagByEaObjType($changedObj, $objType, $wgApprovalTagKey)"/>
        <xsl:choose>
            <xsl:when test="fn:boolean($changedDefinition) and fn:boolean($wgTagValue)">
                <xsl:sequence
                    select="f:extractWgApprovalDateFromDefinition($originalDefinition) = f:extractWgApprovalDateFromDefinition($wgTagValue)
                            and not(f:hasWgApprovalMetadata($changedDefinition))"
                />
            </xsl:when>
        <xsl:otherwise>
              <xsl:sequence select="fn:false()"/>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            Generic template for checking if:
            1. BT/BG id is not in definition anymore
            2. BT/BG id is set as a tag and the id specified in the value matches the original one
        </xd:desc>
        <xd:param name="originalElement"/>
        <xd:param name="changedElement"/>
    </xd:doc>
    <xsl:function name="f:isBtgMetadataTransferred" as="xs:boolean">
        <xsl:param name="originalObj"/>
        <xsl:param name="changedObj"/>
        <xsl:param name="objType"/>

        <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($originalObj, $objType)"/>
        <xsl:variable name="changedDefinition" as="xs:string*" select="f:getDefinitionByObjType($changedObj, $objType)"/>
        <xsl:variable name="btgTagValue" select="f:getTagByEaObjType($changedObj, $objType, $btgTagKey)"/>
        
        <xsl:choose>
            <xsl:when test="fn:boolean($btgTagValue)">
                <xsl:sequence
                    select="f:extractBtIdFromDefinition($originalDefinition) = f:extractBtIdFromDefinition($btgTagValue)
                            and not(f:hasBtgTermIdMetadata($changedDefinition))"
                />
            </xsl:when>
        <xsl:otherwise>
              <xsl:sequence select="fn:false()"/>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            Generic template for checking if the definition of the given external term
            contains a link to an original definition.
            Note that it is not forbidden for the definition to include additional
            information.
        </xd:desc>
        <xd:param name="changedElementDefinition"/>
    </xd:doc>
    <xsl:function name="f:isExtDefinitionLinkProvided" as="xs:boolean">
        <xsl:param name="changedElementDefinition"/>
        <xsl:sequence select="f:hasExtDefinitionMetadata($changedElementDefinition)"/>
    </xsl:function>

<xd:doc>
        <xd:desc>
            Checks if existing definition was replaced by a link pointing to original definition
            of the given external term.
        </xd:desc>
        <xd:param name="originalElement"/>
        <xd:param name="changedElement"/>
    </xd:doc>
    <xsl:template name="externalTermDefLinkProvided">
        <xsl:param name="obj"/>
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:variable name="termPrefix" select="fn:substring-before($objName, ':')"/>
        <xsl:variable name="isExternalTerm" as="xs:boolean"
            select="not($termPrefix = $internalModelPrefixesList or $termPrefix = $ignoredPrefixesList)"
        />
        <xsl:if test="$isExternalTerm">
            <xsl:variable name="originalDefinition" as="xs:string*" select="f:getDefinitionByObjType($obj, $objType)"/>
            <xsl:if test="fn:boolean($originalDefinition)">
                <xsl:variable name="changedObj" as="node()" select="f:getEquivalentObject($obj, $objType, $changedXmiFile)"/>
                <xsl:variable name="changedDefinition" as="xs:string*" select="f:getDefinitionByObjType($changedObj, $objType)"/>
                <xsl:sequence
                    select="
                        if (f:isExtDefinitionLinkProvided($changedDefinition))
                        then
                            f:generateSuccessMessage(
                                fn:concat(
                                    f:genTermInfoByObjType($objName, $objType),
                                    'External term has URL pointing to its original definition provided. ')
                            )
                        else
                            f:generateFailureMessage(
                                fn:concat(
                                    f:genTermInfoByObjType($objName, $objType),
                                    'External term does not have URL pointing to its original definition provided. ')
                            )"
                />  
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>