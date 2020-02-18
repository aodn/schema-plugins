<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
    xmlns:geonet="http://www.fao.org/geonetwork"
    exclude-result-prefixes="mcp geonet"
    version="2.0">

    <xsl:preserve-space elements="*"/>
    <xsl:param name="pattern"/>
    <xsl:param name="replacement"/>

    <!-- default action is to copy -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Always remove geonet:* elements. -->
    <xsl:template match="geonet:*"/>

    <xsl:template match="gmd:URL[normalize-space($pattern) != '' and matches(text(), $pattern)]">
        <xsl:copy>
            <xsl:value-of select="replace(text(), $pattern, $replacement)"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:URL[../../gmd:protocol/*/text()='OGC:WMS-1.1.1-http-get-map']" priority="100">
        <xsl:copy><xsl:value-of select="'https://tilecache.aodn.org.au/geowebcache/service'"/></xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:URL[../../gmd:protocol/*/text()='OGC:WMS-1.3.0-http-get-map']" priority="100">
        <xsl:copy><xsl:value-of select="'https://tilecache.aodn.org.au/geowebcache/service'"/></xsl:copy>
    </xsl:template>

    <xsl:template match="gmd:onLine[gmd:CI_OnlineResource[contains(gmd:linkage/gmd:URL/text(), $pattern)]/gmd:protocol/*/text() = 'OGC:WFS-1.0.0-http-get-capabilities']">

        <xsl:variable name="collection_name"
                      select="gmd:CI_OnlineResource/gmd:name/*/text()"/>
        <gmd:onLine>
            <gmd:CI_OnlineResource>
                <gmd:linkage>
                    <gmd:URL><xsl:value-of select="$pattern"/>/geoserver/ows</gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                    <gco:CharacterString>
                        <xsl:value-of select="'AODN:WFS-EXTERNAL-1.0.0-http-get-capabilities'"/>
                    </gco:CharacterString>
                </gmd:protocol>
                <gmd:name>
                    <gco:CharacterString>
                        <xsl:value-of select="$collection_name"/>
                    </gco:CharacterString>
                </gmd:name>
                <gmd:description>
                    <gco:CharacterString>This OGC WFS service returns filtered geographic information. The returned data
                        is available in multiple formats including CSV.
                    </gco:CharacterString>
                </gmd:description>
            </gmd:CI_OnlineResource>
        </gmd:onLine>

        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>