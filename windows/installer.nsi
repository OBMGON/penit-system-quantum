!define APPNAME "PenitSystem Quantum"
!define COMPANYNAME "Sistema Penitenciario Nacional"
!define DESCRIPTION "Sistema de Gestión Penitenciaria de Guinea Ecuatorial"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0
!define HELPURL "https://github.com/penitsystem/quantum"
!define UPDATEURL "https://github.com/penitsystem/quantum"
!define ABOUTURL "https://github.com/penitsystem/quantum"
!define INSTALLSIZE 50000

RequestExecutionLevel admin
InstallDir "$PROGRAMFILES\${APPNAME}"
Name "${APPNAME}"
Icon "runner\resources\app_icon.ico"
outFile "PenitSystem-Quantum-Setup.exe"

!include LogicLib.nsh

page welcome
page directory
page instfiles

!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin"
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend

function .onInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd

section "install"
	setOutPath $INSTDIR
	file /r "build\windows\runner\Release\*"
	
	writeUninstaller "$INSTDIR\uninstall.exe"

	createDirectory "$SMPROGRAMS\${APPNAME}"
	createShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\penit_system_geosecure_quantum_demo.exe" "" "$INSTDIR\penit_system_geosecure_quantum_demo.exe"
	createShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe"

	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$\"$INSTDIR\penit_system_geosecure_quantum_demo.exe$\""
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "$\"${COMPANYNAME}$\""
	writeRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "$\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\""
	writeRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
	writeRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" ${VERSIONMINOR}
	writeRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
	writeRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
	writeRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
sectionEnd

section "uninstall"
	delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
	delete "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
	rmDir "$SMPROGRAMS\${APPNAME}"

	delete $INSTDIR\uninstall.exe
	rmDir /r $INSTDIR

	deleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
sectionEnd 