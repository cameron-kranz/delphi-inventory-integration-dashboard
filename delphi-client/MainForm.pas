unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.JSON, System.NetEncoding, System.Net.Mime, Add;

type
  TForm2 = class(TForm)
    InventoryGrid: TStringGrid;
    SearchEdit: TEdit;
    SearchButton: TButton;
    AddButton: TButton;
    EditButton: TButton;
    DeleteButton: TButton;
    RefreshButton: TButton;
    ImportButton: TButton;
    ExportButton: TButton;
    HttpClient: TNetHTTPClient;
    SaveCSVDialog: TSaveDialog;
    OpenCSVDialog: TOpenDialog;
    procedure RefreshButtonClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
  private
    procedure LoadInventory(const URL: string);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.AddButtonClick(Sender: TObject);
var
  JSONBody: TJSONObject;
  Response: IHTTPResponse;
begin
  AddEditItem.SkuEdit.Text := '';
  AddEditItem.NameEdit.Text := '';
  AddEditItem.CategoryEdit.Text := '';
  AddEditItem.QuantityEdit.Text := '';
  AddEditItem.UnitPriceEdit.Text := '';
  AddEditItem.SupplierEdit.Text := '';

  if AddEditItem.ShowModal = mrOk then
  begin
    JSONBody := TJSONObject.Create;
    JSONBody.AddPair('sku', AddEditItem.SkuEdit.Text);
    JSONBody.AddPair('name', AddEditItem.NameEdit.Text);
    JSONBody.AddPair('category', AddEditItem.CategoryEdit.Text);
    JSONBody.AddPair('quantity', TJSONNumber.Create(StrToIntDef(AddEditItem.QuantityEdit.Text, 0)));
    JSONBody.AddPair('unit_price', TJSONNumber.Create(StrToFloatDef(AddEditItem.UnitPriceEdit.Text, 0)));
    JSONBody.AddPair('supplier', AddEditItem.SupplierEdit.Text);

    try
      Response := HttpClient.Post(
        'http://localhost:3000/api/inventory',
        TStringStream.Create(JSONBody.ToJSON, TEncoding.UTF8),
        nil,
        [TNetHeader.Create('Content-Type', 'application/json')]
      );
    except
      on E: Exception do
      begin
        JSONBody.Free;
        ShowMessage('Could not connect to the server: ' + E.Message);
        Exit;
      end;
    end;

    JSONBody.Free;

    if Response.StatusCode = 201 then
      LoadInventory('http://localhost:3000/api/inventory')
    else
      ShowMessage('Failed to add item: ' + Response.ContentAsString);
  end;
end;

procedure TForm2.DeleteButtonClick(Sender: TObject);
var
  SelectedRow: Integer;
  ItemId: string;
  ItemName: string;
  Response: IHTTPResponse;
