<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    extension-element-addres="str"
    xmlns:rhythm="http://rhythmofrussian.com/rhythm" version="1.0">

    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>

    <xsl:template match="rhythm:rhythm">
        <div id='poem'>
            <xsl:attribute name="data-type">
                <xsl:text>rhythm-prose</xsl:text>
            </xsl:attribute>
            <div id='poemtitle'>
                <h2>
                    <xsl:value-of select="rhythm:title" />
                    <xsl:if test="rhythm:date">
                        (<xsl:value-of select="rhythm:date"/>)
                    </xsl:if>
                </h2>
            </div>
            <xsl:apply-templates/>
        </div>
        <br/>
    </xsl:template>

    <xsl:template match="rhythm:title"> </xsl:template>

    <xsl:template match="rhythm:author">
        <h4><xsl:value-of select="." /></h4>
    </xsl:template>

    <xsl:template match="rhythm:date"> </xsl:template>

    <xsl:template match="rhythm:translation">
        <div class='translation'>
            <xsl:value-of select='.'/>
        </div>
    </xsl:template>

    <xsl:template match="rhythm:lb"><br/></xsl:template>

    <xsl:template match="rhythm:l">
        <xsl:variable name="line-number" select="position()" />

        <div class='prosody-line'>
            <div id='prosody-shadow-{$line-number}'>
                <xsl:call-template name="parse-line">
                    <xsl:with-param name="shadow" select="'true'" />
                </xsl:call-template>
            </div>

            <div id='prosody-real-{$line-number}'>
                <xsl:call-template name="parse-line" />
            </div>

            <div class="buttons">
                <span class="button">
                    <button class="prosody-checkstress" id="checkstress{$line-number}"
                        name="Check stress" onclick="checkstress({$line-number})" onmouseover="Tip('Check stress', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                        <img src="[PLUGIN_DIR]/stress-default.png"/>
                    </button>
                </span>
                <xsl:if test="/rhythm:rhythm/rhythm:rustext/@type = 'poetry'">
                    <span class="button">
                        <button class="prosody-checkfeet" id="checkfeet{$line-number}" name="Check feet"
                            onclick="checkfeet({$line-number})" onmouseover="Tip('Check feet', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                            <img src="[PLUGIN_DIR]/feet-default.png"/>
                        </button>
                    </span>
                    <span class="button">
                        <button class="prosody-meter" id="checkmeter{$line-number}" name="Check meter"
                            onclick="checkmeter({$line-number},1)" onmouseover="Tip('Check meter', BGCOLOR, '#676767', BORDERWIDTH, 0, FONTCOLOR, '#FFF')" onmouseout="UnTip()">
                            <img src="[PLUGIN_DIR]/meter-default.png"/>
                        </button>
                    </span>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="parse-line">
        <xsl:param name="base" />
        <xsl:param name="suffix" />
        <xsl:param name="terminate" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:param name="addr" select="concat($base, position())" />

        <xsl:for-each select="text()|*">
            <xsl:variable name="line-suffix">
                <xsl:choose>
                    <xsl:when test="position() = last()">
                        <xsl:value-of select="$suffix" />
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="nextaddr" select="concat($addr, '-', position())"/>
            <xsl:choose>
                <xsl:when test="name() = ''" >
                    <xsl:call-template name="parse-feet">
                        <xsl:with-param name="addr" select="$nextaddr" />
                        <xsl:with-param name="suffix" select="$line-suffix" />
                        <xsl:with-param name="terminate" select="$terminate" />
                        <xsl:with-param name="stress" select="$stress" />
                        <xsl:with-param name="shadow" select="$shadow" />
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="parsing">
                        <xsl:with-param name="addr" select="$nextaddr" />
                        <xsl:with-param name="final" select="position() = last()" />
                        <xsl:with-param name="stress" select="$stress" />
                        <xsl:with-param name="shadow" select="$shadow" />
                    </xsl:apply-templates>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="parse-feet">
        <xsl:param name="addr" />
        <xsl:param name="suffix" />
        <xsl:param name="terminate" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:variable name="feet-suffix">
            <xsl:choose>
                <xsl:when test="substring(., string-length(.)) = ' '">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <xsl:value-of select="$suffix" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$terminate">
                <xsl:call-template name="foot">
                    <xsl:with-param name="addr" select="$addr" />
                    <xsl:with-param name="suffix" select="$feet-suffix" />
                    <xsl:with-param name="stress" select="$stress" />
                    <xsl:with-param name="shadow" select="$shadow" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="str:tokenize(., ' ')">
                    <xsl:call-template name="foot">
                        <xsl:with-param name="addr" select="$addr" />
                        <xsl:with-param name="suffix" select="$feet-suffix" />
                        <xsl:with-param name="stress" select="$stress" />
                        <xsl:with-param name="shadow" select="$shadow" />
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="foot">
        <xsl:param name="addr" />
        <xsl:param name="suffix" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:variable name="foot-id" select="concat($addr, '-', position())" />

        <xsl:choose>
            <xsl:when test="$shadow">
                <span class='prosody-shadowsyllable'
                    id='prosody-shadow-{$foot-id}'
                    onclick='switchstress(this);'>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class='prosody-syllable'
                        id='prosody-real-{$foot-id}'
                        onclick='switchfoot(event, "{$foot-id}")'>
                    <xsl:attribute name='data-real'>
                        <xsl:choose>
                            <xsl:when test='$stress'>+</xsl:when>
                            <xsl:otherwise>-</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="." />

                    <xsl:choose>
                        <xsl:when test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$suffix" />
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="rhythm:lb" mode='parsing'>
        <br/><span class='indent'> </span>
    </xsl:template>

    <xsl:template match="rhythm:emph"  mode='parsing'>
        <xsl:param name="addr" />
        <xsl:param name="final" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:choose>
            <xsl:when test="$shadow">
                <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="$stress" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="shadow" select="$shadow" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <i>
                    <xsl:call-template name="parse-line">
                        <xsl:with-param name="base" select="concat($addr,'-')" />
                        <xsl:with-param name="stress" select="$stress" />
                        <xsl:with-param name="suffix">
                            <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                </i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="rhythm:u"  mode='parsing'>
        <xsl:param name="addr" />
        <xsl:param name="final" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:choose>
            <xsl:when test="$shadow">
                <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="$stress" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="shadow" select="$shadow" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <u>
                    <xsl:call-template name="parse-line">
                        <xsl:with-param name="base" select="concat($addr,'-')" />
                        <xsl:with-param name="stress" select="$stress" />
                        <xsl:with-param name="suffix">
                            <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                </u>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="rhythm:single" mode='parsing'>
        <xsl:param name="addr" />
        <xsl:param name="final" />
        <xsl:param name="stress" />
        <xsl:param name="shadow" />

        <xsl:choose>
            <xsl:when test="$shadow">
                <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="$stress" />
                    <xsl:with-param name="terminate" select="'true'" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="shadow" select="$shadow" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="$stress" />
                    <xsl:with-param name="terminate" select="'true'" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="rhythm:stress" mode="parsing">
        <xsl:param name="addr" />
        <xsl:param name="final" />
        <xsl:param name="shadow" />

        <xsl:choose>
            <xsl:when test="$shadow">
               <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="'true'" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="shadow" select="$shadow" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="parse-line">
                    <xsl:with-param name="base" select="concat($addr,'-')" />
                    <xsl:with-param name="stress" select="'true'" />
                    <xsl:with-param name="suffix">
                        <xsl:if test="not($final)"><xsl:text> </xsl:text></xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="rhythm:translation" mode="parsing">
        <xsl:param name="shadow" />

        <span class='translation'><xsl:value-of select="."/></span>
    </xsl:template>
</xsl:stylesheet>