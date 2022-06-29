*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Produces traffic data work items.



Library    RPA.HTTP
Library    RPA.JSON
Library    RPA.Tables
Library    Collections
Library    RPA.Robocorp.WorkItems

*** Variables ***
# var globales de este robot
${TRAFFIC_JSON_FILE_PATH}=      ${OUTPUT_DIR}${/}traffic.json
# JSON data keys:
${COUNTRY_KEY}=                 SpatialDim
${GENDER_KEY}=                  Dim1
${RATE_KEY}=                    NumericValue
${YEAR_KEY}=                    TimeDim


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}=    Load traffic data as table                        #return object table
    ${filtered_data}=    Filter and sort traffic data    ${traffic_data}     #return array
    ${filtered_data}=    Get lastest data by country    ${traffic_data}    #return array
    ${payloads}=    Create work item payloads    ${filtered_data}    #return array
    Save work item payloads    ${payloads}

    Log    ${payloads}
    Log    ${filtered_data}
    Log    ${traffic_data}
    # Write table to CSV    ${filtered_data}    test.csv


*** Keywords ***
Download traffic data
    Download
    ...    https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
    ...    ${TRAFFIC_JSON_FILE_PATH}
    ...    overwrite=True

Load traffic data as table
    ${json}=    Load JSON from file    ${TRAFFIC_JSON_FILE_PATH}

    # convertimos el json a un objeto tabla
    ${table}=    Create Table    ${json}[value]
    [Return]    ${table}


Filter and sort traffic data
    [Arguments]    ${table}
    # nombre_variables    asigar a:    header_columna_csv    
    ${max_rate}=    Set Variable    ${5.0}
    ${both_genders}=    Set Variable    BTSX
    ${rate_key}=    Set Variable    NumericValue
    ${gender_key}=    Set Variable    Dim1
    ${year_key}=    Set Variable    TimeDim

    Filter Table By Column    ${table}    ${RATE_KEY}    <    ${max_rate}
    Filter Table By Column    ${table}    ${GENDER_KEY}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${YEAR_KEY}    False
    [Return]    ${table}

Get lastest data by country
    [Arguments]    ${table}
    ${country_key}=    Set Variable    SpatialDim
    ${table}=    Group Table By Column    ${table}    ${country_key}
    ${lastest_data_by_country}=    Create List    #esto es un array vacio como quien dice

    FOR    ${group}    IN    @{table}
        ${firts_row}=    Pop Table Row    ${group}
        Append To List    ${lastest_data_by_country}    ${firts_row}
    END

    [Return]    ${lastest_data_by_country}



Create work item payloads
    [Arguments]    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        ${payload}=
        ...    Create Dictionary
        ...    country=${row}[${COUNTRY_KEY}]
        ...    year=${row}[${YEAR_KEY}]
        ...    rate=${row}[${RATE_KEY}]
        Append To List    ${payloads}    ${payload}

    END

    [Return]    ${payloads}

Save work item payloads
    [Arguments]    ${payloads}
    FOR    ${payload}    IN    @{payloads}
        Save work item payload    ${payload}
    END


Save work item payload
    [Arguments]    ${payload}
    ${variables}=    Create Dictionary    traffic_data=${payload}
    Create Output Work Item    variables=${variables}    save=True
