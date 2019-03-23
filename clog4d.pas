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
        function Push(Msg:LogRecord)
          : TDateTime;
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

function TLogQueue.Push(Msg:LogRecord)
  : TDateTime;
var
    Len, i: integer;
begin
    Result := Now;
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
        FItems[FTail]^:=Msg;
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
    New(FMessage);
    inherited Create(False);
end;

destructor TLogger.Destroy;
begin
    if FMessage <> nil then
        Dispose(FMessage);
    if Assigned(OnLogBefore) then
       OnLogBefore:=nil;
    if Assigned(OnlogAfter) then
       OnlogAfter:=nil;
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
            FMessage.LogTime:=Now;
        if Assigned(FOnlogBefore) then
        begin
            Synchronize(SynlogBefore);
        end;
        FMessage.LogTime := FQueue.Push(FMessage^);
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
    FLock.Enter;
    try
        if not DirectoryExists(FAppPath + 'LOG') then
            ForceDirectories(FAppPath + 'LOG');
        if sMsg.FileName = '' then
            fn := FAppPath + 'LOG\' + FormatDateTime('yyyymm',
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
        FLock.Leave;
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

gLogger.Free ;

end.
