Unicode true
!include "MUI2.nsh"

!ifndef PRODUCT_VERSION
!error "Debe definirse PRODUCT_VERSION"
!endif

!ifndef SOURCE_ROOT
!error "Debe definirse SOURCE_ROOT"
!endif

Name "Facturas-Harbour ${PRODUCT_VERSION}"
OutFile "${SOURCE_ROOT}/packaging/out/Facturas-Harbour-${PRODUCT_VERSION}-windows-x64-setup.exe"
InstallDir "$PROGRAMFILES64\Facturas-Harbour"
RequestExecutionLevel admin

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SOURCE_ROOT}/LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

Section "Facturas-Harbour" SecPrincipal
  SetOutPath "$INSTDIR"
  File "${SOURCE_ROOT}/Facturas.exe"
  File /oname=LICENSE.txt "${SOURCE_ROOT}/LICENSE"
  WriteUninstaller "$INSTDIR\Desinstalar.exe"
  CreateDirectory "$SMPROGRAMS\Facturas-Harbour"
  CreateShortcut "$SMPROGRAMS\Facturas-Harbour\Facturas-Harbour.lnk" "$INSTDIR\Facturas.exe"
  CreateShortcut "$SMPROGRAMS\Facturas-Harbour\Desinstalar.lnk" "$INSTDIR\Desinstalar.exe"
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\Facturas-Harbour\Facturas-Harbour.lnk"
  Delete "$SMPROGRAMS\Facturas-Harbour\Desinstalar.lnk"
  RMDir "$SMPROGRAMS\Facturas-Harbour"
  Delete "$INSTDIR\Facturas.exe"
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\Desinstalar.exe"
  RMDir "$INSTDIR"
SectionEnd