begin
  SelectedRow := InventoryGrid.Row;

  if SelectedRow = 0 then
  begin
    ShowMessage('Please select an item first.');
    Exit;
  end;

  ItemId := InventoryGrid.Cells[0, SelectedRow];
  ItemName := InventoryGrid.Cells[2, SelectedRow];

  if MessageDlg('Delete "' + ItemName + '"? This cannot be undone.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      Response := HttpClient.Delete('http://localhost:3000/api/inventory/' + ItemId);
    except
      on E: Exception do
      begin
        ShowMessage('Could not connect to the server: ' + E.Message);
        Exit;
      end;
    end;

    if Response.StatusCode = 204 then
      LoadInventory('http://localhost:3000/api/inventory')
    else
      ShowMessage('Failed to delete item: ' + Response.ContentAsString);
  end;
end;

procedure TForm2.EditButtonClick(Sender: TObject);
var
  SelectedRow: Integer;
  ItemId: string;
  JSONBody: TJSONObject;
  Response: IHTTPResponse;
begin
  SelectedRow := InventoryGrid.Row;

  if SelectedRow = 0 then
  begin
    ShowMessage('Please select an item first.');
    Exit;
  end;

  ItemId := InventoryGrid.Cells[0, SelectedRow];

  AddEditItem.SkuEdit.Text := InventoryGrid.Cells[1, SelectedRow];
  AddEditItem.NameEdit.Text := InventoryGrid.Cells[2, SelectedRow];
  AddEditItem.CategoryEdit.Text := InventoryGrid.Cells[3, SelectedRow];
  AddEditItem.QuantityEdit.Text := InventoryGrid.Cells[4, SelectedRow];
  AddEditItem.UnitPriceEdit.Text := InventoryGrid.Cells[5, SelectedRow];
  AddEditItem.SupplierEdit.Text := InventoryGrid.Cells[6, SelectedRow];

  if AddEditItem.ShowModal = mrOk then
  begin
    JSONBody := TJSONObject.Create;
    JSONBody.AddPair('sku', AddEditItem.SkuEdit.Text);
    JSONBody.AddPair('name', AddEditItem.NameEdit.Text);
    JSONBody.AddPair('category', AddEditItem.CategoryEdit.Text);
    JSONBody.AddPair('quantity', TJSONNumber.Create(StrToIntDef(AddEditItem.QuantityEdit.Text, 0)));
    JSONBody.AddPair('unit_price', TJSONNumber.Create(StrToFloatDef(AddEditItem.UnitPriceEdit.Text, 0)));
    JSONBody.AddPair('supplier', AddEditItem.SupplierEdit.Text);

        try
      Response := HttpClient.Put(
        'http://localhost:3000/api/inventory/' + ItemId,
        TStringStream.Create(JSONBody.ToJSON, TEncoding.UTF8),
        nil,
        [TNetHeader.Create('Content-Type', 'application/json')]
      );
    except
      on E: Exception do
      begin
        JSONBody.Free;
        ShowMessage('Could not connect to the server: ' + E.Message);
        Exit;
      end;
    end;

    JSONBody.Free;

    if Response.StatusCode = 200 then
      LoadInventory('http://localhost:3000/api/inventory')
    else
      ShowMessage('Failed to update item: ' + Response.ContentAsString);
  end;
end;

procedure TForm2.ExportButtonClick(Sender: TObject);
var
  Response: IHTTPResponse;
  CSVText: TStringList;
begin
  if SaveCSVDialog.Execute then
  begin
    try
      Response := HttpClient.Get('http://localhost:3000/api/inventory/export');
    except
      on E: Exception do
      begin
        ShowMessage('Could not connect to the server: ' + E.Message);
        Exit;
      end;
    end;

    if Response.StatusCode = 200 then
    begin
      CSVText := TStringList.Create;
      CSVText.Text := Response.ContentAsString;
      CSVText.SaveToFile(SaveCSVDialog.FileName);
      CSVText.Free;
      ShowMessage('Exported successfully to ' + SaveCSVDialog.FileName);
    end
    else
      ShowMessage('Export failed: ' + Response.ContentAsString);
  end;
end;

procedure TForm2.ImportButtonClick(Sender: TObject);
var
  Response: IHTTPResponse;
  FormData: TMultipartFormData;
begin
  if OpenCSVDialog.Execute then
  begin
       FormData := TMultipartFormData.Create;
    try
      FormData.AddFile('file', OpenCSVDialog.FileName);

      try
        Response := HttpClient.Post('http://localhost:3000/api/inventory/import', FormData);
      except
        on E: Exception do
        begin
          ShowMessage('Could not connect to the server: ' + E.Message);
          Exit;
        end;
      end;

      if Response.StatusCode = 200 then
      begin
        ShowMessage('Import complete: ' + Response.ContentAsString);
        LoadInventory('http://localhost:3000/api/inventory');
      end
      else
        ShowMessage('Import failed: ' + Response.ContentAsString);
    finally
      FormData.Free;
    end;
  end;
end;

procedure TForm2.LoadInventory(const URL: string);
var
  Response: IHTTPResponse;
  JSONValue: TJSONValue;
  JSONArray: TJSONArray;
  Item: TJSONValue;
  Row: TJSONObject;
  i: Integer;
begin
  InventoryGrid.Cells[0, 0] := 'ID';
  InventoryGrid.Cells[1, 0] := 'SKU';
  InventoryGrid.Cells[2, 0] := 'Name';
  InventoryGrid.Cells[3, 0] := 'Category';
  InventoryGrid.Cells[4, 0] := 'Quantity';
  InventoryGrid.Cells[5, 0] := 'Unit Price';
  InventoryGrid.Cells[6, 0] := 'Supplier';

  try
    Response := HttpClient.Get(URL);
  except
    on E: Exception do
    begin
      ShowMessage('Could not connect to the server. Please make sure the API is running.' +
                  sLineBreak + 'Details: ' + E.Message);
      Exit;
    end;
  end;

  JSONValue := TJSONObject.ParseJSONValue(Response.ContentAsString);

  if JSONValue is TJSONArray then
  begin
    JSONArray := JSONValue as TJSONArray;
    InventoryGrid.RowCount := JSONArray.Count + 1;

    for i := 0 to JSONArray.Count - 1 do
    begin
      Item := JSONArray.Items[i];
      Row := Item as TJSONObject;

      InventoryGrid.Cells[0, i + 1] := Row.GetValue('id').Value;
      InventoryGrid.Cells[1, i + 1] := Row.GetValue('sku').Value;
      InventoryGrid.Cells[2, i + 1] := Row.GetValue('name').Value;
      InventoryGrid.Cells[3, i + 1] := Row.GetValue('category').Value;
      InventoryGrid.Cells[4, i + 1] := Row.GetValue('quantity').Value;
      InventoryGrid.Cells[5, i + 1] := Row.GetValue('unit_price').Value;
      InventoryGrid.Cells[6, i + 1] := Row.GetValue('supplier').Value;
    end;
  end;

  JSONValue.Free;
end;

procedure TForm2.RefreshButtonClick(Sender: TObject);
begin
  LoadInventory('http://localhost:3000/api/inventory');
end;

procedure TForm2.SearchButtonClick(Sender: TObject);
begin
  LoadInventory('http://localhost:3000/api/inventory?search=' + TNetEncoding.URL.Encode(SearchEdit.Text));
end;

end.
