*** Settings ***
Library     Secrets.py


*** Variables ***
${BPMN:TASK}        local
${BPMN:PROCESS}     local
${api_key}          ${None}


*** Test Cases ***
Use API Key
    Should Not Be Equal    ${api_key}    ${None}
    ${is_secret}=    Evaluate    isinstance($api_key, __import__('robot.utils.secret').utils.secret.Secret)
    Should Be True    ${is_secret}
    Log To Console    api_key (masked) = ${api_key}
    ${fingerprint}    ${bytes}=    Api Key Fingerprint
    VAR    ${api_key_fingerprint}    ${fingerprint}    scope=${BPMN:PROCESS}
    VAR    ${api_key_bytes}          ${bytes}          scope=${BPMN:PROCESS}
