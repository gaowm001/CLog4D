program Demo;

{$MODE Delphi}

uses
  {$IFDEF FPC}{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main, clog4d;
  {$ELSE}
  Main in 'Main.pas' {Form2};
  {$ENDIF}

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := DebugHook<>0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
