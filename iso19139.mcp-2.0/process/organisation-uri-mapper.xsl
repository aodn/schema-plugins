<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink" >
    <xsl:import href="linkage-updater.xsl" />

    <xsl:param name="vocabulary_url"/>
    <xsl:param name="pattern"/>
    <xsl:param name="replacement"/>

    <xsl:variable name="vocabulary" select="document($vocabulary_url)"/>

    <xsl:template match="/">
        <xsl:apply-imports>
            <xsl:with-param name="pattern">$pattern</xsl:with-param>
            <xsl:with-param name="replacement">$replacement</xsl:with-param>
        </xsl:apply-imports>
    </xsl:template>


    <xsl:template match="gmd:organisationName/gco:CharacterString">
        <xsl:variable name="currentOrgName" select="./text()"/>
        <!--  See if the org name matches any prefLabel or altLabel element values in the vocabulary -->
        <xsl:variable name="prefLabelMatches" select="$vocabulary//rdf:Description [skos:prefLabel = $currentOrgName]"/>
        <xsl:variable name="altLabelMatches" select="$vocabulary//rdf:Description [skos:altLabel = $currentOrgName]"/>

        <!--<xsl:message>[*] Pref label matches [<xsl:value-of select="count($prefLabelMatches)"/>]</xsl:message>
        <xsl:message>[*] Alt label matches [<xsl:value-of select="count($altLabelMatches)"/>]</xsl:message>-->

        <xsl:choose>
            <!-- When there are no matches we want to output a message (to identify organisation names that aren't in the vocab)
                 and copy the CharacterString to the output.
            -->
            <xsl:when test="count($prefLabelMatches) = 0 and count($altLabelMatches) = 0">
                <xsl:message>[*] NO ORG VOCABULARY MATCH found for [<xsl:value-of select="$currentOrgName"/>]</xsl:message>
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <!--  We want to create a gmx:Anchor element to replace the CharacterString from the input. -->
                <xsl:choose>
                    <xsl:when test="count($prefLabelMatches) > 0">
                        <!--<xsl:message>[*] PREF LABEL MATCH found for [<xsl:value-of select="$currentOrgName"/>]</xsl:message>-->
                        <xsl:variable name="aboutAttr" select="$prefLabelMatches[1]/@rdf:about"/>
                        <xsl:element name="gmx:Anchor">
                            <xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink"><xsl:value-of select = "$aboutAttr"/></xsl:attribute>
                            <xsl:value-of select="$prefLabelMatches[1]/skos:prefLabel/text()"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--<xsl:message>[*] ALT LABEL MATCH found for [<xsl:value-of select="$currentOrgName"/>]</xsl:message>-->
                        <xsl:variable name="aboutAttr" select="$altLabelMatches[1]/@rdf:about"/>
                        <xsl:element name="gmx:Anchor">
                            <xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink"><xsl:value-of select = "$aboutAttr"/></xsl:attribute>
                            <xsl:value-of select="$altLabelMatches[1]/skos:altLabel/text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>