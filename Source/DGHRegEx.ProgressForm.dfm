object frmProgress: TfrmProgress
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 67
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 444
    Height = 67
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    DesignSize = (
      444
      67)
    object lblInfo: TLabel
      Left = 8
      Top = 11
      Width = 425
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lblInfo'
    end
    object RzProgressBar: TProgressBar
      Left = 8
      Top = 30
      Width = 425
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      BarColor = clHighlight
      TabOrder = 0
    end
  end
end
