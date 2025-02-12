*** Settings ***
Library     random


*** Variables ***
${BPMN:PROCESS}     local


*** Tasks ***
Simulate SUT
    ${value}=    randint    ${0}    ${10}
    IF    ${value} < 3
        FAIL    Processing time is invalid
    ELSE IF    ${value} > 5
        VAR    ${requireManual}    ${True}    scope=${BPMN:PROCESS}
    ELSE
        VAR    ${requireManual}    ${False}    scope=${BPMN:PROCESS}
    END

Simulate SUT Teardown
    Pass Execution    This is fine
