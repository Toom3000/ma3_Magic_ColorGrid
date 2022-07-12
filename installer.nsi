; Simple nsi script for installation of the magic color grid plugin.

;--------------------------------

; The name of the installer
Name "ma3_MagicColorGrid_Installer"

; The file to write
OutFile "ma3_MagicColorGrid_Installer.exe"

; Request application privileges for Windows Vista
RequestExecutionLevel user

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $%PROGRAMDATA%\MALightingTechnology\gma3_library

;--------------------------------

; Pages

Page directory
Page instfiles

;--------------------------------

Function .onVerifyInstDir
    IfFileExists $INSTDIR\*.* Path1Good
      Abort ; if $INSTDIR is not a winamp directory, don't let us install there
Path1Good:
FunctionEnd

; The stuff to install

Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR\media\images
  
  ; Put file there
  File lib_images\*
  
  SetOutPath $INSTDIR\datapools\plugins
  
  File /r lib_plugins\*.*
  
SectionEnd
