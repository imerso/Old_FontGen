// ----------------------------------------------------------------------------
//
// Texture Font Generator 1.0 - ©2002, Vander Nunes / Virtware.net
//
// ----------------------------------------------------------------------------
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

const
     SIG = 'TNYF';

type
  TMainForm = class(TForm)
    imgFont: TImage;
    lblSize: TLabel;
    dlgSaveFont: TSaveDialog;
    panCharSet: TPanel;
    edtCharset: TEdit;
    Label3: TLabel;
    Panel1: TPanel;
    listFontList: TListBox;
    panTools: TPanel;
    Label2: TLabel;
    spdBold: TSpeedButton;
    spdItalic: TSpeedButton;
    spdUnderline: TSpeedButton;
    comboRes: TComboBox;
    butSave: TButton;
    chkOutline: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure comboResChange(Sender: TObject);
    procedure listFontListClick(Sender: TObject);
    procedure spdBoldClick(Sender: TObject);
    procedure spdItalicClick(Sender: TObject);
    procedure spdUnderlineClick(Sender: TObject);
    procedure butSaveClick(Sender: TObject);
    procedure panCharSetResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    imgWidth, imgHeight : Integer;
    ui,vi  : Array[0..255] of Single;    // upper-left uv for each char
    uf,vf  : Array[0..255] of Single;    // bottom-right uv for each char
    cw,ch  : Array[0..255] of Word;      // width and height for each char

    procedure UpdateImgRes;
    procedure genFont;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  listFontList.Items.Assign(Screen.Fonts);
  comboRes.ItemIndex := 3;
  UpdateImgRes();
end;

procedure TMainForm.UpdateImgRes;
var
   resIdx : Integer;
   resStr: String;
   cpyStr: array[0..10] of Char;
   xPos   : PChar;
   iPos   : Integer;
   Bitmap : TBitmap;
begin
  resIdx  := comboRes.ItemIndex;
  resStr  := comboRes.Items[resIdx];
  xPos    := StrPos(PChar(resStr),'x');
  if (xPos <> Nil) then
  begin
    inc(xPos);
    iPos := xPos - PChar(resStr);
    strLcopy(cpyStr,PChar(resStr)+iPos, StrLen(PChar(resStr)) - iPos );
    resStr[iPos] := #0;

    imgWidth := StrToInt(resStr);
    imgHeight := StrToInt(cpyStr);

    Bitmap := TBitmap.Create;
    Bitmap.Canvas.Brush.Color := $FF0000;
    Bitmap.PixelFormat := pf24Bit;
    Bitmap.Monochrome := false;
    Bitmap.HandleType := bmDIB;
    BitMap.Width := imgWidth;
    Bitmap.Height := imgHeight;

    imgFont.Picture.Bitmap.Assign(Bitmap);

    Bitmap.Free;
  end;
end;


procedure TMainForm.comboResChange(Sender: TObject);
begin
  UpdateImgRes;
  if (listFontList.ItemIndex > -1) then genFont;
end;


procedure TMainForm.genFont;
var
   size : Integer;
   px,py: Integer;
   w,h  : Integer;
   ok   : Boolean;
   oops : Boolean;
   c    : Integer;
