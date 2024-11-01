<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math xd"
    version="3.0">

    <xd:doc>
        <xd:desc>The static headder and the title of the report</xd:desc>
    </xd:doc>
    <xsl:template name="title-header">
        <xsl:param name="reportTitle" as="xs:string"/>
        <header class="counter-skip">
            <h1 class="title"><xsl:value-of select="$reportTitle"/></h1>
            <h2>[ <xsl:value-of select="format-date(current-date(), 
                '[D01]/[M01]/[Y0001]')"/> ]</h2>
        </header>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>The static abstract of the report. This should act the introduction</xd:desc>
    </xd:doc>
    <xsl:template name="abstract-comparison">
        <div class="abstract counter-skip">
            <h1>Abstract</h1>
            <p>This is a report outlining results of metadata modification tests run against XMI/XML file. The test set objective was to verify correctness and completeness of the conceptual model metadata that was manually modified as a part of a distinct task.</p>
            
            <p>The tests ensure that metadata previously stored in a term definition as free text was properly moved to new tags. The tests compared the original file (the former version used as the input for the mentioned modification task) and the changed one.
            </p>
            
            <p>The organisation of this document is based on major types of UML elements and
                connectors that are employed in the module of the conceptual model and that were in the scope of the modification task. They are as
                follows: 
                <em>Classes and Attributes, Enumerations, Associations, Dependencies</em>. Each main section lists model objects together with the testing outcome. The filter panel can be used to display correct/incorrect cases only.    
            </p>
            <p>Each affected model object was tested according to the following testing rules:</p>
            <ol>
                <li>
                    Any term with WG approval information specified as free text in its definition must have this information moved to a new tag (skos:historyNote key).
                </li>
                    Any term with one or more eForms BT/BG term identifiers specified as free text in its definition must have this information moved to a new tag (skos:editorialNote key).
                <li>
                    Any external term definition that replicates the original definition (specified in the related external vocabulary) must be replaced with an URL pointing to the term original definition in a human-readable form (HTML page section view). It is allowed for the definition to contain extra text (in case the definition contained additional information specific to the term that doesn't replicate the original definition).
                </li>
            </ol>

            <p>In addition, the remaining model objects were compared to ensure that no unforeseen changes have been introduced in pre-existing objects.</p>

            <p>The UML model in file <em><xsl:value-of select="tokenize(base-uri(.), '/')[last()]"/></em> 
                was tested <xsl:value-of select="format-dateTime(current-dateTime(), 
                    'at [H01]:[m01] on [MNn] [D], [Y0001]')"/>.</p>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>The static abstract of the report. This should act the introduction</xd:desc>
    </xd:doc>
    <xsl:template name="abstract-conformance">
        <div class="abstract counter-skip">
        <h1>Abstract</h1>
            <p>This is a report outlining results of metadata conventions conformance tests run against XMI/XML file. The test set objective was to verify that metadata located in the conceptual model objects conforms to a newly established metadata conventions.</p>
            
            <p>The organisation of this document is based on major types of UML elements and
                connectors that are employed in the module of the conceptual model and that were in the scope of the modification task. They are as
                follows: 
                <em>Classes and Attributes, Enumerations, Associations, Dependencies</em>. Each main section lists model objects together with the testing outcome. The filter panel can be used to display correct/incorrect cases only.    
            </p>
            <p>Each affected model object was tested according to the following metadata convention rules:</p>
            <ol>
                <li>
                    Any term definition must not contain WG approval information as free text.
                </li>
                    Any term definition must not contain identifiers of eForms BT and BG terms as free text.
                <li>
                    Any external term definition must contain an URL pointing to the term original definition in a human-readable form (HTML page section view). It is allowed for the definition to contain extra text (in case the definition contained additional information specific to the term that doesn't replicate the original definition).
                </li>
            </ol>

            <p>The UML model in file <em><xsl:value-of select="tokenize(base-uri(.), '/')[last()]"/></em> 
                was tested <xsl:value-of select="format-dateTime(current-dateTime(), 
                    'at [H01]:[m01] on [MNn] [D], [Y0001]')"/>.</p>
        </div>
    </xsl:template>
    
    
</xsl:stylesheet>