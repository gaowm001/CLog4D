object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 279
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LabelFileName: TLabel
    Left = 18
    Top = 112
    Width = 40
    Height = 13
    Caption = 'filename'
    Color = clBtnFace
    ParentColor = False
  end
  object LabelLevel: TLabel
    Left = 18
    Top = 75
    Width = 22
    Height = 13
    Caption = 'level'
    Color = clBtnFace
    ParentColor = False
  end
  object LabelLog: TLabel
    Left = 18
    Top = 32
    Width = 14
    Height = 13
    Caption = 'log'
    Color = clBtnFace
    ParentColor = False
  end
  object EditFileName: TEdit
    Left = 76
    Top = 104
    Width = 80
    Height = 21
    TabOrder = 0
  end
  object ComboBoxLevel: TComboBox
    Left = 64
    Top = 72
    Width = 100
    Height = 23
    Style = csOwnerDrawVariable
    ItemHeight = 17
    ItemIndex = 1
    TabOrder = 1
    Text = 'INFO'
    Items.Strings = (
      'DEBUG'
      'INFO'
      'WARN'
      'ERROR'
      'FATAL')
  end
  object EditLog: TEdit
    Left = 64
    Top = 32
    Width = 98
    Height = 21
    TabOrder = 2
    Text = 'Hello'
  end
  object MemoLog: TMemo
    Left = 184
    Top = 32
    Width = 206
    Height = 179
    Lines.Strings = (
      'MemoLog')
    TabOrder = 3
  end
  object ButtonWrite: TButton
    Left = 32
    Top = 233
    Width = 75
    Height = 25
    Caption = 'WriteLog'
    TabOrder = 4
    OnClick = ButtonWriteClick
  end
  object ButtonWriteThread: TButton
    Left = 144
    Top = 233
    Width = 120
    Height = 25
    Caption = 'WriteLogThread'
    TabOrder = 5
    OnClick = ButtonWriteThreadClick
  end
  object CheckBoxBefore: TCheckBox
    Left = 32
    Top = 155
    Width = 97
    Height = 17
    Caption = 'Before'
    TabOrder = 6
    OnClick = CheckBoxBeforeClick
  end
  object CheckBoxAfter: TCheckBox
    Left = 32
    Top = 194
    Width = 97
    Height = 17
    Caption = 'After'
    TabOrder = 7
    OnClick = CheckBoxAfterClick
  end
end
