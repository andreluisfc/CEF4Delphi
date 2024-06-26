unit uCEFArgCopy;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

{$I cef.inc}


interface

uses
  {$IFDEF DELPHI16_UP}
    System.Classes, System.SysUtils, System.AnsiStrings;
  {$ELSE}
    Classes, SysUtils;
  {$ENDIF}

type
  {$IFNDEF DELPHI7_UP}
  PPAnsiChar    = Array of PChar;
  {$ENDIF}

  TCEFArgCopy = class
    protected
      FArgCCopy : longint;
      FArgVCopy : PPAnsiChar;

      procedure InitializeFields;
      procedure DestroyFields;

    public
      constructor Create;
      destructor  Destroy; override;
      procedure   CopyFromArgs(aArgc : longint; aArgv : PPAnsiChar);

      property argc : longint     read FArgCCopy;
      property argv : PPAnsiChar  read FArgVCopy;
  end;

implementation
{$IFDEF DELPHI7_UP}
{$POINTERMATH ON}
{$ENDIF}
constructor TCEFArgCopy.Create;
begin
  inherited Create;

  InitializeFields;
end;

destructor TCEFArgCopy.Destroy;
begin
  DestroyFields;

  inherited Destroy;
end;

procedure TCEFArgCopy.InitializeFields;
begin
  FArgCCopy := 0;
  FArgVCopy := nil;
end;

procedure TCEFArgCopy.DestroyFields;
var
  i : integer;
begin
  if (FArgVCopy <> nil) then
    begin
      i := pred(FArgCCopy);

      while (i >= 0) do
        begin
          if (FArgVCopy[i] <> nil) then
            {$IFDEF DELPHI18_UP}System.AnsiStrings.{$ENDIF}StrDispose(FArgVCopy[i]);

          dec(i);
        end;

      FreeMem(FArgVCopy);
    end;

  InitializeFields;
end;

procedure TCEFArgCopy.CopyFromArgs(aArgc : longint; aArgv : PPAnsiChar);
var
  i : integer;
begin
  DestroyFields;

  if (aArgc > 0) and (aArgv <> nil) then
    begin
      i         := 0;
      FArgCCopy := aArgc;

      GetMem(FArgVCopy, (FArgCCopy + 1) * SizeOf(Pointer));

      while (i < aArgc) do
        begin
          {$IFDEF FPC}
            FArgVCopy[i] := StrAlloc(length(aArgv[i]) + 1);
            StrCopy(FArgVCopy[i], aArgv[i]);
          {$ELSE}
            {$IFDEF DELPHI18_UP}
              FArgVCopy[i] := System.AnsiStrings.AnsiStrAlloc(length(aArgv[i]) + 1);
              System.AnsiStrings.StrCopy(FArgVCopy[i], aArgv[i]);
            {$ELSE}
              FArgVCopy[i] := {$IFDEF DELPHI16_UP}System.{$ENDIF}SysUtils.{$IFDEF DELPHI7_UP}Ansi{$ENDIF}StrAlloc(length(aArgv[i]) + 1);
              {$IFDEF DELPHI16_UP}System.{$ENDIF}SysUtils.StrCopy(FArgVCopy[i], aArgv[i]);
            {$ENDIF}
          {$ENDIF}

          inc(i);
        end;

      FArgVCopy[i] := nil;
    end;
end;

end.
