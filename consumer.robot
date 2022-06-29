*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Consumes traffic data work items.

Resource            shared.robot

*** Tasks ***
Consume traffic data work items
    For Each Input Work Item    Process traffic data



*** Keywords ***
Process traffic data
    ${payload}=    Get Work Item Payload
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]