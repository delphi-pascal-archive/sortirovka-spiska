////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : ?????? "?????????? ?????? ?? ??????? "?????????? Windows""
//  * Details   : http://alexander-bagel.blogspot.ru/2013/06/windows.html
//  * Unit Name : Unit1
//  * Purpose   : ?????????? ????????? ??????????
//  * Author    : ????????? (Rouse_) ??????
//  * Version   : 1.0
//  * Home Page : http://rouse.drkb.ru
//  * Home Blog : http://alexander-bagel.blogspot.com/
//  ****************************************************************************
//


unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    Button2: TButton;
    ImageList1: TImageList;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  // ?????????? ????????? ??????????? DefaultListViewSort
  ListView1.SortType := stNone;
  ListView1.CustomSort(nil, 0);
end;

//
// CompareStringOrdinal ?????????? ??? ?????? ?? ??????? ??????????, ?.?.
// "????? ????? (3)" < "????? ????? (103)"
//
// ?????????? ????????? ????????
// -1     - ?????? ?????? ?????? ??????
// 0      - ?????? ????????????
// 1      - ?????? ?????? ?????? ??????
// =============================================================================
function CompareStringOrdinal(const S1, S2: string): Integer;

  // ??????? CharInSet ????????? ??????? ? Delphi 2009,
  // ??? ????? ?????? ?????? ????????? ?? ??????
  function CharInSet(AChar: Char; ASet: TSysCharSet): Boolean;
  begin
    Result := AChar in ASet;
  end;

var
  S1IsInt, S2IsInt: Boolean;
  S1Cursor, S2Cursor: PChar;
  S1Int, S2Int, Counter, S1IntCount, S2IntCount: Integer;
  SingleByte: Byte;
begin
  // ???????? ?? ?????? ??????
  if S1 = '' then
    if S2 = '' then
    begin
      Result := 0;
      Exit;
    end
    else
    begin
      Result := -1;
      Exit;
    end;

  if S2 = '' then
  begin
    Result := 1;
    Exit;
  end;

  S1Cursor := @AnsiLowerCase(S1)[1];
  S2Cursor := @AnsiLowerCase(S2)[1];

  while True do
  begin
    // ???????? ?? ????? ?????? ??????
    if S1Cursor^ = #0 then
      if S2Cursor^ = #0 then
      begin
        Result := 0;
        Exit;
      end
      else
      begin
        Result := -1;
        Exit;
      end;

    // ???????? ?? ????? ?????? ??????
    if S2Cursor^ = #0 then
    begin
      Result := 1;
      Exit;
    end;

    // ???????? ?? ?????? ????? ? ????? ???????
    S1IsInt := CharInSet(S1Cursor^, ['0'..'9']);
    S2IsInt := CharInSet(S2Cursor^, ['0'..'9']);
    if S1IsInt and not S2IsInt then
    begin
      Result := -1;
      Exit;
    end;
    if not S1IsInt and S2IsInt then
    begin
      Result := 1;
      Exit;
    end;

    // ???????????? ?????????
    if not (S1IsInt and S2IsInt) then
    begin
      if S1Cursor^ = S2Cursor^ then
      begin
        Inc(S1Cursor);
        Inc(S2Cursor);
        Continue;
      end;
      if S1Cursor^ < S2Cursor^ then
      begin
        Result := -1;
        Exit;
      end
      else
      begin
        Result := 1;
        Exit;
      end;
    end;

    // ??????????? ????? ?? ????? ????? ? ??????????
    S1Int := 0;
    Counter := 1;
    S1IntCount := 0;
    repeat
      Inc(S1IntCount);
      SingleByte := Byte(S1Cursor^) - Byte('0');
      S1Int := S1Int * Counter + SingleByte;
      Inc(S1Cursor);
      Counter := 10;
    until not CharInSet(S1Cursor^, ['0'..'9']);

    S2Int := 0;
    Counter := 1;
    S2IntCount := 0;
    repeat
      SingleByte := Byte(S2Cursor^) - Byte('0');
      Inc(S2IntCount);
      S2Int := S2Int * Counter + SingleByte;
      Inc(S2Cursor);
      Counter := 10;
    until not CharInSet(S2Cursor^, ['0'..'9']);

    if S1Int = S2Int then
    begin
      if S1Int = 0 then
      begin
        if S1IntCount < S2IntCount then
        begin
          Result := -1;
          Exit;
        end;
        if S1IntCount > S2IntCount then
        begin
          Result := 1;
          Exit;
        end;
      end;
      Continue;
    end;
    if S1Int < S2Int then
    begin
      Result := -1;
      Exit;
    end
    else
    begin
      Result := 1;
      Exit;
    end;
  end;
end;

function LVCompare(lParam1, lParam2, lParamSort: Integer): Integer stdcall;
begin
  Result := CompareStringOrdinal(TListItem(lParam1).Caption, TListItem(lParam2).Caption);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // ?????????? ? ?????????????? CompareStringOrdinal
  ListView1.SortType := stNone;
  ListView1.CustomSort(@LVCompare, 0);
end;

function StrCmpLogicalW(psz1, psz2: PWideChar): Integer; stdcall; external 'Shlwapi.dll';

function LVCompareEx(lParam1, lParam2, lParamSort: Integer): Integer stdcall;
var
  S1, S2: WideString;
begin
  S1 := TListItem(lParam1).Caption;
  S2 := TListItem(lParam2).Caption;
  Result := StrCmpLogicalW(PWideChar(S1), PWideChar(S2));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // ?????????? ? ?????????????? StrCmpLogicalW
  ListView1.SortType := stNone;
  ListView1.CustomSort(@LVCompareEx, 0);
end;

end.
