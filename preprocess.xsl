<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str"
    xmlns:prosody="http://www.prosody.org" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" version="1.0">

    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
    <!-- <xsl:strip-space elements="*"/> -->
    <xsl:preserve-space elements="seg"/>
    <xsl:variable name="scheme">
      <xsl:for-each select="//TEI:lg/@rhyme">
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="text-type">
        <xsl:choose>
            <xsl:when test="/TEI:TEI/TEI:text/@type">
                <xsl:value-of select="/TEI:TEI/TEI:text/@type" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>poetry</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
			<xsl:if test="/TEI:TEI/TEI:text/TEI:body/TEI:lg[1]/@rhyme">
                <div id="rhymegutter">
                    <div id="rhyme" style="display:none;">
                        <div class="rhymespacer"><xsl:text> </xsl:text></div>
                        <form name="{$scheme}" id="rhymeform" autocomplete="off">
                        <xsl:for-each select="/TEI:TEI/TEI:text/TEI:body/TEI:lg">
                            <xsl:variable name="lgPos"><xsl:value-of select="position()"/></xsl:variable>
                            <p><br/></p>
                            <xsl:for-each select="TEI:l">
                                <div class="lrhyme">
                                    <input size="1" maxlength="1" value="" name="lrhyme-{$lgPos}-{position()}" type="text" onFocus="this.value='';this.style['color'] = '#44FFFF';"/>
                                </div>
                            </xsl:for-each>
                        </xsl:for-each>
                            <div class="lrhyme check"><input type="submit" value="&#x2713;" size="1" maxlength="1" id="rhymecheck"/></div>
                        </form>
                    </div>
                    <div id="rhymebar">
                        <div class="rhymespacer"><xsl:text> </xsl:text></div>
                        <div class="rhymefield"><xsl:text> </xsl:text></div>
                    </div>
                    <div id="rhymeflag">Rhyme</div>
                </div>
			</xsl:if>
        <div id="poem">
            <div id="poemtitle">
                <h2>
                    <xsl:apply-templates
                        select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title"/>
                    <xsl:apply-templates
                        select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:publicationStmt/TEI:date"/>
                </h2>
                <xsl:if test="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:author">
                    <h4>
                        <xsl:apply-templates
                            select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:author"/>
                    </h4>
                </xsl:if>
            </div>
            <xsl:apply-templates select="TEI:TEI/TEI:text/TEI:body/*"/>
        </div>
    </xsl:template>

    <xsl:template match="TEI:space">
        <!-- <span class="space_{@quantity}" /> -->
    </xsl:template>

		<xsl:template match="TEI:date">
			<small class="date">
				<xsl:text>(</xsl:text>
					<xsl:value-of select="."/>
				<xsl:text>)</xsl:text>
			</small>
		</xsl:template>

    <xsl:template match="TEI:lg">
        <xsl:variable name="l-type">
            <xsl:value-of select="@type"/>
        </xsl:variable>

        <xsl:variable name="l-mode">
            <xsl:choose>
                <xsl:when test="$l-type = 'Translation'">bare</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:apply-templates select="TEI:space" />
        <xsl:for-each select="TEI:l|TEI:lb">
            <xsl:apply-templates select=".">
                <xsl:with-param name="linegroupindex" select="position()"/>
                <xsl:with-param name="l-mode" select="$l-mode"/>
                <xsl:with-param name="l-type" select="$l-type"/>
            </xsl:apply-templates>
        </xsl:for-each>
        <xsl:if test="not(./@rend='nobreak')">
              <br/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TEI:lb">
        <br/>
    </xsl:template>

    <xsl:template match="TEI:l">
        <xsl:param name="linegroupindex"/>
        <xsl:param name="l-mode"/>
        <xsl:param name="l-type"/>

        <xsl:variable name="line-number" select="@n"/>
        <xsl:variable name="indent" select="@rend" />

        <div class="prosody-line {$indent} type-{$l-type}">
            <xsl:choose>
                <xsl:when test="$l-mode = 'bare'">
                    <div id="bare-{$line-number}" class="line-bare">
                        <xsl:value-of select="."/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="TEI-l" id="prosody-real-{$line-number}">
        <!--                 <xsl:if test="exists(TEI:space)"> -->
                    <xsl:apply-templates select="TEI:space" />
        <!--                 </xsl:if> -->

                    <xsl:for-each select="@*">
                        <xsl:attribute name="data-{name()}"><xsl:value-of select="."/></xsl:attribute>
                    </xsl:for-each>
                    <xsl:attribute name="data-feet">
                        <xsl:for-each select="TEI:seg">
                            <xsl:if test="position()>1">|</xsl:if>
                            <xsl:value-of select="."/>
                        </xsl:for-each>
                    </xsl:attribute>

                    <span style="display:none;" linegroupindex="{$linegroupindex}" answer="{../@met}"
                        >Meter</span>


                    <xsl:for-each select="TEI:seg">
                                            <!-- if the following flag gets set, this indicates that there is a discrepancy in the line which must be later
                            highlighted -->
                    <!--                     <xsl:variable name="discrepant-flag" select="exists(@real)"/>
                    -->
                        <xsl:variable name="discrepant-flag" select="boolean(@real)"/>

                        <!-- if the following flag gets set, this indicates that there is a sb element in the line and the
                        segment ends with a space -->

                        <xsl:variable name="seg-position" select="position()"/>
                        <xsl:for-each select="text()|*">
                            <xsl:if test="name(.)='caesura'">
                                <span class="caesura" style="display:none">//</span>
                            </xsl:if>
                            <xsl:variable name="foot-position" select="position()"/>
                            <xsl:variable name="foot-last" select="last()"/>
                            <xsl:variable name="node-string" select="."/>
                            <xsl:variable name="seg-id" select="concat($line-number, '-', $seg-position, '-', $foot-position)" />

                            <xsl:call-template name="real-foot-nest">
                                <xsl:with-param name="seg-id" select="$seg-id" />
                                <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                            </xsl:call-template>
                        </xsl:for-each>
                        <xsl:if test="(name(following-sibling::*[1]) = 'caesura')">
                            <span class="caesura" style="display:none">//</span>
                        </xsl:if>
                    </xsl:for-each>

                    </div>
                    <div class="buttons">
                        <xsl:if test="TEI:note">
                            <span class="button">
                                <button class="prosody-note-button" id="displaynotebutton{$line-number}"
                                    name="Note about this line" onclick="">
                                    <img src="[PLUGIN_DIR]/note.png"/>
                                </button>
                                <p class="prosody-note" id="hintfor{$line-number}">
                                    <span>Note on line <xsl:value-of select="$line-number"/>:</span>
                                    <xsl:value-of select="TEI:note"/>
                                </p>
                            </span>
                        </xsl:if>
                        <span class="button">
                            <button class="prosody-checkstress" id="checkstress{$line-number}"
                                name="Check stress" onclick="checkstress({$line-number})" onmouseover="Tip('Check stress', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                                <img src="[PLUGIN_DIR]/stress-default.png"/>
                            </button>
                        </span>
                        <xsl:if test="$text-type = 'poetry'">
                            <span class="button">
                                <button class="prosody-checkfeet" id="checkfeet{$line-number}" name="Check feet"
                                    onclick="checkfeet({$line-number})" onmouseover="Tip('Check feet', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                                    <img src="[PLUGIN_DIR]/feet-default.png"/>
                                </button>
                            </span>
                            <span class="button">
                                <button class="prosody-meter" id="checkmeter{$line-number}" name="Check meter"
                                    onclick="checkmeter({$line-number},{$linegroupindex})" onmouseover="Tip('Check meter', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                                    <img src="[PLUGIN_DIR]/meter-default.png"/>
                                </button>
                            </span>
                        </xsl:if>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="TEI:sb">
    </xsl:template>

    <xsl:template match="TEI:single" mode="shadow">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:call-template name="shadow-foot-terminate">
            <xsl:with-param name="seg-id" select="$seg-id" />
            <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
        </xsl:call-template>

        <xsl:text> </xsl:text> <!-- todo: properly detect space case instead of hardcoding -->
    </xsl:template>

    <xsl:template match="TEI:rhyme" mode="shadow">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:for-each select="text()|*">
            <xsl:call-template name="shadow-foot-nest">
                <xsl:with-param name="seg-id" select="concat($seg-id,'-',position())" />
                <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="TEI:emph" mode="shadow">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:for-each select="text()|*">
            <xsl:call-template name="shadow-foot-nest">
                <xsl:with-param name="seg-id" select="concat($seg-id,'-',position())" />
                <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="shadow-foot-nest">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:choose>
            <xsl:when test="name() = ''">
                <xsl:for-each select="str:tokenize(.,' ')">
                    <xsl:call-template name="shadow-foot-terminate">
                        <xsl:with-param name="seg-id" select="$seg-id" />
                        <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="shadow">
                    <xsl:with-param name="seg-id" select="$seg-id" />
                    <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="shadow-foot-terminate">
        <xsl:param name="seg-id" />

        <xsl:if test="string(.)">
            <span class="prosody-shadowsyllable" shadow=""
                id="prosody-shadow-{$seg-id}-{position()}"
                onclick="switchstress(this);">
                <span class="prosody-placeholder">
                    <xsl:apply-templates/>
                    <!-- <xsl:copy-of select="string(.)"/> -->
                    <xsl:if test="not(position()=last())">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TEI:single" mode="real">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />
        <xsl:param name="last-char" />

        <xsl:call-template name="real-foot-terminate">
            <xsl:with-param name="seg-id" select="$seg-id" />
            <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
            <xsl:with-param name="last-char" select="$last-char" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="TEI:rhyme" mode="real">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:for-each select="text()|*">
            <xsl:call-template name="real-foot-nest">
                <xsl:with-param name="seg-id" select="concat($seg-id,'-',position())" />
                <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="TEI:emph" mode="real">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <i>
            <xsl:for-each select="text()|*">
                <xsl:call-template name="real-foot-nest">
                    <xsl:with-param name="seg-id" select="concat($seg-id,'-',position())" />
                    <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                </xsl:call-template>
            </xsl:for-each>
        </i>
    </xsl:template>

    <xsl:template name="real-foot-nest">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />

        <xsl:variable name="last-char-pos" select="string-length(.)"/>
        <xsl:variable name="last-char" select="substring(., $last-char-pos)"/>

        <xsl:choose>
            <xsl:when test="name() = ''">
                <xsl:for-each select="str:tokenize(.,' ')">
                    <xsl:call-template name="real-foot-terminate">
                        <xsl:with-param name="seg-id" select="$seg-id" />
                        <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                        <xsl:with-param name="last-char" select="$last-char" />
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="real">
                    <xsl:with-param name="seg-id" select="$seg-id" />
                    <xsl:with-param name="discrepant-flag" select="$discrepant-flag" />
                    <xsl:with-param name="last-char" select="$last-char" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="real-foot-terminate">
        <xsl:param name="seg-id" />
        <xsl:param name="discrepant-flag" />
        <xsl:param name="last-char" />

        <xsl:if test="string(.)">
            <span class="prosody-syllable" real=""
                id="prosody-real-{$seg-id}-{position()}"
                data-raw="{string(.)}">
                <xsl:if test="$text-type = 'poetry'">
                    <xsl:attribute name="onclick">
                        <xsl:text>switchfoot(event, 'prosody-real-</xsl:text>
                        <xsl:value-of select="$seg-id" />
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="position()" />
                        <xsl:text>');</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$discrepant-flag">
                    <xsl:attribute name="discrepant"/>
                </xsl:if>

                <xsl:copy-of select="text()"/>
                <!-- add space back -->

                <xsl:choose>
                    <xsl:when test="not(position()=last())">
                    <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:when test="$last-char=' '">
                    <xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </span>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
