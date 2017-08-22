<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp" exclude-result-prefixes="mcp" version="2.0">

    <!-- url pattern and replacement for transformed endpoint urls -->
    <xsl:param name="pattern"/>
    <xsl:param name="replacement"/>

    <!-- list of collections to exclude from WMS filter checking -->
    <xsl:variable name="excludedCollections">
        <collection match="default_excluded_layer"/>
    </xsl:variable>

    <!-- default action is to copy -->

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:URL[normalize-space($pattern) != '' and matches(text(), $pattern)]">
        <xsl:copy>
            <xsl:value-of select="replace(text(), $pattern, $replacement)"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:MD_DigitalTransferOptions">
        <xsl:variable name="excludedCollectionSelector"
            select="string-join($excludedCollections/collection/@match, '|')"/>
        <xsl:variable name="collection_name"
            select="gmd:onLine/gmd:CI_OnlineResource/gmd:name[../gmd:protocol/*/text() = 'OGC:WMS-1.1.1-http-get-map']/*/text()"/>
        <xsl:choose>
            <xsl:when test="not(matches($collection_name, $excludedCollectionSelector))">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                    <gmd:onLine>
                        <gmd:CI_OnlineResource>
                            <gmd:linkage>
                                <gmd:URL>http://geoserver-portal-internal.aodn.org.au/geoserver/wms</gmd:URL>
                            </gmd:linkage>
                            <gmd:protocol>
                                <gco:CharacterString>AODN:FILTERS--enabled</gco:CharacterString>
                            </gmd:protocol>
                            <gmd:name gco:nilReason="missing">
                                <gco:CharacterString/>
                            </gmd:name>
                            <gmd:description>
                                <gco:CharacterString>WMS filters check</gco:CharacterString>
                            </gmd:description>
                        </gmd:CI_OnlineResource>
                    </gmd:onLine>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- If it's part of the excluded list, do nothing -->
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
