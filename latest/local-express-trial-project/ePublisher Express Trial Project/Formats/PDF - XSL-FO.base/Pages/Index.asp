<?xml version="1.0" encoding="utf-8"?>
<root
 xmlns="http://www.w3.org/1999/XSL/Format"
 xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
>
 <layout-master-set>
  <!-- Index master pages -->
  <!--                    -->
  <simple-page-master
   wwpage:condition="index-exists"
   wwpage:replace="index-first-master-page"
  />

  <simple-page-master
   wwpage:condition="index-exists"
   wwpage:replace="index-last-master-page"
  />

  <simple-page-master
   wwpage:condition="index-exists"
   wwpage:replace="index-even-master-page"
  />

  <simple-page-master
   wwpage:condition="index-exists"
   wwpage:replace="index-odd-master-page"
  />

  <page-sequence-master master-name="index-pages"
                        wwpage:condition="index-exists"
  >
   <repeatable-page-master-alternatives>
    <conditional-page-master-reference
     page-position="first"
     master-reference="index-first-master-page"
     wwpage:condition="index-first-master-page"
    />
    <conditional-page-master-reference
     page-position="last"
     master-reference="index-last-master-page"
     wwpage:condition="index-last-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="even"
     master-reference="index-even-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="odd"
     master-reference="index-odd-master-page"
    />
   </repeatable-page-master-alternatives>
  </page-sequence-master>
 </layout-master-set>

 <!-- Index page sequence -->
 <!--                     -->
 <page-sequence
  master-reference="index-pages"
  wwpage:condition="index-exists"
  force-page-count="auto"
  wwpage:attribute-force-page-count="index-force-page-count"
  initial-page-number="auto"
  wwpage:attribute-initial-page-number="index-initial-page-number"
  format="1"
  wwpage:attribute-format="index-page-sequence-format"
  letter-value="auto"
  wwpage:attribute-letter-value="index-page-sequence-letter-value"
 >
  <!-- Index header -->
  <!--              -->
  <static-content flow-name="index-first-header" wwpage:condition="index-first-header-exists">
   <block
    wwpage:replace="index-first-header"
   />
  </static-content>

  <static-content flow-name="index-last-header" wwpage:condition="index-last-header-exists">
   <block
    wwpage:replace="index-last-header"
   />
  </static-content>

  <static-content flow-name="index-odd-header" wwpage:condition="index-odd-header-exists">
   <block
    wwpage:replace="index-odd-header"
   />
  </static-content>

  <static-content flow-name="index-even-header" wwpage:condition="index-even-header-exists">
   <block
    wwpage:replace="index-even-header"
   />
  </static-content>

  <!-- Index footer -->
  <!--              -->
  <static-content flow-name="index-first-footer" wwpage:condition="index-first-footer-exists">
   <block
    wwpage:replace="index-first-footer"
   />
  </static-content>

  <static-content flow-name="index-last-footer" wwpage:condition="index-last-footer-exists">
   <block
    wwpage:replace="index-last-footer"
   />
  </static-content>

  <static-content flow-name="index-even-footer" wwpage:condition="index-even-footer-exists">
   <block
    wwpage:replace="index-even-footer"
   />
  </static-content>

  <static-content flow-name="index-odd-footer" wwpage:condition="index-odd-footer-exists">
   <block
    wwpage:replace="index-odd-footer"
   />
  </static-content>

  <flow flow-name="index-body" wwpage:condition="index-exists">
   <marker marker-class-name="ChapterTitle" wwpage:content="index-title-string">Index</marker>
   <marker marker-class-name="RunningTitle" wwpage:content="index-title-string">Index</marker>

   <block
    wwpage:replace="index-title"
   />

   <block wwpage:replace="index-content">
    Index content here...
   </block>
  </flow>
 </page-sequence>
</root>

