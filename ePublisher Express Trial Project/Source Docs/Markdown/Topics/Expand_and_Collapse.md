This section explains how you can mark "**Expand/Collapse**" sections in the source documents provided with the
trial. The procedure will be the same when you purchase a full seat of **ePublisher**; the only difference will be
that you get to customize your own style names to mark the area.
 
# Creating Expand/Collapse Sections 

**Expand/collapse** sections are links in your generated output that users can click on to expand and collapse
content. To create **Expand/Collapse** sections, you apply a custom style name that has been defined with the
**Expand/Collapse** feature in the **ePublisher Stationery**. By applying this defined custom style name to a
heading, the content creator has marked the beginning of the expand and collapse area. This is where **ePublisher**
will place the trigger for the **Expand/Collapse** section. The content creator will then tag the end of the
section with a marker.

<!--style:Heading 3 NoToC-->
Applying Style Names and Markers in Markdown.  

In this example, the procedure list below has the "ExpandCollapse" custom style name applied to the procedure title
"To Create Expand/Collapse Sections" and a "DropDownEnd" marker is inserted at the end of procedure three. 

In the **ePublisher Express Trial Stationery**, the custom style name "ExpandCollapse" was defined with the
**Expand/Collapse** feature. As a result, the procedure title displays a trigger next to it in the generated output.
When users click the trigger, the steps in the procedure will display. 

Click the arrow to display the steps in the procedure below.

<!--style: ExpandCollapse-->
#### To Create Expand/Collapse Sections 

 1. Create you section by typing the content directly into the source document.
 1. Apply the correct custom style name in a comment above the section you created.
 1. Insert a DropDownEnd marker at the end of the content.
    - Example Below:
    `<!--markers: {"DropDownEnd": ""}-->` 
 1. Generate output using ePublisher. 
<!--markers: {"DropDownEnd": ""}-->
	
<!--style:Heading 1 Relevance; #creating-your-first-expandcollapse-section-->	
# Creating Your First Expand/Collapse Section 

The previous section explains how you can create expand and collapse sections by applying an 
"ExpandCollapse" custom style name. In this section, you will create an expand and collapse section using the
**ePublisher Express Trial** source documents and stationery. 

Below is the list you will attach the feature, **Expand/Collapse**. After the procedure title, apply the custom
style name "ExpandCollapse" in a comment above. You will then place the "DropDownEnd" marker after the last step.
 
<!--style:ProcedureTitle-->
To Create Your First Expand/Collapse Section 
	
 1. In the Source Documents folder, look for the folder labled Markdown. 
 1. In the Markdown folder, look for a file titled "Expand_and_Collapse.md"
 1. Open the file in a text or Markdown editor. 
 1. In the open file press Ctrl+f and search for "Creating Your First Expand/Collapse Section"
 1. In the section "Creating Your First Expand/Collapse" find the procedure title "To Create Your First Expand/Collapse Section".
 1. In the comment above the procedure title, replace the custom style name "ProcedureTitle" with "ExpandCollapse". 
 1. Insert a markers comment after the last sentence in this procedure.
    - Example Below: 
      `<!--markers: {"DropDownEnd": ""}-->`	
 1. Save this source document.
 1. Generate output and verify that the **Expand/Collapse** section you created in this section displays correctly in your generated output.
 1. Return to the "ePublisher Express Trial Guide" to continue.
