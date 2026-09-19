#define AppName "Coleciona HQ Agente"
#define AppVersion "1.0.24"
#define AppPublisher "Coleciona HQ"
#define AppExeName "HQ-HUB-Agente.cmd"

[Setup]
AppId={{A3F66D8A-4C12-4A7F-9D41-9C7EF9C6A111}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\Coleciona HQ\Agente
DefaultGroupName=Coleciona HQ
OutputDir=dist
OutputBaseFilename=Coleciona-HQ-Agente-Setup
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
Name: "{autodesktop}\Coleciona HQ - Iniciar agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{group}\Coleciona HQ - Iniciar agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{userstartup}\Coleciona HQ - Agente"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""
Name: "{group}\Desinstalar Coleciona HQ Agente"; Filename: "{uninstallexe}"

[Run]
Filename: "{sys}\wscript.exe"; Parameters: """{app}\HQ-HUB-Agente.vbs"""; Description: "Iniciar o agente Coleciona HQ agora"; Flags: postinstall nowait skipifsilent
