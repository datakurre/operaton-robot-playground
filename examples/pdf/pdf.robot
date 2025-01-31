*** Settings ***

Library  PDF

*** Variables ***

${BPMN:TASK}  local
${message}    Hello, World!
${output}     ${CURDIR}/output.pdf
${a}          ${None}
${b}          ${None}

*** Test Cases ***

Create PDF
    Create PDF    ${output}    ${message}
    VAR    ${output}    ${output}    scope=${BPMN:TASK}

Merge PDF
    Merge PDF    ${a}    ${b}    ${output}
    VAR    ${output}    ${output}    scope=${BPMN:TASK}
