object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object InventoryGrid: TStringGrid
    Left = 0
    Top = 37
    Width = 616
    Height = 404
    ColCount = 7
    RowCount = 2
    TabOrder = 0
  end
  object SearchEdit: TEdit
    Left = 0
    Top = 8
    Width = 113
    Height = 23
    TabOrder = 1
    Text = 'SearchEdit'
  end
  object SearchButton: TButton
    Left = 119
    Top = 8
    Width = 66
    Height = 25
    Caption = 'Search'
    TabOrder = 2
    OnClick = SearchButtonClick
  end
  object AddButton: TButton
    Left = 191
    Top = 8
    Width = 66
    Height = 25
    Caption = 'Add'
    TabOrder = 3
    OnClick = AddButtonClick
  end
  object EditButton: TButton
    Left = 263
    Top = 8
    Width = 66
    Height = 25
    Caption = 'Edit'
    TabOrder = 4
    OnClick = EditButtonClick
  end
  object DeleteButton: TButton
    Left = 335
    Top = 8
    Width = 66
    Height = 25
    Caption = 'Delete'
    TabOrder = 5
    OnClick = DeleteButtonClick
  end
  object RefreshButton: TButton
    Left = 407
    Top = 8
    Width = 74
    Height = 25
    Caption = 'Refresh'
    TabOrder = 6
    OnClick = RefreshButtonClick
  end
  object ImportButton: TButton
    Left = 487
    Top = 8
    Width = 66
    Height = 25
    Caption = 'Import CSV'
    TabOrder = 7
    OnClick = ImportButtonClick
  end
  object ExportButton: TButton
    Left = 559
    Top = 7
    Width = 65
    Height = 25
    Caption = 'Export CSV'
    TabOrder = 8
    OnClick = ExportButtonClick
  end
  object HttpClient: TNetHTTPClient
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 40
    Top = 384
  end
  object SaveCSVDialog: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV Files|*.csv'
    Left = 112
    Top = 384
  end
  object OpenCSVDialog: TOpenDialog
    Filter = 'CSV Files|*.csv'
    Left = 184
    Top = 384
  end
end
