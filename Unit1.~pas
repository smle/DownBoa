unit Unit1;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, HTTPGet, Buttons;

type
  TForm1 = class(TForm)
    HTTPGetFile: THTTPGet;
    URLEdit: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    FileNameEdit: TEdit;
    UseCacheBox: TCheckBox;
    Button3: TButton;
    ProgressBar: TProgressBar;
    dlg: TSaveDialog;
    Button1: TButton;
    procedure HTTPGetPictureError(Sender: TObject);
    procedure HTTPGetPictureProgress(Sender: TObject; TotalSize, Readed: Integer);
    procedure HTTPGetStringDoneString(Sender: TObject; Result: String);
    procedure Button3Click(Sender: TObject);
    procedure HTTPGetFileDoneFile(Sender: TObject; FileName: String; FileSize: Integer);
    procedure UseCacheBoxClick(Sender: TObject);
    procedure Button3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FileNameEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.HTTPGetPictureError(Sender: TObject);
begin
  ShowMessage('뭔가 에러가;;; 뻘뻘;;;;;');
end;

procedure TForm1.HTTPGetPictureProgress(Sender: TObject; TotalSize,
  Readed: Integer);
begin
  ProgressBar.Max := TotalSize;
  ProgressBar.Position := Readed;
end;

procedure TForm1.HTTPGetStringDoneString(Sender: TObject; Result: String);
begin
  ShowMessage(Result);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if URLEdit.Text='' then
  begin
    showmessage('다운받을 url을 입력하세요');
    exit;
  end;
  if Filenameedit.Text='' then
  begin
    showmessage('저장할 위치를 지정하세요');
    exit;
  end;
  HTTPGetFile.URL := URLEdit.Text;
  HTTPGetFile.FileName := FileNameEdit.Text;
  HTTPGetFile.GetFile;
end;

procedure TForm1.HTTPGetFileDoneFile(Sender: TObject; FileName: String; FileSize: Integer);
begin
  ProgressBar.Position := 0;
  filenameedit.Text := '';
  urledit.Text := '';
  ShowMessage('저장경로 : ' + FileName + #13#10 +
              '저장용량 : ' + IntToStr(FileSize) + ' bytes');
end;

procedure TForm1.UseCacheBoxClick(Sender: TObject);
begin
  HTTPGetFile.UseCache := UseCacheBox.Checked;
end;

procedure TForm1.Button3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (random(10)>8) then
  begin
    button3.Caption := '우너츄!!';
  end
  else
  begin
    button3.Caption := '원츄!!';
  end;
end;

procedure TForm1.Button3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  button3.Caption := '아싸!';
end;



procedure TForm1.FileNameEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=vk_return) then
  begin
    button3.Click;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i : Integer;
  count : Integer;
  temp : string;
begin
  count := 0;
  for i := 0 to length(urledit.text)-1 do
  begin
    if urledit.Text[i]='=' then
    begin
      if count<i then  count := i;
    end;
  end;
  for i := 0 to length(urledit.text)-1 do
  begin
    if urledit.Text[i]='/' then
    begin
      if count<i then  count := i;
    end;
  end;


  temp := Copy(urledit.Text,count+1,length(urledit.text));

  if (Pos('.',temp)=0) then
  begin
    dlg.FileName := '';
    dlg.FilterIndex := 1;    
  end
  else
  begin
    dlg.FileName := temp;
    if (pos('.mp3',temp)>0) then
    begin
      dlg.FilterIndex := 2;
    end;
    if (pos('.wma',temp)>0) then
    begin
      dlg.FilterIndex := 3;
    end;
    if (pos('.avi',temp)>0) then
    begin
      dlg.FilterIndex := 4;
    end;

  end;

//\ / : * ? " < > |
  if (random(10)<4) then
  begin
    dlg.Title := '어따할까뇨~';
  end
  else
  begin
    dlg.Title := '어따할까뉴~';
  end;

  if dlg.Execute then
  begin
    filenameedit.Text := dlg.FileName;

    if (dlg.FilterIndex=2) then
    begin
      if (pos('.mp3',dlg.filename)=0) then
      begin
        filenameedit.Text := dlg.FileName + '.mp3';
      end;
    end;

    if (dlg.FilterIndex=3) then
    begin
      if (pos('.wma',dlg.filename)=0) then
      begin
        filenameedit.Text := dlg.FileName + '.wma';
      end;
    end;

    if (dlg.FilterIndex=4) then
    begin
      if (pos('.avi',dlg.filename)=0) then
      begin
        filenameedit.Text := dlg.FileName + '.avi';
      end;
    end;

  end;
end;

end.
