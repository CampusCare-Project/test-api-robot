*** Settings ***
Resource    common.resource

*** Variables ***
${ADMIN_TOKEN}       ${EMPTY}
${STUDENT_TOKEN}     ${EMPTY}
${TECH_TOKEN}        ${EMPTY}

*** Keywords ***
Login User
    [Arguments]    ${identifier}    ${password}
    &{payload}=    Create Dictionary
    ...    identifier=${identifier}
    ...    password=${password}

    ${response}=    POST On Session
    ...    gateway
    ...    /api/auth/login
    ...    json=${payload}
    ...    expected_status=200

    Response Should Be Success    ${response}

    ${body}=    Get Json Body    ${response}
    ${token}=    Evaluate    $body.get("data", {}).get("token") or $body.get("data", {}).get("accessToken") or $body.get("token") or $body.get("accessToken")

    Should Not Be Empty    ${token}
    RETURN    ${token}

Login Admin
    IF    '${ADMIN_TOKEN}' != ''
        RETURN    ${ADMIN_TOKEN}
    END

    ${token}=    Login User    ${ADMIN_IDENTIFIER}    ${ADMIN_PASSWORD}
    Set Suite Variable    ${ADMIN_TOKEN}    ${token}
    RETURN    ${token}

Login Student
    IF    '${STUDENT_TOKEN}' != ''
        RETURN    ${STUDENT_TOKEN}
    END

    ${token}=    Login User    ${STUDENT_IDENTIFIER}    ${STUDENT_PASSWORD}
    Set Suite Variable    ${STUDENT_TOKEN}    ${token}
    RETURN    ${token}

Login Technician
    IF    '${TECH_TOKEN}' != ''
        RETURN    ${TECH_TOKEN}
    END

    ${token}=    Login User    ${TECH_IDENTIFIER}    ${TECH_PASSWORD}
    Set Suite Variable    ${TECH_TOKEN}    ${token}
    RETURN    ${token}