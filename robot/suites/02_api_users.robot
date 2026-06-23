*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/auth.resource

Suite Setup    Create Gateway Session

*** Test Cases ***
Admin Can List Users
    ${token}=    Login Admin
    &{headers}=    Create Auth Headers    ${token}

    ${response}=    GET On Session
    ...    gateway
    ...    /api/auth/users
    ...    headers=${headers}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Admin Can Add Student User
    ${token}=    Login Admin
    &{headers}=    Create Auth Headers    ${token}
    ${suffix}=    Generate Test Suffix

    &{payload}=    Create Dictionary
    ...    username=robot_student_${suffix}
    ...    name=Robot Student ${suffix}
    ...    email=robot_student_${suffix}@campuscare.test
    ...    passwordHash=Password123
    ...    role=STUDENT

    ${response}=    POST On Session
    ...    gateway
    ...    /api/auth/addusers
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Student Cannot Add User
    ${token}=    Login Student
    &{headers}=    Create Auth Headers    ${token}
    ${suffix}=    Generate Test Suffix

    &{payload}=    Create Dictionary
    ...    username=robot_forbidden_${suffix}
    ...    name=Robot Forbidden ${suffix}
    ...    email=robot_forbidden_${suffix}@campuscare.test
    ...    passwordHash=Password123
    ...    role=STUDENT

    ${response}=    POST On Session
    ...    gateway
    ...    /api/auth/addusers
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Unauthorized Or Forbidden    ${response}