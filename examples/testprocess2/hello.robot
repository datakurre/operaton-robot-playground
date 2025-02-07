*** Settings ***
Library     Hello.py


*** Variables ***
${BPMN:TASK}    local
${name}         n/a


*** Tasks ***
My Task
    Fail  NO DATA
    ${message}=    Hello    ${name}
    VAR    ${message}    ${message}    scope=${BPMN:TASK}
