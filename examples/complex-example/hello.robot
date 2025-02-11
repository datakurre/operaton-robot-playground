*** Settings ***
Library     random


*** Variables ***
${BPMN:TASK}    local
${name}         n/a


*** Tasks ***
Validate Test Data
    ${is_test_data_valid} =    randint    ${0}    ${5}
    IF    not $is_test_data_valid    FAIL    Test data is invalid

Stimulate SUT
    ${processing_time} =    randint    ${0}    ${5}
    Sleep    ${processing_time}
    IF    not $processing_time    FAIL    Processing time is invalid
    VAR    ${userid}    ${processing_time}    scope=${BPMN:TASK}
