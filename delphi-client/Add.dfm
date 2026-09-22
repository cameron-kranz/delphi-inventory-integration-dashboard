object AddEditItem: TAddEditItem
  Left = 0
  Top = 0
  Caption = 'AddEditItem'
  ClientHeight = 218
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 13
    Top = 12
    Width = 24
    Height = 15
    Caption = 'SKU:'
  end
  object Label2: TLabel
    Left = 13
    Top = 41
    Width = 35
    Height = 15
    Caption = 'Name:'
  end
  object Label3: TLabel
    Left = 13
    Top = 70
    Width = 51
    Height = 15
    Caption = 'Category:'
  end
  object Label4: TLabel
    Left = 13
    Top = 99
    Width = 49
    Height = 15
    Caption = 'Quantity:'
  end
  object Label5: TLabel
    Left = 13
    Top = 128
    Width = 54
    Height = 15
    Caption = 'Unit Price:'
  end
  object Label6: TLabel
    Left = 13
    Top = 157
    Width = 46
    Height = 15
    Caption = 'Supplier:'
  end
  object SkuEdit: TEdit
    Left = 73
    Top = 8
    Width = 121
    Height = 23
    TabOrder = 0
    Text = 'SkuEdit'
  end
  object OKButton: TButton
    Left = 119
    Top = 185
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object CancelButton: TButton
    Left = 38
    Top = 185
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object NameEdit: TEdit
    Left = 73
    Top = 37
    Width = 121
    Height = 23
    TabOrder = 3
    Text = 'NameEdit'
  end
  object CategoryEdit: TEdit
    Left = 73
    Top = 66
    Width = 121
    Height = 23
    TabOrder = 4
    Text = 'CategoryEdit'
  end
  object QuantityEdit: TEdit
    Left = 73
    Top = 95
    Width = 121
    Height = 23
    TabOrder = 5
    Text = 'QuantityEdit'
  end
  object UnitPriceEdit: TEdit
    Left = 73
    Top = 124
    Width = 121
    Height = 23
    TabOrder = 6
    Text = 'UnitPriceEdit'
  end
  object SupplierEdit: TEdit
    Left = 73
    Top = 153
    Width = 121
    Height = 23
    TabOrder = 7
    Text = 'SupplierEdit'
  end
end
