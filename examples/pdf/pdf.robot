*** Settings ***

Library  PDF

*** Variables ***

${BPMN}       local
${message}    Hello, World!
${output}     ${CURDIR}/output.pdf
${a}          MISSING
${b}          MISSING

*** Test Cases ***

Create PDF
    Create PDF    ${output}    ${message}
    VAR    ${output}    ${output}    scope=${BPMN}

Merge PDF
    Merge PDF    ${a}    ${b}    ${output}
    VAR    ${output}    ${output}    scope=${BPMN}