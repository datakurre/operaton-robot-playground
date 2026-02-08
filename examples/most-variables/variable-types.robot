*** Settings ***
Library     DateTime
Library     String


*** Variables ***
${BPMN:TASK}        local

${String Input}     ${None}
${Number Input}     ${None}
${Boolean Input}    ${None}
${Date Input}       ${None}
@{List Input}       ${None}
&{Dict Input}       &{EMPTY}


*** Tasks ***
Test Variable Tpyes
    ${Date Input}    Convert Date    ${Date Input}
    Log Variables
    VAR    ${String Output}    ${String Input}    scope=${BPMN:TASK}
    VAR    ${Number Output}    ${Number Input}    scope=${BPMN:TASK}
    VAR    ${Boolean Output}    ${Boolean Input}    scope=${BPMN:TASK}
    VAR    ${Date Output}    ${Date Input}    scope=${BPMN:TASK}
    VAR    ${List Output}    ${List Input}    scope=${BPMN:TASK}
    VAR    ${Dict Output}    ${Dict Input}    scope=${BPMN:TASK}
