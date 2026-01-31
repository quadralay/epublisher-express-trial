**ePublisher** Syntax has some built in mapping connecting syntax to styles in **ePublisher**. An example of this
is the syntax `#` is already mapped to *Heading 1* in **ePublisher**.  Styles are a collection of attributes and
formatting information that can be used to ensure uniformity throughout source document and generated output. The
following sections provide definitions for the styles used within this source document. Use the information in this
section to learn more about the different paragraph and character styles and marker types used within this source
document.

<!--style:Glossterm-->
Paragraph Styles  

<!--style:GlossDef-->
Paragraph styles apply to entire paragraphs of text. Use paragraph styles if you want to apply certain formatting to a particular section of your content. 

<!--style:Glossterm-->
Paragraph 

<!--style:GlossDef-->
All content that serves as the body of this document uses the "Paragraph" paragraph style. For example, any text that is not part of a table, numbered or bulleted list should use this paragraph style

<!--style:Glossterm-->
Title

<!--style:GlossDef-->
The "Title" paragraph style allows you to identify new chapters in your document.  

<!--style:Glossterm-->
ExpandCollapse  

<!--style:GlossDef-->
The "ExpandCollapse" style creates links that display or hide content in an expand or collapse section in the generated output. Apply this style to any text that you want to serve as a link for an expand/collapse section. 

<!--style:Glossterm-->
GlossDef

<!--style:GlossDef-->
The "GlossDef" style should be applied to the glossary definition for glossary terms. 

<!--style:Glossterm-->
GlossTerm

<!--style:GlossDef-->
The "GlossTerm" style should be applied to any glossary term that will appear in the glossary section. Content with the GlossTerm style should always precede the GlossDef style. 

<!--style:Glossterm-->
Heading 1, Heading 2, and Heading 3  

<!--style:GlossDef-->
Heading styles can be used to label titles for major sections in source documents. Each heading style differs in font size and font weight. 

<!--style:Glossterm-->
OList, OList Item  

<!--style:GlossDef-->
The "OList" styles allow you to create ordered lists. In Markdown using the syntax for numbered list "`1. `" will automatically apply the Ordered styling information. Use indentation in the source document to nest lists within lists.

<!--style:Glossterm-->
UList, UList Item  

<!--style:GlossDef-->
The "UList" styles allow you to create unordered lists. In Markdown using the syntax for unordered list "`* `" will automatically apply the Unordered styling information. Use indentation in the source document to nest lists within lists.

<!--style:Glossterm-->
ProcedureTitle

<!--style:GlossDef-->
The "ProcedureTitle" style should be used for procedure introductory statements. Apply this style to any text that introduces the procedure. This style does not create expand/ collapse sections that display or hide steps in a procedure. If you want to create procedure introductory statements that display or hide steps in a procedure, use the "ExpandCollapse" paragraph style. 

<!--style:Glossterm-->
RelatedTopic

<!--style:GlossDef-->
The RelatedTopic style creates related topics links in the generated output. Apply this style to a list of cross-references that you want to display as links in your generated output. 

<!--style:Glossterm-->
Character or Inline Styles 

<!--style:GlossDef-->
Character or Inline styles allow you to override paragraph styles when you need to change the style attributes for a small amount of text. For example, you can use these styles when you want to italicize, bold or underline a specific word in a paragraph without overriding the existing paragraph style.

<!--style:Glossterm-->
Code

<!--style:GlossDef-->
The "Code" style allows you to apply a monospace font to text that will appear as code in your content. This style is automatically applied when using the Markdown syntax "\`\`". 

<!--style:Glossterm-->
Hyperlink

<!--style:GlossDef-->
The "Hyperlink" style applies a blue font and underline to text, which allows you to display URL addresses and other links as clickable items. This style is automatially applied with the Markdown syntax for links 

<!--style:Glossterm-->
Marker Types 

<!--style:GlossDef-->
Marker types allow you to embed information in your source documents and add functional elements to your generated output. For example, you can use markers to create popup windows and context-sensitive help topics.

<!--style:Glossterm-->
DropDownEnd

<!--style:GlossDef-->
The "DropdownEnd" marker should be inserted at the end of the text that you want to display in an expand/collapse section. This marker indicates the end of the content you want to display in an expand/collapse section. 

<!--style:Glossterm-->
TopicAlias 

<!--style:GlossDef-->
The "TopicAlias" marker should be inserted in any topic that you want to use as a context-sensitive help topic. Specify the topic ID you wish to assign to the topic as the marker text for the marker. 
