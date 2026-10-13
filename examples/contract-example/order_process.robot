*** Settings ***
Library     OperatonContracts    OrderTasks


*** Variables ***
${BPMN:TASK}        local

${orderId}          ${EMPTY}
${orderCount}       ${1}
${isUrgent}         ${False}


*** Tasks ***
Process Order
    VAR    ${orderResult}=    ${None}    scope=${BPMN:TASK}
    ${input}=    Validate Task Input    OrderProcessingInput
    Log    Processing order ${input}[orderId] (count=${input}[orderCount], urgent=${input}[isUrgent])
    VAR    ${result_dict}=
    ...    ${{ {"orderId": $input["orderId"], "status": "CONFIRMED", "count": $input["orderCount"]} }}
    VAR    ${orderResult}=    ${result_dict}    scope=${BPMN:TASK}
