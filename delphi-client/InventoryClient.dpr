program InventoryClient;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form2},
  Add in 'Add.pas' {AddEditItem};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TAddEditItem, AddEditItem);
  Application.Run;
end.
