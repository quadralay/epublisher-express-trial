# Paragraphs

A paragraph is simply one or more consecutive lines of text, separated by one or more blank lines above and below the text. (A blank line is any line that looks like a blank line — a line containing nothing but spaces or tabs is considered blank.) Normal paragraphs should not be indented with spaces or tabs.

ePublisher Markdown++ looks at list item entries as either paragraphs, list, tables, or graphics. This is an important detail when it comes to styling your list. This will be covered in more detail in the [List](#Lists) section.

Default styling for paragraphs 
<!--condition: onlineonly-->
|Markdown Syntax|**ePublisher** Style Name| Styling Information |
|----|----|----|
| n/a | Paragraph | **font-family:** Arial; <br /> **font-size:** 12pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
<!--/condition-->

## Line Breaks in Paragraphs

When typing in your Markdown editor, a single *carriage return* after content will not result in a line break. To make a line break you will need first a *space*, then a *carriage return* after the last character in your line of content. This will keep the content all in the same paragraph, but move the content after the *carriage return* to the next line in the output. 

<!--style: Example, this style only applies in PDF-->
Example: 

 <!--style: ExampleLable, this style only applies in PDF-->
**Markdown View**

```
This is a sentence with just a single carriage return.
With only a single carriage return it will move this
 text to the next line in the editor,
but in the output they will be all part of the same paragraph.
```

 <!--style: ExampleLable, this style only applies in PDF-->
 **Output View**
 
This is a sentence with just a single carriage return.
With only a single carriage return it will move this text to the next line in the editor,
but in the output they will be all part of the same paragraph.

***

This is the same content with a *space* and *carriage return* typed in the editor which will actually create a break in the output. 

<!--style: Example, this style only applies in PDF-->
Example: 

 <!--style: ExampleLable, this style only applies in PDF-->
 **Markdown View**

>This is a sentence with a space after the last character and then carriage return. 
>With a space and then carriage return, the output finishes the paragraph and starts another one. 
>This will cause the output to look exactly as it does in the editor. 

 <!--style: ExampleLable, this style only applies in PDF-->
**Output View**

This is a sentence with a space after the last character and then carriage return. 
With a space and then carriage return, the output finishes the paragraph and starts another one. 
This will cause the output to look exactly as it does in the editor. 
