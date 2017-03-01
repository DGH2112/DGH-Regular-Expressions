program DGHRegEx;

{$R 'DGHRegExITHVerInfo.res' 'DGHRegExITHVerInfo.RC'}

uses
  {$IFDEF EUREKALOG}
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  {$ENDIF}
  Vcl.Forms,
  DGHRegEx.Types in 'Source\DGHRegEx.Types.pas',
  DGHRegEx.MainForm in 'Source\DGHRegEx.MainForm.pas' {frmDGHGrepMainForm},
  DGHRegEx.ProgressForm in 'Source\DGHRegEx.ProgressForm.pas' {frmProgress},
  DGHRegEx.Interfaces in 'Source\DGHRegEx.Interfaces.pas',
  DGHRegEx.RegExPreProcessingEng in 'Source\DGHRegEx.RegExPreProcessingEng.pas',
  SynHighlighterRegEx in '..\..\Components\Source\SynHighlighterRegEx.pas',
  SynEditOptionsForm in '..\..\Library\SynEditOptionsForm.pas' {frmEditorOptions};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  {$IFDEF EUREKALOG}
  SetEurekaLogState(DebugHook = 0);
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DGH Regular Expressions';
  Application.CreateForm(TfrmDGHGrepMainForm, frmDGHGrepMainForm);
  Application.Run;
end.
