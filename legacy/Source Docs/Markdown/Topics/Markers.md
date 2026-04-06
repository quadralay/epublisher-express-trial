<!--#markers-->
# Markers

Marker is a unique ability in **ePublisher** Markdown Syntax. We included markers because of the enhancement it gives to content creators when writing toward specific users. Markers can be used to denote the end point of certain **ePublisher** features, like **"Expand/Collapse"** list, they can also be used for features like Topic Alias Markers (used in context sensitive help) and they can be used for keywords to increase searchability. It is such a versatile ability that we felt we had to include Markers in our syntax.

It is easy to create a marker. The format is the same for any marker you are trying to create, you just enter different information in the marker definition area. Below is an example of marker syntax: 

```
<!--markers:{"type":"definition"}-->
```

It is very important to know where to place a marker within the source document. To show the difference between different types of markers and where to place them, below are examples of a **ePublisher feature** marker, a **TopicAlias** marker and a **Keywords** marker. 

## Example ePublisher Markers

An ePublisher marker is a marker that identifies some meta information that is used during the publishing of the output.

**Marker Syntax**

`<!--markers:{"<marker name>":"<definition>"}-->`

<!--style:mdnote-->
Note - In markdown when placing markers you have to include a marker and a value. If you do not have a value, then empty quotes are fine ""

The below example contains a live marker found in this document in the section "To Create Expand/Collapse Sections". In the example we are creating an expand/collapse menu. We are using the marker to indicate the end of the information that will be included in the drop down menu, "DropDownEnd". There is no need for any additional information with this marker type, so we have left that field blank, but we must still account for the field with the `""` quotation marks.  

1. Create content that will serve as the link users click to expand or collapse the content.
1. Apply the ".ExpandCollapse" paragraph style to the content.
1. Insert a DropDownEnd marker at the end of the content you want to include in the expand/collapse section. (Example Below)

```
<!--markers:{"DropDownEnd": ""}-->
```

**Example TopicAlias Marker**

**Marker Syntax** 
`<!--markers: {"TopicAlias":"TopicID"}-->`

The below example can be found in the "Creating Context-Sensitive Help Topics" header. We have indicated that this is a Topic Alias marker in the type field and have entered the id in the definition field. Be sure to look in the source documents for an example of this type of marker because markers do no appear in the output.

`<!--markers: {"TopicAlias":"IDH_CreatingContextSensitiveHelpTopics"}-->`
`## Creating Context-Sensitive Help Topics`

**Example Keywords Marker**

**Marker Syntax** 
`<!--markers: {"Keywords": "List keywords here, separate with commas"}`

The below example can be found in the `Headings.md` source documents in the "Custom Syntax Headings" section. We identified Keywords in the type filed. The actual keywords or phrases will be entered in the definition field seperated by commas.

```
<!--markers:{"Keywords": "custom style names, paragraph styles, styling"};  #Custom-Style-Names; This is an example of an ePublisher ++ comment with several functions-->
## Custom Style Names
```

Here are some important instructions when it comes to creating markers in markdown. 

1. You must put your markers in a comment
1. You must identify the type of marker before the definition.
1. **ePublisher** feature markers must use the proper ID. IDs can be found in **ePublisher**, or in the Help Documentation
1. It is important to place the marker correctly. 
 
   Example: 
   ``` 
   ### Inline-Style Links in a Single Document 
   [@markers]({"Keywords": "anchors, links, Inline-style"}) 
   ```
