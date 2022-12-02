program EDITOR;

uses
  Forms,
  Editor1 in 'Editor1.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
