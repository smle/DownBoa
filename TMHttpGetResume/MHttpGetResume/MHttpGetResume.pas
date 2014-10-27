unit MHttpGetResume;

interface

uses
  Windows, Messages, SysUtils, Classes, WinInet, Controls, ComCtrls, StdCtrls, Dialogs, Forms;

type
  TOnProgressEvent = procedure(Sender: TObject) of object;
  TOnConcluidoEvent = procedure(Sender: TObject) of object;
  TOnStatusEvent = procedure(Sender: TObject; sMsg: String) of object;

  TMHttpGetResume = class(TComponent)
  private
    FURL: String;
    FUsuario: String;
    FSenha: String;
    FPorta: Integer;
    FServidorProxy: String;
    FPortaProxy: Integer;
    FArquivoLocal: String;

    FProgressBar: TProgressBar;
    FLblTotal: TLabel;
    FLblRecebido: TLabel;
    FLblRestante: TLabel;
    FLblTaxaTransf: TLabel;
    FLblTempoRestante: TLabel;
    FLblTempoDecorrido: TLabel;
    FLblTempoAutoRecon: TLabel;
    FLblNumAutoRecon: TLabel;

    FBaixando: Boolean;
    FPos: Integer;
    FAutoRecon: Boolean;
    FTempoAutoRecon: Integer;
    FNumAutoRecon: Integer;
    FTamanhoArquivo: Integer;
    FBytesRecebidos: Integer;
    FTotalRecebido: Integer;
    FtInicial: TTime;
    FtDecorrido: TTime;
    FTempoDownload: Double;
    FTaxaTransf: Double;
    FTempoEstimado: Double;
    H, M, Sec, MS: Word;
    iRedownload, iTempoAutoRecon, iNumAutoRecon: Integer;

    FProgress: TOnProgressEvent;
    FConcluido: TOnConcluidoEvent;
    FStatus: TOnStatusEvent;
    FErro: Boolean;
    function downloadAtPos(const AURL, AFileName: String; APos: Integer): Integer;
    procedure ParseURL(AURL: String; var AHost, AResource: String);
    function getResourceSize(const AURL: String): Integer;
    procedure UpdateProgress(ACompleted: Integer);
    procedure UpdateStatus(aMsg: String);
    procedure UpdateConcluido;
    procedure verificaErro;
  public
    constructor Create(aOwner: TComponent); override;
    procedure IniciarDownload;
  published
    property MURL: String read FURL write FURL;
    property MUsuario: String read FUsuario write FUsuario;
    property MSenha: String read FSenha write FSenha;
    property MPorta: Integer read FPorta write FPorta;
    property MServidorProxy: String read FServidorProxy write FServidorProxy;
    property MPortaProxy: Integer read FPortaProxy write FPortaProxy;
    property MArquivoLocal: String read FArquivoLocal write FArquivoLocal;

    property MBaixando: Boolean read FBaixando write FBaixando;
    property MAutoReconectar: Boolean read FAutoRecon write FAutoRecon;
    property MTempoAutoReconectar: Integer read FTempoAutoRecon write FTempoAutoRecon;
    property MVezesAutoReconectar: Integer read FNumAutoRecon write FNumAutoRecon;
    property MErro: Boolean read FErro;
    property MTamanhoArquivo: Integer read FTamanhoArquivo;
    property MBytesRecebidos: Integer read FBytesRecebidos;
    property MTotalRecebido: Integer read FTotalRecebido;
    property MTempoInicial: TTime read FtInicial;
    property MTempoDecorrido: TTime read FtDecorrido;
    property MTempoDownload: Double read FTempoDownload;
    property MTaxaTransferencia: Double read FTaxaTransf;
    property MTempoEstimado: Double read FTempoEstimado;

    property MProgressBar: TProgressBar read FProgressBar write FProgressBar;
    property MLblTotal: TLabel read FLblTotal write FLblTotal;
    property MLblRecebido: TLabel read FLblRecebido write FLblRecebido;
    property MLblRestante: TLabel read FLblRestante write FLblRestante;
    property MLblTaxaTransferencia: TLabel read FLblTaxaTransf write FLblTaxaTransf;
    property MLblTempoRestante: TLabel read FLblTempoRestante write FLblTempoRestante;
    property MLblTempoDecorrido: TLabel read FLblTempoDecorrido write FLblTempoDecorrido;
    property MLblTempoAutoRecon: TLabel read FLblTempoAutoRecon write FLblTempoAutoRecon;
    property MLblNumAutoRecon: TLabel read FLblNumAutoRecon write FLblNumAutoRecon;

    property MOnProgress: TOnProgressEvent read FProgress write FProgress;
    property MOnConcluido: TOnConcluidoEvent read FConcluido write FConcluido;
    property MOnStatus: TOnStatusEvent read FStatus write FStatus;
  end;

