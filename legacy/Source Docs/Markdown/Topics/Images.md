# Images

Markdown was written so that images syntax would resemble link syntax. Markdown has the ability to manage images with Alt-text and titles. Like all other text editor's, Markdown can not embed images, but it is very versatile with reference links. In the final HTML output, **ePublisher** gives you the ability to handle images however you would like within the limits of the output environment, for example HTML5 standards.

Markdown accepts two types of image links, Inline-style and Reference-style links. 

**Syntax for Inline-style images:** 
`![<Alt Text Here>](<Image Filepath Here> "<Optional Image Title Text Here>")`

<!--style:mdnote-->
Note - Inline styles are not allowed in the "<Optional Image Title Text>".

Source Document Example: 
`![Screen shot of **ePublisher** HTML output](images/myeditshtml.png "ePublisher HTML5 Output")`

You will notice that the image syntax starts with "!" then follows the same syntax as an inline-style link. The content between the brackets "[ ]" is alternative text which makes the image accessible to the visually impaired. The second set of brackets "( )" contain the path to the image file as well as a title. The path can be relative, or it can be an URL address. The title will be contained in the double quotes (""). 

**Syntax for Referenced images :** 
`![<Alt Text Here>][<Reference Name Here>]`

Source Document Example: 
`![Screen shot of **ePublisher** **Express** project][image1]`

Again, the syntax for an image starts with "!", but then follows the same syntax as a reference link. The content between the first set of brackets "[ ]" is the alternative text, and the content between the second set of brackets "[ ]" is the reference id. 

In your reference section, you will create the path to the image. In the above example, the reference id is "image1" and in the reference section, of the source document,  it is written like this: 
`[image1]: images/myeditsepub.png "ePublisher Express Project"`

<!--style:mdnote-->
Note - You can keep your link references and your image references in the same reference section. 
