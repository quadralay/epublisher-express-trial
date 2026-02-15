<?xml version="1.0" encoding="utf-8"?>
<root
 xmlns="http://www.w3.org/1999/XSL/Format"
 xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
>
 <layout-master-set>
  <!-- Body master pages -->
  <!--                   -->
  <simple-page-master
   wwpage:replace="body-first-master-page"
  />

  <simple-page-master
   wwpage:replace="body-last-master-page"
  />

  <simple-page-master
   wwpage:replace="body-odd-master-page"
  />

  <simple-page-master
   wwpage:replace="body-even-master-page"
  />

  <page-sequence-master master-name="body-pages">
   <repeatable-page-master-alternatives>
    <conditional-page-master-reference
     page-position="first"
     master-reference="body-first-master-page"
     wwpage:condition="body-first-master-page"
    />
    <conditional-page-master-reference
     page-position="last"
     master-reference="body-last-master-page"
     wwpage:condition="body-last-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="even"
     master-reference="body-even-master-page"
    />
    <conditional-page-master-reference
     odd-or-even="odd"
     master-reference="body-odd-master-page"
    />
   </repeatable-page-master-alternatives>
  </page-sequence-master>
 </layout-master-set>

 <!-- Body page sequence -->
 <!--                    -->
 <page-sequence
  master-reference="body-pages"
  force-page-count="auto"
  wwpage:attribute-force-page-count="body-force-page-count"
  initial-page-number="auto"
  wwpage:attribute-initial-page-number="body-initial-page-number"
  format="1"
  wwpage:attribute-format="body-page-sequence-format"
  letter-value="auto"
  wwpage:attribute-letter-value="body-page-sequence-letter-value"
 >
  <!-- Footnote separator -->
  <!--                    -->
  <static-content flow-name="xsl-footnote-separator">
   <block width="100%"><leader leader-pattern="rule" /></block>
  </static-content>

  <!-- First header -->
  <!--              -->
  <static-content flow-name="body-first-header" wwpage:condition="body-first-header-exists">
   <block
    wwpage:replace="body-first-header"
   />
  </static-content>

  <!-- Last header -->
  <!--             -->
  <static-content flow-name="body-last-header" wwpage:condition="body-last-header-exists">
   <block
    wwpage:replace="body-last-header"
   />
  </static-content>

  <!-- Even header -->
  <!--             -->
  <static-content flow-name="body-even-header" wwpage:condition="body-even-header-exists">
   <block
    wwpage:replace="body-even-header"
   />
  </static-content>

  <!-- Odd header -->
  <!--            -->
  <static-content flow-name="body-odd-header" wwpage:condition="body-odd-header-exists">
   <block
    wwpage:replace="body-odd-header"
   />
  </static-content>

  <!-- First footer -->
  <!--              -->
  <static-content flow-name="body-first-footer" wwpage:condition="body-first-footer-exists">
   <block
    wwpage:replace="body-first-footer"
   />
  </static-content>

  <!-- Last footer -->
  <!--             -->
  <static-content flow-name="body-last-footer" wwpage:condition="body-last-footer-exists">
   <block
    wwpage:replace="body-last-footer"
   />
  </static-content>

  <!-- Even footer -->
  <!--             -->
  <static-content flow-name="body-even-footer" wwpage:condition="body-even-footer-exists">
   <block
    wwpage:replace="body-even-footer"
   />
  </static-content>

  <!-- Odd footer -->
  <!--            -->
  <static-content flow-name="body-odd-footer" wwpage:condition="body-odd-footer-exists">
   <block
    wwpage:replace="body-odd-footer"
   />
  </static-content>

  <!-- Flow -->
  <!--      -->
  <flow flow-name="body-body">
   <block wwpage:replace="body">
    Page content...
   </block>
  </flow>
 </page-sequence>
</root>