procedure Register;

implementation

{ TMHttpGetResume }

constructor TMHttpGetResume.Create(aOwner: TComponent);
begin
   inherited Create(aOwner);
   FPorta := 80;
   FPortaProxy := 3128;
   FTamanhoArquivo := 0;
   FErro := False;
   FBaixando := False;
   FAutoRecon := False;
   FTempoAutoRecon := 15;
   FNumAutoRecon := 5;
   iNumAutoRecon := 1;
end;

function TMHttpGetResume.downloadAtPos(const AURL, AFileName: String;
  APos: Integer): Integer;
const
   FileOpenModes: array[Boolean] of DWORD = (fmCreate, fmOpenWrite);
var
   FileStream: TFileStream;
   hOpen, hConnect, hResource: HINTERNET;
   host, resource, s: string;
   DataProceed: array[0..8191] of Byte;
   numread: DWORD;
begin
   try
      ParseURL(AURL, host, resource);
      FBytesRecebidos := 0;
      repeat
         iRedownload := iRedownload + 1;
         if iRedownload > 1 then
            UpdateStatus('Download reiniciado automaticamente ('+IntToStr(iRedownload-1)+')!');
         if not FErro then
            hOpen := InternetOpen('MHttpGetResume', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
         verificaErro;
         if not FErro then
            hConnect := InternetConnect(hOpen, PChar(host), INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
         verificaErro;
         if not FErro then
            hResource := HttpOpenRequest(hConnect, 'GET', PChar(resource), nil, nil, nil, 0, 0);
         verificaErro;

         Result := APos;
         if not FErro then
         begin
            if (Result > 0) then
            begin
               UpdateStatus('Download a ser resumido, definindo escopo...');
               s := Format('Range: bytes=%d-', [Result]);
               HttpAddRequestHeaders(hResource, PChar(s), Length(s), HTTP_ADDREQ_FLAG_ADD_IF_NEW);
               verificaErro;
            end;
         end;

         if not FErro then
         begin
            UpdateStatus('Enviando requisição ao servidor...');
            HttpSendRequest(hResource, nil, 0, nil, 0);
            verificaErro;
         end;

         if FErro then
         begin
            if not FAutoRecon then
               Exit
            else
            begin
               iTempoAutoRecon := FTempoAutoRecon;
               if FLblNumAutoRecon <> nil then
                  FLblNumAutoRecon.Caption := IntToStr(iNumAutoRecon);
               iNumAutoRecon := iNumAutoRecon + 1;
               UpdateStatus('Aguarde, reconectando em '+IntToStr(FTempoAutoRecon)+' segundos...');
               Application.ProcessMessages;
               while iTempoAutoRecon >= 0 do
               begin
                  if FAutoRecon then
                  begin
                     if FLblTempoAutoRecon <> nil then
                        FLblTempoAutoRecon.Caption := IntToStr(iTempoAutoRecon)+' s';
                     Application.ProcessMessages;
                     Sleep(1000);
                     iTempoAutoRecon := iTempoAutoRecon - 1;
                  end
                  else
                     Break;
               end;
               FBaixando := False;
               IniciarDownload;
               Exit;
            end;
         end;

         FileStream := TFileStream.Create(AFileName, FileOpenModes[FileExists(AFileName)]);
         try
            FileStream.Position := Result;
            if Result > 0 then
               UpdateStatus('Resumindo download...')
            else
               UpdateStatus('Iniciando download...');
            repeat
               if FErro then
                  Exit;
               ZeroMemory(@DataProceed, SizeOf(DataProceed));
               InternetReadFile(hResource, @DataProceed, SizeOf(DataProceed), numread);
               verificaErro;
               if (numread <= 0) then
                  Break;
               FileStream.Write(DataProceed, numread);
               FBytesRecebidos := FBytesRecebidos + Integer(numread);
               Result := Result + Integer(numread);
               FTotalRecebido := Result;

               FtDecorrido := Now-FtInicial;
               DecodeTime(FtDecorrido, H, M, Sec, MS);
               Sec := Sec+M*60+H*3600;
               FTempoDownload := Sec+MS/1000;
               if FTempoDownload > 0 then
               begin
                  FTaxaTransf := (FBytesRecebidos/1024)/FTempoDownload;
                  FTempoEstimado := (((FTamanhoArquivo-Result)/1024)/FTaxaTransf);
               end;

               UpdateProgress(Result);
               if Result = FTamanhoArquivo then
                  Break;
            until (not FBaixando);
         finally
            FileStream.Free();
            InternetCloseHandle(hConnect);
            InternetCloseHandle(hOpen);
         end;
         APos := Result;
         if Result = FTamanhoArquivo then
            Break
         else
         begin
            if not FBaixando then
               UpdateStatus('Download pausado!');
         end;
      until (not FBaixando);
   except
      on E: Exception do
         UpdateStatus(E.Message);
   end;
end;

procedure TMHttpGetResume.IniciarDownload;
begin
   if FBaixando then
      Exit;
   FBaixando := True;
   iRedownload := 0;
   FErro := False;
   if (FNumAutoRecon = 0) or (iNumAutoRecon <= FNumAutoRecon) then
   begin
      try
         try
            FTamanhoArquivo := getResourceSize(FURL);
            if FLblTotal <> nil then
               FLblTotal.Caption := FormatFloat('###,###,##0.00 KB', (FTamanhoArquivo/1024));
            if (FTamanhoArquivo > 0) or (FErro) then
            begin
               if not FileExists(FArquivoLocal) then
                  FPos := 0
               else
               begin
                  with TFileStream.Create(FArquivoLocal, fmOpenRead) do
                  begin
                     FPos := Size;
                     Free;
                  end;
               end;
               if (FPos <> FTamanhoArquivo) or (FErro) then
               begin
                  FProgressBar.Max := FTamanhoArquivo;
                  FProgressBar.Position := FPos;
                  FtInicial := Now;
                  FPos := DownloadAtPos(FURL, FArquivoLocal, FPos);
                  if FBaixando then
                     UpdateConcluido;
               end
               else
               begin
                  FBaixando := False;
                  UpdateConcluido;
               end;
            end;
         except
            on E: Exception do
               UpdateStatus(E.Message);
         end;
      finally
         FBaixando := False;
      end;
   end
   else
   begin
      FErro := False;
      FBaixando := False;
      iNumAutoRecon := 1;
      UpdateStatus(' -> Número máximo de reconexões automáticas já feitos ('+IntToStr(FNumAutoRecon)+')!');
      UpdateStatus(' -> Experimente novamente mais tarde!');
   end;
end;

function TMHttpGetResume.getResourceSize(const AURL: String): Integer;
var
   hOpen, hConnect, hResource: HINTERNET;
   host, resource: string;
   buflen, tmp: DWORD;
begin
   try
      ParseURL(AURL, host, resource);

      if not FErro then
      begin
         UpdateStatus('Verificando tamanho do download...');
         hOpen := InternetOpen('MHttpGetResume', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
         verificaErro;
         if not FErro then
            hConnect := InternetConnect(hOpen, PChar(host), INTERNET_DEFAULT_HTTP_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 0);
         verificaErro;
         if not FErro then
            hResource := HttpOpenRequest(hConnect, 'HEAD', PChar(resource), nil, nil, nil, 0, 0);
         verificaErro;
         if not FErro then
            HttpSendRequest(hResource, nil, 0, nil, 0);
         verificaErro;
      end;

      if not FErro then
      begin
         buflen := SizeOf(Result);
         tmp := 0;
         Result := 0;
         HttpQueryInfo(hResource, HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,
               @Result, buflen, tmp);
         verificaErro;
      end
      else
         Result := 0;                                 

      InternetCloseHandle(hConnect);
      InternetCloseHandle(hOpen);
   except
      on E: Exception do
         UpdateStatus(E.Message);
   end;
end;

procedure TMHttpGetResume.ParseURL(AURL: String; var AHost, AResource: String);

   procedure CleanArray(var Arr: array of Char);
   begin
      ZeroMemory(Arr + 0, High(Arr) - Low(Arr) + 1);
   end;

var
   UrlComponents: TURLComponents;
   scheme: array[0..INTERNET_MAX_SCHEME_LENGTH - 1] of Char;
   host: array[0..INTERNET_MAX_HOST_NAME_LENGTH - 1] of Char;
   user: array[0..INTERNET_MAX_USER_NAME_LENGTH - 1] of Char;
   password: array[0..INTERNET_MAX_PASSWORD_LENGTH - 1] of Char;
   urlpath: array[0..INTERNET_MAX_PATH_LENGTH - 1] of Char;
   fullurl: array[0..INTERNET_MAX_URL_LENGTH - 1] of Char;
   extra: array[0..1024 - 1] of Char;
begin
   try
      if LowerCase(Copy(AURL,1,7)) <> 'http://' then
         AURL := 'http://'+AURL;
      FURL := AURL;
      CleanArray(scheme);
      CleanArray(host);
      CleanArray(user);
      CleanArray(password);
      CleanArray(urlpath);
      CleanArray(fullurl);
      CleanArray(extra);
      ZeroMemory(@UrlComponents, SizeOf(TURLComponents));

      UrlComponents.dwStructSize := SizeOf(TURLComponents);
      UrlComponents.lpszScheme := scheme;
      UrlComponents.dwSchemeLength := High(scheme) + 1;
      UrlComponents.lpszHostName := host;
      UrlComponents.dwHostNameLength := High(host) + 1;
      UrlComponents.lpszUserName := user;
      UrlComponents.dwUserNameLength := High(user) + 1;
      UrlComponents.lpszPassword := password;
      UrlComponents.dwPasswordLength := High(password) + 1;
      UrlComponents.lpszUrlPath := urlpath;
      UrlComponents.dwUrlPathLength := High(urlpath) + 1;
      UrlComponents.lpszExtraInfo := extra;
      UrlComponents.dwExtraInfoLength := High(extra) + 1;

      InternetCrackUrl(PChar(AURL), Length(AURL), ICU_DECODE or ICU_ESCAPE, UrlComponents);

      verificaErro;

      AHost := host;
      AResource := urlpath;
   except
      on E: Exception do
         UpdateStatus(E.Message);
   end;
end;

procedure Register;
begin
   RegisterComponents('Samples', [TMHttpGetResume]);
end;

procedure TMHttpGetResume.UpdateProgress(ACompleted: Integer);
begin
   try
      if FProgressBar <> nil then
         FProgressBar.Position := ACompleted;
      if FLblRecebido <> nil then
         FLblRecebido.Caption := FormatFloat('###,###,##0.00 KB', (ACompleted/1024))+' ('+
               FormatFloat('##0.00%', (ACompleted/FTamanhoArquivo)*100)+')';
      if FLblRestante <> nil then
         FLblRestante.Caption := FormatFloat('##,###,##0.00', (FTamanhoArquivo-ACompleted)/1024)+' KB ('+
               FormatFloat('##,###,##0.00', ((FTamanhoArquivo-ACompleted)/FTamanhoArquivo)*100)+'%)';
      if FLblTempoDecorrido <> nil then
         FLblTempoDecorrido.Caption := 'Tempo decorrido: '+TimeToStr(FtDecorrido)+' s';
      if FLblTempoRestante <> nil then
         FLblTempoRestante.Caption := 'Tempo restante: '+FormatFloat('00',(FTempoEstimado/3600))+':'+
               FormatFloat('00',(FTempoEstimado/60))+':'+FormatFloat('00',(FTempoEstimado-(60*Trunc(FTempoEstimado/60))))+' s';
      if FLblTaxaTransf <> nil then
         FLblTaxaTransf.Caption := 'Taxa de transferência: '+FormatFloat('0.00 KB/s', FTaxaTransf);
      if Assigned(FProgress) then
         FProgress(Self);
      Application.ProcessMessages();
   except
      on E: Exception do
         UpdateStatus(E.Message);
   end;
end;

procedure TMHttpGetResume.UpdateStatus(aMsg: String);
begin
   if Assigned(FStatus) then
      FStatus(Self, aMsg);
   Application.ProcessMessages();
end;

procedure TMHttpGetResume.verificaErro;
const
   iCodErro: array [1..59] of Integer = (12001, 12002, 12003, 12004, 12005, 12006, 12007, 12008,
         12009, 12010, 12011, 12012, 12013, 12014, 12015, 12016, 12017, 12018, 12019, 12020, 12021,
         12022, 12023, 12024, 12025, 12026, 12027, 12028, 12029, 12030, 12031, 12032, 12033, 12036,
         12037, 12038, 12039, 12040, 12041, 12042, 12043, 12110, 12111, 12130, 12131, 12132, 12133,
         12134, 12135, 12136, 12137, 12138, 12150, 12151, 12152, 12153, 12154, 12155, 12156);
   sDescErro: array [1..59] of String = ('ERROR_INTERNET_OUT_OF_HANDLES - No more handles could be generated at this time.',
         'ERROR_INTERNET_TIMEOUT - The request has timed out.',
         'ERROR_INTERNET_EXTENDED_ERROR - An extended error was returned from the server. This is typically a string or buffer containing a verbose error message. Call InternetGetLastResponseInfo to retrieve the error text.',
         'ERROR_INTERNET_INTERNAL_ERROR - An internal error has occurred.',
         'ERROR_INTERNET_INVALID_URL - The URL is invalid.',
         'ERROR_INTERNET_UNRECOGNIZED_SCHEME - The URL scheme could not be recognized or is not supported.',
         'ERROR_INTERNET_NAME_NOT_RESOLVED - The server name could not be resolved.',
         'ERROR_INTERNET_PROTOCOL_NOT_FOUND - The requested protocol could not be located.',
         'ERROR_INTERNET_INVALID_OPTION - A request to InternetQueryOption or InternetSetOption specified an invalid option value.',
         'ERROR_INTERNET_BAD_OPTION_LENGTH - The length of an option supplied to InternetQueryOption or InternetSetOption is incorrect for the type of option specified.',
         'ERROR_INTERNET_OPTION_NOT_SETTABLE - The request option cannot be set, only queried.',
         'ERROR_INTERNET_SHUTDOWN - The Win32 Internet function support is being shut down or unloaded.',
         'ERROR_INTERNET_INCORRECT_USER_NAME - The request to connect and log on to an FTP server could not be completed because the supplied user name is incorrect.',
         'ERROR_INTERNET_INCORRECT_PASSWORD - The request to connect and log on to an FTP server could not be completed because the supplied password is incorrect.',
         'ERROR_INTERNET_LOGIN_FAILURE - The request to connect to and log on to an FTP server failed.',
         'ERROR_INTERNET_INVALID_OPERATION - The requested operation is invalid.',
         'ERROR_INTERNET_OPERATION_CANCELLED - The operation was canceled, usually because the handle on which the request was operating was closed before the operation completed.',
         'ERROR_INTERNET_INCORRECT_HANDLE_TYPE - The type of handle supplied is incorrect for this operation.',
         'ERROR_INTERNET_INCORRECT_HANDLE_STATE - The requested operation cannot be carried out because the handle supplied is not in the correct state.',
         'ERROR_INTERNET_NOT_PROXY_REQUEST - The request cannot be made via a proxy.',
         'ERROR_INTERNET_REGISTRY_VALUE_NOT_FOUND - A required registry value could not be located.',
         'ERROR_INTERNET_BAD_REGISTRY_PARAMETER - A required registry value was located but is an incorrect type or has an invalid value.',
         'ERROR_INTERNET_NO_DIRECT_ACCESS - Direct network access cannot be made at this time.',
         'ERROR_INTERNET_NO_CONTEXT - An asynchronous request could not be made because a zero context value was supplied.',
         'ERROR_INTERNET_NO_CALLBACK - An asynchronous request could not be made because a callback function has not been set.',
         'ERROR_INTERNET_REQUEST_PENDING - The required operation could not be completed because one or more requests are pending.',
         'ERROR_INTERNET_INCORRECT_FORMAT - The format of the request is invalid.',
         'ERROR_INTERNET_ITEM_NOT_FOUND - The requested item could not be located.',
         'ERROR_INTERNET_CANNOT_CONNECT - The attempt to connect to the server failed.',
         'ERROR_INTERNET_CONNECTION_ABORTED - The connection with the server has been terminated.',
         'ERROR_INTERNET_CONNECTION_RESET - The connection with the server has been reset.',
         'ERROR_INTERNET_FORCE_RETRY - Calls for the Win32 Internet function to redo the request.',
         'ERROR_INTERNET_INVALID_PROXY_REQUEST - The request to the proxy was invalid.',
         'ERROR_INTERNET_HANDLE_EXISTS - The request failed because the handle already exists.',
         'ERROR_INTERNET_SEC_CERT_DATE_INVALID - SSL certificate date that was received from the server is bad. The certificate is expired.',
         'ERROR_INTERNET_SEC_CERT_CN_INVALID - SSL certificate common name (host name field) is incorrect. For example, if you entered www.server.com and the common name on the certificate says www.different.com.',
         'ERROR_INTERNET_HTTP_TO_HTTPS_ON_REDIR - The application is moving from a non-SSL to an SSL connection because of a redirect.',
         'ERROR_INTERNET_HTTPS_TO_HTTP_ON_REDIR - The application is moving from an SSL to an non-SSL connection because of a redirect.',
         'ERROR_INTERNET_MIXED_SECURITY - Indicates that the content is not entirely secure. Some of the content being viewed may have come from unsecured servers.',
         'ERROR_INTERNET_CHG_POST_IS_NON_SECURE - The application is posting and attempting to change multiple lines of text on a server that is not secure.',
         'ERROR_INTERNET_POST_IS_NON_SECURE - The application is posting data to a server that is not secure.',
         'ERROR_FTP_TRANSFER_IN_PROGRESS - The requested operation cannot be made on the FTP session handle because an operation is already in progress.',
         'ERROR_FTP_DROPPED - The FTP operation was not completed because the session was aborted.',
         'ERROR_GOPHER_PROTOCOL_ERROR - An error was detected while parsing data returned from the gopher server.',
         'ERROR_GOPHER_NOT_FILE - The request must be made for a file locator.',
         'ERROR_GOPHER_DATA_ERROR - An error was detected while receiving data from the gopher server.',
         'ERROR_GOPHER_END_OF_DATA - The end of the data has been reached.',
         'ERROR_GOPHER_INVALID_LOCATOR - The supplied locator is not valid.',
         'ERROR_GOPHER_INCORRECT_LOCATOR_TYPE - The type of the locator is not correct for this operation.',
         'ERROR_GOPHER_NOT_GOPHER_PLUS - The requested operation can only be made against a Gopher+server or with a locator that specifies a Gopher+operation.',
         'ERROR_GOPHER_ATTRIBUTE_NOT_FOUND - The requested attribute could not be located.',
         'ERROR_GOPHER_UNKNOWN_LOCATOR - The locator type is unknown.',
         'ERROR_HTTP_HEADER_NOT_FOUND - The requested header could not be located.',
         'ERROR_HTTP_DOWNLEVEL_SERVER - The server did not return any headers.',
         'ERROR_HTTP_INVALID_SERVER_RESPONSE - The server response could not be parsed.',
         'ERROR_HTTP_INVALID_HEADER - The supplied header is invalid.',
         'ERROR_HTTP_INVALID_QUERY_REQUEST - The request made to HttpQueryInfo is invalid.',
         'ERROR_HTTP_HEADER_ALREADY_EXISTS - The header could not be added because it already exists.',
         'ERROR_HTTP_REDIRECT_FAILED - The redirection failed because either the scheme changed (for example, HTTP to FTP) or all attempts made to redirect failed (default is five attempts).');
var
   iErro, i: Integer;
begin
   iErro := GetLastError;
   if (iErro >= 12001) and (iErro <= 12171) then
   begin
      i := 0;
      while (i < Length(iCodErro)) do
      begin
         FErro := iCodErro[i] = iErro;
         if FErro then
         begin
            UpdateStatus('<<< '+IntToStr(iCodErro[i])+' - '+sDescErro[i]+' >>>');
            Break;
         end;
         i := i + 1;
      end;
      if not FErro then
      begin
         UpdateStatus('<<< '+IntToStr(iErro)+' - ERRO NÃO PREVISTO - Por favor, verifique o código do erro. >>>');
         FErro := True;
      end;
   end;
end;

procedure TMHttpGetResume.UpdateConcluido;
begin
   if (FBaixando) and (not FErro) then
   begin
      UpdateStatus('Download concluído com sucesso!');
      FBaixando := False;
   end
   else if (not FBaixando) and (not FErro) then
      UpdateStatus('Download já efetuado e concluído com sucesso!');
   if Assigned(FConcluido) then
      FConcluido(Self);
end;

end.