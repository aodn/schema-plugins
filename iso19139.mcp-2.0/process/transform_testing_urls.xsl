<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
    exclude-result-prefixes="mcp"
    version="2.0">
    
    <!-- url substitutions to be performed -->

    <xsl:variable name="urlSubstitutions">
        <substitution match="https?://geoserver-123.aodn.org.au(:443)?" replaceWith="http://geoserver-systest.aodn.org.au"/>
        <substitution match="https?://geoserver-wps.aodn.org.au(:443)?" replaceWith="http://geoserver-wps-systest.aodn.org.au"/>
        <substitution match="https?://thredds.aodn.org.au(:443)?" replaceWith="http://thredds-systest.aodn.org.au"/>
    </xsl:variable>

    <xsl:variable name="urlSubstitutionSelector" select="string-join($urlSubstitutions/substitution/@match, '|')"/>

    <!-- default action is to copy -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert point of truth links only to avoid accidental edits -->

    <xsl:template match="gmd:URL[../../gmd:protocol/*/text()='WWW:LINK-1.0-http--metadata-URL']">
        <gmd:URL><xsl:value-of select="replace(.,'catalogue-imos', 'catalogue-systest')"/></gmd:URL>
    </xsl:template>

    <!-- substitute production service endpoints with systest service endpoints -->

    <xsl:template match="gmd:URL[matches(., $urlSubstitutionSelector)]">
        <xsl:variable name="url" select="."/>

        <xsl:for-each select="$urlSubstitutions/substitution">
            <xsl:if test="matches(string($url), string(@match))">
                <gmd:URL><xsl:value-of select="replace($url, string(@match), string(@replaceWith))"/></gmd:URL>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:param name="shape-file-online-resource">
        <gmd:onLine>
            <gmd:CI_OnlineResource>
                <gmd:linkage>
                    <gmd:URL>http://geoserver-systest.aodn.org.au/geoserver/imos/ows?typeName=imos:soop_auscpr_zoop_trajectory_map&amp;outputFormat=SHAPE-ZIP</gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                    <gco:CharacterString>AODN:SHAPE-ZIP</gco:CharacterString>
                </gmd:protocol>
                <gmd:name>
                    <gco:CharacterString>SHAPE-ZIP</gco:CharacterString>
                </gmd:name>
                <gmd:description>
                    <gco:CharacterString>AusCPR Zooplankton</gco:CharacterString>
                </gmd:description>
            </gmd:CI_OnlineResource>
        </gmd:onLine>

    </xsl:param>

    <xsl:variable name="expectedId" >c1344e70-480e-0993-e044-00144f7bc0f4</xsl:variable>

    <xsl:template match="gmd:MD_DigitalTransferOptions">
        <xsl:copy>
            <xsl:copy-of select="@* | node()"/>
            <xsl:if test="../../../../gmd:fileIdentifier/gco:CharacterString/text() = $expectedId">
                <xsl:copy-of select="$shape-file-online-resource"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
