<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="OAC_Annotation">
    <span style="padding: 1px; background-color: yellow; border-style: solid; border-width: 1px;" class="OAC_Annotation">
    <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="OAC_img">
    <img style="background-color: none; -moz-box-shadow: 0px 0px 7px #000; -webkit-box-shadow: 0px 0px 7px #000; box-shadow: 0px 0px 7px #000; border: 1px solid #fff; ">
      <xsl:attribute name="src">
        <xsl:value-of select="@src" />
      </xsl:attribute>
    </img>
  </xsl:template>
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
