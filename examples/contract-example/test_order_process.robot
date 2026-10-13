*** Settings ***
Library             OperatingSystem
Library             RobotLibrary

Test Template       Test Process Order


*** Variables ***
${orderResult}      ${None}


*** Test Cases ***    ORDER_ID    ORDER_COUNT    IS_URGENT
Normal Order    ORD-101    ${2}    ${False}
Urgent Order    ORD-999    ${5}    ${True}
Invalid Order Input Raises Contract Error
    [Template]    NONE
    ${suite}=    Join Path    ${EXECDIR}    order_process.robot
    Run Keyword And Expect Error    *InvalidTaskInput*
    ...    Run Robot Test
    ...    ${suite}
    ...    Process Order
    ...    BPMN:TASK=global
    ...    orderId=NO
    ...    orderCount=${0}


*** Keywords ***
Test Process Order
    [Arguments]    ${order_id}    ${order_count}    ${is_urgent}
    ${suite}=    Join Path    ${EXECDIR}    order_process.robot
    Run Robot Test    ${suite}
    ...    Process Order
    ...    BPMN:TASK=global
    ...    orderId=${order_id}
    ...    orderCount=${order_count}
    ...    isUrgent=${is_urgent}
    Should Not Be Equal    ${orderResult}    ${None}
    Should Be Equal    ${orderResult}[status]    CONFIRMED
    Should Be Equal    ${orderResult}[orderId]    ${order_id}
