unit Main;

{$IFDEF fpc}
{$mode objfpc}{$H+}
{$ENDIF}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
    TypInfo, Clog4D;

type

    { TForm1 }

    TFormMain = class(TForm)
        ButtonWriteThread: TButton;
        ButtonWrite: TButton;
        CheckBoxAfter: TCheckBox;
        CheckBoxBefore: TCheckBox;
        ComboBoxLevel: TComboBox;
        EditLog: TEdit;
        EditFileName: TEdit;
        LabelLog: TLabel;
        LabelLevel: TLabel;
        LabelFileName: TLabel;
        MemoLog: TMemo;
        procedure ButtonWriteClick(Sender: TObject);
        procedure ButtonWriteThreadClick(Sender: TObject);
        procedure CheckBoxAfterClick(Sender: TObject);
        procedure CheckBoxBeforeClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private

    public
        procedure ShowBegin(Logs: LogRecord);
        procedure ShowEnd(Logs: LogRecord);
    end;

    TWrite = procedure(f: string);

var
    FormMain: TFormMain;

implementation
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}
{ TFormMain }

procedure WriteLog;
var
    i: Integer;
begin
    for i := 1 to 100 do
    begin
//        gLogger.WriteLog(TGUID.NewGuid.ToString, info, i.ToString + '.log');
        gLogger.WriteLog(i.ToString, info, i.ToString + '.log');
    end;

end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
    // gLogger.Start;
    // gLogger.WriteLog('ddddd');
end;

procedure TFormMain.ButtonWriteClick(Sender: TObject);
begin
    gLogger.WriteLog(EditLog.Text, TLevel(GetEnumValue(TypeInfo(TLevel),
      ComboBoxLevel.Text)), EditFileName.Text);
end;

procedure TFormMain.ButtonWriteThreadClick(Sender: TObject);
var
    i: Integer;
begin
    for i := 1 to 100 do
    begin
        TThread.CreateAnonymousThread({$IFDEF FPC}@{$ENDIF}WriteLog).Start;
    end;
end;

procedure TFormMain.CheckBoxAfterClick(Sender: TObject);
begin
    if CheckBoxAfter.Checked then
        gLogger.OnLogAfter := {$IFDEF FPC}@{$ENDIF}ShowEnd
    else
        gLogger.OnLogAfter := nil;

end;

procedure TFormMain.CheckBoxBeforeClick(Sender: TObject);
begin
    if CheckBoxBefore.Checked then
        gLogger.OnLogBefore := {$IFDEF FPC}@{$ENDIF}ShowBegin
    else
        gLogger.OnLogBefore := nil;
end;

procedure TFormMain.ShowBegin(Logs: LogRecord);
begin
    MemoLog.Lines.Add(FormatDatetime('yyyymmdd hhmiss', Logs.LogTime) + ':[Begin]' +
      Logs.Log);
end;
procedure TFormMain.ShowEnd(Logs: LogRecord);
begin
    MemoLog.Lines.Add(FormatDatetime('yyyymmdd hhmiss', Logs.LogTime) + ':[WriteOK]' +
      Logs.Log);
end;

end.
