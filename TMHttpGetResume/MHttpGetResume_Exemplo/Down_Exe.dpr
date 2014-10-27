program Down_Exe;

uses
  Forms,
  UPrincipal in 'UPrincipal.pas' {FrmMHttpGetResumeExemplo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMHttpGetResumeExemplo, FrmMHttpGetResumeExemplo);
  Application.Run;
end.
