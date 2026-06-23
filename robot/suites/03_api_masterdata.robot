*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/auth.resource

Suite Setup    Create Gateway Session

*** Test Cases ***
Admin Can Create Category Building And Room
    ${token}=    Login Admin
    &{headers}=    Create Auth Headers    ${token}
    ${suffix}=    Generate Test Suffix

    &{category}=    Create Dictionary
    ...    name=Robot Category ${suffix}
    ...    slug=robot-category-${suffix}
    ...    description=Kategori dari Robot Framework
    ...    defaultSlaHours=${72}

    ${category_response}=    POST On Session
    ...    gateway
    ...    /api/categories
    ...    headers=${headers}
    ...    json=${category}
    ...    expected_status=anything

    Response Should Be Success    ${category_response}
    ${category_data}=    Get Data From Response    ${category_response}
    ${category_id}=    Evaluate    $category_data.get("id")
    Should Not Be Empty    ${category_id}

    &{building}=    Create Dictionary
    ...    name=Robot Building ${suffix}
    ...    code=RB-${suffix}
    ...    address=Alamat Robot
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
    Should Not Be Empty    ${building_id}

    &{room}=    Create Dictionary
    ...    buildingId=${building_id}
    ...    name=Robot Room ${suffix}
    ...    code=RR-${suffix}
    ...    floorName=Lantai Robot
    ...    description=Ruangan dari test automation

    ${room_response}=    POST On Session
    ...    gateway
    ...    /api/locations/rooms
    ...    headers=${headers}
    ...    json=${room}
    ...    expected_status=anything

    Response Should Be Success    ${room_response}