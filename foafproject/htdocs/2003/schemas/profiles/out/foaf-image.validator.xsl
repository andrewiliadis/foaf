<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" version="1.0" rdf:dummy-for-xmlns="" rdfs:dummy-for-xmlns="" foaf:dummy-for-xmlns="" dc:dummy-for-xmlns="">
<axsl:output method="html"/>
<axsl:template mode="schematron-get-full-path" match="*|@*">
<axsl:apply-templates mode="schematron-get-full-path" select="parent::*"/>
<axsl:text>/</axsl:text>
<axsl:if test="count(. | ../@*) = count(../@*)">@</axsl:if>
<axsl:value-of select="name()"/>
<axsl:text>[</axsl:text>
<axsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
<axsl:text>]</axsl:text>
</axsl:template>
<axsl:template match="/">
<html>
<style>
         a:link    { color: black}
         a:visited { color: gray}
         a:active  { color: #FF0088}
         h3        { background-color:black; color:white;
                     font-family:Arial Black; font-size:12pt; }
         h3.linked { background-color:black; color:white;
                     font-family:Arial Black; font-size:12pt; }
      </style>
<h2 title="Schematron contact-information is at the end of                   this page">
<font color="#FF0080">Schematron</font> Report
      </h2>
<h1 title=" ">FOAF "Image" Validator</h1>
<div class="errors">
<ul>
<h3>Namespace Checks</h3>
<axsl:apply-templates mode="M5" select="/"/>
<h3>Basic Validation</h3>
<axsl:apply-templates mode="M6" select="/"/>
<h3>RDF Validation</h3>
<axsl:apply-templates mode="M7" select="/"/>
<h3>Identifying Properties</h3>
<axsl:apply-templates mode="M9" select="/"/>
</ul>
</div>
<hr color="#FF0080"/>
<p>
<font size="2">Schematron Report by David Carlisle.
      <a title="Link to the home page of the Schematron,                  a tree-pattern schema language" href="http://www.ascc.net/xml/resource/schematron/schematron.html">
<font color="#FF0080">The Schematron</font>
</a> by
      <a title="Email to Rick Jelliffe (pronounced RIK JELIF)" href="mailto:ricko@gate.sinica.edu.tw">Rick Jelliffe</a>,
      <a title="Link to home page of Academia Sinica" href="http://www.sinica.edu.tw">Academia Sinica Computing Centre</a>.
      </font>
</p>
</html>
</axsl:template>
<axsl:template mode="M5" priority="4000" match="*">
<axsl:choose>
<axsl:when test="namespace-uri()='http://www.w3.org/1999/02/22-rdf-syntax-ns#' or                     namespace-uri()='http://www.w3.org/2000/01/rdf-schema#'                     or namespace-uri()='http://xmlns.com/foaf/0.1/'                     or namespace-uri()='http://purl.org/dc/elements/1.1/'"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Element<axsl:text xml:space="preserve"> </axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:text xml:space="preserve"> </axsl:text>is from an unknown namespace.
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M5"/>
</axsl:template>
<axsl:template mode="M5" priority="-1" match="text()"/>
<axsl:template mode="M6" priority="4000" match="/">
<axsl:choose>
<axsl:when test="rdf:RDF"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Root element must be rdf:RDF
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="3999" match="rdf:RDF">
<axsl:choose>
<axsl:when test="foaf:Image"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: The root rdf:RDF element must contain at least one foaf:Image element
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="count(foaf:Image) = count(*)"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: The only legalchildren of rdf:RDF are foaf:Image elements
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="3998" match="foaf:Image">
<axsl:choose>
<axsl:when test="dc:title"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Images must have a title
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="dc:creator"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Images musthave a creator
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="foaf:depicts"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Images must indicate the people they depict
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="@rdf:about"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: An<axsl:text xml:space="preserve"> </axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:text xml:space="preserve"> </axsl:text>must have an rdf:about attribute, indicating the images location
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="starts-with(@rdf:about, 'http://')"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">rdf:about attributes must contain non-relative HTTP URIs
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="3997" match="foaf:depicts">
<axsl:choose>
<axsl:when test="foaf:Person"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: The person depicted is not specified
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="count(foaf:Person) = 1"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Only a single foaf:Person can be included in a foaf:depicts element
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:choose>
<axsl:when test="count(foaf:Person) = count(*)"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Only a foaf:Person element can be included in foaf:depicts
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="3996" match="dc:creator|dc:title">
<axsl:if test="child::*">
<li>
<a title="Link to where this pattern was found" target="out" href="schematron-out.html#{generate-id(.)}">Error: A<axsl:text xml:space="preserve"> </axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:text xml:space="preserve"> </axsl:text>element must may only contain text.
         ()
      </a>
</li>
</axsl:if>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="3995" match="foaf:Person">
<axsl:choose>
<axsl:when test="count(rdfs:seeAlso) + count(foaf:mbox_sha1sum) = 2"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: a<axsl:text xml:space="preserve"> </axsl:text>
<axsl:value-of select="name(.)"/>
<axsl:text xml:space="preserve"> </axsl:text>element must containonly an rdfs:seeAlso element and a foaf:mbox_sha1sum element
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M6"/>
</axsl:template>
<axsl:template mode="M6" priority="-1" match="text()"/>
<axsl:template mode="M7" priority="3999" match="foaf:thumbnail">
<axsl:choose>
<axsl:when test="starts-with(@rdf:resource, 'http:')"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">Error: Mail-boxes must be specified as http: URIs
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M7"/>
</axsl:template>
<axsl:template mode="M7" priority="3998" match="rdfs:seeAlso">
<axsl:apply-templates mode="M7"/>
</axsl:template>
<axsl:template mode="M7" priority="-1" match="text()"/>
<axsl:template mode="M9" priority="4000" match="rdf:RDF/foaf:Person">
<axsl:choose>
<axsl:when test="foaf:mbox or foaf:mbox_sha1sum or foaf:jabberID or foaf:aimChatID or foaf:icqChatID or foaf:yahooChatID or foaf:msnChatID or foaf:homepage or foaf:weblog"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">You should include at least one inverse functional property
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M9"/>
</axsl:template>
<axsl:template mode="M9" priority="3999" match="foaf:knows/foaf:Person">
<axsl:choose>
<axsl:when test="foaf:mbox or foaf:mbox_sha1sum or foaf:jabberID or foaf:aimChatID or foaf:icqChatID or foaf:yahooChatID or foaf:msnChatID or foaf:homepage or foaf:weblog"/>
<axsl:otherwise>
<li>
<a title="Link to where this pattern was expected" target="out" href="schematron-out.html#{generate-id(.)}">You should include atleast one inverse functional property
         ()
      </a>
</li>
</axsl:otherwise>
</axsl:choose>
<axsl:apply-templates mode="M9"/>
</axsl:template>
<axsl:template mode="M9" priority="-1" match="text()"/>
<axsl:template priority="-1" match="text()"/>
</axsl:stylesheet>
