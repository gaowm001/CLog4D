(*
  This file is part of CLog4D Demo.

  CLog4D is a library file for super fast log writing for Delphi and lazarus.

  CLog4D Information - https://github.com/gaowm001/CLog4D

  This demo file uses multi-threading to write logs, which takes less than a minute to write 10,000 logs

  This program can classify and process different types of logs in one program, and write the logs to different log files.

  author:
  - GaoMing(QQ:17300620)

  *** BEGIN LICENSE BLOCK *****
  MIT License
  Copyright (c) 2019 GAOMING

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  ***** END LICENSE BLOCK *****

  Version 0.2

  Add property:defaultdatetime, default property is 'yyyymmdd', that means the log files generated  are named by date .
  Then you can set this property to 'yyyymm' or 'yyyymmddhh', that means generate a separate log monthly or hourly .

  Version 0.1

  Example:

  First,

  uses Clog4D;

  second,

  gLogger.Writelog('Hello!');

  then,

  You will find 'LOG' directory, and log file in this dirctory.
*)
unit clog4d;

{$H+}
{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses
    Classes, SysUtils, TypInfo, syncobjs;

const
    _SizeOfPointer = 4;

type
    TLevel = (DEBUG = 0, INFO, WARN, ERROR, FATAL);

    LogRecord = record
        Log: string;
        FileName: string;
        LogTime: TDateTime;
        Level: TLevel;
    end;

    pLogRecord = ^LogRecord;

    TLogQueue = class
    private
        FHead: integer;
        FTail: integer;
        FItems: array of pLogRecord;
        FCS: TCriticalSection;
    public
        FCount: integer;
        constructor Create;
        destructor Destroy; override;
        procedure Push(Msg: LogRecord);
        function Pop: LogRecord;
    end;

    TOnlog = procedure(Logs: LogRecord) of object;

    TLogger = class(TThread)
    private
    private
        FQueue: TLogQueue;
        FLock: TCriticalSection;
        FAppPath: string;
        FLevel: TLevel;
        FMessage: pLogRecord;
        FDefaultDatetime:String;
    protected
        function GetLogMsg: LogRecord;
        procedure Execute; override;
        procedure DoLocalLog(sMsg: LogRecord);
    public
        FOnlogBefore: TOnlog;
        FOnlogAfter: TOnlog;
        procedure SynlogBefore;
        procedure SynlogAfter;
        constructor Create;
        procedure WriteLog(logMsg: string; Level: TLevel = INFO;
          FileName: string = '');
        procedure SetModel(Level: TLevel);
        destructor Destroy; override;
        property DefaultDatetime:String read FDefaultDatetime write FDefaultDatetime;
        property OnLogBefore: TOnlog read FOnlogBefore write FOnlogBefore;
        property OnLogAfter: TOnlog read FOnlogAfter write FOnlogAfter;
    end;

    pLogger = ^TLogger;

var
    gLogger: TLogger;

implementation

constructor TLogQueue.Create;
begin
    FCS := TCriticalSection.Create;;
    FHead := 0;
    FTail := 0;
    FCount := 0;
end;

destructor TLogQueue.Destroy;
var
    i: integer;
begin
    if FCount > 0 then
    begin
        if FTail > FHead then
            for i := FHead to FTail - 1 do
                Dispose(FItems[i])
        else
        begin
            if FTail > 0 then
                for i := 0 to FTail - 1 do
                    Dispose(FItems[i]);
            for i := FHead to Length(FItems) - 1 do
                Dispose(FItems[i]);
        end;
    end;
    SetLength(FItems, 0);
    FCS.Free;
    inherited;
end;

procedure TLogQueue.Push(Msg: LogRecord);
var
    Len, i: integer;
begin
    FCS.Enter;
    try
        Len := Length(FItems);
        if FCount = Len then
        begin
            if Len = 0 then
            begin
                Len := 4;
                SetLength(FItems, Len);
            end
            else
            begin
                SetLength(FItems, Len * 2);
                if FTail <= FHead then
                begin
                    if FTail > 0 then
                        for i := 0 to FTail - 1 do
                        begin
                            FItems[Len + i] := FItems[i];
                            FItems[i] := nil;
                        end;
                    Inc(FTail, Len);
                end;
                Inc(Len, Len);
            end;
        end;
        if FItems[FTail] = nil then
            New(FItems[FTail]);
        FItems[FTail]^ := Msg;
        if FTail = Len - 1 then
            FTail := 0
        else
            Inc(FTail);
        Inc(FCount);
    finally
        FCS.Leave;
    end;
end;

function TLogQueue.Pop: LogRecord;
begin
    FCS.Enter;
    try
        if FCount = 0 then
            exit;
        Result := FItems[FHead]^;
        Dispose(FItems[FHead]);
        FItems[FHead] := nil;
        if FHead = Length(FItems) - 1 then
            FHead := 0
        else
            Inc(FHead);;
        Dec(FCount);
    finally
        FCS.Leave;
    end;
end;

constructor TLogger.Create;
begin
    FQueue := TLogQueue.Create;
    FLock := TCriticalSection.Create;
    FAppPath := ExtractFilePath(GetModuleName(HINSTANCE));
    SetModel(INFO);
    FDefaultDatetime:='yyyymmdd';
    New(FMessage);
    inherited Create(False);
end;

destructor TLogger.Destroy;
begin
    if FMessage <> nil then
        Dispose(FMessage);
    if Assigned(OnLogBefore) then
        OnLogBefore := nil;
    if Assigned(OnLogAfter) then
        OnLogAfter := nil;
    FQueue.Free;
    FLock.Free;
    inherited;
end;

procedure TLogger.SetModel(Level: TLevel);
begin
    FLevel := Level;
end;

procedure TLogger.WriteLog(logMsg: string; Level: TLevel; FileName: string);
begin
    if FLevel > Level then
        exit;
    logMsg := '[' + IntToStr(ThreadId) + ']' + logMsg;
    FLock.Enter;
    try
        FMessage.FileName := FileName;
        FMessage.Level := Level;
        FMessage.Log := logMsg;
        FMessage.LogTime := Now;
        if Assigned(FOnlogBefore) then
        begin
            Synchronize(SynlogBefore);
        end;
        FQueue.Push(FMessage^);
    finally
        FLock.Leave;
    end;
end;

procedure TLogger.DoLocalLog(sMsg: LogRecord);
var
    fn: string;
    LogMessage: string;
    hFile: TextFile;
begin
    try
        if not DirectoryExists(FAppPath + 'LOG') then
            ForceDirectories(FAppPath + 'LOG');
        if sMsg.FileName = '' then
            fn := FAppPath + 'LOG\' + FormatDateTime(FDefaultDatetime,
              sMsg.LogTime) + '.log'
        else
            fn := FAppPath + 'LOG\' + sMsg.FileName;
        LogMessage := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', sMsg.LogTime) +
          '[' + GetEnumName(TypeInfo(TLevel), Ord(sMsg.Level)) + ']:' +
          sMsg.Log;
        AssignFile(hFile, fn);
        try
            if FileExists(fn) then
                Append(hFile)
            else
                ReWrite(hFile);
            Writeln(hFile, LogMessage);
            if Assigned(FOnlogAfter) then
            begin
                FMessage^ := sMsg;
                Synchronize(SynlogAfter);
            end;
        finally
            CloseFile(hFile);
        end;
    finally
    end;
end;

function TLogger.GetLogMsg: LogRecord;
begin
    FLock.Enter;
    try
        Result := FQueue.Pop;
    finally
        FLock.Leave;
    end;
end;

procedure TLogger.Execute;
begin
    while not Terminated do
    begin
        if FQueue.FCount > 0 then
        begin
            DoLocalLog(FQueue.Pop);
        end
        else
            Sleep(10);
    end;
end;

procedure TLogger.SynlogBefore;
begin
    if Assigned(FOnlogBefore) then
    begin
        FOnlogBefore(FMessage^);
    end;

end;

procedure TLogger.SynlogAfter;
begin
    if Assigned(FOnlogAfter) then
    begin
        FOnlogAfter(FMessage^);
    end;
end;

initialization

gLogger := TLogger.Create;

finalization

gLogger.Free;

end.
