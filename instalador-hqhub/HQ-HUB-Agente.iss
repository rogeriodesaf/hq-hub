#define AppName "HQ-HUB Agente"
#define AppVersion "1.0.12"
#define AppPublisher "HQ-HUB"
#define AppExeName "HQ-HUB-Agente.cmd"

[Setup]
AppId={{A3F66D8A-4C12-4A7F-9D41-9C7EF9C6A111}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\HQ-HUB\Agente
DefaultGroupName=HQ-HUB
OutputDir=dist
OutputBaseFilename=HQ-HUB-Agente-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
DisableProgramGroupPage=yes

[Files]
Source: "dist\agente\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
Name: "{app}\python"

[Icons]
Name: "{autodesktop}\HQ-HUB - Iniciar agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{group}\HQ-HUB - Iniciar agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{userstartup}\HQ-HUB - Agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{group}\Desinstalar HQ-HUB Agente"; Filename: "{uninstallexe}"

[Run]
Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""; Description: "Iniciar o agente HQ-HUB agora"; Flags: postinstall nowait skipifsilent
