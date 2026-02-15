<?xml version="1.0" encoding="utf-8"?>
<root
 xmlns="http://www.w3.org/1999/XSL/Format"
 xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
>
 <!-- Master pages -->
 <!--              -->
 <layout-master-set>
  <!-- Title master page -->
  <!--                   -->
  <wwpage:Macro action="copy-layout-masters" source="Title.asp" />

  <!-- TOC master pages -->
  <!--                  -->
  <wwpage:Macro action="copy-layout-masters" source="TOC.asp" />

  <!-- Index master pages -->
  <!--                    -->
  <wwpage:Macro action="copy-layout-masters" source="Index.asp" />

  <!-- Body master pages -->
  <!--                   -->
  <wwpage:Macro action="generate-layout-masters" source="Body.asp" />
 </layout-master-set>

 <!-- Bookmarks - Table of Contents -->
 <!--                               -->
 <bookmark-tree wwpage:condition="bookmarks-exist" wwpage:replace="bookmarks">
  <bookmark>
   <bookmark-title> Some Title </bookmark-title>
  </bookmark>
 </bookmark-tree>

 <!-- Title page sequence -->
 <!--                     -->
 <wwpage:Macro action="copy-page-sequences" source="Title.asp" />

 <!-- TOC page sequence -->
 <!--                   -->
 <wwpage:Macro action="copy-page-sequences" source="TOC.asp" />

 <!-- Body page sequence -->
 <!--                    -->
 <wwpage:Macro action="generate-page-sequences" source="Body.asp" />

 <!-- Index page sequence -->
 <!--                     -->
 <wwpage:Macro action="copy-page-sequences" source="Index.asp" />
</root>
