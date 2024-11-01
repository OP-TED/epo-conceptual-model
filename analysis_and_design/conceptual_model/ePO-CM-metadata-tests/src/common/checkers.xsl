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
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:functx="http://www.functx.com"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:f="http://https://github.com/costezki/model2owl#" version="3.0">

    <xd:doc scope="stylesheet">
        <xd:desc>A set of useful boolean test functions</xd:desc>
    </xd:doc>


    <xd:doc>
        <xd:desc>Checks if the given text contains any form of WG approval metadata specified</xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:hasWgApprovalMetadata" as="xs:boolean">
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="fn:matches($text, 'WG .*[0-9]{2,4}[/-][0-9]{1,2}[/-][0-9]{2,4}')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Checks if the given text contains any form of eForms BT or BG identifier specified</xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:hasBtgTermIdMetadata" as="xs:boolean">
        <xsl:param name="text" as="xs:string*"/>
        <xsl:sequence select="fn:matches($text, 'B[TG] ?- ?[0-9]{1,4}') and fn:matches($text, 'e[fF]orms')"/>
    </xsl:function>
</xsl:stylesheet>