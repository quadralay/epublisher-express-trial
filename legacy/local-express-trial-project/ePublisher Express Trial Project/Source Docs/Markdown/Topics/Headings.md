# Headings

Markdown is typically limited to 6 hashtag Headings. **ePublisher** gives you more functionality in Markdown by allowing up to 9 hashtag headings as well as allowing for custom style names. All this is managed through **ePublisher Designer**, but for the purpose of this trial we will show you predetermined custom style names. For example in the source documents the [Custom Style Name](#Custom-Style-Names) `<!--style:ExpandCollapse-->` can be seen in some procedure titles.   

<!--markers:{"Keywords": "Standard Syntax Headings, ePublisher Style Name, Styling Information"}; #syntax-headings-->
## Standard Syntax Headings

The following table will detail the default style settings for the 9 hastag Headings and 2 Title settings for standard Markdown syntax. This means you can create these Titles and Headings in your source documents by using standard Markdown syntax. 

<!--style:mdnote-->
Note - These defaults can be changed with a purchased seat of **ePublisher Designer**. 

* First column - syntax as it should appear in the source document. 
* Second column  - the **_"Style Name"_** that **ePublisher** associates with that syntax. This is the name that will be the class name in the HTML output. 
* Third column will list the default stying information. This is the infomation used when ePublisher generates output in the trial.  


|Markdown Syntax|**ePublisher** Style Name| Styling Information |
| ---- | -------- |----|
|"Title Content" <br/> `=============` | Title 1 | **font-family:** arial; <br /> **font-size:** 20pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
|"Title Content" <br/> `-------------` | Title 2 | **font-family:** arial; <br /> **font-size:** 20pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
|`#` | Heading 1 | **font-family:** arial; <br /> **font-size:** 17pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
|`##` | Heading 2 | **font-family:** arial; <br /> **font-size:** 15pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
|`###` | Heading 3 | **font-family:** arial; <br /> **font-size:** 14pt; <br/> **font-weight:** normal; <br/> **font-style:** normal; |
|`####` | Heading 4 | **font-family:** arial; <br /> **font-size:** 13pt; <br/> **font-weight:** bold; <br/> **font-style:** normal; |
|`#####`| Heading 5 | **font-family:** arial; <br /> **font-size:** 12pt; <br/> **font-weight:** bold; <br/> **font-style:** italic; |
|`######` | Heading 6 | **font-family:** arial; <br /> **font-size:** 9pt; <br/> **font-weight:** bold; <br/> **font-style:** normal; |

<!--markers:{"Keywords": "custom style names, paragraph styles, styling"};  #Custom-Style-Names; This is an example of an ePublisher ++ comment with several functions-->
<!--/condition-->
## Custom Style Names 

**ePublisher** gives you the ability to add custom style names to any heading or paragraph by adding a comment before the content. For example, if you had a custom style name "BoldHeading" that bolded text and set the font to Arial 20pt, this is how it would appear in the source document: 

`<!--style:BoldHeading-->`
`This Is The Title I Use For My Examples`

In the output, "This Is The Title I Use For My Examples" would be in bold with Arial 20pt font. Comments with **ePublisher Markdown++** syntax will always take presedence in the generated output. Take this source document example: 

`<!--style:BoldHeading-->`
`# This Is The Title I Use For My Examples`


In that example, "This Is The Title I Use For My Examples" would appear in the generated output in bold with Arial 20pt font even though the default style for a Heading 1 (from `# `) is normal Arial 20pt. 

This feature is useful if you are working with Developers who keep their documentation in a repository program like GitHub. They can format their documentation with standard Markdown syntax, and any Content Manager can go in and add comments to uniform and manage your help documentation set for different output. Since Github view will ignore the comment, all that will be seen in the GitHub HTML preview is the Title "This Is The Title I Use For My Examples." **ePublisher strengthens your workflow with Markdown while not interrupting the Developers' workflow. 

There is a naming convention you have to adhear to when creating custom style names. 

* Naming convention
  * Names are case sensitive
  * Names can contain any of the following characters
    - alphanumeric (a-z and 0-9)
    - dashes and underscores (we recommend using dashes only, as some outputs convert spaces to underscores)
    - spaces within the name
  * No spaces at the end of the name
  * In certain output formats, spaces become underscores making them non-unique
    - For example, `Heading 1` becomes `Heading_1` and thus is not unique from `Heading_1`.   

<!--style:mdnote-->
Note - The custom style names for the trial have already been added to the pre-built stationery using **ePublisher Designer**.