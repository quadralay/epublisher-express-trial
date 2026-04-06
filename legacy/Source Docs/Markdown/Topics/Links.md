<!--markers:{"Keywords":"Inline-Style Links, Links, cross reference, anchors"}; #links--> 
# Links

Markdown was developed as a simple [text-to-HTML][1] conversion tool. As such, it has a simplified link process. Two types of link syntax are supported in Markdown, inline and reference. Inline links are very versatile and **ePublisher** makes them more so with the use of [anchors](#inline-style-links-in-a-single-document)  and [paths](#inline-style-links-to-a-relative-reference).
Reference-style links are used to notate referenced material. This section will describe how **ePublisher** processes these links for different scenarios: 

* [Inline-Style Links to the Web](#weblinks) 
  Example: `[Inline content here](https:/www.yourwebsite here)`
* [Inline-Style Links in the Same Document](#inline-style-links-in-a-single-document)  
  Example: `[Expand/Collapse](#expand-and-collapse)`
* [Inline-Style Links to a Relative Reference](#inline-style-links-to-a-relative-reference)  
  Example: `[Your content here](../folder name/file.md#optional-anchor)`
* [Reference-style links](#reference-style-links) 
  Example: `[text-to-HTML][1]`

<!--style:Heading 2 Relevance; markers:"Keywords":"internet, web"; #weblinks-->
## Inline-Style Links to the Web 

First, you can easily create a web link by typing the web URL directly. 

Example: 
- Source document syntax
  - `This is a link to the Webworks home page - https://www.webworks.com/`
- Output view
  - This is a link to the Webworks home page - https://www.webworks.com/ 
  
To create an inline link to the web you would use the syntax `[Content Here](Web Url Here)`. For example, if we could rewrite the above example as:  

- Source document syntax
  - `This is a link to the [Webworks home page](https://www.webworks.com/) page`
- Output view
  - This is a link to the [Webworks home page](https://www.webworks.com/) page 

<!--style:mdnote-->
Note - When writing a valid URL, you must include *http:* or *https:*

**Tips for Links:**

 * Do not put a space between the [content] and the (path).
 * Use normal spacing around an inline link.
 * **ePublisher** allows for link target information to appear in search results. 
   Make sure the computer you are generating from has access to the link target so **ePublisher** can index its information. 

<!--style:Heading 2 Relevance; markers:"Keywords":"anchors, links, inline-style"; #inline-style-links-in-a-single-document-->
Inline-Style Links in a Single Document 

Markdown also provides for links to specific areas withing a document by using anchors. To create a custom anchor, go to the spot in the documentation that will represent the link target. Before that spot, add a comment with the proper ePublisher Markdown++ syntax, as shown below:  

`<!--#customanchorname-->`

Once you have the anchor in place, you can now link to the spot using the custom anchor. In the above example, here is the syntax for the link to it: 

This is an example sentence showing how to `[link](#customanchorname)` to the custom anchor in the previous example.

<!--style:mdnote-->
Note - When creating the anchors use the correct syntax in the comment and when creating the link use the `()` after the brackets. 

Here is an example within this document that uses anchors to link to specific areas:
 <!--condition: onlineonly-->
|Source document syntax for Anchor|Source document syntax for Link |
|----|----|
|`<!--#weblinks-->` <br/> `## Inline-Style Links to the Web` |`[Inline-Style Links to the Web](#weblinks)`| 
<!--/condition-->

### Automatic Heading Anchor IDs  

**ePublisher** automatically creates an Anchor ID for any [heading](#syntax-headings) created in the source documents. This feature is in place so in some instances the Content Creator would not have to create an anchor for the heading, but instead just use the automatic anchor id at the end of the link. All the Content Creator needs to know is the naming convention **ePublisher** uses for the Automatic ID. 

**Automatic Heading Anchor ID Naming Convention**
  - All text is converted to lowercase.
  - All non-word text (such as punctuation or HTML) is removed.
  - All spaces are converted to hyphens.
  - Two or more hyphens in a row are converted to one.
  - If a header with the same ID has already been generated, a unique incrementing number is appended, starting at 1

Example:

 Heading | Generated Automatic Anchor ID 
---------|---------
`# This header has spaces in it`|`this-header-has-spaces-in-it`
`# This header has Unicode in it: 한글`|`this-header-has-unicode-in-it-한글`
`## This header has spaces in it`|`this-header-has-spaces-in-it-1`
`### This header has spaces in it`|`this-header-has-spaces-in-it-2`
`## This header has 3.5 in it (and parentheses)`|`this-header-has-35-in-it-and-parentheses` 

<!--style:mdnote-->
Note - If you rely on the automatic anchor generater for your anchors, if the Title ever changes you will have to manually update your links.   
  
<!--#inline-style-links-to-a-relative-reference-->
## Inline-Style Links to a Relative Reference 

This link is to a resource that could be part of the document set (e.g. It could be the same document set, but a different file than where the link originates) or a resource that is located on the same server as the HTML output (e.g. Items like PDFs, images, or even full document sets). There is an example of this type of link in this source document. In the section titled "Adding Functional Elements to Online Content using **ePublisher**" the last sentence includes this link `["My Edits"](my edits.md)`. In the generated output, this all appears to be the same contained documentation set, where in reality the "My Edits" section is a separate file. The source document is utilizing links to make it appear as one set. 

Here is what is looks like in the generated output:

![Screen shot of **ePublisher** HTML output](images/myeditshtml.png "**ePublisher** HTML5 Output")

Here is what the project looks like:

![Screen shot of ePublisher Express project][image1]

As you can see **ePublisher** generated a single HTML document set where all resources, internal and external, will be searchable. The only step for the content creator is to make sure to set up the links correctly. Below is the above link in an example form for a side-by-side comparison. 
 
Example:
- Source document syntax
  - `Then in the ["My Edits"](My Edits.md) sections,...`
- Output view
  - Then in the ["My Edits"](My Edits.md) sections,...

<!--style:mdnote-->
Note - File/folder names are not case sensitive  

<!--#reference-style-links-->
## Reference-Style Links

Reference-style links are a useful way to indicate referenced material in documentation. There is a very simple syntax to create a reference style link and the process is automated. To create a reference style link, first list your reference resource in a reference section. Number each reference source sequentially one after another like the example listed below: 

Example: 
```
[1]: reference source 
[2]: reference source 
[3]: reference source
```

With the reference section created, note the reference in the content by using the correct number. 

Example: 

This is a sentence that I would like to use a `[reference][1]` for my user. 

The reference section can be anywhere in the document. WebWorks recommends keeping all reference sources together and at the bottom of the file so it can be found easily. 

**ePublisher** will automatically make the link between the reference and reference source by using the number indicated. You can see an example of a reference under the topic "Links" in the first sentence of the first paragraph.  

Example of reference section entry: 
`[1]: https://daringfireball.net/projects/markdown/`

Example of reference entry: 
`Markdown was developed as a simple [text-to-HTML][1] conversion tool.` 

<!--style:noshow-->
This is the Reference List

[1]: https://daringfireball.net/projects/markdown/
[image1]: images/myeditsepub.png "**ePublisher** **Express** Project"