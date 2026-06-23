*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/auth.resource

Suite Setup    Create Gateway Session

*** Test Cases ***
Admin Can Login
    ${token}=    Login Admin
    Should Not Be Empty    ${token}

Student Can Login
    ${token}=    Login Student
    Should Not Be Empty    ${token}

Login With Wrong Password Should Fail
    &{payload}=    Create Dictionary
    ...    identifier=${ADMIN_IDENTIFIER}
    ...    password=wrong-password

    ${response}=    POST On Session
    ...    gateway
    ...    /api/auth/login
    ...    json=${payload}
    ...    expected_status=anything

    Should Be True    ${response.status_code} == 400 or ${response.status_code} == 401