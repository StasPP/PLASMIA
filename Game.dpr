program Game;

uses
  Forms,
  Unit1 in 'Unit1.pas'{Mainform};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'PLASMIA';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
