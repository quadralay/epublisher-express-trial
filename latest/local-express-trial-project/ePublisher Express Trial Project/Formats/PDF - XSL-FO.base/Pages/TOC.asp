<?xml version="1.0" encoding="utf-8"?>
<root
 xmlns="http://www.w3.org/1999/XSL/Format"
 xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
>
 <layout-master-set>
  <!-- TOC master pages -->
  <!--                  -->
  <simple-page-master
   wwpage:condition="toc-exists"
   wwpage:replace="toc-first-master-page"
  />

  <simple-page-master
   wwpage:condition="toc-exists"
   wwpage:replace="toc-last-master-page"
  />

  <simple-page-master
   wwpage:condition="toc-exists"
   wwpage:replace="toc-even-master-page"
  />

  <simple-page-master
   wwpage:condition="toc-exists"
   wwpage:replace="toc-odd-master-page"
  />

  <page-sequence-master master-name="toc-pages"
                        wwpage:condition="toc-exists"
  >
   <repeatable-page-master-alternatives>
    <conditional-page-master-reference
     page-position="first"
     master-reference="toc-first-master-page"
     wwpage:condition="toc-first-master-page"
    />
    <conditional-page-master-reference
     page-position="last"
     master-reference="toc-last-master-page"
     wwpage:condition="toc-last-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="even"
     master-reference="toc-even-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="odd"
     master-reference="toc-odd-master-page"
    />
   </repeatable-page-master-alternatives>
  </page-sequence-master>
 </layout-master-set>

 <!-- TOC page sequence -->
 <!--                   -->
 <page-sequence
  master-reference="toc-pages"
  wwpage:condition="toc-exists"
  force-page-count="auto"
  wwpage:attribute-force-page-count="toc-force-page-count"
  initial-page-number="auto"
  wwpage:attribute-initial-page-number="toc-initial-page-number"
  format="1"
  wwpage:attribute-format="toc-page-sequence-format"
  letter-value="auto"
  wwpage:attribute-letter-value="toc-page-sequence-letter-value"
 >
  <!-- TOC header -->
  <!--            -->
  <static-content flow-name="toc-first-header" wwpage:condition="toc-first-header-exists">
   <block
    wwpage:replace="toc-first-header"
   />
  </static-content>

  <static-content flow-name="toc-last-header" wwpage:condition="toc-last-header-exists">
   <block
    wwpage:replace="toc-last-header"
   />
  </static-content>

  <static-content flow-name="toc-even-header" wwpage:condition="toc-even-header-exists">
   <block
    wwpage:replace="toc-even-header"
   />
  </static-content>

  <static-content flow-name="toc-odd-header" wwpage:condition="toc-odd-header-exists">
   <block
    wwpage:replace="toc-odd-header"
   />
  </static-content>

  <!-- TOC footer -->
  <!--            -->
  <static-content flow-name="toc-first-footer" wwpage:condition="toc-first-footer-exists">
   <block
    wwpage:replace="toc-first-footer"
   />
  </static-content>

  <static-content flow-name="toc-last-footer" wwpage:condition="toc-last-footer-exists">
   <block
    wwpage:replace="toc-last-footer"
   />
  </static-content>

  <static-content flow-name="toc-even-footer" wwpage:condition="toc-even-footer-exists">
   <block
    wwpage:replace="toc-even-footer"
   />
  </static-content>

  <static-content flow-name="toc-odd-footer" wwpage:condition="toc-odd-footer-exists">
   <block
    wwpage:replace="toc-odd-footer"
   />
  </static-content>

  <flow flow-name="toc-body" wwpage:condition="toc-exists">
   <marker marker-class-name="ChapterTitle" wwpage:content="toc-title-string">Table of Contents</marker>
   <marker marker-class-name="RunningTitle" wwpage:content="toc-title-string">Table of Contents</marker>

   <block
    wwpage:replace="toc-title"
   />

   <block wwpage:replace="toc-content">
    TOC content here...
   </block>
  </flow>
 </page-sequence>
</root>
