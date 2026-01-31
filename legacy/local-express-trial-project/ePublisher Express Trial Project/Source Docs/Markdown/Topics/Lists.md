<!--markers:{"Keywords": "list, bullets, ordered, unordered"}; #lists-->
# Lists

Markdown handles two types of lists: 
  1. ordered list and 
  1. unordered list. 

**ePublisher** gives you more functionality when publishing lists. You can position the list or even substitute an image for a bullet. 
The default style names used for creating a list are:
  * For the list container name, either: **UList** or **OList**.
  * For each entry in the list: **List Item**.
  * For the text in each entry: **Paragraph**.

For the trial, these styles are predetermined but you can customize your list with a purchased seat. **ePublisher** recognizes the beginning of a list by using the appropriate Markdown syntax then a space and then content. Here is an example of a level one unordered list entry:

|Syntax|Space|Content|
|---|---|---|
|*| |This is level one|

`* This is level one`

To create a list with multiple levels, place the new line item syntax directly below it's parent level. Indent the new line item *syntax* marker until it is direclty below the first content character of the parent level.  

This is an example of an unordered list with four levels:

* This is level 1
  * This is level 2
    * This is level 3
      * This is level 4
* Back to level 1

The Chart Below Shows the Syntax.

|Syntax|**ePublisher** Style Names| Example in Source|
|---- |----|----|
|`* This is level 1`|UList > UList Item > UList Paragraph|See Above|
|`...* This is level 2`|UList > UList Item > UList Paragraph|See Above|
|`......* This is level 3`|UList > UList Item > UList Paragraph|See Above|
|`.........* This is level 4`|UList > UList Item > UList Paragraph|See Above|
|`* Back to level 1`|UList > UList Item > UList Paragraph|See Above|


You can also do ordered list. It follows the same format as an unordered list, but numbering is not necessary as when the output is generated the correct numbering is applied in the output.  

1. This is level 1
   1. This is level 2
   1. This is another line on level 2
      1. This is level 3
      1. This is another line on level 3
         1. This is level 4
1. And back to level 1 


|Syntax|**ePublisher** Style Names| Example in Source|
|---- |----|----|
|`1. This is level 1`|OList > OList Item > OList Paragraph|See Above|
|`...1. This is level 2`|OList > OList Item > OList Paragraph|See Above|
|`...1. This is another line on level 2`|OList > OList Item > OList Paragraph|See Above|
|`......1. This is level 3`|OList > OList Item > OList Paragraph|See Above|
|`......1. This is another line on level 3`|OList > OList Item > OList Paragraph|See Above|
|`.........1. This is level 4`|OList > OList Item > OList Paragraph|See Above|

Finally, you can do a combination of both: 

1. This is level one
   - This is level 2
   - This is level 2 also
1. This is level one
   * This is level 2
     1. This is level 3
	   1. This is also level 3
	      * This is a level 4
   * This is level 2
1. And back to level 1

Notice that no matter what syntax is being used, the sub-level line syntax is always placed under the first character of the parent level. 

This is a list of acceptable syntax for list 

* `* ` Unordered list
* `- ` Unordered list
* `1. ` Ordered list

We understand how important styling these list can be. We went with basic styling for the trial, however you will be able to customize your list with a full seat of **ePublisher**. 

## Tables In List

When inserting tables in list, with ePublisher Markdown you just need to make sure to start the table with the same indention as the line item you want the table to appear on. 

For example:
 
|Table Heading 1|Table Heading 2|Table Heading 3|
|---|---|---|
|Cell Body 1 |Cell Body 2|Cell Body 3|
|Cell Body 1 |Cell Body 2|Cell Body 3| 

1. This is level one
   - This is level 2
   - This is level 2 with a table

     <!--style:Heading 5-->
     This is a heading

     |Table Heading 1|Table Heading 2|Table Heading 3|
     |---|---|---|
     |Cell Body 1 |Cell Body 2|Cell Body 3|
     |Cell Body 1 |Cell Body 2|Cell Body 3|

1. This is a level one right after the table
   - Level 2 with more content
   - Level 2 again more content different bullets
     1. This is a level 3 table

        |Table Heading 1|Table Heading 2|Table Heading 3|
        |---|---|---|
        |Cell Body 1 |Cell Body 2|Cell Body 3|
        |Cell Body 1 |Cell Body 2|Cell Body 3|

1. Trying a Code Block
   ```
   This is in a code block
	 This is in a code block
	 ```
