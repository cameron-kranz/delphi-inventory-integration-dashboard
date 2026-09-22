unit Add;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TAddEditItem = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SkuEdit: TEdit;
    OKButton: TButton;
    CancelButton: TButton;
    NameEdit: TEdit;
    CategoryEdit: TEdit;
    QuantityEdit: TEdit;
    UnitPriceEdit: TEdit;
    SupplierEdit: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddEditItem: TAddEditItem;

implementation

{$R *.dfm}

end.
