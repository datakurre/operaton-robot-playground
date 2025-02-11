*** Settings ***
Library     purjo
Library     Collections
Library     DateTime


*** Variables ***
${String Input}     Hello World!
${Number Input}     ${100}
${Boolean Input}    ${True}
@{List Input}       ${1}    ${2}    ${3}
&{Dict Input}       one=${1}    two=${2}    three=${3}


*** Test Cases ***
Test Hello World
    ${Date Input}=    Get Current Date
    ${Input Variables}=    Create Dictionary
    ...    String Input=${String Input}
    ...    Number Input=${Number Input}
    ...    Boolean Input=${Boolean Input}
    ...    List Input=${List Input}
    ...    Dict Input=${Dict Input}
    ...    Date Input=${Date Input}
    ${Expected Output Variables}=    Create Dictionary
    ...    String Output=${String Input}
    ...    Number Output=${Number Input}
    ...    Boolean Output=${Boolean Input}
    ...    List Output=${List Input}
    ...    Dict Output=${Dict Input}
    ...    Date Output=${Date Input}
    ${Output Variables}=    Get Output Variables
    ...    ${CURDIR}${/}most-variables
    ...    Test Variable Types
    ...    ${Input Variables}
    Dictionaries Should Be Equal    ${Output Variables}    ${Expected Output Variables}
