*** Settings ***
Library    AppiumLibrary    run_on_failure=Capture Page Screenshot

*** Variables ***
${IDENTIFIER_INPUT}       accessibility_id=login-identifier-input
${PASSWORD_INPUT}         accessibility_id=login-password-input
${LOGIN_BUTTON}           accessibility_id=login-submit-button
${DASHBOARD_ROLE_TEXT}    accessibility_id=dashboard-role-text

*** Keywords ***
Open CampusCare From Expo Go
    Open Application    ${APPIUM_SERVER}
    ...    platformName=Android
    ...    automationName=UiAutomator2
    ...    deviceName=${DEVICE_NAME}
    ...    appPackage=${EXPO_GO_PACKAGE}
    ...    appActivity=${EXPO_GO_ACTIVITY}
    ...    noReset=true
    ...    dontStopAppOnReset=true
    ...    ignoreHiddenApiPolicyError=true
    ...    newCommandTimeout=120

    Wait Until Page Contains Element    ${IDENTIFIER_INPUT}    30s

Login With Valid Account
    [Arguments]    ${identifier}    ${password}

    Wait Until Page Contains Element    ${IDENTIFIER_INPUT}    30s
    Click Element    ${IDENTIFIER_INPUT}
    Clear Text    ${IDENTIFIER_INPUT}
    Input Text    ${IDENTIFIER_INPUT}    ${identifier}

    Click Element    ${PASSWORD_INPUT}
    Clear Text    ${PASSWORD_INPUT}
    Input Text    ${PASSWORD_INPUT}    ${password}

    Hide Keyboard
    Click Element    ${LOGIN_BUTTON}

Dashboard Should Be Visible
    Wait Until Page Contains Element    ${DASHBOARD_ROLE_TEXT}    30s