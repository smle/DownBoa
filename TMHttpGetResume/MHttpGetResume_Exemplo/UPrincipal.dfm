object FrmMHttpGetResumeExemplo: TFrmMHttpGetResumeExemplo
  Left = 192
  Top = 114
  Width = 669
  Height = 465
  Caption = 'Exemplo de utiliza'#231#227'o do MHttpGetResume'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LblTempoDecorrido: TLabel
    Left = 149
    Top = 6
    Width = 50
    Height = 13
    Caption = '00:00:00 s'
  end
  object LblTempoRestante: TLabel
    Left = 149
    Top = 30
    Width = 50
    Height = 13
    Caption = '00:00:00 s'
  end
  object LblRecebido: TLabel
    Left = 149
    Top = 94
    Width = 23
    Height = 13
    Caption = '0 KB'
  end
  object LblTaxaTransf: TLabel
    Left = 149
    Top = 142
    Width = 33
    Height = 13
    Caption = '0 KB/s'
  end
  object LblTotal: TLabel
    Left = 149
    Top = 70
    Width = 23
    Height = 13
    Caption = '0 KB'
  end
  object LblRestante: TLabel
    Left = 149
    Top = 118
    Width = 23
    Height = 13
    Caption = '0 KB'
  end
  object LblTempoAutoRecon: TLabel
    Left = 149
    Top = 240
    Width = 14
    Height = 13
    Caption = '0 s'
  end
  object LblNumAutoRecon: TLabel
    Left = 149
    Top = 216
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label1: TLabel
    Left = 29
    Top = 70
    Width = 112
    Height = 13
    Caption = 'Tamanho do download:'
  end
  object Label2: TLabel
    Left = 58
    Top = 6
    Width = 83
    Height = 13
    Caption = 'Tempo decorrido:'
  end
  object Label3: TLabel
    Left = 64
    Top = 30
    Width = 77
    Height = 13
    Caption = 'Tempo restante:'
  end
  object Label4: TLabel
    Left = 92
    Top = 94
    Width = 49
    Height = 13
    Caption = 'Recebido:'
  end
  object Label5: TLabel
    Left = 95
    Top = 118
    Width = 46
    Height = 13
    Caption = 'Restante:'
  end
  object Label6: TLabel
    Left = 35
    Top = 142
    Width = 106
    Height = 13
    Caption = 'Taxa de transfer'#234'ncia:'
  end
  object Label7: TLabel
    Left = 8
    Top = 216
    Width = 133
    Height = 13
    Caption = 'Auto reconex'#245'es realizadas:'
  end
  object Label8: TLabel
    Left = 3
    Top = 240
    Width = 138
    Height = 13
    Caption = 'Tempo para auto reconectar:'
  end
  object Label9: TLabel
    Left = 7
    Top = 271
    Width = 25
    Height = 13
    Caption = 'URL:'
  end
  object Label10: TLabel
    Left = 7
    Top = 319
    Width = 50
    Height = 13
    Caption = 'Salvar em:'
  end
  object PB: TProgressBar
    Left = 0
    Top = 414
    Width = 661
    Height = 17
    Align = alBottom
    TabOrder = 5
  end
  object MemStatus: TMemo
    Left = 376
    Top = 0
    Width = 285
    Height = 368
    Align = alRight
    ReadOnly = True
    TabOrder = 4
    OnChange = MemStatusChange
  end
  object EdtURL: TEdit
    Left = 4
    Top = 286
    Width = 365
    Height = 21
    TabOrder = 2
    Text = 'http://www.7-zip.org/alpha/7z458a6.exe'
  end
  object PnlBotoes: TPanel
    Left = 0
    Top = 368
    Width = 661
    Height = 46
    Align = alBottom
    TabOrder = 6
    object BtnDownload: TButton
      Left = 232
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Download'
      TabOrder = 0
      OnClick = BtnDownloadClick
    end
    object BtnSair: TButton
      Left = 344
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Sair'
      TabOrder = 1
      OnClick = BtnSairClick
    end
  end
  object CBAutoRecon: TCheckBox
    Left = 61
    Top = 184
    Width = 113
    Height = 17
    Caption = 'Auto reconectar'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object CBLog: TCheckBox
    Left = 301
    Top = 5
    Width = 70
    Height = 17
    Caption = 'Salvar log'
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object EdtArquivoLocal: TEdit
    Left = 4
    Top = 334
    Width = 365
    Height = 21
    TabOrder = 3
    Text = 'C:\7zip.exe'
  end
  object http: TMHttpGetResume
    MPorta = 80
    MPortaProxy = 3128
    MArquivoLocal = 'C:\teste.exe'
    MBaixando = False
    MAutoReconectar = True
    MTempoAutoReconectar = 10
    MVezesAutoReconectar = 3
    MProgressBar = PB
    MLblTotal = LblTotal
    MLblRecebido = LblRecebido
    MLblRestante = LblRestante
    MLblTaxaTransferencia = LblTaxaTransf
    MLblTempoRestante = LblTempoRestante
    MLblTempoDecorrido = LblTempoDecorrido
    MLblTempoAutoRecon = LblTempoAutoRecon
    MLblNumAutoRecon = LblNumAutoRecon
    MOnProgress = httpMOnProgress
    MOnConcluido = httpMOnConcluido
    MOnStatus = httpMOnStatus
    Left = 304
    Top = 72
  end
end
