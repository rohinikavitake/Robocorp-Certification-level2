*** Settings ***
Documentation     Orders robots from RobotSpareBin Inc.
Library           RPA.Browser
Library           RPA.HTTP
Library           RPA.Tables
Library           Dialogs
Library           RPA.PDF 
Library           RPA.Robocloud.Secrets
Library           RPA.core.notebook
Library           RPA.Archive
Library           RPA.FileSystem
Library           RPA.Dialogs


# +
*** Keywords ***
Open the robot order website
    ${website}=  Get Secret  websitedata
    Open Available Browser   ${website}[url] 
    Maximize Browser Window

    
# -

*** Keywords ***
Download The csv File
    ${csv_url}=  Get Value From User  Please enter the csv url     https://robotsparebinindustries.com/orders.csv  overwrite=True
    Download    ${csv_url}  order.csv

*** Keywords *** 
Fill the form one order
  [Arguments]   ${row}
  Select From List By Value      id:head    ${row}[Head] 
  Click Element    id-body-${row}[Body]
  Wait Until Element Is Enabled    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
  Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input  ${row}[Legs]
  Wait Until Element Is Enabled    id:address
  Input Text    id:address    ${row}[Address]
  Wait Until Element Is Enabled    id:preview
  Sleep   2
  Click Button    id:preview
  Sleep   2 Seconds
  Wait Until Element Is Enabled    id:order
  Click Button    id:order
  Sleep   2 Seconds
  ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
    END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
        ${error} =    Is Element Enabled    order
    END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
    END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
    END


*** Keywords ***
Fill The Form
    Click Button  OK
    ${orders}=  Read table from CSV    orders.csv
    FOR    ${row}     IN  @{orders}
        Fill the form one order    ${row}
        Take a screenshot of robot      ${row}
    END    

*** Keywords ***
Take a Screenshot of robot
    [Arguments]  ${row} 
    Sleep  5 seconds
    ${reciept_data}=  Get Element Attribute  //div[@id="receipt"]  outerHTML
    Html To Pdf  ${reciept_data}  ${CURDIR}${/}reciepts${/}${row}[Order number].pdf
    Screenshot  //div[@id="robot-preview-image"]  ${CURDIR}${/}robots${/}${row}[Order number].png
    Sleep  2 Seconds
    Click Button  id:order-another
    Click Button  OK
    Sleep  5 Seconds

*** Keywords ***
Zip File
    Archive Folder With Zip  ${CURDIR}${/}reciepts  reciept.zip  recursive=True  include=*.pdf  exclude=/.*

*** Tasks ***
Order Robots From RobotSpareBin Industries Inc
    Open the robot order website
    Download The csv File
    Fill The Form
    Zip File
    [Teardown]  Close Browser


