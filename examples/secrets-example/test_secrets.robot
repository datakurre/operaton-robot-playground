*** Settings ***
Library             RobotLibrary


*** Variables ***
${api_key}          s3cr3t


*** Test Cases ***
Secret injected as variable
    Run Robot Test    ${CURDIR}/secrets.robot
    ...    Use API Key
    ...    BPMN:PROCESS=global
    ...    api_key=${{__import__('robot.utils.secret').utils.secret.Secret('s3cr3t')}}

    ${expected}=    Evaluate    __import__('hashlib').sha256(b's3cr3t').hexdigest()
    Should Be Equal    ${api_key_fingerprint}    ${expected}
    Should Be Equal As Integers    ${api_key_bytes}    ${6}
