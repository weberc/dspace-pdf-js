<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:oreatom="http://www.openarchives.org/ore/atom/"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xalan="http://xml.apache.org/xalan"
        xmlns:encoder="xalan://java.net.URLEncoder"
        xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
        xmlns:jstring="java.lang.String"
        xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>


    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemSummaryView-DIM"/>

        <!-- Preview pdf with pdf document viewer -->
        <xsl:call-template name="pdf-viewer"/>


        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h4><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h4>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h4><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h4>
                <table class="ds-table file-list">
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="pdf-viewer">
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='application/pdf']">
            <hr/>
            <left>
                <h3>Preview</h3>
            </left>
            <xsl:for-each select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='application/pdf']">
                <xsl:choose>
                    <xsl:when test="@SIZE &lt; 1024 * 1024 * 5">
                        <div style="text-align:left;">
                        <div class="row">
                            <dl class="bitstream-description">
                                <dt>
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                                    <xsl:text>:</xsl:text>
                                </dt>
                                <dd class="word-break">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                                </dd>
                            </dl>
                            <div class="pdfIframeWrapper">
                                <iframe src="{concat($theme-path,'vendor/pdfjs-dist-viewer-min/build/minified/web/viewer.html?file=', mets:FLocat/@xlink:href, '#zoom=page-fit')}" allowfullscreen="allowfullscreen">

                                    <xsl:choose>
                                        <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                                            <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                                                <xsl:with-param name="context" select="."/>
                                                <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                                            </xsl:apply-templates>
                                        </xsl:when>

                                        <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                                            <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                                            <table class="ds-table file-list">
                                                <tr class="ds-table-header-row">
                                                    <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                                                    <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                                                    <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                                                    <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                                                </tr>
                                                <tr>
                                                    <td colspan="4">
                                                        <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                                                    </td>
                                                </tr>
                                            </table>

                                        </xsl:otherwise>
                                    </xsl:choose>
                                </iframe>
                            </div>
                            <hr />
                        </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div style="text-align:left;">
                        <div class="row">
                            <dl class="bitstream-description">
                                <dt>
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                                    <xsl:text>:</xsl:text>
                                </dt>
                                <dd class="word-break">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                                </dd>
                            </dl>
                        <div>
                            <xsl:text>Preview not available. Download file below.</xsl:text>
                        </div>
                        <hr />
                        </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <hr/>
            <br />
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>