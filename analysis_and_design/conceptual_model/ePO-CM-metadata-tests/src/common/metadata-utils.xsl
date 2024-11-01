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


    <xsl:import href="fetchers.xsl"/>
    <xsl:import href="../config/config.xsl"/>

    <xd:doc>
        <xd:desc>
            Generates term information depending on the corresponding object
            type.
            
            A helper function to be used with message generation functions. 
            The function generates additional information for classes
            and attributes. This extra information is needed as messages
            for the both types are kept together.
        </xd:desc>
        <xd:param name="changedElementDefinition"/>
    </xd:doc>
    <xsl:function name="f:genTermInfoByObjType" as="xs:string*">
        <xsl:param name="objName"/>
        <xsl:param name="objType"/>
        <xsl:if test="$objType = 'uml:Class'">
            <xsl:sequence select="fn:concat($objName, ' (class): ' )"/>
        </xsl:if>
        <xsl:if test="$objType = 'Attribute'">
            <xsl:sequence select="fn:concat($objName, ' (attribute): ' )"/>
        </xsl:if>
    </xsl:function>

    
    <xd:doc>
        <xd:desc>
            Returns a tag for the given object (element/connector).
            Supports a special case of an association which holds tags in
            it's target object.
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getTagByEaObjType" as="xs:string*">
        <xsl:param name="eaObj"/>
        <xsl:param name="eaObjType"/>
        <xsl:param name="tagKey"/>
        <xsl:variable name="tagNode" select="if ($eaObjType = 'Association') then $eaObj/target else $eaObj"/>
        <xsl:sequence select="f:getTagValueByKey($tagNode, $tagKey)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            Returns a definition for the given object.
            Supports different types of EA (element/connector/attribute) and
            UML (uml:Class/uml:Enumeration) objects.
            that have a definition located under a different path.
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:getDefinitionByObjType" as="xs:string*">
        <xsl:param name="node"/>
        <xsl:param name="objType"/>
        <xsl:choose>
            <xsl:when test="$objType = 'uml:Class' or $objType = 'uml:Enumeration'">
                <xsl:sequence>
                    <xsl:evaluate xpath="$elementDefinitionXpath" context-item="$node"/>
                </xsl:sequence>
            </xsl:when>
            <xsl:when test="$objType = 'Attribute'">
                <xsl:sequence>
                    <xsl:evaluate xpath="$attributeDefinitionXpath" context-item="$node"/>
                </xsl:sequence>
            </xsl:when>
            <xsl:when test="$objType = 'Association' or $objType = 'Dependency'">
                <xsl:sequence>
                    <xsl:evaluate xpath="$connectorDefinitionXpath" context-item="$node"/>
                </xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="fn:error()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>