begin
   // start with a reasonable size
   size := Round(imgFont.Picture.Height / sqrt(Length(edtCharset.Text)));

   imgFont.Visible := false;
   lblSize.Visible := true;
   edtCharset.Enabled := false;
   butSave.Enabled := false;
   spdBold.Enabled := false;
   spdItalic.Enabled := false;
   spdUnderline.Enabled := false;

   oops := false;
   ok := false;

   imgFont.Canvas.Font.Name := listFontList.Items[listFontList.ItemIndex];

   if (spdBold.Down) then
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style + [fsBold]
   else
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style - [fsBold];

   if (spdItalic.Down) then
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style + [fsItalic]
   else
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style - [fsItalic];

   if (spdUnderline.Down) then
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style + [fsUnderline]
   else
     imgFont.Canvas.Font.Style := imgFont.Canvas.Font.Style - [fsUnderline];

   imgFont.Canvas.Brush.Style := bsClear;

   while (not ok) do
   begin
     lblSize.Caption := IntToStr(size);
     ok := true;
     updateImgRes;
     px := 0;
     py := 0;
     c  := 1;
     imgFont.Canvas.Font.Height := size;
     while (c <= Length(edtCharset.Text)) do
     begin
       Application.ProcessMessages;

       w := imgFont.Canvas.TextWidth(edtCharset.Text[c])+1;
       h := imgFont.Canvas.TextHeight(edtCharset.Text[c])+1;

       if (py + h >= imgFont.Picture.Height) then
         ok := false;

       if (px + w >= imgFont.Picture.Width) then
       begin
         py := py + h + 1;
         px := 0;
       end;

       if (chkOutline.checked) then
       begin
         imgFont.Canvas.Font.Color := clBlack;
         imgFont.Canvas.TextOut(px-1,py-1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px,py-1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px+1,py-1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px+1,py,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px+1,py+1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px,py+1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px-1,py+1,edtCharset.Text[c]);
         imgFont.Canvas.TextOut(px-1,py,edtCharset.Text[c]);
       end;

       imgFont.Canvas.Font.Color := clWhite;
       imgFont.Canvas.TextOut(px,py,edtCharset.Text[c]);

       cw[c-1] := w;
       ch[c-1] := h;

       ui[c-1] := px / imgFont.Picture.Width;
       vi[c-1] := py / imgFont.Picture.Height;

       uf[c-1] := (px+w) / imgFont.Picture.Width;
       vf[c-1] := (py+h) / imgFont.Picture.Height;

       px := px + w + 1;
       inc(c);
     end;

     if (not ok) then
     begin
       if (size > 2) then
       begin
         size := Round(size - 1);
         oops := true
       end else begin
         ok := true;
       end;
     end else begin
       if (py < (imgFont.Picture.Height)) and not oops then
       begin
         size := Round(size + 1);
         ok := false
       end;
     end;
   end;

   spdUnderline.Enabled := true;
   spdItalic.Enabled := true;
   spdBold.Enabled := true;
   butSave.Enabled := true;
   edtCharset.Enabled := true;
   lblSize.Visible := false;
   imgFont.Visible := true;
end;


procedure TMainForm.listFontListClick(Sender: TObject);
begin
  genFont;
end;

procedure TMainForm.spdBoldClick(Sender: TObject);
begin
  if (listFontList.ItemIndex > -1) then genFont;
end;

procedure TMainForm.spdItalicClick(Sender: TObject);
begin
  if (listFontList.ItemIndex > -1) then genFont;
end;

procedure TMainForm.spdUnderlineClick(Sender: TObject);
begin
  if (listFontList.ItemIndex > -1) then genFont;
end;

procedure TMainForm.butSaveClick(Sender: TObject);
var
   fileName: String;
   bmpName : String;
   f       : Integer;
   c       : Integer;
   uii,vii : WORD;
   ufi,vfi : WORD;
   nc      : BYTE;
begin
  if (dlgSaveFont.Execute) then
  begin

    // ---------------------------------------------------------------------
    // Filename request dialog
    // ---------------------------------------------------------------------
    fileName := dlgSaveFont.FileName;

    if (StrPos(PChar(fileName), '.') = Nil) then
      fileName := fileName + '.fon';
    // ---------------------------------------------------------------------


    // ---------------------------------------------------------------------
    // save bmp
    // ---------------------------------------------------------------------
    bmpName := fileName;
    bmpName[StrLen(PChar(bmpName))-2] := 'b';
    bmpName[StrLen(PChar(bmpName))-1] := 'm';
    bmpName[StrLen(PChar(bmpName))-0] := 'p';

    imgFont.Picture.SaveToFile(bmpName);
    // ---------------------------------------------------------------------


    // ---------------------------------------------------------------------
    // save fon
    // ---------------------------------------------------------------------
    f := FileCreate(fileName);
    if (f < 1) then exit;

    // write file signature
    for c := 1 to Length(SIG) do
    begin
      nc := ord(SIG[c]);
      FileWrite(f, nc, 1);
    end;

    // number of chars on the file
    // BYTE
    nc := Length(edtCharset.Text);
    FileWrite(f, nc, 1);

    // list ASCII of each char on the file
    // BYTE
    for c := 1 to nc do
    begin
      nc := ord(edtCharset.Text[c]);
      FileWrite(f, nc, 1);
    end;

    // write width, height and uv coordinates of each character
    // WORD
    for c := 1 to nc do
    begin
      // width
      FileWrite(f, cw[c-1], 2);

      // height
      FileWrite(f, ch[c-1], 2);

      // initial uv
      uii := Round(ui[c-1] * 65535);
      vii := Round(vi[c-1] * 65535);
      FileWrite(f, uii, 2);
      FileWrite(f, vii, 2);
      // final uv
      ufi := Round(uf[c-1] * 65535);
      vfi := Round(vf[c-1] * 65535);
      FileWrite(f, ufi, 2);
      FileWrite(f, vfi, 2);
    end;
    FileClose(f);
    // ---------------------------------------------------------------------

  end;
end;

procedure TMainForm.panCharSetResize(Sender: TObject);
begin
  edtCharset.Width := panCharSet.Width - 22;
end;

end.

