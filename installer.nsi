; Simple nsi script for installation of the magic color grid plugin.

;--------------------------------

Var MA3_VERSION	

; The name of the installer
Name "ma3_MagicColorGrid_Installer"

; The file to write
OutFile "ma3_MagicColorGrid_Installer.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel user

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $%PROGRAMDATA%\MALightingTechnology

;--------------------------------

; Pages

Page directory
Page instfiles

;--------------------------------

 Function .onInit
	StrCpy $MA3_VERSION "1.7.2"
 FunctionEnd


Function .onVerifyInstDir
    IfFileExists $INSTDIR\gma3_library\*.* Path1Good
      Abort ; if $INSTDIR is not a winamp directory, don't let us install there
Path1Good:
	IfFileExists $INSTDIR\gma3_$MA3_VERSION\*.* Path2Good
      Abort ; if $INSTDIR is not a winamp directory, don't let us install there
Path2Good:
  FunctionEnd

; The stuff to install

Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR\gma3_library\media\images
  
  ; Put file there
  File lib_images\*
  
  SetOutPath $INSTDIR\gma3_1.6.3\shared\resource\lib_plugins
  
  File /r lib_plugins\*.*
  
SectionEnd
