################################################################################
## OCS Inventory NG Server For Windows Setup
## Copyleft Didier LIROULET 2006
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################

;----------------------------------------------------------------------------
; Installer properties
;----------------------------------------------------------------------------

; Use bzip2 compressor, better compress to the other
SetCompressor bzip2
; Installer default properties
Name "OCS Inventory NG"
; Caption "${PRODUCT_NAME}"
; Check file date and CRC
SetDateSave on
SetDatablockOptimize on
CRCCheck on
; No silent install
SilentInstall normal
; Create setup file
OutFile "OCSNG-Windows-Server-Setup.exe"
; Default install location
InstallDir "C:\Xampp"
; Show install/uninstall logs
ShowInstDetails show
ShowUnInstDetails show
; Install XAMPP + OCS Server (Full) or OCS Server only (Minimal)
InstType "Full"
InstType "Minimal"


;----------------------------------------------------------------------------
; Product informations
;----------------------------------------------------------------------------
!define PRODUCT_NAME "OCS Inventory NG"
!define PRODUCT_VERSION "2.2.0"
!define PRODUCT_PUBLISHER "OCS Inventory NG Team"
!define PRODUCT_WEB_SITE "http://www.ocsinventory-ng.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
BRANDINGTEXT "${PRODUCT_NAME} Server for Windows ${PRODUCT_VERSION}"

; OCS Inventory NG Server Internal Version
!define Compile_version "5.0.0.6"
; XAMPP Server file setup and version
!define XAMPP_SERVER_FILE ""
!define XAMPP_SERVER_VERSION ""
!define APACHE_FILE_VERSION ""
!define APACHE_SERVICE_NAME_DEFAULT ""
; Perl Addon no more used because included in 1.7.3 ZIP file
; XAMPP Perl addon file and version
;!define XAMPP_PERL_FILE "xampp-win32-perl-addon-5.10.0-2.2.11-pl2.zip"
;!define XAMPP_PERL_VERSION "5.10.0"
; XML::Simple Perl module
!define XML_SIMPLE_PATH ""
; Default settings for max deployement package size en MB
!define MAX_DEPLOY_PACKAGE_SIZE "128"

;----------------------------------------------------------------------------
; Installer UI settings
;----------------------------------------------------------------------------
; MUI 1.67 compatible ------
!include "MUI.nsh"
; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "OCSInventory.ico"
!define MUI_UNICON "OCSInventory.ico"
; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"
; Welcome page properties
!define MUI_WELCOMEPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME
; License page properties
;!define MUI_LICENSEPAGE_RADIOBUTTONS
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "License.txt"
; Directory page properties
!insertmacro MUI_PAGE_DIRECTORY
; Components page properties
!insertmacro MUI_PAGE_COMPONENTS
; Start menu page properties
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page properties
!insertmacro MUI_PAGE_INSTFILES
; Finish page properties
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Review XAMPP Security (Recommended)"
!define MUI_FINISHPAGE_RUN_FUNCTION "StartXamppConfig"
!insertmacro MUI_PAGE_FINISH
; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES
; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Turkish"
; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS


;----------------------------------------------------------------------------
; Plugins used
;----------------------------------------------------------------------------

