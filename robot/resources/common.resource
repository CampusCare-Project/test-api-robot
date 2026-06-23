*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***
${BASE_URL}    http://localhost:8080

*** Keywords ***
Create Gateway Session
    Create Session    gateway    ${BASE_URL}    verify=${False}

Response Should Be Success
    [Arguments]    ${response}
    Should Be True    ${response.status_code} >= 200 and ${response.status_code} < 300
    ...    msg=Expected 2xx but got ${response.status_code}: ${response.text}

Response Should Be Unauthorized Or Forbidden
    [Arguments]    ${response}
    Should Be True    ${response.status_code} == 401 or ${response.status_code} == 403
    ...    msg=Expected 401/403 but got ${response.status_code}: ${response.text}

Get Json Body
    [Arguments]    ${response}
    ${body}=    Evaluate    $response.json()
    RETURN    ${body}

Get Data From Response
    [Arguments]    ${response}
    ${body}=    Get Json Body    ${response}
    ${data}=    Evaluate    $body.get("data", $body)
    RETURN    ${data}

Create Auth Headers
    [Arguments]    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    RETURN    &{headers}

Generate Test Suffix
    ${epoch}=    Get Time    epoch
    ${random}=    Generate Random String    5    [LOWER]
    ${suffix}=    Set Variable    ${epoch}-${random}
    RETURN    ${suffix}