<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math xd xsl uml xmi umldi fn"
    xmlns:uml="http://www.omg.org/spec/UML/20131001"
    xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
    xmlns:umldi="http://www.omg.org/spec/UML/20131001/UMLDI" xmlns:functx="http://www.functx.com"
    xmlns:f="http://https://github.com/costezki/model2owl#" version="3.0">

    <xsl:import href="functx-1.0.1-doc.xsl"/>


    <xd:doc>
        <xd:desc>Detects a date of WG approval and returns it in MM/DD/YYYY format.
        Supports a few common date formats. 
        </xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:extractWgApprovalDateFromDefinition">
        <xsl:param name="text"/>
        <xsl:variable name="postWgSubstr" as="xs:string" select="fn:substring-after($text, 'WG')"/>
        <xsl:variable name="commonDatePattern" as="xs:string" select="'[0-9]{2,4}[/-][0-9]{2}[/-][0-9]{2,4}'"/>
        <xsl:variable name="dateRightSubstr" as="xs:string" 
            select="fn:analyze-string($postWgSubstr, $commonDatePattern)/fn:match[1]/text()"
        />
        <xsl:sequence select="f:extractDateFromText($dateRightSubstr)" />
    </xsl:function>

    <xd:doc>
        <xd:desc>Detects first substring that matches one of several common date formats
        and returns the date in MM/DD/YYYY format.
        </xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:extractDateFromText">
        <xsl:param name="text"/>
        <xsl:variable name="dateStr" as="xs:string" 
            select="fn:analyze-string($text, '[0-9]{1,4}[/-][0-9]{1,2}[/-][0-9]{1,4}')/fn:match[1]/text()"
        />
        <xsl:sequence select="f:getDateInCanonicalFormat($dateStr)" />
    </xsl:function>

    <xd:doc>
        <xd:desc>Returns the given date in the canonical format (DD/MM/YYYY)</xd:desc>
        <xd:param name="connectorName"/>
    </xd:doc>
    <xsl:function name="f:getDateInCanonicalFormat">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="sep" as="xs:string" select="'/'"/>
        <xsl:choose>
            <xsl:when test="fn:matches($date, '[0-9]{2}[//-][0-9]{2}[//-][0-9]{4}')">
                <!-- 01/11/2024 OR 01-11-2024 -->
                <xsl:variable name="day" as="xs:string" select="fn:substring($date, 1, 2)"/>
                <xsl:variable name="month" as="xs:string" select="fn:substring($date, 4, 2)"/>
                <xsl:variable name="year" as="xs:string" select="fn:substring($date, 7, 4)"/>
                <xsl:sequence select="fn:concat($day, $sep, $month, $sep, $year)" />
            </xsl:when>

            <xsl:when test="fn:matches($date, '[0-9]{4}[//-][0-9]{2}[//-][0-9]{2}')">
                <!-- 2024/11/01 OR 2024-11-01 -->
                <xsl:variable name="year" as="xs:string" select="fn:substring($date, 1, 4)"/>
                <xsl:variable name="month" as="xs:string" select="fn:substring($date, 6, 2)"/>
                <xsl:variable name="day" as="xs:string" select="fn:substring($date, 9, 2)"/>
                <xsl:sequence select="fn:concat($day, $sep, $month, $sep, $year)" />
            </xsl:when>
            <xsl:otherwise>
                fn:error(xs:QName('unsupported-date-format'), 'the date has unsupported format', $date)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
        </xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:extractBtIdFromDefinition" as="xs:string*">
        <xsl:param name="text"/>
        <xsl:variable name="BtgPattern" as="xs:string" select="'B[TG] ?- ?[0-9]{1,4}'"/>
        <xsl:sequence select="fn:analyze-string($text, $BtgPattern)/fn:match/text()"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>
        </xd:desc>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:function name="f:hasExtDefinitionMetadata" as="xs:boolean">
        <xsl:param name="text"/>
        <xsl:variable name="ExtDefPattern" as="xs:string" select="'External concept defined by *http[s]?://.+'"/>
        <xsl:sequence select="fn:matches($text, $ExtDefPattern)"/>
    </xsl:function>

</xsl:stylesheet>
