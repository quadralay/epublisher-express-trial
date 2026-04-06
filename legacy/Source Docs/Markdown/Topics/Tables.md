<!--markers: {"Keywords": "tables, cell, cell headings, cell body"}; #tables-->
# Tables

**ePublisher** not only allows for tables in Markdown documentation it also allows for style assignement, giving you the ability to publish tables with different styling throughout your documentation. By default, no styling information for tables is needed in the Markdown source. The Markdown source just needs to indicate which are heading cells and have a clear separation of content between cells. To show the separation between heading and body cells use no less than three dashes between each cell `---`. To show the separation between the content of cells, use the pipe or vertical bar key `|`. 

Here is an example of how to show the separation between header and body cells. 

**Syntax**

```
|Heading 1 | Heading 2 | Heading 3 |
|---|---|---|
|Body 1|Body 2|Body 3|
```

**Output**

|Heading 1 | Heading 2 | Heading 3 |
|---|---|---|
|Body 1|Body 2|Body 3|

Take a close look at the above example and note how the dash and pipe keys are used to separate cells. Also there is no need to align the cells. Only the content of the cell should be in the source document. **ePublisher** will align cells, add boarder and background depending on the styling information you enter into the **ePublisher** **Designer** project. Here are some tips on how to make tables in Markdown source: 

1. Use the pipe key "|" to separate content between cells.
1. Use at least three dashes "---" to separate heading cells from body cells.
1. Make sure there is at least one empty line above and below a table. 
1. Do not enter extra spaces to style the table.

<!--style:mdnote-->
Note - The beginning and ending pipe keys are not needed when creating a table. In markdown the only pipe keys are are needed are the ones seperating content.

**Column Cell Alignment** 
Column horizontal alignment can be controlled using the "`:`" character around the header cell dash characters. Here are the three types of alignment:

Left alignment: 
`|:---|` or `|---|`

Right alignment: 
`|---:|`

Center alignment: 
`|:---:|`
