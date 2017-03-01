(**

  This module contains a class to represent a progress form.

  @Author  David Hoyle
  @Version 1.0
  @Date    28 Jan 2017

**)
Unit DGHRegEx.ProgressForm;

Interface

Uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls;

Type
  (** A class to represent the progress form. **)
  TfrmProgress = Class(TForm)
    pnlBackground: TPanel;
    lblInfo: TLabel;
    RzProgressBar: TProgressBar;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  Private
    { Private declarations }
    FNotifier : TNotifyEvent;
  Public
    { Public declarations }
    Class Procedure ShowProgress(Notifier : TNotifyEvent);
    Class Procedure UpdateProgress(Const strText : String; iPos, iMax: Integer);
    Class Procedure HideProgress;
  End;

Implementation

{$R *.dfm}

Var
  (** A private variable to hold the form instance. **)
  frmProgress: TfrmProgress;

{ TfrmProgress }

(**

  This is an on key down event handle for the form.

  @precon  None.
  @postcon Notifiers the calling application that escape has been pressed.

  @param   Sender as a TObject
  @param   Key    as a Word as a reference
  @param   Shift  as a TShiftState

**)
Procedure TfrmProgress.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);

Begin
  If Key = 27 Then
    If Assigned(FNotifier) Then
      frmProgress.FNotifier(Sender);
End;

(**

  This method hides the progress form.

  @precon  None.
  @postcon The form is hidden.

**)
Class Procedure TfrmProgress.HideProgress;

Begin
  frmProgress.Hide;
End;

(**

  This method shows the progress form.

  @precon  None.
  @postcon The progress form is displayed.

  @param   Notifier as a TNotifyEvent

**)
Class Procedure TfrmProgress.ShowProgress(Notifier : TNotifyEvent);

Begin
  frmProgress.FNotifier := Notifier;
  frmProgress.lblInfo.Caption := 'Please wait...';
  frmProgress.Show;
End;

(**

  This method updates the position of the progress bar on the form along with the information
  text.

  @precon  None.
  @postcon The progress bar and information text are updated.

  @param   strText as a String as a constant
  @param   iPos    as an Integer
  @param   iMax    as an Integer

**)
Class Procedure TfrmProgress.UpdateProgress(Const strText : String; iPos, iMax: Integer);

Begin
  If iMax  = 0 Then
    iMax := 1;
  frmProgress.lblInfo.Caption := strText;
  frmProgress.RzProgressBar.Position := Trunc(Int(iPos) / Int(iMax) * 100.0);
  frmProgress.RzProgressBar.Position := frmProgress.RzProgressBar.Position - 1;
  frmProgress.RzProgressBar.Position := frmProgress.RzProgressBar.Position + 1;
  Application.ProcessMessages;
End;

(** Creates an instances of the form. **)
Initialization
  frmProgress := TfrmProgress.Create(Application.MainForm);
(** Frees the instance of the form. **)
Finalization
  frmProgress.Free;
End.
