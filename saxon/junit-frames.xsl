<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:redirect="http://xml.apache.org/xalan/redirect" xmlns:stringutils="xalan://org.apache.tools.ant.util.StringUtils" extension-element-prefixes="redirect">
    <xsl:output method="html" encoding="utf-8" indent="yes" />
    <xsl:decimal-format decimal-separator="." grouping-separator="," />
    <!-- Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements. See the NOTICE file distributed with this work for additional information regarding copyright ownership. The ASF licenses this file to You under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
        OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License. -->

    <!-- Sample stylesheet to be used with Ant JUnitReport output. It creates a set of HTML files a la javadoc where you can browse easily through all packages and classes. -->
    <xsl:param name="output.dir" select="'.'" />
    <xsl:param name="TITLE">
        Unit Test Results
    </xsl:param>


    <xsl:template match="testsuites">

        <!-- create the all.html -->
        <redirect:write file="{$output.dir}/all.html">
            <xsl:call-template name="all.html" />
        </redirect:write>

        <!-- create the failed.html this will include tests with errors as well as failures -->
        <redirect:write file="{$output.dir}/failed.html">
            <xsl:call-template name="failed.html" />
        </redirect:write>

        <!-- create the overview.html -->
        <redirect:write file="{$output.dir}/index.html">
            <xsl:call-template name="index.html" />
        </redirect:write>

        <!-- generate individual reports per test case -->
        <xsl:for-each select="./testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
            <xsl:call-template name="package">
                <xsl:with-param name="name" select="@package" />
            </xsl:call-template>
        </xsl:for-each>

        <!-- create the stylesheet.css -->
        <redirect:write file="{$output.dir}/stylesheet.css">
            <xsl:call-template name="stylesheet.css" />
        </redirect:write>

    </xsl:template>

    <!-- Process each package -->
    <xsl:template name="package">
        <xsl:param name="name" />
        <xsl:variable name="package.dir">
            <xsl:if test="not($name = '')">
                <xsl:value-of select="translate($name,'.','/')" />
            </xsl:if>
            <xsl:if test="$name = ''">
                <xsl:value-of select="$name" />
            </xsl:if>
        </xsl:variable>



        <xsl:for-each select="/testsuites/testsuite[@package = $name]">
            <xsl:if test="$package.dir = ''">
                <redirect:write file="{$output.dir}/{@id}_{@name}.html">
                    <xsl:apply-templates select="." mode="testsuite.page" />
                </redirect:write>
            </xsl:if>
            <xsl:if test="not($package.dir = '')">
                <redirect:write file="{$output.dir}/{$package.dir}/{@id}_{@name}.html">
                    <xsl:apply-templates select="." mode="testsuite.page" />
                </redirect:write>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- One file per test suite / class -->
    <xsl:template match="testsuite" name="testsuite" mode="testsuite.page">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <title>
                    Test - <xsl:value-of select="@name" />
                </title>
                <xsl:call-template name="test.favicon">
                    <xsl:with-param name="errors" select="@errors + @failures" />
                </xsl:call-template>
                <xsl:call-template name="create.resource.links">
                    <xsl:with-param name="package.name" select="@package" />
                </xsl:call-template>
            </head>
            <body>

                <div class="container container_8" id="report">

                    <!-- The Grails logo and page header-->
                    <div class="grid_6">
                        <xsl:call-template name="create.logo.link">
                            <xsl:with-param name="package.name" select="@package" />
                        </xsl:call-template>

                        <h1><xsl:value-of select="@name" /></h1>
                        <h2>Package: <xsl:value-of select="@package" /></h2>
                    </div>

                    <!-- The navigation links in the upper right corner -->
                    <div class="grid_2">
                        <xsl:call-template name="navigation.links">
                            <xsl:with-param name="package.name" select="@package" />
                        </xsl:call-template>
                    </div>

                    <div class="clear"></div>

                    <xsl:apply-templates select="." mode="summary">
                            <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                            <xsl:sort select="@name" />
                    </xsl:apply-templates>

                    <div class="clear"></div>
                </div>

                <xsl:call-template name="output.parser.js" />

            </body>
        </html>
    </xsl:template>


    <!-- This will produce a large file containing failed (including errors) tests -->
    <xsl:template name="failed.html" match="testsuites" mode="all.tests">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <title><xsl:value-of select="$TITLE" /> - Failed tests</title>
                <xsl:call-template name="test.favicon">
                    <xsl:with-param name="errors" select="sum(testsuite/@errors) + sum(testsuite/@failures)" />
                </xsl:call-template>
                <link href="stylesheet.css" rel="stylesheet" type="text/css" />
            </head>
            <body>

                <div id="report" class="container container_8">
                    <div class="grid_6 alpha">
                        <div class="grailslogo"></div>
                        <h1><xsl:value-of select="$TITLE" /> - Failed tests</h1>

                        <p class="intro">
                            <xsl:call-template name="test.count.summary">
                                <xsl:with-param name="tests" select="sum(testsuite/@tests)" />
                                <xsl:with-param name="errors" select="sum(testsuite/@errors)" />
                                <xsl:with-param name="failures" select="sum(testsuite/@failures)" />
                            </xsl:call-template>
                        </p>
                    </div>

                    <!-- Page navigation links -->
                    <div class="grid_2 omega">
                        <xsl:call-template name="navigation.links">
                            <xsl:with-param name="package.name" select="''" />
                        </xsl:call-template>
                    </div>

                    <div class="clear"></div>

                    <xsl:apply-templates select="testsuite[@errors &gt; 0 or @failures &gt; 0]" mode="summary">
                        <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                        <xsl:sort select="@name" />
                    </xsl:apply-templates>

                    <div class="clear"></div>
                </div>

                <xsl:call-template name="output.parser.js" />
            </body>
        </html>
    </xsl:template>

    <xsl:template name="all.html" match="testsuites" mode="all.tests">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <title><xsl:value-of select="$TITLE" /> - All tests</title>
                <xsl:call-template name="test.favicon">
                    <xsl:with-param name="errors" select="sum(testsuite/@errors) + sum(testsuite/@failures)" />
                </xsl:call-template>
                <link href="stylesheet.css" rel="stylesheet" type="text/css" />
            </head>
            <body>

                <div id="report" class="container container_8">

                    <!-- Logo and page header -->
                    <div class="grid_6 alpha">
                        <div class="grailslogo"></div>

                        <h1><xsl:value-of select="$TITLE" /> - All tests </h1>

                        <p class="intro">
                            <xsl:call-template name="test.count.summary">
                                <xsl:with-param name="tests" select="sum(testsuite/@tests)" />
                                <xsl:with-param name="errors" select="sum(testsuite/@errors)" />
                                <xsl:with-param name="failures" select="sum(testsuite/@failures)" />
                            </xsl:call-template>
                        </p>
                    </div>

                    <!-- Page navigation links -->
                    <div class="grid_2 omega">
                        <xsl:call-template name="navigation.links">
                            <xsl:with-param name="package.name" select="''" />
                        </xsl:call-template>
                    </div>

                    <div class="clear"></div>

                    <xsl:apply-templates select="testsuite" mode="summary">
                        <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                        <xsl:sort select="@name" />
                    </xsl:apply-templates>

                    <div class="clear"></div>
                </div>

                <xsl:call-template name="output.parser.js" />
            </body>
        </html>
    </xsl:template>


    <!-- Produces a file with a package / test case summary with links to more detailed per-test case reports. -->
    <xsl:template name="index.html" match="testsuites" mode="all.tests">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
        <html>
            <head>
                <title><xsl:value-of select="$TITLE" /> - Package summary</title>
                <xsl:call-template name="test.favicon">
                    <xsl:with-param name="errors" select="sum(testsuite/@errors) + sum(testsuite/@failures)" />
                </xsl:call-template>
                <link href="stylesheet.css" rel="stylesheet" type="text/css" />
            </head>
            <body>

                <div id="report" class="container container_8">
                    <div class="grid_6 alpha">
                        <div class="grailslogo"></div>
                        <h1><xsl:value-of select="$TITLE" />- Summary </h1>

                        <p class="intro">
                            <xsl:call-template name="test.count.summary">
                                <xsl:with-param name="tests" select="sum(testsuite/@tests)" />
                                <xsl:with-param name="errors" select="sum(testsuite/@errors)" />
                                <xsl:with-param name="failures" select="sum(testsuite/@failures)" />
                            </xsl:call-template>
                        </p>
                    </div>

                    <div class="grid_2 omega">
                        <xsl:call-template name="navigation.links">
                            <xsl:with-param name="package.name" select="''" />
                        </xsl:call-template>
                    </div>

                    <div class="clear"></div>

                    <xsl:for-each select="./testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
                        <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                        <xsl:sort select="../@name" />

                        <xsl:call-template name="packages.overview">
                            <xsl:with-param name="packageName" select="@package" />
                        </xsl:call-template>
                    </xsl:for-each>

                    <div class="clear"></div>
                </div>

            </body>
        </html>
    </xsl:template>


    <!-- A list of all packages and their test cases -->
    <xsl:template name="packages.overview">
        <xsl:param name="packageName" />

        <xsl:variable name="sumTime" select="sum(/testsuites/testsuite[@package = $packageName]/@time)" />
        <xsl:variable name="testCount" select="sum(/testsuites/testsuite[@package = $packageName]/@tests)" />
        <xsl:variable name="errorCount" select="sum(/testsuites/testsuite[@package = $packageName]/@errors)" />
        <xsl:variable name="failureCount" select="sum(/testsuites/testsuite[@package = $packageName]/@failures)" />
        <xsl:variable name="successCount" select="$testCount - $errorCount - $failureCount" />

        <xsl:variable name="cssclass">
            <xsl:choose>
                <xsl:when test="$failureCount &gt; 0 and $errorCount = 0">failure</xsl:when>
                <xsl:when test="$errorCount &gt; 0">error</xsl:when>
                <xsl:otherwise>success</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div>
            <xsl:attribute name="class">testsuite <xsl:value-of select="$cssclass" /></xsl:attribute>

            <div class="header">
                <h2><xsl:value-of select="$packageName" /></h2>
                <h3>
                    <xsl:call-template name="test.count.summary">
                        <xsl:with-param name="tests" select="$testCount" />
                        <xsl:with-param name="errors" select="$errorCount" />
                        <xsl:with-param name="failures" select="$failureCount" />
                    </xsl:call-template>
                </h3>
            </div>

            <ul class="clearfix">
                <xsl:for-each select="/testsuites/testsuite[@package = $packageName]">
                    <xsl:sort select="@name" />

                    <xsl:variable name="testcaseCssClass">
                        <xsl:choose>
                            <xsl:when test="count(testcase/error) &gt; 0">error</xsl:when>
                            <xsl:when test="count(testcase/failure) &gt; 0">failure</xsl:when>
                            <xsl:otherwise>success</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <li>
                        <xsl:attribute name="class">packagelink <xsl:value-of select="$testcaseCssClass" /></xsl:attribute>

                        <a>
                            <xsl:variable name="package.name" select="@package" />

                            <xsl:attribute name="href">
                            <xsl:if test="not($package.name='')">
                                <xsl:value-of select="translate($package.name,'.','/')" /><xsl:text>/</xsl:text>
                            </xsl:if><xsl:value-of select="@id" />_<xsl:value-of select="@name" /><xsl:text>.html</xsl:text>
                        </xsl:attribute>

                            <xsl:attribute name="title"><xsl:value-of select="@tests" /> tests executed in <xsl:value-of select="@time" /> seconds.</xsl:attribute>

                            <span>
                                <xsl:attribute name="class">icon <xsl:value-of select="$testcaseCssClass" /></xsl:attribute>
                            </span>
                            <xsl:value-of select="@name" />
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>


    <!-- Writes the test summary -->
    <xsl:template match="testsuite" mode="summary">
        <xsl:variable name="cssclass">
            <xsl:choose>
                <xsl:when test="@failures &gt; 0 and @errors = 0">failure</xsl:when>
                <xsl:when test="@errors &gt; 0">error</xsl:when>
                <xsl:otherwise>success</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div>
            <xsl:attribute name="class">testsuite <xsl:value-of select="$cssclass" /></xsl:attribute>

            <div class="header">
                <h2><xsl:value-of select="@name" /></h2>
                <h3>
                    <xsl:call-template name="test.count.summary">
                        <xsl:with-param name="tests" select="@tests" />
                        <xsl:with-param name="errors" select="@errors" />
                        <xsl:with-param name="failures" select="@failures" />
                    </xsl:call-template>
                </h3>
            </div>

            <xsl:apply-templates select="testcase" mode="tableline">
            </xsl:apply-templates>

            <div class="clearfix output footer">
                <div class="sysout">
                    <h2>Standard output</h2>
                    <pre class="stdout">
                        <xsl:value-of select="system-out" />
                    </pre>
                </div>
                <div class="syserr">
                    <h2>System error</h2>
                    <pre class="syserr">
                        <xsl:value-of select="system-err" />
                    </pre>
                </div>
            </div>
            <div class="clear"></div>
        </div>
    </xsl:template>

    <!-- Test method -->
    <xsl:template match="testcase" mode="tableline">
        <xsl:variable name="cssclass">
            <xsl:choose>
                <xsl:when test="count(error) &gt; 0">error</xsl:when>
                <xsl:when test="count(failure) &gt; 0">failure</xsl:when>
                <xsl:otherwise>success</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="grid_8">
            <xsl:attribute name="data-name"><xsl:value-of select="@name" /></xsl:attribute>
            <xsl:attribute name="class">testcase clearfix <xsl:value-of select="$cssclass" /> grid_8 alpha omega</xsl:attribute>

            <div class="grid_4 alpha">
                <p>
                    <span>
                        <xsl:attribute name="class">icon <xsl:value-of select="$cssclass" /></xsl:attribute>
                    </span>
                    <b>
                        <xsl:attribute name="class">testname message <xsl:value-of select="$cssclass" /></xsl:attribute>
                        <xsl:value-of select="@name" />
                    </b>
                </p>

                <p class="summary">Executed in <xsl:value-of select="@time" /> seconds.</p>
            </div>

            <div class="grid_4 omega outputinfo">
                <xsl:apply-templates select="failure | error" mode="testcase.details" />
            </div>

            <div class="clear"></div>
        </div>
    </xsl:template>

    <!-- Test failure -->
    <xsl:template match="failure | error" mode="testcase.details">
        <div class="details">
            <p>
                <b class="message">
                    <xsl:value-of select="@message" />
                </b>
            </p>
            <pre>
                <xsl:value-of select="." />
            </pre>
        </div>
    </xsl:template>


    <!-- Test count summary, the number of executed tests, errors and failures -->
    <xsl:template name="test.count.summary">
        <xsl:param name="tests" />
        <xsl:param name="errors" />
        <xsl:param name="failures" />

        <xsl:choose>
            <xsl:when test="$tests = 0">
                No tests executed.
            </xsl:when>
            <xsl:otherwise>

                <!-- Test count -->
                <xsl:choose>
                    <xsl:when test="$tests = 1">
                        A single test executed
                    </xsl:when>
                    <xsl:otherwise>
                        Executed
                        <xsl:value-of select="$tests" />
                        tests
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Error / failure count -->
                <xsl:choose>
                    <xsl:when test="$errors = 0 and $failures = 0">
                        without a single error or failure!
                    </xsl:when>
                    <xsl:when test="$errors &gt; 0 and $failures = 0">
                        with
                        <xsl:call-template name="plural.singular">
                            <xsl:with-param name="number" select="$errors" />
                            <xsl:with-param name="word" select="'error'" />
                        </xsl:call-template>
                        .
                    </xsl:when>
                    <xsl:when test="$errors = 0 and $failures &gt; 0">
                        with
                        <xsl:call-template name="plural.singular">
                            <xsl:with-param name="number" select="$failures" />
                            <xsl:with-param name="word" select="'failure'" />
                        </xsl:call-template>
                        .
                    </xsl:when>
                    <xsl:otherwise>
                        with
                        <xsl:call-template name="plural.singular">
                            <xsl:with-param name="number" select="$errors" />
                            <xsl:with-param name="word" select="'error'" />
                        </xsl:call-template>

                        and
                        <xsl:call-template name="plural.singular">
                            <xsl:with-param name="number" select="$failures" />
                            <xsl:with-param name="word" select="'failure'" />
                        </xsl:call-template>
                        .
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="plural.singular">
        <xsl:param name="number" />
        <xsl:param name="word" />

        <xsl:choose>
            <xsl:when test="$number = 0">zero <xsl:value-of select="$word" />s</xsl:when>
            <xsl:when test="$number = 1">one <xsl:value-of select="$word" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$number" /><xsl:text> </xsl:text><xsl:value-of select="$word" />s</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- this is the stylesheet css to use for nearly everything -->
    <xsl:template name="stylesheet.css">
        <![CDATA[

        /* html5 boilerplate */
        html, body, div, span, object, iframe,
        h1, h2, h3, h4, h5, h6, p, blockquote, pre,
        abbr, address, cite, code, del, dfn, em, img, ins, kbd, q, samp,
        small, strong, sub, sup, var, b, i, dl, dt, dd, ol, ul, li {
        margin: 0;
        padding: 0;
        border: 0;
        font-size: 100%;
        font: inherit;
        vertical-align: baseline;
        }

        select, input, textarea, button { font:99% sans-serif; }
        pre, code, kbd, samp { font-family: monospace, sans-serif; }

        html { overflow-y: scroll; }
        a:hover, a:active { outline: none; }

        ::-moz-selection{ background: #FF9800; color:#fff; text-shadow: none; }
        ::selection { background: #FF9800; color:#fff; text-shadow: none; }
        a:link { -webkit-tap-highlight-color: #FF9800; }

        h1 { font-size: 2.5em; }
        h1, h2, h3, h4, h5, h6 { font-weight: bold; }
        body, select, input, textarea { color: #333; }

        /* html5 boilerpalte end */

        body {
            color: #333333;
            background-color: #F8F8F8;
            font:13px/1.231 ubuntu, sans-serif; *font-size:small;
        }

        p.intro { font-size: 1.5em; }

        a { color: #1A4491; text-decoration: none; }
        a:hover { }

        pre {
            border-radius: 5px;
            margin-bottom: 8px;
            padding: 15px;
            background-color: #FFFFFF;
            border: 1px solid #DEDEDE;
            font-family: Consolas, Monaco, monospace;
            font-size: 0.9em;
            white-space: pre;
            white-space: pre-wrap;
            word-wrap:
            break-word;
        }

        #report {
            border-radius: 8px;
            box-shadow: 0 0 8px #F5F5F5;

            background-color: white;
            margin: 10px auto;
            padding: 10px 15px;
        }

        /* Navigation links between the various views
        - - - - - - - - - - - - - - - - - - - - - - */
        #navigationlinks { text-align: right; }
        #navigationlinks p { padding: 2px; }
        #navigationlinks a { font-size: 1.1em; color: #464F38; }
        #navigationlinks a:hover { color: #333; }

        /* Test suites
        - - - - - - */

        .testsuite {
            border-radius: 5px;
            box-shadow: 0 0 4px #F8F8F8;

            background-color: F7F7F7;
            background: -moz-linear-gradient(center top , #F7F7F7, #FEFEFE);

            border: 1px solid #EEEEEE;
            margin: 20px 0;
            text-align: left;
            width: 100%;
        }

        .testsuite .header {
            color: white;
            padding: 5px 7px;
            text-shadow: 0 0 4px rgba(0, 0, 0, 0.2);
            font-size: 1.3em;

            border-radius: 5px 5px 0 0;
            box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
        }

        .testsuite.error .header {
            background-color: #BC2F2F;
            background: -moz-linear-gradient(#BC2F2F, #C96952);
            background: -webkit-linear-gradient(#BC2F2F, #C96952);
            background: linear-gradient(#BC2F2F, #C96952);
            border-bottom: 1px solid #BE5B5B;
        }

        .testsuite.failure .header {
            background-color: #E69814;
            background: -moz-linear-gradient(#FFB75B, #E69814);
            background: -webkit-linear-gradient(#FFB75B, #E69814);
            background: linear-gradient(#FFB75B, #E69814);
            border-bottom: 1px solid #CD912B;
        }

        .testsuite.success .header {
            background-color: #A6CC3B;
            background: -moz-linear-gradient(#A6CC3B, #CBD53B);
            background: -webkit-linear-gradient(#A6CC3B, #CBD53B);
            background: linear-gradient(#A6CC3B, #CBD53B);
            border-bottom: 1px solid #C4D5B6;
        }

        .testsuite .header h2, h3 { margin: 0; padding: 0; }
        .testsuite .header h3 { font-size: 0.8em; }

        .testsuite .name {
            width: 50%;
        }

        .testsuite .time {
            width: 10%;
        }

        .testsuite .testcase {
            padding: 5px 0;
        }

        /* Link to individual test cases
        - - - - - - - - - - - - - - - - - */

        .packagelink {
            border: 1px solid transparent;
            float: left;
            font-size: 1.1em;
            list-style: none outside none;
            padding: 2px 7px 4px 7px;
            margin: 3px;
        }

        .packagelink:hover {
            border-radius: 4px;
            background-color: #f7f7f7;
            border: 1px solid #ddd;
        }

        .packagelink a {
            color: blue;
            text-decoration: none;
            display: inline-block;
        }

        .packagelink.failure a {
            color: #FB6C00 !important;
        }

        .packagelink.error a {
            color: #DD0707 !important;
        }

        .packagelink.success a {
            color: #344804 !important;
        }

        /* force line break for long test names wihtout white-space */
        .message { word-wrap: break-word; }

        .testcase.success .message { color: #595E51; }
        .testcase.error .message { color: #AA0E0E; }
        .testcase.failure .message { color: #FB6C00; }

        .testsuite .testcase:nth-of-type(2n) {
            background-color: #F4F4F4;
            border-bottom: 1px solid #EEEEEE;
            border-top: 1px solid #EEEEEE;
        }

        .testcase .message {
            font-size: 1.1em;
            font-weight: bold;
        }

        .testcase p.summary {
            margin-left: 5px;
            font-size: 1em;
            color: #444;
        }
        
        .testcase.clearfix{
            width:100%!important;
        }
        .outputinfo p { margin-top: 9px; }

        /* output is parsed using javascript and not visible by default.
        I don't think that having a non-javascript fallback is important
        as most Grails developers won't be using IE 6 :D */

        .testsuite .footer { display: none; }
        p { padding: 4px; }

        .footer.output {
            border-radius: 0 0 5px 5px;
            background-color: #F8F8F8;
            background: -moz-linear-gradient(center top , #F8F8F8, #F2F2F2);
            border-top: 1px solid #EEEEEE;
            margin-top: 10px;
        }

        .footer.output h2 { padding: 5px 0 0 5px; }
        .footer.output .sysout, .syserr { float: left; width: 49%; }
        .footer.output pre { margin: 5px; }

        .errorMessage {
            color: #AA0E0E;
            font-size: 1em;
            font-weight: bold;
        }

        .errorMessage.failure { color: #FB6C00 !important; }

        .grailslogo {
            background-image: url('data:image/png;base64,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');
            width: 351px;
            height: 66px;
            margin: 0 10px 5px 0;
            float: left;
        }

        /* icons */
        .icon { width: 16px; height: 16px; margin: 6px 4px 0; display: inline-block; }
        .icon.failure { background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAadQTFRF/5YA/5YC/////+3U/+/Y/5gJ/5YE/5YB/9OX/+7X/+rO/5YD/7RP/6w7/7BE/+/Z/8V3/6Yr/9Wd/5cF/5gI/8Ft/5gK/+vO/+bE/8Nv/50Y/6Mi/8Z3//rz/9ef/6gy/+/a/8qC/5gL/+fF/6kz/75l/7FD//r0/9ad/5kL/6Ac/7JL/+bD/6Eg/7th//Tm/6Qm//Pk/50W/+C2/6o3/+O8/6Af/7dU/6Ae/8qD/6Ab/6Ys/7pc/8Jt/6ct//bo//Hd/8Z4/+rN/8V0/5kI/+zR/8h8//v2/7NM/58d/7JM/608/7xh/+TA/7dW/9Sa/+3W/8Ny/6cu/6cv/7BG/7BF/5cH/5YG/5gM/5gH/8Fu/54Z/9ae/9af//Tl/58e//Db/8h9/7xi/6gw/7xf/7pb/8Br/7RQ/8Rx/7BD/6w8/96x//Dd/5sR/5cG//Ph/6Yu//Lg/8Ju/8uF/7FG/8Bs/8Fs/5kN/82K/+rP/+bC/6k2/5cJ/+XA/50X/8qE/86J/5wO/9ur/8qB/+S//8yF/8uC/9CS//ft/5cI/5sM//ju////XEMRUwAAAI10Uk5T//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8A2F5VawAAAPlJREFUeNosj2Vvw0AAQ30XTsq4csfMzMzMjO2YmZm3+9FL01myZL1PfmCJKLuLjpcRY0Jv9OqzfGFYPq1VkiDlxOaeuzh3jwYzBxNgb2jTbO6fmLT07Zh6rDrYiFQVqSa/P19dWx4fYOB7hfps2lwRWaLdR64yDo4ZbfaV0uJSSt87tG8Zq4JI0P4VCv0GQcTpVnQJEoG98/CYi0Ejog05HglN9xzPcwUZkJwy+H0EKtNVX6P35voWuRzYuvDz0bYF+LxPz85q/UdLYOpgmxAiZbnEuqhxvSQNnof5S9wVviXlVuJ59jPLWE2D9d+WMT78mBpWjPknwABNFkK/nayT6wAAAABJRU5ErkJggg=="); }
        .icon.error { background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAk9QTFRF////ykY0/5GK/5KK+vb1+eLg+lNG2UYz8OPg/3xz/G1j6riz9drY942E7peN6UYz0UY28kY02EY02kY17kY200c2/1RF/1VHzEY0/5uS9Uk69Onn/5aOz0Y01kg39Ojm/3Rq/nVr30s53Es76Eo6+fLw+21i9Hhw/7ex/GRY67Ks74qC9ray6kYz/v//7rKs30Yz4ltN/GZb+uPh7dPP7WNY9+Lg7VNF7dHM8c/L9FdM90Yz+WRY8VdK9+bk9ldL/nRp32JW6mJW3Ec48tTQ70k68Hxy8t3a75WM8KKb+eHf/Eo7/Pn47NzY3kY170k5+Ovq+WJW7aSb4U89+uDe/Pf2+pOL/3xy3Ew88JGI+Ozr3F1O/a2o31BB10Yz+ubk6Z+X8Hhv6s3J1kY25kg39+Ph1kY17FdK6Uk699PQ/5KL8EY09qih/W5j4oh/3EY079nZ75uS9bWx4IF270Y04l9R79/c1Uo69sTB7mpf4WZZ6JuT77aw/7Ks/nNp7Lex+fPx7lhL9uLg20k64lA+7+Dc+IF44ks67pWM9EY09+Ti5Whe2GVX5Eg67qmg6NTO8m1i/KSe8aWd0kYz9sC86tzY+ezr7kk6/5qS9NrY3UYz7pqQ4YZ89kYz7omB/7Su5p6W7YqB9uPh69vY6Ug4/Uw96NXR/8nE56Oc8HVp22hc1kYz+e7tzkYz4FxO+uHf56Ob73Rp7mZb5ZqS50s94FdJ83pw9tDM6dvX+N/d9uHf/3Rr9Us867izxEY044d99KOc7pSK9t/d8uDc////NUopuQAAAMV0Uk5T/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wA0VseRAAABBElEQVR42mI4AgLrK3SKpoSAmQxAbJwTs1xjfu3EA14QgcywGcxZTEzMMpK820EC8W2cahNydyvUqXOFb2MFCkQaWc2b6cbGlsijba+58AgDq+10p1CGNZWbohh8TF3NdzLUbBFW8mRgmBbAoDep3a9XnyGhWUBo1mxVFpaGQoP8ZOdqhgXl+2RXO7pLyx+uYk+TEN3MUK/MuLbHopWDo8xk1WRGOS0Gs1j26KRlizsO+vYXdMdFHGI4MkclOGgHH7+ux9S+lpRioDvs1vkv2Vgi2Jm9MkNkayrI6S6le+Z6i4kvtZYytIR4risvPVDRwaZx/yKob48caeJesWHvLjATIMAAiZBvi5wj6TUAAAAASUVORK5CYII="); }
        .icon.success { background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAn9QTFRF////BcEAWfsgGNYCA4YAINsDZPopA4QABaAAC8QAPOsOkP9TBcMABcYABccACMgAEdEAB4YADcwABMEADrcADcwAENAABsgABI8AAIMAAYoAC5gBAYwABJQABYwAApEACJoAEKwBGbMEEK4BDa0BEK0BEbMBFbcCA4gAA4oAGKsEA5MAB50ACqUBDJABD6kBG7EEPL4TLr4LHrYFKb4JM9wMJcoFJdQFN8AQSeMZWNUjDcgAEMIBF8sCG9cCJNMFK+IHMN4KNMQOPOoOPukQQ8EWSPIXS/IXTMgcTNQbT8geUPQaUeocUt8eV/cgWfogXOYmYf4mZuwtav8ta+YybvI0c/Y5d/c6d/g7hPFKivFRk+5clPFemO5jmvRln/BtpOtyreyBrfB/sOqEse2CtOqJWKAqWaErWqEsW6ItXKMuXaQuXqUvX6UwYKYxYacyYqgzY6g0ZKk1Zao2Zqs2Z6s3aKw4aa05aq46a647bK88bbA9brE+b7E/cLJAcbNBcrNCc7RDdLVEdrZFd7ZGeLdHebhIerhJe7lKfLpLfbpNfrtOf7xPgLxQgb1Rgr5Sg79ThL9UhcBVhsFXh8FYicJZisNai8NbjMRcjcRejsVfj8ZgkMZhkcdjkshkk8hllMlmlcpolsppmMtqmcxrmsxtm81unM1vnc5xns9yn89zoNB0odF2otF3pNJ5pdJ6ptN7p9R9qNR+qdV/qtWBq9aCrNeErdeFrtiGsNiIsdmJstqLs9qMtNuOtduPttyRt92SuN2Uut6Vu96XvN+YveCavuCbv+GdwOGeweKgwuKhxOOjxeSlxuSmx+WoyOWpyearyuaty+euzeiwzuiyC5FmAAAAAAF0Uk5TAEDm2GYAAACFSURBVBgZfcGhCsMwEAbg/1FPRMREVETUVRwcFCIiyk3EJRAxs2eIDaNmD7SOMtqK7fuAfwRXMnmcCb+Sw0H4qaoWQAjYzNOaggwWkBBnIHDPqs4CHNce4sK9JnUWwJCpNZFGJXmPD7cUYxrdKwt2/kabyoovl4hIMg5jeTDhbBSDK8JPb8CGNtTmyz9LAAAAAElFTkSuQmCC"); }

        /* 960gs */
        body{min-width:1200px}
        .container_8{margin-left:auto;margin-right:auto;width:1200px}
        .grid_1,.grid_2,.grid_3,.grid_4,.grid_5,.grid_6,.grid_7,.grid_8{display:inline;float:left;position:relative;margin-left:15px;margin-right:15px}
        .push_1,.pull_1,.push_2,.pull_2,.push_3,.pull_3,.push_4,.pull_4,.push_5,.pull_5,.push_6,.pull_6,.push_7,.pull_7,.push_8,.pull_8{position:relative}
        .alpha{margin-left:0}
        .omega{margin-right:0}
        .container_8 .grid_1{width:120px}
        .container_8 .grid_2{width:270px}
        .container_8 .grid_3{width:420px}
        .container_8 .grid_4{width:570px}
        .container_8 .grid_5{width:720px}
        .container_8 .grid_6{width:870px}
        .container_8 .grid_7{width:1020px}
        .container_8 .grid_8{width:1170px}
        .container_8 .prefix_1{padding-left:150px}
        .container_8 .prefix_2{padding-left:300px}
        .container_8 .prefix_3{padding-left:450px}
        .container_8 .prefix_4{padding-left:600px}
        .container_8 .prefix_5{padding-left:750px}
        .container_8 .prefix_6{padding-left:900px}
        .container_8 .prefix_7{padding-left:1050px}
        .container_8 .suffix_1{padding-right:150px}
        .container_8 .suffix_2{padding-right:300px}
        .container_8 .suffix_3{padding-right:450px}
        .container_8 .suffix_4{padding-right:600px}
        .container_8 .suffix_5{padding-right:750px}
        .container_8 .suffix_6{padding-right:900px}
        .container_8 .suffix_7{padding-right:1050px}
        .container_8 .push_1{left:150px}
        .container_8 .push_2{left:300px}
        .container_8 .push_3{left:450px}
        .container_8 .push_4{left:600px}
        .container_8 .push_5{left:750px}
        .container_8 .push_6{left:900px}
        .container_8 .push_7{left:1050px}
        .container_8 .pull_1{left:-150px}
        .container_8 .pull_2{left:-300px}
        .container_8 .pull_3{left:-450px}
        .container_8 .pull_4{left:-600px}
        .container_8 .pull_5{left:-750px}
        .container_8 .pull_6{left:-900px}
        .container_8 .pull_7{left:-1050px}
        .clear{clear:both;display:block;overflow:hidden;visibility:hidden;width:0;height:0}
        .clearfix:before,.clearfix:after{content:'\0020';display:block;overflow:hidden;visibility:hidden;width:0;height:0}
        .clearfix:after{clear:both}
        .clearfix{zoom:1}
        
        /* Custom */
        .testcase.failure.clearfix {
            background: rgba(255, 157, 157, 0.5);
        }
        
        .testcase.error.clearfix {
            background: rgba(255, 157, 157, 0.5);
        }
        
        ]]>
    </xsl:template>

    <!-- transform string like a.b.c to ../../../ @param path the path to transform into a descending directory path -->
    <xsl:template name="path">
        <xsl:param name="path" />
        <xsl:if test="contains($path,'.')">
            <xsl:text>../</xsl:text>
            <xsl:call-template name="path">
                <xsl:with-param name="path">
                    <xsl:value-of select="substring-after($path,'.')" />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(contains($path,'.')) and not($path = '')">
            <xsl:text>../</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="test.favicon">
        <xsl:param name="errors" />
        <xsl:choose>
            <xsl:when test="$errors &gt; 0"><link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAABsAAAAMgAAAGQAVVX/AAAAXAAAAMgAAACOAAAAwAAHB/8AAAAaAAAAhgB1df8AAABMACcn/wAAALAAe3v/ANPT6wAAADwAAACoAAAAoACBgf8AAADSAKOjxwAAAJAAk5OzAAAAVgAAAMIAAACIAAAA9ABTU/8AAABOADk5/wAAAIAAAABGAAUF/wAAAHgAAABwAEVF/wAAAGAAAAD+AAAAWAAAAMQAj4+wAL+/3QBLS/8AAABQAAAAvAAxMf8AAADuAJ+fxQAAAEgAAACkAHFx/wBXV/8AAACcACMj/wAAAGIA5+f5AAkJ/wAAAJQA////ANfX7QAAAIwAQ0P/AH19/wAAAPAAAAC2AAAAEAAAAHwALy//AAAAOgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4eHjgAAAAAAAAAAAAAFjcbMUIvPBQAAAAAAAAADzklHD09QyUlHAAAAAAAEwoSLik9PSkuEgohAAAAAAIfGhoaGhoaGhofAgAAAAdEIg0NDSsZDQ0NIgInAAAlCkcDAwMyFwMDA0czBQAAHAUkJCQkLCwkJCQkAUUAADRFHD8/PxE+Pz8/PwsYAAAAKkMICAg6OggICAgGAAAAAAkoHR0dPT0dHR0jOwAAAAAAJiAwQD09RkZGLQAAAAAAAAAENQw9PRUVNgAAAAAAAAAAAAA2QRAeAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AAD8PwAA8A8AAOAHAADAAwAAwAMAAIABAACAAQAAgAEAAIABAADAAwAAwAMAAOAHAADwDwAA/D8AAP//AAA=" rel="icon" type="image/x-icon" /></xsl:when>
            <xsl:otherwise><link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAa4qcAGuKnABripwAa4qcAGuKnABripwAa4qdiGuKn/xrip/8a4qdNGuKnABripwAa4qcAGuKnABripwAa4qcAGuKnABripwAa4qcAGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKnABripwAa4qcAGuKnABripwAa4qcAGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qcAGuKnABripwAa4qcAGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qcAGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKnABripwAa4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qe4GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qdNGuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qfKGuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qdiGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKnABripwAa4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qcAGuKnABrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qcAGuKnABripwAa4qcGGuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qcAGuKnABripwAa4qcAGuKnABripwAa4qf/GuKn/xrip/8a4qf/GuKn/xrip/8a4qf/GuKn/xripwAa4qcAGuKnABripwAa4qcAGuKnABripwAa4qcAGuKnABripwAa4qfKGuKn/xrip/8a4qe4GuKnABripwAa4qcAGuKnABripwAa4qcA/n8AAPAPAADgBwAAwAMAAIABAACAAQAAAAEAAAAAAAAAAAAAAAEAAIABAACAAQAAwAMAAOAHAADwDwAA/D8AAA==" rel="icon" type="image/x-icon" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- create the link to the stylesheet based on the package name -->
    <xsl:template name="create.resource.links">
        <xsl:param name="package.name" />
        <link rel="shortcut icon" href="http://grails.org/images/favicon.ico" type="image/x-icon"></link>
        <link rel="stylesheet" type="text/css" title="Style">
            <xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name" /></xsl:call-template></xsl:if>stylesheet.css</xsl:attribute>
        </link>
    </xsl:template>

    <!-- create the link to the home page wrapped around the grails logo -->
    <xsl:template name="create.logo.link">
        <xsl:param name="package.name" />
        <a title="Home">
            <xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name" /></xsl:call-template></xsl:if>index.html</xsl:attribute>
            <div class="grailslogo"></div>
        </a>
    </xsl:template>

    <!-- create the links for the various views -->
    <xsl:template name="navigation.links">
        <xsl:param name="package.name" />
        <nav id="navigationlinks">
            <p>
                <a>
                    <xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name" /></xsl:call-template></xsl:if>failed.html</xsl:attribute>
                    Tests with failure and errors
                </a>
            </p>
            <p>
                <a>
                    <xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name" /></xsl:call-template></xsl:if>index.html</xsl:attribute>
                    Package summary
                </a>
            </p>
            <p>
                <a>
                    <xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name" /></xsl:call-template></xsl:if>all.html</xsl:attribute>
                    Show all tests
                </a>
            </p>
        </nav>
    </xsl:template>

    <!-- template that will convert a carriage return into a br tag @param word the text from which to convert CR to BR tag -->
    <xsl:template name="br-replace">
        <xsl:param name="word" />
        <xsl:value-of disable-output-escaping="yes" select='stringutils:replace(string($word),"&#xA;","&lt;br/>")' />
    </xsl:template>

    <xsl:template name="display-time">
        <xsl:param name="value" />
        <xsl:value-of select="format-number($value,'0.000')" />
    </xsl:template>

    <xsl:template name="display-percent">
        <xsl:param name="value" />
        <xsl:value-of select="format-number($value,'0.00%')" />
    </xsl:template>


    <xsl:template name="output.parser.js">
        <xsl:comment>
            Parses JUnit output and associates it with the corresponding test case
        </xsl:comment>
        <script language="javascript">
<![CDATA[

/**
 * The JUnit report format is incredibly stuipd in the
 * sense that it accumulates output from all test methods
 * into a single xml node.
 */
(function() {

    var outputElements = findOutputElements();
    for (var i in outputElements) {
        var outputElement = outputElements[i];
        var textOutput = outputElement.element.firstChild.nodeValue;
        var header = outputElement.getHeader();
        appendTestMethodOutput(textOutput, header);
    }

    function findOutputElements() {
        var outputElements = [];
        var preElements = document.getElementsByTagName("pre");
        for (var i in preElements) {
            var preElement = preElements[i];
            var className = preElement.className || "";
            if (className.indexOf("stdout") >= 0) {
                var outputElement = new OutputElement(preElement, "output");
                outputElements.push(outputElement);
            } else if (className.indexOf("syserr") >= 0) {
                var outputElement = new OutputElement(preElement, "error");
                outputElements.push(outputElement);
            }
        }

        return outputElements;
    }

    function OutputElement(element, type) {
        this.element = element;
        this.type = type;

        this.getHeader = function() {
            if (type === "output") {
                return "System output";
            } else if ("error") {
                return "System error";
            }
        }
    }

    function appendTestMethodOutput(text, header) {
        var testOutput = new TestMethodOutput(header);

        var lines = text.split(/\r\n|\r|\n/);
        for (var i in lines) {
            var line = lines[i];
            var matches = line.match(/^--Output from (.*)--$/);
            if (matches !== null && matches.length == 2) {
                testOutput.flushToDom();
                testOutput.testName = matches[1];
            } else {
                testOutput.addLine(line);
            }
        }

        testOutput.flushToDom();
    }

    function TestMethodOutput(header) {
        this.header = header;
        this.testName = undefined;
        this.buffer = "";

        this.addLine = function(line) {
            this.buffer += line + "\n";
        }

        this.flushToDom = function() {
            if (this.testName !== undefined) {
                var domNode = getTestcaseElementByName(this.testName);
                if (domNode !== undefined && trimString(this.buffer).length > 0) {
                    this.appendTo(domNode);
                }

                this.reset();
            }
        }

        this.appendTo = function(domNode) {
            var node = document.createElement("div");
            node.innerHTML = '<p><b class="message">' + header + '</b></p>';

            var preNode = document.createElement("pre");
            preNode.appendChild(document.createTextNode(this.buffer));
            node.appendChild(preNode);

            var outputContainer = findElementByTagClassAndParent("div", "outputinfo", domNode);
            outputContainer.appendChild(node);
        }

        this.reset = function() {
            this.methodName = undefined;
            this.buffer = "";
        }
    }

    function getTestcaseElementByName(name) {
        var divElements = document.getElementsByTagName("div");
        var elementCount = divElements.length;
        for (var i=0; i<elementCount; i++) {
            var el = divElements[i];
            if (el.getAttribute("data-name") === name) {
                return el;
            }
        }
    }

    function findElementByTagClassAndParent(tagName, className, parentNode) {
        var elements = parentNode.getElementsByTagName(tagName);
        for (var i in elements) {
            var element = elements[i];

            // Not 100% correct, but good enough here
            if (element.className !== undefined && element.className.indexOf(className) >= 0) {
                return element;
            }
        }
    }

    function trimString(str) {
        return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    }

})();
]]>
        </script>
    </xsl:template>

</xsl:stylesheet>