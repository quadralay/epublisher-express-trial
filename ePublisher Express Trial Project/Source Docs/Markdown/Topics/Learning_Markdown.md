 
Markdown is a fast and simple authoring tool that most anyone can use. Markdown was originally developed as a text-to-HTML conversion tool for web developers. 

> The overriding design goal for Markdown's formatting syntax is to make it as readable as possible. The idea is that a Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions. While Markdown’s syntax has been influenced by several existing text-to-HTML filters, the single biggest source of inspiration for Markdown’s syntax is the format of plain text email.
>  **[John Gruber][1]**

As a result, the viewer's browser would do most of the styling and while this works well for simple text documents, it does provide some challenges when working with professional documents that need a clear message, uniformity and information architecture.
 
This dynamic has presented a problem in the online help industry. Markdown is an attractive solution for SME's contributing content, but it is not powerful enough for Technical Writers to present a clear message and maintain document sets. **ePublisher Markdown++** adds additoinal features to Markdown, making it a possible solution for professional document sets. **ePublisher Markdown++** gives Technical Writers the ability to incorporate a style guide into the conversion process from Markdown to HTML and PDF. **ePublisher Markdown++** also gives you the ability to create custom syntax within the markdown document so you can have more control over what happens in the output. This is accomplished through a combination of standard Markdown syntax, and some custom comment structure. For the purpose of this trial we are using predetermined custom style names, but if you choose to purchase **ePublisher** you will be able to use your own custom style names.

# ePublisher Custom Syntax

For **ePubisher** to allow for the features needed to generate and manage a full and functional help set, we have developed a way for it to read custom comments within the Markdown file as well as standard Markdown syntax. To make a comment in Markdown, you will put it between the standard comment markers `<!--` and `-->`. The begining of a comment triggers **ePublisher** to start looking for custom syntax. If there is none, then **ePublisher** will treat it just as a comment. If the correct syntax is in the comment, then **ePublisher** will apply styles, write meta data, or perform a certain functions when generating output. 

Below is an example of a custom **ePublisher Markdown++** paragraph style written within a comment.

`<!--style:CustomStyleName-->`
`Standard Markdown Content`  

The first line is a comment with a custom style name. **ePublisher** will recognize "style:" and understand that a custom name will follow. **ePublisher** will hold the styling information for "CustomStyleName" in the **ePublisher Stationery**,  and automatically apply that information in the generated output. This is the workflow of **ePublisher** **One-Click Publishing** . Using a predetermined set of syntax in the source documents to generate specific behavior in the output.

The following topics will show you the syntax needed to alter the output the trial generates. If you have any questions you can [contact us.][2]      

1. [Headings](#headings)
1. [Paragraphs](#paragraphs)
1. [Inline Emphasis](#inline-emphasis)
1. [Lists](#lists)
1. [Links](#links)
1. [Markers](#markers)
1. [Images](#images)
1. [Code and Code Fence](#code-and-code-fence)
1. [Tables](#tables)
1. [HTML in Markdown](#html)
1. [Horizontal Rule](#horizontal-rule)
1. [Includes](#include)
1. [Conditions and Variables](#conditions-variables) 

[1]: https://daringfireball.net/projects/markdown/ "Markdown Article"
[2]: https://www.webworks.com/Company/Contact/ "Webworks contact page"