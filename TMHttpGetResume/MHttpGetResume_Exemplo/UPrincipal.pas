unit UPrincipal;

interface

uses
  Windows, Forms, StdCtrls, MHttpGetResume, Controls, ExtCtrls, ComCtrls, Classes,
  SysUtils, Dialogs;

type
  TFrmMHttpGetResumeExemplo = class(TForm)
    http: TMHttpGetResume;
    LblTempoDecorrido: TLabel;
    LblTempoRestante: TLabel;
    LblRecebido: TLabel;
    LblTaxaTransf: TLabel;
    PB: TProgressBar;
    LblTotal: TLabel;
    LblRestante: TLabel;
    MemStatus: TMemo;
    LblTempoAutoRecon: TLabel;
    LblNumAutoRecon: TLabel;
    EdtURL: TEdit;
    PnlBotoes: TPanel;
    BtnDownload: TButton;
    BtnSair: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    CBAutoRecon: TCheckBox;
    Label8: TLabel;
    CBLog: TCheckBox;
    Label9: TLabel;
    EdtArquivoLocal: TEdit;
    Label10: TLabel;
    procedure BtnDownloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure httpMOnProgress(Sender: TObject);
    procedure httpMOnConcluido(Sender: TObject);
    procedure httpMOnStatus(Sender: TObject; sMsg: String);
    procedure MemStatusChange(Sender: TObject);
  private
    { Private declarations }
    procedure verificaBtnInicial;
  public
    { Public declarations }
  end;

var
  FrmMHttpGetResumeExemplo: TFrmMHttpGetResumeExemplo;

implementation

{$R *.dfm}

procedure TFrmMHttpGetResumeExemplo.BtnDownloadClick(Sender: TObject);
begin
   http.MAutoReconectar := CBAutoRecon.Checked;
   http.MURL := EdtURL.Text;
   http.MArquivoLocal := EdtArquivoLocal.Text;
   if BtnDownload.Caption <> 'Pausar' then
      http.IniciarDownload
   else
   begin
      http.MBaixando := False;
      verificaBtnInicial;
   end;
end;

procedure TFrmMHttpGetResumeExemplo.FormCreate(Sender: TObject);
begin
   Application.Title := 'MHttpGet';
   DoubleBuffered := True;
   verificaBtnInicial;
end;

procedure TFrmMHttpGetResumeExemplo.BtnSairClick(Sender: TObject);
begin
   Self.Close;
end;

procedure TFrmMHttpGetResumeExemplo.verificaBtnInicial;
begin
   if FileExists(EdtArquivoLocal.Text) then
      BtnDownload.Caption := 'Resumir'
   else
      BtnDownload.Caption := 'Download';
end;

procedure TFrmMHttpGetResumeExemplo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := (not http.MBaixando) or (http.MErro);
   if (not CanClose) then
      ShowMessage('O download está em progresso!')
   else
      http.MAutoReconectar := False;
end;

procedure TFrmMHttpGetResumeExemplo.httpMOnProgress(Sender: TObject);
begin
   if http.MBaixando then
   begin
      Self.Caption := 'Exemplo de utilização do MHttpGetResume - '+LblRecebido.Caption;
      Application.Title := 'MHttpGet - '+FormatFloat('##0%',
            (http.MTotalRecebido/http.MTamanhoArquivo)*100);
      BtnDownload.Caption := 'Pausar';
   end;
end;

procedure TFrmMHttpGetResumeExemplo.httpMOnConcluido(Sender: TObject);
begin
   if not http.MErro then
   begin
      verificaBtnInicial;
      ShowMessage('Download concluído com sucesso!');
   end
   else
      verificaBtnInicial;
end;

procedure TFrmMHttpGetResumeExemplo.httpMOnStatus(Sender: TObject; sMsg: String);
begin
   MemStatus.Lines.Add(sMsg);
end;

procedure TFrmMHttpGetResumeExemplo.MemStatusChange(Sender: TObject);
begin
   if CBLog.Checked then
      MemStatus.Lines.SaveToFile('MHttpGet.log');
end;

end.
