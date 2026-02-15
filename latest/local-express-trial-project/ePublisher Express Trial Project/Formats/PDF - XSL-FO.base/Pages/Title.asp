<?xml version="1.0" encoding="utf-8"?>
<root
 xmlns="http://www.w3.org/1999/XSL/Format"
 xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
>
 <layout-master-set>
  <!-- Title master pages -->
  <!--                    -->
  <simple-page-master
   wwpage:condition="title-exists"
   wwpage:replace="title-first-master-page"
  />

  <simple-page-master
   wwpage:condition="title-exists"
   wwpage:replace="title-last-master-page"
  />

  <simple-page-master
   wwpage:condition="title-exists"
   wwpage:replace="title-even-master-page"
  />

  <simple-page-master
   wwpage:condition="title-exists"
   wwpage:replace="title-odd-master-page"
  />

  <page-sequence-master master-name="title-pages"
                        wwpage:condition="title-exists"
  >
   <repeatable-page-master-alternatives>
    <conditional-page-master-reference
     page-position="first"
     master-reference="title-first-master-page"
     wwpage:condition="title-first-master-page"
    />
    <conditional-page-master-reference
     page-position="last"
     master-reference="title-last-master-page"
     wwpage:condition="title-last-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="even"
     master-reference="title-even-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="odd"
     master-reference="title-odd-master-page"
    />
   </repeatable-page-master-alternatives>
  </page-sequence-master>
 </layout-master-set>

 <!-- Title page sequence -->
 <!--                     -->
 <page-sequence
  master-reference="title-pages"
  wwpage:condition="title-exists"
  force-page-count="auto"
  wwpage:attribute-force-page-count="title-force-page-count"
  initial-page-number="auto"
  wwpage:attribute-initial-page-number="title-initial-page-number"
  format="1"
  wwpage:attribute-format="title-page-sequence-format"
  letter-value="auto"
  wwpage:attribute-letter-value="title-page-sequence-letter-value"
 >
  <!-- Title header -->
  <!--              -->
  <static-content flow-name="title-first-header" wwpage:condition="disable-title-first-header-exists">
   <block
    wwpage:replace="title-first-header"
   />
  </static-content>

  <static-content flow-name="title-last-header" wwpage:condition="disable-title-last-header-exists">
   <block
    wwpage:replace="title-last-header"
   />
  </static-content>

  <static-content flow-name="title-even-header" wwpage:condition="disable-title-even-header-exists">
   <block
    wwpage:replace="title-even-header"
   />
  </static-content>

  <static-content flow-name="title-odd-header" wwpage:condition="disable-title-odd-header-exists">
   <block
    wwpage:replace="title-odd-header"
   />
  </static-content>

  <!-- Title footer -->
  <!--              -->
  <static-content flow-name="title-first-footer" wwpage:condition="disable-title-first-footer-exists">
   <block
    wwpage:replace="title-first-footer"
   />
  </static-content>

  <static-content flow-name="title-last-footer" wwpage:condition="disable-title-last-footer-exists">
   <block
    wwpage:replace="title-last-footer"
   />
  </static-content>

  <static-content flow-name="title-even-footer" wwpage:condition="disable-title-even-footer-exists">
   <block
    wwpage:replace="title-even-footer"
   />
  </static-content>

  <static-content flow-name="title-odd-footer" wwpage:condition="disable-title-odd-footer-exists">
   <block
    wwpage:replace="title-odd-footer"
   />
  </static-content>

  <flow flow-name="title-body" wwpage:condition="title-exists">
   <marker marker-class-name="ChapterTitle" wwpage:content="title-page-title-string"></marker>
   <marker marker-class-name="RunningTitle" wwpage:content="title-page-title-string"></marker>

   <block wwpage:condition="display-title-page-title" wwpage:replace="title-page-title">
    Title
   </block>

   <block wwpage:condition="display-title-page-subtitle" wwpage:replace="title-page-subtitle">
    Subtitle
   </block>

   <block wwpage:condition="display-title-page-publish-date" wwpage:replace="publish-date">
    publish-date
   </block>
  </flow>
 </page-sequence>
</root>
