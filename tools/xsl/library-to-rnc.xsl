<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="3.0">

<!-- WTF!? Why am I generating the RNC form instead of the RNG form? -->

<xsl:param name="assign" select="'='"/>

<xsl:output method="xml"/>

<xsl:template match="/">
  <rnc>
  <xsl:text>default namespace p = "http://www.w3.org/ns/xproc"&#10;</xsl:text>
  <xsl:text>namespace local = ""&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>
  <xsl:text># This schema could be made more constrained.&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>Step</xsl:text>
  <xsl:value-of select="concat(' ', $assign, ' ')"/>
  <xsl:for-each select="/p:library/p:declare-step">
    <xsl:if test="position() &gt; 1"> | </xsl:if>
    <xsl:text>Step-</xsl:text>
    <xsl:value-of select="substring-after(@type, 'p:')"/>
  </xsl:for-each>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:apply-templates select="/p:library/p:declare-step"/>
  </rnc>
</xsl:template>

<xsl:template match="p:declare-step">
  <xsl:text>Step-</xsl:text>
  <xsl:value-of select="substring-after(@type, 'p:')"/>
  <xsl:text> =&#10;</xsl:text>
  <xsl:text>  element </xsl:text>
  <xsl:value-of select="substring-after(@type, 'p:')"/>
  <xsl:text> {&#10;</xsl:text>
  <xsl:text>    name.ncname.attr?,&#10;</xsl:text>
  <xsl:text>    common.attributes,&#10;</xsl:text>
  <xsl:text>    use-when.attr?,&#10;</xsl:text>
  <xsl:text>    step.attributes,&#10;</xsl:text>
  <xsl:apply-templates select="p:option"/>

  <xsl:choose>
    <xsl:when test="p:input">
      <xsl:text>    (WithInput*</xsl:text>
      <xsl:if test="p:option"> &amp; WithOption*</xsl:if>
      <xsl:if test="p:input[@kind='parameter']"> &amp; WithParam*</xsl:if>
      <xsl:text> &amp; (Documentation|PipeInfo)*</xsl:text>
      <xsl:text>)&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="p:option">
	  <xsl:text>    (WithOption* &amp; (Documentation|PipeInfo)*)&#10;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>     (Documentation|PipeInfo)*&#10;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text>  }&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="p:option">
  <xsl:variable name="stepType" select="parent::*/@type"/>
  <xsl:variable name="name" select="@name"/>
  <xsl:variable name="type" as="xs:string+">
    <xsl:choose>
      <xsl:when test="@values">
        <xsl:variable name="text" select="replace(@values, '^\s*\(\s*(.*)\s*\)\s*$', '$1')"/>
	<xsl:for-each select="tokenize($text,'\s*,\s*')">
	  <xsl:if test="position()&gt;1">|</xsl:if>
          <xsl:value-of select="."/>
	</xsl:for-each>
      </xsl:when>
      <xsl:when test="not(@as)">
	<xsl:message>
          <xsl:text>Warning: no type for option: </xsl:text>
          <xsl:value-of select="$name"/>
        </xsl:message>
	<xsl:value-of select="'xsd:string'"/>
      </xsl:when>
      <xsl:when test="@as = 'xs:string*' or @as = 'xs:anyURI*'">
        <!-- We have options that take list values, but you can't specify lists of strings in RELAX NG. -->
        <!-- This is OK though because if you put the value in the option shortcut form, it's flattened -->
        <!-- into a single string anyway. -->
	<xsl:value-of select="replace(replace(substring-before(@as, '*'), 'xs:', 'xsd:'), '#', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="replace(replace(@as, 'xs:', 'xsd:'), '#', '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>    attribute </xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:text> { avt.datatype }?,&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
