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
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:f="http://https://github.com/costezki/model2owl#" version="3.0">


    <xd:doc>
        <xd:desc>This function will generate a info message</xd:desc>
        <xd:param name="infoMessage"/>
        <xd:param name="pathChecked"/>
        <xd:param name="ruleIdentifier"/>
        <xd:param name="semicRuleIdentifier"/>
        <xd:param name="semicRuleIdentifierLinks"/>
    </xd:doc>
    <xsl:function name="f:generateInfoMessage">
        <xsl:param name="infoMessage"/>
        <xsl:param name="pathChecked"/>
        <xsl:param name="ruleIdentifier"/>
        <xsl:param name="semicRuleIdentifier"/>
        <xsl:param name="semicRuleIdentifierLinks"/>
        <xsl:sequence>
            <dd class="filter infos">
                <i class="fa fa-info-circle info"/>
                <xsl:value-of select="$infoMessage"/>
            </dd>
        </xsl:sequence>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function will generate a success message</xd:desc>
        <xd:param name="message"/>
    </xd:doc>
    <xsl:function name="f:generateSuccessMessage">
        <xsl:param name="message"/>
        <xsl:sequence>
            <dd class="filter infos">
                <i class="fa fa-check info"/>
                <xsl:value-of select="$message"/>
            </dd>
        </xsl:sequence>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function will generate a failure message</xd:desc>
        <xd:param name="message"/>
    </xd:doc>
    <xsl:function name="f:generateFailureMessage">
        <xsl:param name="message"/>
                            
        <xsl:sequence>
            <dd class="filter errors">
                <i class="fa fa-times-circle error"/>
                <xsl:value-of select="$message"/>
            </dd>
        </xsl:sequence>
    </xsl:function>


</xsl:stylesheet>