; Use File functions standard NSIS plugin (http://nsis.sourceforge.net/Docs/AppendixE.html)
!include "FileFunc.nsh"
!insertmacro GetParent
!insertmacro GetFileVersion
; Use TextReplace plugin (http://nsis.sourceforge.net/TextReplace_plugin)
!include "TextReplace.nsh"
; Use Logic Library plugin (http://nsis.sourceforge.net/LogicLib)
!include "LogicLib.nsh"
; Use Registry plugin (http://nsis.sourceforge.net/Registry_plug-in)
!include "Registry.nsh"
; Use ZipDLL plugin (http://nsis.sourceforge.net/ZipDLL_plug-in)
; Use services plugin (http://nsis.sourceforge.net/Services_plug-in)



;----------------------------------------------------------------------------
; Version Information section
;----------------------------------------------------------------------------
VIProductVersion "${Compile_version}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "${PRODUCT_NAME} ${PRODUCT_VERSION} Server for Windows Setup"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${PRODUCT_NAME}. Inventory and package deployement tool under GNU Licence."
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${PRODUCT_PUBLISHER} ${PRODUCT_WEB_SITE}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "OCSNG-Windows-Server-Setup.exe"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${Compile_version}"


;----------------------------------------------------------------------------
; Global variables
;----------------------------------------------------------------------------
; Apache service name
var APACHE_SERVICE_NAME
; Is XAMPP and Perl Addon installed ?
var XAMPP_PERL_AVAILABLE
; XAMPP Parent Install Folder
var XAMPP_PARENT_FOLDER


;----------------------------------------------------------------------------
; Just open web browser on XAMPP Security configuration page
;----------------------------------------------------------------------------
Function StartXamppConfig
      ExecShell "open" "http://localhost/security/index.php"
FunctionEnd


;----------------------------------------------------------------------------
; Get displayed name of Apache service
;
; Old version of XAMPP set Apache as service name
; Since XAMPP 1.6, Apache service name is Apache2.2
; So, if XAMPP is already installed, we must find apache service name
;
; If Apache web Server not installed, set it to APACHE_SERVICE_NAME_DEFAULT
;----------------------------------------------------------------------------
Function GetApacheServiceName
  Push $0
  StrCpy $APACHE_SERVICE_NAME ""
  services::GetServiceNameFromDisplayName "Apache"
  Pop $0
  ${If} $0 <> 1
    StrCpy $APACHE_SERVICE_NAME "${APACHE_SERVICE_NAME_DEFAULT}"
  ${Else}
    IntOp $0 $0 - 1
    Pop $APACHE_SERVICE_NAME
  ${EndIf}
  Pop $0
FunctionEnd


;----------------------------------------------------------------------------
; Get XAMPP setup parent folder
;
; Because include xampp\something directory structure, we must unzip XAMPP
; in parent folder
; This function set in $XAMPP_PARENT_FOLDER
;----------------------------------------------------------------------------
Function GetXamppParentFolder
  Push $0
  Push $1
  ${GetParent} $INSTDIR $0
  Strlen $1 $0
  ${If} $1 < 2
    StrCpy $INSTDIR "C:\Xampp"
    StrCpy $XAMPP_PARENT_FOLDER "C:\"
  ${Else}
    StrCpy $XAMPP_PARENT_FOLDER "$0\"
  ${EndIf}
  Pop $1
  Pop $0
FunctionEnd


;----------------------------------------------------------------------------
; StrSlash
; Author: dirtydingus
;
; Slash to Backslash converter.
; Call it with the haystack and the direction on the stack as shown in the comment above it
; Push $filenamestring (e.g. 'c:\this\and\that\filename.htm')
; Push "\"
; Call StrSlash
; Pop $R0
; ;Now $R0 contains 'c:/this/and/that/filename.htm'
;----------------------------------------------------------------------------
Function StrSlash
  Exch $R3 ; $R3 = needle ("\" or "/")
  Exch
  Exch $R1 ; $R1 = String to replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R4 ; $R4 = not $R3 ("/" or "\")
  Push $R6
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R6 $R1
  StrCpy $R4 "\"
  StrCmp $R3 "/" loop
  StrCpy $R4 "/"
loop:
  StrCpy $R7 $R1 1
  StrCpy $R1 $R1 $R6 1
  StrCmp $R7 $R3 found
  StrCpy $R2 "$R2$R7"
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R4
  Pop $R2
  Pop $R1
  Exch $R3
FunctionEnd

;----------------------------------------------------------------------------
; RemoveAfterLine
; Author: Afrow UK
;
; This function deletes lines from a line (including that line) to another line (also including that line)
; Push "$EXEDIR\file.ext" ;file
; Push "start line$\r$\n" ;line to start deleting from
; Push "finish line$\r$\n" ;line to stop deleting at
; Call RemoveAfterLine
;----------------------------------------------------------------------------
Function RemoveAfterLine
  Exch $1 ;end string
  Exch
  Exch $2 ;begin string
  Exch 2
  Exch $3 ;file
  Exch 2
  Push $R0
  Push $R1
  Push $R2
  Push $R3
  GetTempFileName $R2
  FileOpen $R1 $R2 w
  FileOpen $R0 $3 r
  ClearErrors
  FileRead $R0 $R3
  IfErrors Done
  StrCmp $R3 $2 +3
  FileWrite $R1 $R3
  Goto -5
  ClearErrors
  FileRead $R0 $R3
  IfErrors Done
  StrCmp $R3 $1 +4 -3
  FileRead $R0 $R3
  IfErrors Done
  FileWrite $R1 $R3
  ClearErrors
  Goto -4
Done:
  FileClose $R0
  FileClose $R1
  SetDetailsPrint none
  Delete $3
  Rename $R2 $3
  SetDetailsPrint both
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $3
  Pop $2
  Pop $1
FunctionEnd

;----------------------------------------------------------------------------
; WriteToFile
; Author: Afrow UK
;
; This is a simple function to write a piece of text to a file. This will write to the end always.
; Push "hello$\r$\n" ;text to write to file
; Push "$INSTDIR\log.txt" ;file to write to
; Call WriteToFile
;----------------------------------------------------------------------------
Function WriteToFile
  Exch $0 ;file to write to
  Exch
  Exch $1 ;text to write
  FileOpen $0 $0 a #open file
  FileSeek $0 0 END #go to end
  FileWrite $0 $1 #write to file
  FileClose $0
  Pop $1
  Pop $0
FunctionEnd

;----------------------------------------------------------------------------
; VersionCompare
; Author: Instructor
;
; Compare version numbers.
; Syntax:
; ${VersionCompare} "[Version1]" "[Version2]" $var
;      "[Version1]"        ; First version
;      "[Version2]"        ; Second version
;      $var                ; Result:
;                          ;    $var=0  Versions are equal
;                          ;    $var=1  Version1 is newer
;                          ;    $var=2  Version2 is newer
;----------------------------------------------------------------------------
Function VersionCompare
  !define VersionCompare `!insertmacro VersionCompareCall`
  !macro VersionCompareCall _VER1 _VER2 _RESULT
    Push `${_VER1}`
    Push `${_VER2}`
    Call VersionCompare
    Pop ${_RESULT}
  !macroend
  Exch $1
  Exch
  Exch $0
  Exch
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6
  Push $7
begin:
  StrCpy $2 -1
  IntOp $2 $2 + 1
  StrCpy $3 $0 1 $2
  StrCmp $3 '' +2
  StrCmp $3 '.' 0 -3
  StrCpy $4 $0 $2
  IntOp $2 $2 + 1
  StrCpy $0 $0 '' $2
  StrCpy $2 -1
  IntOp $2 $2 + 1
  StrCpy $3 $1 1 $2
  StrCmp $3 '' +2
  StrCmp $3 '.' 0 -3
  StrCpy $5 $1 $2
  IntOp $2 $2 + 1
  StrCpy $1 $1 '' $2
  StrCmp $4$5 '' equal
  StrCpy $6 -1
  IntOp $6 $6 + 1
  StrCpy $3 $4 1 $6
  StrCmp $3 '0' -2
  StrCmp $3 '' 0 +2
  StrCpy $4 0
  StrCpy $7 -1
  IntOp $7 $7 + 1
  StrCpy $3 $5 1 $7
  StrCmp $3 '0' -2
  StrCmp $3 '' 0 +2
  StrCpy $5 0
  StrCmp $4 0 0 +2
  StrCmp $5 0 begin newer2
  StrCmp $5 0 newer1
  IntCmp $6 $7 0 newer1 newer2
  StrCpy $4 '1$4'
  StrCpy $5 '1$5'
  IntCmp $4 $5 begin newer2 newer1
equal:
  StrCpy $0 0
  goto end
newer1:
  StrCpy $0 1
  goto end
newer2:
  StrCpy $0 2
end:
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd


;----------------------------------------------------------------------------
; Overide OnInit function to check previous installation
;----------------------------------------------------------------------------
Function .onInit
  ; Prevent Multiple Instances
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${PRODUCT_NAME}") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 SETUP_NOT_RUNNING
  ; Setup is already running, abort
  MessageBox MB_OK|MB_ICONSTOP "The installer for ${PRODUCT_NAME} is already running!"
  Abort "The installer for ${PRODUCT_NAME} is already running!"

SETUP_NOT_RUNNING:
  !insertmacro MUI_LANGDLL_DISPLAY
  ; By default, assume that XAMPP + PERL addon not installed
  StrCpy $XAMPP_PERL_AVAILABLE "false"

  ; Check if old OCS Inventory NG Server installed
  ${registry::Read} "HKLM\Software\${PRODUCT_NAME}" "" $R0 $R1
  StrCmp "$R1" "REG_SZ" OLD_OCS_DETECTED OLD_OCS_NOT_DETECTED

OLD_OCS_DETECTED:
  ; OCS Inventory NG Server 1.0 RC3 or previous installed
   StrCpy $INSTDIR $R0
   goto CHECK_XAMPP

OLD_OCS_NOT_DETECTED:
  ; Check if XAMPP installed
  ${registry::Read} "HKLM\Software\xampp" "Install_Dir" $R0 $R1
  StrCmp "$R1" "REG_SZ" XAMPP_DETECTED CHECK_XAMPP

XAMPP_DETECTED:
  ; XAMPP already installed
  StrCpy $INSTDIR $R0
  Call GetXamppParentFolder
  
CHECK_XAMPP:
  ; Check if XAMPP is really installed
  IfFileExists "$INSTDIR\xampp-control.exe" XAMPP_INSTALLED SETUP_XAMPP_PERL_REQUIRED

XAMPP_INSTALLED:
  ; Check if Perl is really installed
  IfFileExists "$INSTDIR\Perl\bin\Perl.exe" PERL_INSTALLED PERL_NOT_INSTALLED

PERL_INSTALLED:
  ; Check if mod_perl is really installed
  IfFileExists "$INSTDIR\apache\modules\mod_perl.so" MOD_PERL_INSTALLED MOD_PERL_NOT_INSTALLED

PERL_NOT_INSTALLED:
MOD_PERL_NOT_INSTALLED:
  ; XAMPP Perl not installed
  StrCmp $XAMPP_PERL_AVAILABLE "false" 0 SETUP_XAMPP_PERL_REQUIRED
  ; XAMPP Perl addon not installed, but provided version is not suitable for install
  MessageBox MB_ICONSTOP|MB_OK "XAMPP Web Server is installed but Perl not found on your computer!$\r$\n$\r$\nProvided XAMPP Web Server ${XAMPP_SERVER_VERSION} is not suitable to update/upgrade your version of XAMPP. You must first download and install Perl Addon for your version of XAMPP Web Server."
  Abort "XAMPP Web Server is installed but Perl not found!"
  
MOD_PERL_INSTALLED:
  ; As XAMPP + Perl installed, use Minimal setup
  StrCpy $XAMPP_PERL_AVAILABLE "true"
  SetCurInstType 1
  MessageBox MB_ICONINFORMATION|MB_OK "XAMPP Web Server with Perl is installed into directory <$INSTDIR>.$\r$\n$\r$\nYOU MUST SELECT THIS DIRECTORY to setup ${PRODUCT_NAME} Server components.$\r$\n$\r$\nNB: Upgrade of your current XAMPP using ${PRODUCT_NAME} Server included version IS NOT recommended. See XAMPP web site for more information."
  goto BEGIN_SETUP

SETUP_XAMPP_PERL_REQUIRED:
  ; Setup XAMPP + Perl Addon required
  MessageBox MB_ICONEXCLAMATION|MB_OK "XAMPP Web Server with Perl not found on your computer!$\r$\n$\r$\nYOU MUST SELECT AN EXISTING XAMPP DIRECTORY OR INSTALL XAMPP Web Server ${XAMPP_SERVER_VERSION} components provided with this setup.$\r$\n$\r$\nNB: ${PRODUCT_NAME} Server Setup for Windows doesn't support any other web server than XAMPP."
  SetCurInstType 0
  
BEGIN_SETUP:
  Call GetApacheServiceName
  ; Clear all previous errors
  ClearErrors
FunctionEnd


;----------------------------------------------------------------------------
; Section to install XAMPP components
;----------------------------------------------------------------------------
Section "XAMPP Web Server" SEC01
  ; Only in full type
  SectionIn 1
  Call GetXamppParentFolder
  DetailPrint "XAMPP Web Server will be installed to $INSTDIR..."
  ; Overwrite files only if newer
  SetOverwrite ifnewer
  ; Extract files TEMP directory
  SetOutPath "$TEMP"
  File "${XAMPP_SERVER_FILE}"
;  File "${XAMPP_PERL_FILE}"
  ; Launch XAMPP Web server setup in silent mode
  DetailPrint "Extracting XAMPP Web Server Files to $XAMPP_PARENT_FOLDER, please wait..."
  ZipDLL::extractall "$TEMP\${XAMPP_SERVER_FILE}" "$XAMPP_PARENT_FOLDER"
  Pop $0
  StrCmp $0 "success" +3
    MessageBox MB_ICONSTOP|MB_OK "XAMPP Web Server setup errors detected!$\r$\n$\r$\nUnable to continue. Try installing XAMPP Web server manually."
    Abort "XAMPP Web Server setup errors detected !"
  DetailPrint "XAMPP Web Server setup finished."
  ; Launch XAMPP Perl addon setup in silent mode
;  DetailPrint "Now Extracting XAMPP Perl addon, please wait..."
;  ZipDLL::extractall "$TEMP\${XAMPP_PERL_FILE}" "$INSTDIR"
;  Pop $0
;  StrCmp $0 "success" +3
;    MessageBox MB_ICONSTOP|MB_OK "XAMPP Perl addon setup errors detected!$\r$\n$\r$\nUnable to continue. Try installing XAMPP Perl addon manually."
;    Abort "XAMPP Perl addon setup errors detected !"
;  DetailPrint "XAMPP Perl addon setup finished."
  DetailPrint "Adding XML::Simple Perl module."
  SetOutPath "$INSTDIR\perl\site\lib\XML"
  File "${XML_SIMPLE_PATH}\lib\XML\Simple.pm"
  SetOutPath "$INSTDIR\perl\site\lib\XML\Simple"
  File "${XML_SIMPLE_PATH}\lib\XML\Simple\FAQ.pod"
  DetailPrint "XML::Simple Perl module extracted."
  DetailPrint "Configuring XAMPP Web Server, please wait..."
  DetailPrint "----------------------- CAUTION ------------------------------------"
  DetailPrint "SIMPLY PRESS ENTER to ALL QUESTIONS TO USE DEFAULT VALUES,"
  DetailPrint "unless you know what your are doing!"
  DetailPrint ""
  DetailPrint "DO NOT USE XAMPP Control Panel to register Apache, MySQL as service!"
  DetailPrint "--------------------------------------------------------------------"
  ExecWait "$INSTDIR\setup_xampp.bat" $0
  DetailPrint "XAMPP Web Server setup finished."

  ; Check if MySQL is already registered as service
  services::IsServiceInstalled "mysql"
  Pop $0
  StrCmp $0 "Yes" SKIP_INSTALL_MYSQL_SERVICE
  ; Register MySQL as a service
  DetailPrint "Now registering MySQL as a service, please wait..."
  nsExec::ExecToLog "$INSTDIR\xampp_cli.exe installservice mysql"
  Pop $0
  ${If} $0 <> 0
    MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to register MySQL as a service.$\r$\n$\r$\nCheck Windows EventLog for more details."
  ${Else}
    DetailPrint "MySQL registered as a service"
  ${EndIf}
  
SKIP_INSTALL_MYSQL_SERVICE:
  ; Check if Apache is already registered as service
  services::IsServiceInstalled "$APACHE_SERVICE_NAME"
  Pop $0
  StrCmp $0 "Yes" SKIP_INSTALL_APACHE_SERVICE
  ; Register Apache as a service
  DetailPrint "Now registering Apache Web Server as a service, please wait..."
  nsExec::ExecToLog "$INSTDIR\xampp_cli.exe installservice apache"
  Pop $0
  ${If} $0 <> 0
    MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to register Apache2 as a service.$\r$\n$\r$\nCheck Apache error.log file for more details."
  ${Else}
    DetailPrint "Apache Web Server registered as a service"
  ${EndIf}
  ; Set XAMPP + Perl installed flag
  StrCpy $XAMPP_PERL_AVAILABLE "true"

SKIP_INSTALL_APACHE_SERVICE:
SectionEnd

;----------------------------------------------------------------------------
; Section to install OCS Inventory NG Server components
;----------------------------------------------------------------------------
Section "!${PRODUCT_NAME} Server" SEC02
  ; In full or minimal type
  SectionIn 1 2
  Call GetXamppParentFolder
  ; Always overwrite files
  SetOverwrite on
  ; Check XAMPP + Perl installed flag
  StrCmp $XAMPP_PERL_AVAILABLE "true" 0 ABORT_OCS_SETUP
  ; Check if XAMPP is really installed
  IfFileExists "$INSTDIR\xampp-control.exe" 0 ABORT_OCS_SETUP
  ; Check if Perl is really installed
  IfFileExists "$INSTDIR\Perl\bin\Perl.exe" 0 ABORT_OCS_SETUP
  ; Check if Perl is really installed
  IfFileExists "$INSTDIR\apache\modules\mod_perl.so" BEGIN_OCS_SETUP ABORT_OCS_SETUP

ABORT_OCS_SETUP:
  ; Abort OCS Setup because XAMPP + Perl not installed
  MessageBox MB_ICONSTOP|MB_OK "XAMPP Web Server with Perl not found on directory <$INSTDIR>!$\r$\n$\r$\nYou must relaunch Setup and select to install XAMPP Web Server components. If you're using XAMPP without Perl Addon, you must install suitable Perl addon for your XAMPP Version."
  Abort "XAMPP Web Server with Perl not found!"
  
BEGIN_OCS_SETUP:
  ; First, stop Apache and MySQL services
  services::IsServiceRunning "$APACHE_SERVICE_NAME"
  Pop $0
  StrCmp $0 "Yes" 0 APACHE_SERVICE_NOT_RUNNING
  DetailPrint "Stopping Apache Web Server, please wait..."
  nsExec::ExecToLog "$SYSDIR\net stop $APACHE_SERVICE_NAME"
  Pop $0
  ${If} $0 <> 0
    DetailPrint "Unable to stop Apache Web Server, perhaps not started ?"
  ${Else}
    DetailPrint "Apache Web Server stopped."
  ${EndIf}

APACHE_SERVICE_NOT_RUNNING:
  services::IsServiceRunning "mysql"
  Pop $0
  StrCmp $0 "Yes" 0 MYSQL_SERVICE_NOT_RUNNING
  DetailPrint "Stopping MySQL service, please wait..."
  nsExec::ExecToLog "$SYSDIR\net stop mysql"
  Pop $0
  ${If} $0 <> 0
    DetailPrint "Unable to stop MySQL service, perhaps not started ?"
  ${Else}
    DetailPrint "MySQL service stopped."
  ${EndIf}

MYSQL_SERVICE_NOT_RUNNING:
  ; Delete OCS communication server older than 1.0 RC3
  DetailPrint "Removing Communication Server 1.0 RC2 or previous files, please wait..."
  RMDir /r "$INSTDIR\htdocs\ocsinventory-NG"
  ; Remove OCS Inventory NG Communication server 1.0 RC2 or previous config
  DetailPrint "Removing Communication Server 1.0 RC2 or previous configuration from httpd.conf, please wait..."
  Push "$INSTDIR\apache\conf\httpd.conf" ;file
  Push "#ocsinventory-ng configuration$\r$\n" ;line to start deleting from
  Push "</Location>$\r$\n" ;line to stop deleting at
  Call RemoveAfterLine
  ; Remove OCS Inventory NG Communication server 1.0 RC3 or previous config
  DetailPrint "Removing Communication Server 1.0 RC3 configuration from httpd.conf, please wait..."
  Push "$INSTDIR\apache\conf\httpd.conf" ;file
  Push "#ocsinventory-ng RC3 configuration$\r$\n" ;line to start deleting from
  Push "Include conf/ocsinventory.conf$\r$\n" ;line to stop deleting at
  Call RemoveAfterLine
  Delete "$INSTDIR\apache\conf\ocsinventory.conf"
  ; Remove OCS Inventory NG Communication server 1.0 RC3 or previous config
  DetailPrint "Removing Communication Server 1.01 configuration from httpd.conf, please wait..."
  Push "$INSTDIR\apache\conf\httpd.conf" ;file
  Push "# OCS Inventory NG Communication Server$\r$\n" ;line to start deleting from
  Push "Include conf/extra/ocsinventory.conf$\r$\n" ;line to stop deleting at
  Call RemoveAfterLine
  Delete "$INSTDIR\apache\conf\extra\ocsinventory.conf"
  ; Clear all previous errors
  ClearErrors

  ; Copy Communication Server files
  SetOutPath "$INSTDIR\${PRODUCT_NAME}"
  File "../ocsinventory-server\Apache\Changes"
  File "../ocsinventory-server\Apache\LICENSE"
  SetOutPath "$INSTDIR\perl\site\lib\Apache"
  File "../ocsinventory-server\Apache\Ocsinventory.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Map.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\SOAP.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Interface"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Config.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Database.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Extensions.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\History.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Internals.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Inventory.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Ipdiscover.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Interface\Updates.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Communication.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Constants.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Duplicate.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Groups.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Modperl1.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Modperl2.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\System.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\Capacities"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Download.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Example.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Filter.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Ipdiscover.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Notify.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Registry.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Update.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\Capacities\Download"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Capacities\Download\Inventory.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\Communication"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Communication\Session.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\Inventory"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Cache.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Capacities.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Data.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Export.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Filter.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Update.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\Inventory\Update"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Update\AccountInfos.pm"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\Inventory\Update\Hardware.pm"
  SetOutPath "$INSTDIR\perl\site\lib\Apache\Ocsinventory\Server\System"
  File "../ocsinventory-server\Apache\Ocsinventory\Server\System\Config.pm"
  SetOutPath "$INSTDIR\${PRODUCT_NAME}\binutils"
  File "../ocsinventory-server\binutils\ipdiscover-util.pl"
  File "../ocsinventory-server\binutils\ipdiscover-util.README"
  File "../ocsinventory-server\binutils\ocs-errors"
  File "../ocsinventory-server\binutils\ocsinventory-injector.pl"
  File "../ocsinventory-server\binutils\ocsinventory-injector.README"
  File "../ocsinventory-server\binutils\ocsinventory-log.pl"
  File "../ocsinventory-server\binutils\ocsinventory-log.README"
  File "../ocsinventory-server\binutils\soap-client.pl"
  File "../ocsinventory-server\binutils\soap-client.README"
  SetOutPath "$INSTDIR\${PRODUCT_NAME}\dtd"
  File "../ocsinventory-server\dtd\file_request.dtd"
  File "../ocsinventory-server\dtd\inventory_reply.dtd"
  File "../ocsinventory-server\dtd\inventory_request.dtd"
  File "../ocsinventory-server\dtd\prolog_reply.dtd"
  File "../ocsinventory-server\dtd\prolog_request.dtd"
  File "../ocsinventory-server\dtd\update_reply.dtd"
  File "../ocsinventory-server\dtd\update_request.dtd"
  SetOutPath "$INSTDIR\${PRODUCT_NAME}\dtd\Interface"
  File "../ocsinventory-server\dtd\Interface\get_computers_V1-request.dtd"
  SetOutPath "$INSTDIR\apache\conf\extra"
;  File "../ocsinventory-server\etc\ocsinventory\ocsinventory-reports.conf"
  File "../ocsinventory-server\etc\ocsinventory\ocsinventory-server.conf"
  SetOutPath "$INSTDIR"

  ; Copy Administration Console files
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\admin_attrib.php"
  File "..\ocsinventory-ocsreports\admin_language.php"
  File "..\ocsinventory-ocsreports\ajout_maj.php"
  File "..\ocsinventory-ocsreports\all_soft.php"
  File "..\ocsinventory-ocsreports\blacklist.php"
  File "..\ocsinventory-ocsreports\confiGale.php"
  File "..\ocsinventory-ocsreports\console.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\css"
  File "..\ocsinventory-ocsreports\css\boxsizing.htc"
  File "..\ocsinventory-ocsreports\css\ocsreports.css"
  File "..\ocsinventory-ocsreports\css\onglets.css"
  File "..\ocsinventory-ocsreports\css\winclassic.css"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\cvs.php"
  File "..\ocsinventory-ocsreports\dbconfig.inc.php"
  File "..\ocsinventory-ocsreports\dico.php"
  File "..\ocsinventory-ocsreports\donAdmini.php"
  File "..\ocsinventory-ocsreports\donnees.php"
  File "..\ocsinventory-ocsreports\doublons.php"
  File "..\ocsinventory-ocsreports\download.php"
  File "..\ocsinventory-ocsreports\favicon.ico"
  File "..\ocsinventory-ocsreports\fichierConf.class.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\files"
  File "..\ocsinventory-ocsreports\files\ocsbase.sql"
  File "..\ocsinventory-ocsreports\files\oui.txt"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\footer.php"
  File "..\ocsinventory-ocsreports\groups.php"
  File "..\ocsinventory-ocsreports\group_show.php"
  File "..\ocsinventory-ocsreports\header.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\image"
  File "..\ocsinventory-ocsreports\image\activer.png"
  File "..\ocsinventory-ocsreports\image\adm.png"
  File "..\ocsinventory-ocsreports\image\administration.png"
  File "..\ocsinventory-ocsreports\image\administration_a.png"
  File "..\ocsinventory-ocsreports\image\adm_a.png"
  File "..\ocsinventory-ocsreports\image\agent.png"
  File "..\ocsinventory-ocsreports\image\agent_a.png"
  File "..\ocsinventory-ocsreports\image\aide.png"
  File "..\ocsinventory-ocsreports\image\aide_a.png"
  File "..\ocsinventory-ocsreports\image\archive.png"
  File "..\ocsinventory-ocsreports\image\archives.png"
  File "..\ocsinventory-ocsreports\image\banner-ocs.png"
  File "..\ocsinventory-ocsreports\image\bios.png"
  File "..\ocsinventory-ocsreports\image\bios_a.png"
  File "..\ocsinventory-ocsreports\image\bios_d.png"
  File "..\ocsinventory-ocsreports\image\blanc.png"
  File "..\ocsinventory-ocsreports\image\cal.gif"
  File "..\ocsinventory-ocsreports\image\codes.png"
  File "..\ocsinventory-ocsreports\image\codes_a.png"
  File "..\ocsinventory-ocsreports\image\compress.png"
  File "..\ocsinventory-ocsreports\image\configuration.png"
  File "..\ocsinventory-ocsreports\image\configuration_a.png"
  File "..\ocsinventory-ocsreports\image\connexion.png"
  File "..\ocsinventory-ocsreports\image\controleur.png"
  File "..\ocsinventory-ocsreports\image\controleur_a.png"
  File "..\ocsinventory-ocsreports\image\controleur_d.png"
  File "..\ocsinventory-ocsreports\image\deconnexion.png"
  File "..\ocsinventory-ocsreports\image\delete_all.png"
  File "..\ocsinventory-ocsreports\image\dictionnaire.png"
  File "..\ocsinventory-ocsreports\image\dictionnaire_a.png"
  File "..\ocsinventory-ocsreports\image\disque.png"
  File "..\ocsinventory-ocsreports\image\disque_a.png"
  File "..\ocsinventory-ocsreports\image\disque_d.png"
  File "..\ocsinventory-ocsreports\image\doublons.png"
  File "..\ocsinventory-ocsreports\image\doublons_a.png"
  File "..\ocsinventory-ocsreports\image\down.png"
  File "..\ocsinventory-ocsreports\image\fond.png"
  File "..\ocsinventory-ocsreports\image\fond_orig.png"
  File "..\ocsinventory-ocsreports\image\Gest_admin1.png"
  File "..\ocsinventory-ocsreports\image\Gest_admin2.png"
  File "..\ocsinventory-ocsreports\image\groups.png"
  File "..\ocsinventory-ocsreports\image\groups_a.png"
  File "..\ocsinventory-ocsreports\image\imprimante.png"
  File "..\ocsinventory-ocsreports\image\imprimante_a.png"
  File "..\ocsinventory-ocsreports\image\imprimante_d.png"
  File "..\ocsinventory-ocsreports\image\imprimer.png"
  File "..\ocsinventory-ocsreports\image\interdit.jpg"
  File "..\ocsinventory-ocsreports\image\label.png"
  File "..\ocsinventory-ocsreports\image\label_a.png"
  File "..\ocsinventory-ocsreports\image\local.png"
  File "..\ocsinventory-ocsreports\image\local_a.png"
  File "..\ocsinventory-ocsreports\image\logiciels.png"
  File "..\ocsinventory-ocsreports\image\logiciels_a.png"
  File "..\ocsinventory-ocsreports\image\logiciels_d.png"
  File "..\ocsinventory-ocsreports\image\logo OCS-ng-48.png"
  File "..\ocsinventory-ocsreports\image\mail.gif"
  File "..\ocsinventory-ocsreports\image\memoire.png"
  File "..\ocsinventory-ocsreports\image\memoire_a.png"
  File "..\ocsinventory-ocsreports\image\memoire_d.png"
  File "..\ocsinventory-ocsreports\image\message.gif"
  File "..\ocsinventory-ocsreports\image\modem.png"
  File "..\ocsinventory-ocsreports\image\modem_a.png"
  File "..\ocsinventory-ocsreports\image\modem_d.png"
  File "..\ocsinventory-ocsreports\image\modif.png"
  File "..\ocsinventory-ocsreports\image\modif_a.png"
  File "..\ocsinventory-ocsreports\image\modif_all.png"
  File "..\ocsinventory-ocsreports\image\modif_anul.png"
  File "..\ocsinventory-ocsreports\image\modif_anul_v2.png"
  File "..\ocsinventory-ocsreports\image\modif_tab.png"
  File "..\ocsinventory-ocsreports\image\modif_valid.png"
  File "..\ocsinventory-ocsreports\image\modif_valid_v2.png"
  File "..\ocsinventory-ocsreports\image\moniteur.png"
  File "..\ocsinventory-ocsreports\image\moniteur_a.png"
  File "..\ocsinventory-ocsreports\image\moniteur_d.png"
  File "..\ocsinventory-ocsreports\image\norm_left.gif"
  File "..\ocsinventory-ocsreports\image\norm_left_on.gif"
  File "..\ocsinventory-ocsreports\image\norm_right.gif"
  File "..\ocsinventory-ocsreports\image\norm_right.gif.png"
  File "..\ocsinventory-ocsreports\image\norm_right_on.gif"
  File "..\ocsinventory-ocsreports\image\norm_right_on.gif.png"
  File "..\ocsinventory-ocsreports\image\oeil.png"
  File "..\ocsinventory-ocsreports\image\pack.png"
  File "..\ocsinventory-ocsreports\image\pack_a.png"
  File "..\ocsinventory-ocsreports\image\paquets.png"
  File "..\ocsinventory-ocsreports\image\paquets_a.png"
  File "..\ocsinventory-ocsreports\image\paquets_d.png"
  File "..\ocsinventory-ocsreports\image\pass.png"
  File "..\ocsinventory-ocsreports\image\pass_a.png"
  File "..\ocsinventory-ocsreports\image\peripherique.png"
  File "..\ocsinventory-ocsreports\image\peripherique_a.png"
  File "..\ocsinventory-ocsreports\image\peripherique_d.png"
  File "..\ocsinventory-ocsreports\image\port.png"
  File "..\ocsinventory-ocsreports\image\port_a.png"
  File "..\ocsinventory-ocsreports\image\port_d.png"
  File "..\ocsinventory-ocsreports\image\prec16.png"
  File "..\ocsinventory-ocsreports\image\prec24.png"
  File "..\ocsinventory-ocsreports\image\processeur.png"
  File "..\ocsinventory-ocsreports\image\processeur_a.png"
  File "..\ocsinventory-ocsreports\image\processeur_d.png"
  File "..\ocsinventory-ocsreports\image\proch16.png"
  File "..\ocsinventory-ocsreports\image\proch24.png"
  File "..\ocsinventory-ocsreports\image\recherche.png"
  File "..\ocsinventory-ocsreports\image\recherche_a.png"
  File "..\ocsinventory-ocsreports\image\recurrence.png"
  File "..\ocsinventory-ocsreports\image\recurrence_a.png"
  File "..\ocsinventory-ocsreports\image\red.png"
  File "..\ocsinventory-ocsreports\image\regconfig.png"
  File "..\ocsinventory-ocsreports\image\regconfig_a.png"
  File "..\ocsinventory-ocsreports\image\registre.png"
  File "..\ocsinventory-ocsreports\image\registre_a.png"
  File "..\ocsinventory-ocsreports\image\registre_d.png"
  File "..\ocsinventory-ocsreports\image\repartition.png"
  File "..\ocsinventory-ocsreports\image\repartition_a.png"
  File "..\ocsinventory-ocsreports\image\reseau.png"
  File "..\ocsinventory-ocsreports\image\reseau_a.png"
  File "..\ocsinventory-ocsreports\image\reseau_d.png"
  File "..\ocsinventory-ocsreports\image\rien.png"
  File "..\ocsinventory-ocsreports\image\rien_a.png"
  File "..\ocsinventory-ocsreports\image\securite.png"
  File "..\ocsinventory-ocsreports\image\securite_a.png"
  File "..\ocsinventory-ocsreports\image\slot.png"
  File "..\ocsinventory-ocsreports\image\slot_a.png"
  File "..\ocsinventory-ocsreports\image\slot_d.png"
  File "..\ocsinventory-ocsreports\image\son.png"
  File "..\ocsinventory-ocsreports\image\son_a.png"
  File "..\ocsinventory-ocsreports\image\son_d.png"
  File "..\ocsinventory-ocsreports\image\spec.png"
  File "..\ocsinventory-ocsreports\image\spec_a.png"
  File "..\ocsinventory-ocsreports\image\stat.png"
  File "..\ocsinventory-ocsreports\image\stockage.png"
  File "..\ocsinventory-ocsreports\image\stockage_a.png"
  File "..\ocsinventory-ocsreports\image\stockage_d.png"
  File "..\ocsinventory-ocsreports\image\supp.png"
  File "..\ocsinventory-ocsreports\image\suppv.png"
  File "..\ocsinventory-ocsreports\image\test.jpg"
  File "..\ocsinventory-ocsreports\image\ttaff.png"
  File "..\ocsinventory-ocsreports\image\ttlogiciels.png"
  File "..\ocsinventory-ocsreports\image\ttlogiciels_a.png"
  File "..\ocsinventory-ocsreports\image\ttmachines.png"
  File "..\ocsinventory-ocsreports\image\ttmachinesred.png"
  File "..\ocsinventory-ocsreports\image\ttmachinesred_a.png"
  File "..\ocsinventory-ocsreports\image\ttmachines_a.png"
  File "..\ocsinventory-ocsreports\image\up.png"
  File "..\ocsinventory-ocsreports\image\utilisateur OK.png"
  File "..\ocsinventory-ocsreports\image\utilisateurOK_a.png"
  File "..\ocsinventory-ocsreports\image\utilisateurs.png"
  File "..\ocsinventory-ocsreports\image\utilisateurs_.png"
  File "..\ocsinventory-ocsreports\image\utilisateurs_a.png"
  File "..\ocsinventory-ocsreports\image\video.png"
  File "..\ocsinventory-ocsreports\image\video_a.png"
  File "..\ocsinventory-ocsreports\image\video_d.png"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\index.php"
  File "..\ocsinventory-ocsreports\install.php"
  File "..\ocsinventory-ocsreports\ipcsv.php"
  File "..\ocsinventory-ocsreports\ipdiscover.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\js"
  File "..\ocsinventory-ocsreports\js\datetimepicker.js"
  File "..\ocsinventory-ocsreports\js\range.js"
  File "..\ocsinventory-ocsreports\js\slider.js"
  File "..\ocsinventory-ocsreports\js\timer.js"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\label.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\languages"
  File "..\ocsinventory-ocsreports\languages\brazilian_portuguese.png"
  File "..\ocsinventory-ocsreports\languages\brazilian_portuguese.txt"
  File "..\ocsinventory-ocsreports\languages\english.png"
  File "..\ocsinventory-ocsreports\languages\english.txt"
  File "..\ocsinventory-ocsreports\languages\french.png"
  File "..\ocsinventory-ocsreports\languages\french.txt"
  File "..\ocsinventory-ocsreports\languages\german.png"
  File "..\ocsinventory-ocsreports\languages\german.txt"
  File "..\ocsinventory-ocsreports\languages\hungarian.png"
  File "..\ocsinventory-ocsreports\languages\hungarian.txt"
  File "..\ocsinventory-ocsreports\languages\italian.png"
  File "..\ocsinventory-ocsreports\languages\italian.txt"
  File "..\ocsinventory-ocsreports\languages\polish.png"
  File "..\ocsinventory-ocsreports\languages\polish.txt"
  File "..\ocsinventory-ocsreports\languages\portuguese.png"
  File "..\ocsinventory-ocsreports\languages\portuguese.txt"
  File "..\ocsinventory-ocsreports\languages\russian.png"
  File "..\ocsinventory-ocsreports\languages\russian.txt"
  File "..\ocsinventory-ocsreports\languages\slovenian.png"
  File "..\ocsinventory-ocsreports\languages\slovenian.txt"
  File "..\ocsinventory-ocsreports\languages\spanish.png"
  File "..\ocsinventory-ocsreports\languages\spanish.txt"
  File "..\ocsinventory-ocsreports\languages\turkish.png"
  File "..\ocsinventory-ocsreports\languages\turkish.txt"
  SetOutPath "$INSTDIR\htdocs\ocsreports\libraries"
  File "..\ocsinventory-ocsreports\libraries\zip.lib.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\local.php"
  File "..\ocsinventory-ocsreports\machine.php"
  File "..\ocsinventory-ocsreports\multicritere.php"
  File "..\ocsinventory-ocsreports\opt_download.php"
  File "..\ocsinventory-ocsreports\opt_frequency.php"
  File "..\ocsinventory-ocsreports\opt_ipdiscover.php"
  File "..\ocsinventory-ocsreports\opt_param.php"
  File "..\ocsinventory-ocsreports\opt_prolog.php"
  File "..\ocsinventory-ocsreports\opt_suppr.php"
  File "..\ocsinventory-ocsreports\pass.php"
  File "..\ocsinventory-ocsreports\popup_rules_redistribution.php"
  File "..\ocsinventory-ocsreports\preferences.php"
  File "..\ocsinventory-ocsreports\req.class.php"
  File "..\ocsinventory-ocsreports\reqRegistre.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports\require"
  File "..\ocsinventory-ocsreports\require\function_config_generale.php"
  File "..\ocsinventory-ocsreports\require\function_dico.php"
  File "..\ocsinventory-ocsreports\require\function_opt_param.php"
  File "..\ocsinventory-ocsreports\require\function_rules.php"
  File "..\ocsinventory-ocsreports\require\function_server.php"
  File "..\ocsinventory-ocsreports\require\function_table_html.php"
  SetOutPath "$INSTDIR\htdocs\ocsreports"
  File "..\ocsinventory-ocsreports\resultats.php"
  File "..\ocsinventory-ocsreports\rules_redistrib.php"
  File "..\ocsinventory-ocsreports\security.php"
  File "..\ocsinventory-ocsreports\server_redistrib.php"
  File "..\ocsinventory-ocsreports\tele_activate.php"
  File "..\ocsinventory-ocsreports\tele_actives.php"
  File "..\ocsinventory-ocsreports\tele_affect.php"
  File "..\ocsinventory-ocsreports\tele_compress.php"
  File "..\ocsinventory-ocsreports\tele_massaffect.php"
  File "..\ocsinventory-ocsreports\tele_package.php"
  File "..\ocsinventory-ocsreports\tele_stats.php"
  File "..\ocsinventory-ocsreports\uploadfile.php"
  File "..\ocsinventory-ocsreports\users.php"

  IfErrors 0 CONFIGURE_OCS
  MessageBox MB_ICONSTOP|MB_OK "Errors where detected while copying files!$\r$\n$\r$\nUnable to continue."
  Abort "Errors where detected while copying files!"
  
CONFIGURE_OCS:
  ; Clear all previous errors
  ClearErrors
  ; Disable Perl tainting
  DetailPrint "Disabling Perl tainting in Apache, please wait..."
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\perl.conf" "$INSTDIR\apache\conf\extra\perl.conf" "PerlSwitches -T" "#PerlSwitches -T # Commented by OCS Setup" "/S=1 /C=1 /AO=1" $0
  ; Update ocsinventory-server.conf
  DetailPrint "Configuring Communication Server in Apache, please wait..."
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "VERSION_MP" "2" "/S=1 /C=1 /AO=1" $0
  Push "$INSTDIR\apache\logs"
  Push "\"
  Call StrSlash
  Pop $R0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "PATH_TO_LOG_DIRECTORY" "$R0" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "DATABASE_SERVER" "localhost" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "DATABASE_PORT" "3306" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "Apache::DBI" "DBI" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "$INSTDIR\apache\conf\extra\ocsinventory-server.conf" "PerlSetEnv OCS_OPT_OCS_FILES_PATH /tmp" "PerlSetEnv OCS_OPT_OCS_FILES_PATH $TEMP" "/S=1 /C=1 /AO=1" $0
  ; Add call to ocsinventory-server.conf into httpd.conf if needed
  DetailPrint "Checking Apache configuration, please wait..."
  ${textreplace::FindInFile} "$INSTDIR\apache\conf\httpd.conf" "Include conf/extra/ocsinventory-server.conf" "/S=1" $0
  ${If} $0 == 0
    ; Add include to OCS Inventory NG Communication server config file
    DetailPrint "Adding Communication Server configuration call to httpd.conf, please wait..."
    Push "$\r$\n# OCS Inventory NG Communication Server$\r$\nInclude conf/extra/ocsinventory-server.conf$\r$\n" ;text to write to file
    Push "$INSTDIR\apache\conf\httpd.conf" ;file to write to
    Call WriteToFile
  ${Else}
    DetailPrint "Communication Server configuration call in httpd.conf already set, skipping..."
  ${EndIf}

  ; Enable MySQL InnoDB engine into default MySQL Configuration file my.cnf
  DetailPrint "Activating MySQL InnoDB engine, please wait..."
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "max_allowed_packet = 1M" "max_allowed_packet = 4M" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "skip-innodb" "# skip-innodb" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#innodb_data_home_dir" "innodb_data_home_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#innodb_data_file_path" "innodb_data_file_path" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#innodb_log_group_home_dir" "innodb_log_group_home_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#innodb_log_arch_dir" "innodb_log_arch_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#set-variable = innodb_buffer_pool_size" "set-variable = innodb_buffer_pool_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#set-variable = innodb_additional_mem_pool_size" "set-variable = innodb_additional_mem_pool_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#set-variable = innodb_log_file_size" "set-variable = innodb_log_file_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#set-variable = innodb_log_buffer_size" "set-variable = innodb_log_buffer_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#innodb_flush_log_at_trx_commit" "innodb_flush_log_at_trx_commit" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\mysql\bin\my.cnf" "$INSTDIR\mysql\bin\my.cnf" "#set-variable = innodb_lock_wait_timeout" "set-variable = innodb_lock_wait_timeout" "/S=1 /C=1 /AO=1" $0
  IfFileExists "$WINDIR\my.ini" UPDATE_MY_INI INNODB_ENABLED

UPDATE_MY_INI:
  ; Enable MySQL InnoDB engine into actually in use MySQL Configuration file my.ini
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "max_allowed_packet = 1M" "max_allowed_packet = 4M" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "skip-innodb" "# skip-innodb" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#innodb_data_home_dir" "innodb_data_home_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#innodb_data_file_path" "innodb_data_file_path" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#innodb_log_group_home_dir" "innodb_log_group_home_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#innodb_log_arch_dir" "innodb_log_arch_dir" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#set-variable = innodb_buffer_pool_size" "set-variable = innodb_buffer_pool_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#set-variable = innodb_additional_mem_pool_size" "set-variable = innodb_additional_mem_pool_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#set-variable = innodb_log_file_size" "set-variable = innodb_log_file_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#set-variable = innodb_log_buffer_size" "set-variable = innodb_log_buffer_size" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#innodb_flush_log_at_trx_commit" "innodb_flush_log_at_trx_commit" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\my.ini" "$WINDIR\my.ini" "#set-variable = innodb_lock_wait_timeout" "set-variable = innodb_lock_wait_timeout" "/S=1 /C=1 /AO=1" $0

INNODB_ENABLED:
  ; Set memory_limit, file_uploads, upload_max_filesize, post_max_size, max_execution_time and max_input_time PHP values for XAMPP
  DetailPrint "Configuring Apache and PHP to allow deployment up to ${MAX_DEPLOY_PACKAGE_SIZE} MB, please wait..."
;  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "max_execution_time =" "max_execution_time = 0 ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
;  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "max_input_time =" "max_input_time = 0 ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "memory_limit =" "memory_limit = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "post_max_size =" "post_max_size = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "file_uploads =" "file_uploads = On ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" "upload_max_filesize =" "upload_max_filesize = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" ";extension=php_openssl.dll" "extension=php_openssl.dll ; Was not enabled before OCS setup" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$INSTDIR\apache\bin\php.ini" "$INSTDIR\apache\bin\php.ini" ";extension=php_zip.dll" "extension=php_zip.dll ; Was not enabled before OCS setup" "/S=1 /C=1 /AO=1" $0
  IfFileExists "$WINDIR\php.ini" UPDATE_PHP_WIN_INI UPDATE_OCSBASE_SQL

UPDATE_PHP_WIN_INI:
  ; Set memory_limit, file_uploads, upload_max_filesize, post_max_size, max_execution_time and max_input_time PHP values for default PHP install
;  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "max_execution_time =" "max_execution_time = 0 ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
;  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "max_input_time =" "max_input_time = 0 ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "memory_limit =" "memory_limit = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "post_max_size =" "post_max_size = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "file_uploads =" "file_uploads = On ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" "upload_max_filesize =" "upload_max_filesize = ${MAX_DEPLOY_PACKAGE_SIZE}M ; Before OCS setup, value was" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" ";extension=php_openssl.dll" "extension=php_openssl.dll ; Was not enabled before OCS setup" "/S=1 /C=1 /AO=1" $0
  ${textreplace::ReplaceInFile} "$WINDIR\php.ini" "$WINDIR\php.ini" ";extension=php_zip.dll" "extension=php_zip.dll ; Was not enabled before OCS setup" "/S=1 /C=1 /AO=1" $0

UPDATE_OCSBASE_SQL:
  ; Update Admin console configuration to set Download directory to $INSTDIR/htdocs/download
  StrCpy $0 "$INSTDIR/htdocs"
  Push $0
  Push "\"
  Call StrSlash
  Pop $1
  ${textreplace::ReplaceInFile} "$INSTDIR\htdocs\ocsreports\files\ocsbase.sql" "$INSTDIR\htdocs\ocsreports\files\ocsbase.sql" "/var/lib/ocsinventory-reports" "$1" "/S=1 /C=1 /AO=1" $0
  ; Start MySQL and Apache services
  DetailPrint "Starting MySQL service, please wait..."
  nsExec::ExecToLog "$SYSDIR\net start mysql"
  Pop $0
  ${If} $0 <> 0
    DetailPrint "Unable to start MySQL service."
    MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to start MySQL service.$\r$\n$\r$\nCheck Windows EventLog for more details."
  ${Else}
    DetailPrint "MySQL service started."
    DetailPrint "Starting Apache Web Server, please wait..."
    nsExec::ExecToLog "$SYSDIR\net start $APACHE_SERVICE_NAME"
    Pop $0
    ${If} $0 <> 0
      DetailPrint "Unable to start Apache Web Server."
      MessageBox MB_ICONEXCLAMATION|MB_OK "Unable to start Apache Web Server.$\r$\n$\r$\nCheck Apache Web Server error.log for more details."
    ${Else}
      DetailPrint "Apache Web Server started"
      DetailPrint "Launching OCS Inventory NG Administration Console into you web browser."
      DetailPrint "Database configuration or upgrade wizard will start if needed, please wait..."
      ExecShell "open" "http://localhost/ocsreports/install.php"
      DetailPrint "${PRODUCT_NAME} Setup completed."
    ${EndIf}
  ${EndIf}

  ; Delete XAMPP installations
  DetailPrint "Removing XAMPP temporary installation files, please wait..."
  Delete "$TEMP\${XAMPP_SERVER_FILE}"

  ; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

;----------------------------------------------------------------------------
; Section to create shortcuts in start menu and destop
;----------------------------------------------------------------------------
Section -AdditionalIcons
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  ; Add icon group to All Users
  SetShellVarContext all
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP"
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\OCS Inventory NG Reports.lnk" "http://localhost/ocsreports" "" "$INSTDIR\htdocs\ocsreports\favicon.ico"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\OCS Inventory NG Installation and Administration Guide.lnk" "http://wiki.ocsinventory-ng.org/index.php/Documentation:Main" "" "$SYSDIR\Shell32.dll" 23
  Delete "$SMPROGRAMS\$ICONS_GROUP\OCS Inventory NG Website.lnk"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\OCS Inventory NG on the Web.lnk" "${PRODUCT_WEB_SITE}" "" "$SYSDIR\Shell32.dll" 13
  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall ${PRODUCT_NAME} Server.lnk" "$INSTDIR\${PRODUCT_NAME}\uninst.exe" "" "$SYSDIR\msiexec.exe"
  CreateShortCut "$DESKTOP\OCS Inventory NG Reports.lnk" "http://localhost/ocsreports" "" "$INSTDIR\htdocs\ocsreports\favicon.ico"
  ; Remove old current user icon group
  SetShellVarContext current
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP"
!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

;----------------------------------------------------------------------------
; Section to create uninstaller
;----------------------------------------------------------------------------
Section -Post
  WriteUninstaller "$INSTDIR\${PRODUCT_NAME}\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\${PRODUCT_NAME}\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Install ApacheFriends XAMPP Web Server ${XAMPP_SERVER_VERSION} (Apache2, MySQL,Php, Perl).$\r$\n$\r$\nNB: Upgrading an existing version IS NOT recommended !"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Install or update ${PRODUCT_NAME} Server for Windows (requires XAMPP Web Server with Perl already installed)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END


;----------------------------------------------------------------------------
; Overide uninstall standard functions to customize them
;----------------------------------------------------------------------------
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer.$\r$\n$\r$\nDon't forget removing line <Include conf/extra/ocsinventory-server.conf> from file <$INSTDIR\apache\conf\httpd.conf>!$\r$\nThen restart Apache Web Server."
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Do you really want to uninstall  $(^Name) ?$\r$\n$\r$\nNB: XAMPP components will not be uninstalled." IDYES +2
  Abort
FunctionEnd

;----------------------------------------------------------------------------
; Section for uninstalling OCS Inventory NG Server components only
; XAMPP components must be removed manually.
;----------------------------------------------------------------------------
Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  ; Remove programs group
  SetShellVarContext all
  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall $ICONS_GROUP Server.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\$ICONS_GROUP Website.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\$ICONS_GROUP on the Web.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\$ICONS_GROUP Reports.lnk"
  Delete "$DESKTOP\$ICONS_GROUP Reports.lnk"
  Delete "$INSTDIR\..\perl\site\lib\Apache\Ocsinventory.pm"
  Delete "$INSTDIR\..\apache\conf\extra\ocsinventory-server.conf"
  ; Remove folders
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r "$INSTDIR\..\perl\site\lib\Apache\Ocsinventory"
  RMDir /r "$INSTDIR\..\htdocs\ocsreports"
  RMDir /r "$INSTDIR"
  ; Remove registry key
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetShellVarContext current
  SetAutoClose true
SectionEnd
