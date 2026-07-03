*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/auth.resource

Suite Setup    Create Gateway Session

*** Variables ***
${REPORT_ID}       ${EMPTY}
${CATEGORY_ID}     ${EMPTY}
${BUILDING_ID}     ${EMPTY}
${ROOM_ID}         ${EMPTY}
${TECHNICIAN_ID}   ${EMPTY}

*** Test Cases ***
Prepare Master Data
    ${admin_token}=    Login Admin
    &{headers}=    Create Auth Headers    ${admin_token}
    ${suffix}=    Generate Test Suffix

    &{category}=    Create Dictionary
    ...    name=Robot Report Category ${suffix}
    ...    slug=robot-report-category-${suffix}
    ...    description=Kategori untuk report flow
    ...    defaultSlaHours=${24}

    ${category_response}=    POST On Session
    ...    gateway
    ...    /api/categories
    ...    headers=${headers}
    ...    json=${category}
    ...    expected_status=anything

    Response Should Be Success    ${category_response}
    ${category_data}=    Get Data From Response    ${category_response}
    ${category_id}=    Evaluate    $category_data.get("id")
    Set Suite Variable    ${CATEGORY_ID}    ${category_id}

    &{building}=    Create Dictionary
    ...    name=Robot Flow Building ${suffix}
    ...    code=RFB-${suffix}
    ...    address=QA Address
    ...    latitude=${0}
    ...    longitude=${0}

    ${building_response}=    POST On Session
    ...    gateway
    ...    /api/locations/buildings
    ...    headers=${headers}
    ...    json=${building}
    ...    expected_status=anything

    Response Should Be Success    ${building_response}
    ${building_data}=    Get Data From Response    ${building_response}
    ${building_id}=    Evaluate    $building_data.get("id")
    Set Suite Variable    ${BUILDING_ID}    ${building_id}

    &{room}=    Create Dictionary
    ...    buildingId=${BUILDING_ID}
    ...    name=Robot Flow Room ${suffix}
    ...    code=RFR-${suffix}
    ...    floorName=Lantai QA
    ...    description=Room untuk E2E report

    ${room_response}=    POST On Session
    ...    gateway
    ...    /api/locations/rooms
    ...    headers=${headers}
    ...    json=${room}
    ...    expected_status=anything

    Response Should Be Success    ${room_response}
    ${room_data}=    Get Data From Response    ${room_response}
    ${room_id}=    Evaluate    $room_data.get("id")
    Set Suite Variable    ${ROOM_ID}    ${room_id}

Get Technician Id
    ${admin_token}=    Login Admin
    &{headers}=    Create Auth Headers    ${admin_token}

    ${response}=    GET On Session
    ...    gateway
    ...    /api/auth/technician
    ...    headers=${headers}
    ...    expected_status=anything

    Response Should Be Success    ${response}

    ${data}=    Get Data From Response    ${response}
    Log To Console    TECHNICIAN DATA: ${data}
    Log To Console    TECH IDENTIFIER LOGIN: ${TECH_IDENTIFIER}

    ${target_identifier}=    Convert To Lower Case    ${TECH_IDENTIFIER}
    ${found_id}=    Set Variable    ${EMPTY}

    FOR    ${tech}    IN    @{data}
        ${username}=    Get From Dictionary    ${tech}    username
        ${email}=       Get From Dictionary    ${tech}    email

        ${username_lower}=    Convert To Lower Case    ${username}
        ${email_lower}=       Convert To Lower Case    ${email}

        IF    '${username_lower}' == '${target_identifier}' or '${email_lower}' == '${target_identifier}'
            ${found_id}=    Get From Dictionary    ${tech}    id_user
            Exit For Loop
        END
    END

    Should Not Be Empty
    ...    ${found_id}
    ...    msg=Teknisi dengan identifier "${TECH_IDENTIFIER}" tidak ditemukan di /api/auth/technician

    Log To Console    SELECTED TECHNICIAN ID: ${found_id}
    Set Suite Variable    ${TECHNICIAN_ID}    ${found_id}
    
Student Can Create Report
    ${student_token}=    Login Student
    &{headers}=    Create Auth Headers    ${student_token}
    ${suffix}=    Generate Test Suffix

    &{payload}=    Create Dictionary
    ...    clientLocalId=robot-${suffix}
    ...    categoryId=${CATEGORY_ID}
    ...    buildingId=${BUILDING_ID}
    ...    roomId=${ROOM_ID}
    ...    title=Robot Report ${suffix}
    ...    description=Laporan dibuat dari Robot Framework
    ...    priority=MEDIUM
    ...    locationText=Lokasi QA
    ...    latitude=${0}
    ...    longitude=${0}

    ${response}=    POST On Session
    ...    gateway
    ...    /api/reports
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}
    ${data}=    Get Data From Response    ${response}
    ${report_id}=    Evaluate    $data.get("id")
    Should Not Be Empty    ${report_id}
    Set Suite Variable    ${REPORT_ID}    ${report_id}

Admin Can Verify Report
    ${admin_token}=    Login Admin
    &{headers}=    Create Auth Headers    ${admin_token}

    &{payload}=    Create Dictionary
    ...    note=Diverifikasi oleh Robot Framework

    ${response}=    PATCH On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}/verify
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Admin Can Assign Technician
    ${admin_token}=    Login Admin
    &{headers}=    Create Auth Headers    ${admin_token}

    Should Not Be Empty    ${REPORT_ID}
    Should Not Be Empty    ${TECHNICIAN_ID}

    &{payload}=    Create Dictionary
    ...    technicianId=${TECHNICIAN_ID}

    Log To Console    ASSIGN REPORT ID: ${REPORT_ID}
    Log To Console    ASSIGN TECHNICIAN ID: ${TECHNICIAN_ID}
    Log To Console    ASSIGN PAYLOAD: ${payload}

    ${response}=    PATCH On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}/assign
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Log To Console    ASSIGN STATUS: ${response.status_code}
    Log To Console    ASSIGN BODY: ${response.text}

    Response Should Be Success    ${response}

Technician Can Update Status To In Progress
    ${tech_token}=    Login Technician
    &{headers}=    Create Auth Headers    ${tech_token}

    &{payload}=    Create Dictionary
    ...    status=IN_PROGRESS
    ...    note=Sedang diproses oleh Robot Framework

    ${response}=    PATCH On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}/status
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Technician Can Resolve Report
    ${tech_token}=    Login Technician
    &{headers}=    Create Auth Headers    ${tech_token}

    &{payload}=    Create Dictionary
    ...    status=RESOLVED
    ...    note=Selesai oleh Robot Framework
    ...    resolvedNote=Selesai oleh Robot Framework

    ${response}=    PATCH On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}/status
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Student Can Give Feedback
    ${student_token}=    Login Student
    &{headers}=    Create Auth Headers    ${student_token}

    &{payload}=    Create Dictionary
    ...    rating=${5}
    ...    comment=Feedback dari Robot Framework

    ${response}=    POST On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}/feedback
    ...    headers=${headers}
    ...    json=${payload}
    ...    expected_status=anything

    Response Should Be Success    ${response}

Report Detail Should Be Accessible
    ${admin_token}=    Login Admin
    &{headers}=    Create Auth Headers    ${admin_token}

    ${response}=    GET On Session
    ...    gateway
    ...    /api/reports/${REPORT_ID}
    ...    headers=${headers}
    ...    expected_status=anything

    Response Should Be Success    ${response}