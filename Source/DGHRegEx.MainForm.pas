(**

  This module contains a form class and code to provide a test-bed for regular expressions for
  parsing C++ code and identifying classes, structures and functions.

  @Author  David Hoyle
  @Version 1.0
  @date    28 Feb 2017

**)
Unit DGHRegEx.MainForm;

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
  Vcl.ComCtrls,
  IniFiles,
  RegularExpressions,
  RegularExpressionsCore,
  SynHighlighterDfm,
  SynHighlighterCpp,
  SynEditHighlighter,
  SynHighlighterPas,
  SynEdit,
  VirtualTrees,
  Generics.Collections,
  System.Actions,
  Vcl.ActnList,
  SynHighlighterGeneral,
  SynHighlighterRegEx,
  System.ImageList,
  Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan,
  Vcl.ToolWin,
  Vcl.ActnCtrls,
  DGHRegEx.Types,
  Vcl.Menus,
  Vcl.ActnPopup,
  Vcl.StdActns,
  DGHRegEx.Interfaces;

Type
  (** A class to present a form for testing Reg Ex expressions. **)
  TfrmDGHGrepMainForm = Class(TForm)
    spResults: TSplitter;
    edtFiles: TEdit;
    SynPasSyn: TSynPasSyn;
    SynCppSyn: TSynCppSyn;
    pnlResults: TPanel;
    vstResults: TVirtualStringTree;
    splResults: TSplitter;
    pnlGrepSearch: TPanel;
    tmTimer: TTimer;
    atbrToolbar: TActionToolBar;
    amActions: TActionManager;
    ilImages: TImageList;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actFileNew: TAction;
    actFileClose: TAction;
    actFileExit: TAction;
    dlgFileSave: TFileSaveDialog;
    dlgFileOpen: TFileOpenDialog;
    actEditCut: TEditCut;
    actEditCopy: TEditCopy;
    actEditPaste: TEditPaste;
    actEditSelectAll: TEditSelectAll;
    actEditUndo: TEditUndo;
    actEditDelete: TEditDelete;
    apmContextMenu: TPopupActionBar;
    Undo1: TMenuItem;
    N1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    SelectAll1: TMenuItem;
    actToolsEditorOptions: TAction;
    actEditFind: TAction;
    dlgFind: TFindDialog;
    actToolsUpdateInterval: TAction;
    stbrEditorStatus: TStatusBar;
    pnlPreview: TPanel;
    pabTreeContext: TPopupActionBar;
    actEditCopyToClipboard: TAction;
    CopytoClipboard1: TMenuItem;
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure vstResultsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; Var CellText: String);
    Procedure vstResultsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      Var LineBreakStyle: TVTTooltipLineBreakStyle; Var HintText: String);
    Procedure vstResultsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    Procedure tmTimerTimer(Sender: TObject);
    Procedure vstResultsPaintText(Sender: TBaseVirtualTree; Const TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    Procedure edtFilesChange(Sender: TObject);
    procedure actFileExitExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actFileSaveUpdate(Sender: TObject);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileSaveAsUpdate(Sender: TObject);
    procedure actFileOpenExecute(Sender: TObject);
    procedure actFileCloseExecute(Sender: TObject);
    procedure actFileCloseUpdate(Sender: TObject);
    procedure actFileNewExecute(Sender: TObject);
    procedure actToolsEditorOptionsExecute(Sender: TObject);
    procedure actToolsEditorOptionsUpdate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actEditFindExecute(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure actToolsUpdateIntervalExecute(Sender: TObject);
    procedure actEditCopyToClipboardExecute(Sender: TObject);
    procedure actEditCopyToClipboardUpdate(Sender: TObject);
  Strict Private
    Type
      (** This is a private record to describe the information that needs to be stored for each
          virtual treeview node. **)
      TNodeInfo = Record
        FValue:    String;
        FFileName: String;
        FNodeType: TNodeType;
        FItemNum:  Integer;
        FIndex:    Integer;
        FLength:   Integer;
        Constructor Create(strValue, strFileName : String; eNodeType : TNodeType; iItemNum, iIndex,
          iLength : Integer);
      End;
      (** A record to return information from the regex searches. **)
      TRegExResult = Record
        FFilesFound   : Integer;
        FMatchesFound : Integer;
        FTimeForRegEx : Double;
        Procedure Reset;
      End;
  Strict Private
    { Private declarations }
    FIniFile:        TMemIniFile;
    FFileExt:        TArray<String>;
    FRegEx:          TRegEx;
    FSynEdit:        TSynEdit;
    FRegExText:      TSynEdit;
    FNodeInfo:       TList<TNodeInfo>;
    FExpandedNodes:  TStringList;
    FSelectedPath:   String;
    FMaxFiles:       Integer;
    FFileCount:      Integer;
    FLastEdited:     Int64;
    FSynRegExSyn:    TSynRegExSyn;
    FRegExFileName:  String;
    FLastFileName:   String;
    FParsing:        Boolean;
    FSearchRegEx:    TRegEx;
    FUpdateInterval: Integer;
    Procedure LoadSettings;
    Procedure SaveSettings;
    Function RecurseFiles(Parent: PVirtualNode; Const strPath: String) : TRegExResult;
    Function SearchFile(Const strFileName: String; Node: PVirtualNode): TRegExResult;
    Procedure FindHighlighter(Const strFileName: String);
    Function AddNode(Parent: PVirtualNode; Const strValue, strFileName: String;
      eNodeType: TNodeType; iItemNum : Integer = 0; iIndex : Integer = 0;
      iLength : Integer = 0): PVirtualNode;
    Procedure GetExpandedNodes;
    Procedure SetExpandedNodes;
    Function CountFiles(Const strPath: String): Integer;
    Procedure ConfigureSynEdit(SynEdit: TSynEdit);
    Procedure RegExTextChange(Sender: TObject);
    Procedure RegExTextStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    Function FormatRegEx(Const strRegEx: String): String;
    Procedure IterateRegExDefs(Err: PVirtualNode; DGHRegExPreProcEng : IDGHRegExPreProcessingEng);
    Procedure FindRegExDefinition(Node: PVirtualNode; SynEdit : TSynEdit);
    Procedure FocusRegExTextLine(iLine: Integer; SynEdit : TSynEdit);
    Procedure ParseRegEx(Sender: TObject);
    Procedure LoadSynEditFromINI(SynEdit: TSynEdit; const strKey: String; INIFile: TMemIniFile);
    Procedure SaveSynEditToINI(SynEdit: TSynEdit; const strKey: String; INIFile: TMemIniFile);
    Procedure LoadSynEditHighlighterFromINI(SynEditHighlighter: TSynCustomHighlighter;
      const strKey: String; INIFile: TMemIniFile);
    Procedure SaveSynEditHighlighterToINI(SynEditHighlighter: TSynCustomHighlighter;
      const strKey: String; INIFile: TMemIniFile);
    Procedure UpdateLastEdit(Sender : TObject);
    Procedure CheckForAbort(Sender: TObject);
    Procedure UpdateMatches(Node : PVirtualNode; RegExResult : TRegExResult);
    Function  TickTime : Double;
  Public
    { Public declarations }
  End;

Var
  (** A global form variable managed by the IDE. **)
  frmDGHGrepMainForm: TfrmDGHGrepMainForm;

Implementation

{$R *.dfm}


Uses
  CodeSiteLogging,
  DGHRegEx.ProgressForm,
  SynUnicode,
  System.UITypes,
  SynEditOptionsForm,
  DGHRegEx.RegExPreProcessingEng, Vcl.Clipbrd;

{ TfrmDGHGrepMainForm.TNodeInfo }

(**

  A constructor for the TNodeInfo class.

  @precon  None.
  @postcon Initialises the record with the passed data.

  @param   strValue    as a String
  @param   strFileName as a String
  @param   eNodeType   as a TNodeType
  @param   iItemNum    as an Integer
  @param   iIndex      as an Integer
  @param   iLength     as an Integer

**)
Constructor TfrmDGHGrepMainForm.TNodeInfo.Create(strValue, strFileName: String; // FI:W525
  eNodeType: TNodeType; iItemNum, iIndex, iLength: Integer);

Begin
  FValue := strValue;
  FFileName := strFileName;
  FNodeType := eNodeType;
  FItemNum := iItemNum;
  FIndex := iIndex;
  FLength := iLength;
End;

{ TfrmDGHGrepMainForm.TRegExResult }

(**

  This method initialises the record to with zero values.

  @precon  None.
  @postcon The record is initialises to zero.

**)
Procedure TfrmDGHGrepMainForm.TRegExResult.Reset;

Begin
  FFilesFound := 0;
  FMatchesFound := 0;
  FTimeForRegEx := 0;
End;

(**

  This is an on execute event handler for the CopyToClipboard action.

  @precon  None.
  @postcon Copies the selected node text to the clipboard.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actEditCopyToClipboardExecute(Sender: TObject);

Var
  C: TClipboard;

Begin
  If vstResults.FocusedNode <> Nil Then
    Begin
      C := TClipboard.Create;
      Try
        C.Open;
        Try
          Clipboard.SetTextBuf(PChar(vstResults.Text[vstResults.FocusedNode, 0]));
        Finally
          C.Close;
        End;
      Finally
        C.Free;
      End;
    End;
End;

(**

  This is an on update event handler for the CopyToClipboard action.

  @precon  None.
  @postcon Enabled the action only if there is a valid selected (focused) node.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actEditCopyToClipboardUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Enabled := (vstResults.FocusedNode <> Nil);
End;

(**

  This is an on execute event handler for the Edit Find action.

  @precon  None.
  @postcon Displays the find dialogue.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actEditFindExecute(Sender: TObject);

Begin
  dlgFind.FindText := (ActiveControl As TSynEdit).WordAtCursor;
  dlgFind.Execute(Self.Handle);
End;

(**

  This is an on execute event handler for the File Close action.

  @precon  None.
  @postcon Checks that the file is saved if modified and then clears / disables the Reg Ex Syn Edit
           control.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileCloseExecute(Sender: TObject);

Var
  boolCanClose : Boolean;

Begin
  boolCanClose := True;
  FormCloseQuery(Sender, boolCanClose);
  If boolCanClose Then
    Begin
      FRegExFileName := '';
      FRegExText.Clear;
      FRegExText.Modified := False;
      FRegExText.ReadOnly := True;
      FRegExText.Enabled := False;
      Caption := Application.Title;
      RegExTextChange(Sender);
    End;
End;

(**

  This is an on update event handler for the File Close action.

  @precon  None.
  @postcon Enables this action ONLY if the reg ex syn edit control is enabled.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileCloseUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Enabled := FRegExText.Enabled;
End;

(**

  This is an on execute event handler for the File Exit action.

  @precon  None.
  @postcon Closes the application.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileExitExecute(Sender: TObject);

Begin
  Close;
End;

(**

  This is an on execute event handler for the File New action.

  @precon  None.
  @postcon Checks that any unsaved data is saved and then creates a new blank reg ex file.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileNewExecute(Sender: TObject);

Var
  boolCanClose: Boolean;

Begin
  boolCanClose := True;
  FormCloseQuery(Sender, boolCanClose);
  If boolCanClose Then
    Begin
      FRegExFileName := 'Untitled.RegEx';
      FRegExText.Clear;
      Caption := Application.Title + ': ' + FRegExFileName;
      FRegExText.ReadOnly := False;
      FRegExText.Enabled := True;
    End;
End;

(**

  This is an on execute event handler for the File Open action.

  @precon  None.
  @postcon Checks that any existing modified data is saved and then opens the new file for editing.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileOpenExecute(Sender: TObject);

Var
  boolCanClose: Boolean;

Begin
  boolCanClose := True;
  FormCloseQuery(Sender, boolCanClose);
  If boolCanClose Then
    If dlgFileOpen.Execute Then
      Begin
        FRegExFileName := dlgFileOpen.FileName;
        FRegExText.Lines.LoadFromFile(FRegExFileName);
        Caption := Application.Title + ': ' + FRegExFileName;
        FRegExText.ReadOnly := False;
        FRegExText.Enabled := True;
        RegExTextChange(Sender);
      End;
End;

(**

  This is an on execute event handler for the File SaveAs action.

  @precon  None.
  @postcon Prompts the user to save the files to a disk and then if confirmed saves the file.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileSaveAsExecute(Sender: TObject);

Begin
  If dlgFileSave.Execute Then
    Begin
      FRegExFileName := dlgFileSave.FileName;
      FRegExText.Lines.SaveToFile(FRegExFileName);
      Caption := Application.Title + ': ' + FRegExFileName;
      FRegExText.Modified := False;
    End Else
      Abort;
End;

(**

  This is an on update event handler for the File SaveAs action.

  @precon  None.
  @postcon Enables the SaveAs action if the reg ex filename is not empty.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileSaveAsUpdate(Sender: TObject);

Begin
  If (Sender Is TAction) Then
    (Sender As TAction).Enabled := FRegExFileName <> '';
End;

(**

  This is an on execute event handler for the File Save action.

  @precon  None.
  @postcon If the directory of the reg ex file is valid it saves the files else its calls the Save
           As action to save the file.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileSaveExecute(Sender: TObject);

Begin
  If DirectoryExists(ExtractFilePath(FRegExFileName)) Then
    Begin
      FRegExText.Lines.SaveToFile(FRegExFileName);
      FRegExText.Modified := False;
    End Else
      actFileSaveAsExecute(Sender);
End;

(**

  This is an on update event handler for the File Save action.

  @precon  None.
  @postcon Enables the action if the reg ex text has been modified.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actFileSaveUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Enabled := FRegExText.Modified;
End;

(**

  This is an on execute event handler for the Tools Editor Options action.

  @precon  None.
  @postcon Displays the editor options form for the active synedit control so that the editor and
           highlighter options can be changed.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actToolsEditorOptionsExecute(Sender: TObject);

Begin
  If ActiveControl Is TSynEdit Then
    TfrmEditorOptions.Execute(Self, ActiveControl As TSynEdit, True);
End;

(**

  This is an on update event handler for the Tools Editor Options action.

  @precon  None.
  @postcon makes the action only available IF the active control is a synedit control.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actToolsEditorOptionsUpdate(Sender: TObject);

Begin
  If Sender Is TAction Then
    (Sender As TAction).Enabled := (ActiveControl Is TSynEdit);
End;

(**

  This is an on execute event handler for the Tools update Interval action.

  @precon  None.
  @postcon Displays an input box in which a new update interval (in seconds) can be entered.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.actToolsUpdateIntervalExecute(Sender: TObject);

Var
  strInterval : String;
  iInterval: Integer;
  iErrorCode: Integer;

Begin
  Repeat
    strInterval := InputBox('Update Interval', 'Please enter a value in seconds',
      IntToStr(FUpdateInterval));
    Val(strInterval, iInterval, iErrorCode);
  Until (iErrorCode = 0);
  FUpdateInterval := iInterval;
End;

(**

  This method adds a node to the results tree view without match/group data.

  @precon  Parent must be either nil or a valid parent node.
  @postcon A node is added to the results tree view without match/group data for selection.

  @param   Parent      as a PVirtualNode
  @param   strValue    as a String as a constant
  @param   strFileName as a String as a constant
  @param   eNodeType   as a TNodeType
  @param   iItemNum    as an integer
  @param   iIndex      as an Integer
  @param   iLength     as an Integer
  @return  a PVirtualNode

**)
Function TfrmDGHGrepMainForm.AddNode(Parent: PVirtualNode; Const strValue, strFileName: String;
  eNodeType: TNodeType; iItemNum : integer = 0; iIndex : Integer = 0;
  iLength : Integer = 0): PVirtualNode;

Var
  NodeData: PNodeData;

Begin
  Result := vstResults.AddChild(Parent);
  NodeData := vstResults.GetNodeData(Result);
  NodeData.FNodeIndex := FNodeInfo.Add(TNodeInfo.Create(strValue, strFileName, eNodeType, iItemNum,
    iIndex, iLength));
End;

(**

  This method counts the number of files that are going to be processed for each macro.

  @precon  None.
  @postcon Returns the number of files that are going to be processed for each macro.

  @param   strPath as a String as a constant
  @return  an Integer

**)
Function TfrmDGHGrepMainForm.CountFiles(Const strPath: String): Integer;

Var
  iExt: Integer;
  iResult: Integer;
  recSearch: TSearchRec;

Begin
  Result := 0;
  For iExt := Low(FFileExt) To High(FFileExt) Do
    Begin
      iResult := FindFirst(strPath + FFileExt[iExt], faAnyFile, recSearch);
      Try
        While iResult = 0 Do
          Begin
            Inc(Result);
            iResult := FindNext(recSearch);
          End;
      Finally
        FindClose(recSearch);
      End;
    End;
  iResult := FindFirst(strPath + '*.*', faAnyFile, recSearch);
  Try
    While iResult = 0 Do
      Begin
        If (recSearch.Attr And faDirectory > 0) And (recSearch.Name <> '.') And
          (recSearch.Name <> '..') Then
          Inc(Result, CountFiles(strPath + recSearch.Name + '\'));
        iResult := FindNext(recSearch);
      End;
  Finally
    FindClose(recSearch);
  End;
End;

(**

  This method searches the active synedit control for the reg ex text entered in the find dialogue.

  @precon  None.
  @postcon The reg ex search is found else a message is returned.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.dlgFindFind(Sender: TObject);

Var
  strSearch : String;
  Ops : TRegExOptions;
  MC: TMatchCollection;
  SynEdit : TSynEdit;
  iMatch: Integer;

Begin
  SynEdit := (ActiveControl As TSynEdit);
  strSearch := SynEdit.Lines.Text;
  Ops := [roMultiLine, roExplicitCapture, roCompiled, roSingleLine];
  If Not (frMatchCase In dlgFind.Options) Then
    Include(Ops, roIgnoreCase);
  FSearchRegEx := TRegEx.Create(dlgFind.FindText, Ops);
  MC := FSearchRegEx.Matches(strSearch);
  If MC.Count > 0 Then
    Begin
      If frDown In dlgFind.Options Then
        Begin
          For iMatch := 0 To MC.Count - 1 Do
            If MC.Item[iMatch].Index - 1 > SynEdit.SelStart Then
              Break;
          If iMatch >= MC.Count Then
            iMatch := 0;
        End Else
        Begin
          For iMatch := MC.Count - 1 DownTo 0 Do
            If MC.Item[iMatch].Index - 1 < SynEdit.SelStart Then
              Break;
          If iMatch < 0 Then
            iMatch := MC.Count - 1;
        End;
      SynEdit.SelStart := MC.Item[iMatch].Index - 1;
      SynEdit.SelLength := MC.Item[iMatch].Length;
      SynEdit.EnsureCursorPosVisible;
    End Else
      MessageDlg(Format('The regular expression "%s" did not matchany test!', [dlgFind.FindText]),
        mtError, [mbOK], 0);
End;

(**

  This is an on change event handler for the Files edit control.

  @precon  None.
  @postcon Updates the last time that changes were made to either the reg ex or the file filter.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.edtFilesChange(Sender: TObject);

Begin
  UpdateLastEdit(Sender);
End;

(**

  This method searches for macro that do not start with an "!" and iterates all the files searching
  for instances of matches within those files and displays their results in the tree.

  @precon  None.
  @postcon The reg ex associated with the macros are places in the tree view.

  @param   Err                as a PVirtualNode
  @param   DGHRegExPreProcEng as an IDGHRegExPreProcessingEng

**)
Procedure TfrmDGHGrepMainForm.IterateRegExDefs(Err: PVirtualNode;
  DGHRegExPreProcEng : IDGHRegExPreProcessingEng);

Var
  iRegEx: Integer;
  E: PVirtualNode;
  strMacroName: String;
  strRegEx: String;
  RegExResult : TRegExResult;

Begin
  For iRegEx := 0 To DGHRegExPreProcEng.RegExCount - 1 Do
    Begin
      strMacroName := DGHRegExPreProcEng.MacroName[iRegEx];
      If Copy(strMacroName, 1, 3) <> '$(!' Then
        Begin
          E := AddNode(Nil, strMacroName, '', ntElement);
          strRegEx := DGHRegExPreProcEng[strMacroName];
          If strRegEx <> '' Then
            Try
              AddNode(E, strRegEx, '', ntRegEx);
              FRegEx := TRegEx.Create(strRegEx, [roMultiLine, roCompiled, roSingleLine,
                roExplicitCapture]);
              RegExResult.Reset;
              If High(FFileExt) >= Low(FFileExt) Then
                RegExResult := RecurseFiles(E, ExtractFilePath(edtFiles.Text));
              UpdateMatches(E, RegExResult);
            Except
              On E: ERegularExpressionError Do
                AddNode(Err, Format('%s:%s'#13#10'%s',
                  [strMacroName, E.Message, strRegEx]), '', ntError,
                  Succ(FRegExText.Lines.IndexOfName(strMacroName)));
            End;
          vstResults.Expanded[E] := True;
        End;
    End;
End;

(**

  This method configures the given synedit control with a standard setup.

  @precon  None.
  @postcon The passed synedit control is formatted as required.

  @param   SynEdit as a TSynEdit

**)
Procedure TfrmDGHGrepMainForm.ConfigureSynEdit(SynEdit: TSynEdit);

Begin
  SynEdit.Align := alClient;
  SynEdit.Font.Name := 'Consolas';
  SynEdit.Font.Size := 11;
  SynEdit.AlignWithMargins := True;
  SynEdit.WordWrap := True;
  SynEdit.ActiveLineColor := clSkyBlue;
  SynEdit.Gutter.ShowLineNumbers := True;
  SynEdit.Gutter.Font.Assign(SynEdit.Font);
  SynEdit.RightEdgeColor := clMaroon;
  SynEdit.RightEdge := 120;
  SynEdit.ReadOnly := True;
End;

(**

  This method finds the appropriate TSynCustomHighlighter for the file being previewed.

  @precon  None.
  @postcon If a custom highlighter with a matching file extension is found on the form it is set as
           the highlighter for the preview.

  @param   strFileName as a String as a constant

**)
Procedure TfrmDGHGrepMainForm.FindHighlighter(Const strFileName: String);

Var
  strExt: String;
  iComponent: Integer;
  H: TSynCustomHighlighter;

Begin
  strExt := LowerCase(ExtractFileExt(strFileName));
  For iComponent := 0 To ComponentCount - 1 Do
    If Components[iComponent] Is TSynCustomHighlighter Then
      Begin
        H := Components[iComponent] As TSynCustomHighlighter;
        If Pos(strExt, LowerCase(H.DefaultFilter)) > 0 Then
          Begin
            FSynEdit.Highlighter := H;
            Break;
          End;
      End;
End;

(**

  This method fines the root of the result tree which is the regex macro name and search for it in
  the reg ex text and places the cursor on that line and centres that line in the editor.

  @precon  None.
  @postcon The reg ex macro is found, focused and centred in thr editor.

  @param   Node    as a PVirtualNode
  @param   SynEdit as a TSynEdit

**)
Procedure TfrmDGHGrepMainForm.FindRegExDefinition(Node: PVirtualNode; SynEdit : TSynEdit);

Var
  iLine: Integer;
  P: PVirtualNode;
  NodeData: PNodeData;
  NodeInfo: TNodeInfo;

Begin
  P := Node;
  While vstResults.NodeParent[P] <> Nil Do
    P := vstResults.NodeParent[P];
  NodeData := vstResults.GetNodeData(P);
  NodeInfo := FNodeInfo[NodeData.FNodeIndex];
  iLine := SynEdit.Lines.IndexOfName(NodeInfo.FValue);
  If iLine > - 1 Then
    Begin
      Inc(iLine);
      SynEdit.CaretX := 1;
      SynEdit.CaretY := iLine;
      iLine := iLine - (SynEdit.LinesInWindow Div 2);
      If iLine < 1 Then
        iLine := 1;
      SynEdit.TopLine := iLine;
      SynEdit.EnsureCursorPosVisible;
    End;
End;

(**

  This method places the cursor position in the middle of the given syn edit control.

  @precon  None.
  @postcon The cursor is places in the middle of the given syn edit control.

  @param   iLine   as an Integer
  @param   SynEdit as a TSynEdit

**)
Procedure TfrmDGHGrepMainForm.FocusRegExTextLine(iLine: Integer; SynEdit : TSynEdit);

Begin
  iLine := iLine - (SynEdit.LinesInWindow Div 2);
  If iLine < 1 Then
    iLine := 1;
  SynEdit.TopLine := iLine;
  SynEdit.EnsureCursorPosVisible;
End;

(**

  This method formats a regular expression so that it is easier to read a comlpex reg ex.

  @precon  None.
  @postcon Adds LFCR after ( and before ) and indents nested content.

  @param   strRegEx as a String as a constant
  @return  a String

**)
Function TfrmDGHGrepMainForm.FormatRegEx(Const strRegEx: String): String;

  (**

    This method check to see if the current character is aliteral by being preceeded with a \
    character.

    @precon  None.
    @postcon Returns true if the character is a literal.

    @param   strText as a String as a constant
    @param   iPos    as an Integer
    @return  a Boolean

  **)
  Function IsLiteral(const strText : String; iPos : Integer) : Boolean;

  Begin
    Result := False;
    If iPos > 1 Then
      Result := strText[Pred(iPos)] = '\';
  End;

  (**

    This method check to see if the opening parenthesis is from a marco start.

    @precon  None.
    @postcon returns true of the parenthesis is from a macro.

    @param   strText as a String as a constant
    @param   iPos    as an Integer
    @return  a Boolean

  **)
  Function IsMacroStart(const strText : String; iPos : Integer) : Boolean;

  Begin
    Result := False;
    If iPos > 1 Then
      Result := strText[Pred(iPos)] = '$';
  End;

  (**

    This method check to see of the closing parenthesis is from a marco.

    @precon  None.
    @postcon Returns true if the closing parenthesis is from a macro.

    @param   strText as a String as a constant
    @param   iPos    as an Integer
    @return  a Boolean

  **)
  Function IsMacroEnd(const strText : String; iPos : Integer) : Boolean;

  Const
    strIdentifierChars = ['a'..'z', 'A'..'Z', '_', '0'..'9'];

  Var
    iIndex : Integer;

  Begin
    Result := False;
    iIndex := iPos;
    Dec(iIndex);
    If iIndex > 1 Then
      If CharInSet(strText[iIndex], strIdentifierChars) Then
        Begin
          While (iIndex > 0) And CharInSet(strText[iIndex], strIdentifierChars) Do
            Dec(iIndex);
          If (iIndex > 0) And (strText[iIndex] = '(') Then
            Dec(iIndex)
          Else
            Exit;
          Result := (iIndex > 0) And (strText[iIndex] = '$')
        End;
  End;

Var
  iPos: Integer;
  iCount: Integer;
  strInsert: String;

Begin
  Result := strRegEx;
  iCount := 0;
  iPos := 1;
  While iPos <= Length(Result) Do
    Begin
      If (Result[iPos] = '(') And Not IsLiteral(Result, iPos) And Not IsMacroStart(Result, iPos) Then
        Begin
          Inc(iCount);
          strInsert := '('#13#10 + StringOfChar(#32, iCount * 2);
          Result := Copy(Result, 1, Pred(iPos)) + strInsert + Copy(Result, Succ(iPos),
            Length(Result) - Succ(iPos) + 1);
          Inc(iPos, Length(strInsert));
        End Else
      If (Result[iPos] = ')') And Not IsLiteral(Result, iPos) And Not IsMacroEnd(Result, iPos) Then
        Begin
          Dec(iCount);
          strInsert := #13#10 + StringOfChar(#32, iCount * 2) + ')';
          Result := Copy(Result, 1, Pred(iPos)) + strInsert + Copy(Result, Succ(iPos),
            Length(Result) - Succ(iPos) + 1);
          Inc(iPos, Length(strInsert));
        End Else
          Inc(iPos);
    End;
End;

(**

  This method is a form on close query event handler.

  @precon  None.
  @postcon Asks the users to save the file is the reg ex has been modified.

  @param   Sender   as a TObject
  @param   CanClose as a Boolean as a reference

**)
Procedure TfrmDGHGrepMainForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);

Const
  strMsg = 'The file "%s" has been modified. Do you want to save the changes?';

Begin
  dlgFind.CloseDialog;
  FLastEdited := 0;
  If FRegExText.Modified Then
    Case MessageDlg(Format(strMsg, [FRegExFileName]), mtConfirmation, [mbYes, mbNo, mbCancel], 0) Of
      mrYes: actFileSaveExecute(Sender);
      mrCancel: CanClose := False;
    End;
  If CanClose Then
    GetExpandedNodes;
End;

(**

  This is an OnFormCreate Event Handler for the TfrmDGHGrepMainForm class.

  @precon  None.
  @postcon Creates 2 TSynEdit components - one to preview code and another for the reg exs and
           then loads the apps settings.

  @param   Sender as a TObject

**)

Procedure TfrmDGHGrepMainForm.FormCreate(Sender: TObject);

Begin
  Application.HintColor := clLime;
  Application.HintHidePause := 30000;
  Application.HintPause := 500;
  Application.HintShortPause := 50;
  vstResults.NodeDataSize := SizeOf(TNodeData);
  FNodeInfo := TList<TNodeInfo>.Create;
  FSynEdit := TSynEdit.Create(Self);
  FSynEdit.Parent := pnlPreview;
  FSynEdit.PopupMenu := apmContextMenu;
  FSynEdit.OnStatusChange := RegExTextStatusChange;
  ConfigureSynEdit(FSynEdit);
  FRegExText := TSynEdit.Create(Self);
  FRegExText.Parent := pnlGrepSearch;
  FRegExText.Enabled := False;
  FRegExText.PopupMenu := apmContextMenu;
  FRegExText.OnChange := RegExTextChange;
  FRegExText.OnStatusChange := RegExTextStatusChange;
  ConfigureSynEdit(FRegExText);
  FSynRegExSyn := TSynRegExSyn.Create(Self);
  If FileExists(ExtractFilePath(ParamStr(0)) + 'Keywords.txt') Then
    FSynRegExSyn.KeyWords.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Keywords.txt');
  TUnicodeStringList(FSynRegExSyn.KeyWords).Sort;
  FRegExText.Highlighter := FSynRegExSyn;
  FExpandedNodes := TStringList.Create;
  FExpandedNodes.Sorted := True;
  FExpandedNodes.Duplicates := dupIgnore;
  LoadSettings;
  UpdateLastEdit(Self);
  tmTimer.Enabled := True;
End;

(**

  This is an OnFormDestroy Event Handler for the TfrmDGHGrepMainForm class.

  @precon  None.
  @postcon save the apps settings and frees memory.

  @param   Sender as a TObject

**)

Procedure TfrmDGHGrepMainForm.FormDestroy(Sender: TObject);

Begin
  SaveSettings;
  FNodeInfo.Free;
  FExpandedNodes.Free;
End;

(**

  This is an on key down event handler for the form.

  @precon  None.
  @postcon Updates the last edited time to signify that a change as happened.

  @param   Sender as a TObject
  @param   Key    as a Word as a reference
  @param   Shift  as a TShiftState

**)
Procedure TfrmDGHGrepMainForm.FormKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);

Begin
  If Key = 27 Then
    UpdateLastEdit(Sender);
End;

(**

  This method extracts all the expanded nodes from the results tree view so that they can be
  expanded later on.

  @precon  None.
  @postcon All the expanded nodes are stored for later reuse.

**)

Procedure TfrmDGHGrepMainForm.GetExpandedNodes;

Var
  N: PVirtualNode;
  iNodeCount: Integer;

Begin
  FSelectedPath := '';
  If vstResults.FocusedNode <> Nil Then
    FSelectedPath := vstResults.Path(vstResults.FocusedNode, 0, ttNormal, '|');
  N := vstResults.GetFirstChild(vstResults.RootNode);
  iNodeCount := 0;
  While N <> Nil Do
    Begin
      vstResults.IterateSubtree(N,
        Procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; Var Abort: Boolean)
        Var
          strPath: String;
          iIndex: Integer;
        Begin
          CheckForAbort(Sender);
          If vstResults.ChildCount[Node] > 0 Then
            Begin
              strPath := vstResults.Path(Node, 0, ttNormal, '|');
              If FExpandedNodes.Find(strPath, iIndex) Then
                Begin
                  If vstResults.Expanded[Node] Then
                    FExpandedNodes.Objects[iIndex] := TObject(1)
                  Else
                    FExpandedNodes.Delete(iIndex);
                End
              Else
                If vstResults.Expanded[Node] Then
                  FExpandedNodes.AddObject(strPath, TObject(Integer(vstResults.Expanded[Node])));
            End;
          Inc(iNodeCount);
          If iNodeCount Mod 1000 = 0 Then
            TfrmProgress.UpdateProgress(
              Format('Getting expanded nodes (%1.0n in %1.0n)...', [Int(iNodeCount),
              Int(vstResults.TotalCount)]),
              iNodeCount,
              vstResults.TotalCount);
        End,
        Nil);
      N := vstResults.GetNextSibling(N);
    End;
End;

(**

  This method loads the settings from the INI File.

  @precon  None.
  @postcon Settings are loaded from the INI File.

**)

Procedure TfrmDGHGrepMainForm.LoadSettings;

Var
  sl: TStringList;
  i: Integer;

Begin
  FIniFile := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  Top := FIniFile.ReadInteger('Setup', 'Top', 100);
  Left := FIniFile.ReadInteger('Setup', 'Left', 100);
  Width := FIniFile.ReadInteger('Setup', 'Width', Width);
  Height := FIniFile.ReadInteger('Setup', 'Height', Height);
  vstResults.Width := FIniFile.ReadInteger('Setup', 'Results', 200);
  pnlGrepSearch.Height := FIniFile.ReadInteger('Setup', 'GrepHeight', 200);
  FRegExFileName := FIniFile.ReadString('Setup', 'RegExFileName', '');
  FUpdateInterval := FIniFile.ReadInteger('Setup', 'UpdateInterval', 1);
  If FileExists(FRegExFileName) Then
    Begin
      FRegExText.Lines.LoadFromFile(FRegExFileName);
      Caption := Application.Title + ': ' + FRegExFileName;
      FRegExText.ReadOnly := False;
      FRegExText.Enabled := True;
    End;
  edtFiles.Text := FIniFile.ReadString('Setup', 'Files',
    GetCurrentDir + '\*.pas;*.dpr;*.dpk;*.dfm;*.cpp;*.h');
  sl := TStringList.Create;
  Try
    FIniFile.ReadSection('ExpandedNodes', sl);
    For i := 0 To sl.Count - 1 Do
      FExpandedNodes.AddObject(sl[i], TObject(FIniFile.ReadInteger('ExpandedNodes', sl[i], 0)));
  Finally
    sl.Free;
  End;
  LoadSynEditFromINI(FRegExText, 'RegExText', FINIFile);
  LoadSynEditFromINI(FSynEdit, 'Preview', FIniFile);
  LoadSynEditHighlighterFromINI(FSynRegExSyn, 'RegExHighlighter', FINIFile);
  LoadSynEditHighlighterFromINI(SynPasSyn, 'PasHighlighter', FINIFile);
  LoadSynEditHighlighterFromINI(SynCppSyn, 'CPPHighlighter', FINIFile);
End;

(**

  This is an on execute event handler for the Parse action.

  @precon  None.
  @postcon Starts the parsing of Reg Ex expressions in the files.

  @param   Sender as a TObject

**)

Procedure TfrmDGHGrepMainForm.ParseRegEx(Sender: TObject);

Var
  strExt: String;
  Err: PVirtualNode;
  DGHRegExPreProcEng : IDGHRegExPreProcessingEng;
  iError: Integer;
  iMacro: Integer;

Begin
  strExt := ExtractFileName(edtFiles.Text);
  FFileExt := strExt.Split([';']);
  TfrmProgress.ShowProgress(UpdateLastEdit);
  Try
    GetExpandedNodes;
    vstResults.Clear;
    FNodeInfo.Clear;
    Err := AddNode(Nil, 'Errors', '', ntElement);
    DGHRegExPreProcEng := TDGHRegExPreProcessingEng.Create(FRegExText.Lines);
    For iError := 0 To DGHRegExPreProcEng.ErrorCount - 1 Do
      AddNode(Err, DGHRegExPreProcEng.Errors[iError].FErrorMsg, '', ntError,
        DGHRegExPreProcEng.Errors[iError].FErrorLine);
    vstResults.Expanded[Err] := True;
    FMaxFiles := 0;
    FFileCount := 0;
    For iMacro := 0 To DGHRegExPreProcEng.RegExCount - 1 Do
      If Copy(DGHRegExPreProcEng.MacroName[iMacro], 1, 3) <> '$(!' Then
        Inc(FMaxFiles, CountFiles(ExtractFilePath(edtFiles.Text)));
    IterateRegExDefs(Err, DGHRegExPreProcEng);
    If vstResults.ChildCount[Err] = 0 Then
      vstResults.DeleteNode(Err);
    SetExpandedNodes;
  Finally
    TfrmProgress.HideProgress;
  End;
End;

(**

  This method loads the settings of a SynEdit control from an INI file.

  @precon  SynEdit and INIFile must be valid instances.
  @postcon The synedit control is configured with information stored in the INI file.

  @param   SynEdit as a TSynEdit
  @param   strKey  as a String as a Constant
  @param   INIFile as a TMemIniFile

**)
Procedure TfrmDGHGrepMainForm.LoadSynEditFromINI(SynEdit: TSynEdit; const strKey: string;
  INIFile: TMemIniFile);

Begin
  SynEdit.Color := IniFile.ReadInteger(strKey, 'Colour', SynEdit.Color);
  SynEdit.ActiveLineColor := IniFile.ReadInteger(strKey, 'Active Line Colour',
    SynEdit.ActiveLineColor);
  SynEdit.Font.Name := IniFile.ReadString(strKey, 'Font Name', SynEdit.Font.Name);
  SynEdit.Font.Size := IniFile.ReadInteger(strKey, 'Font Size', SynEdit.Font.Size);
  SynEdit.Gutter.Font.Assign(Font);
  SynEdit.WordWrap := IniFile.ReadBool(strKey, 'Wordwrap', False);
  SynEdit.Gutter.ShowLineNumbers := IniFile.ReadBool(strKey, 'Show Line Numbers',
    SynEdit.Gutter.ShowLineNumbers);
  SynEdit.Options := TSynEditorOptions(IniFile.ReadInteger(strKey, 'Editor Options',
    Integer(SynEdit.Options)));
  SynEdit.RightEdge := IniFile.ReadInteger(strKey, 'Right Edge', SynEdit.RightEdge);
  SynEdit.RightEdgeColor := IniFile.ReadInteger(strKey, 'Right Edge Colour',
    SynEdit.RightEdgeColor);
  SynEdit.SelectedColor.Foreground := IniFile.ReadInteger(strKey, 'Selected Foreground',
    SynEdit.SelectedColor.Foreground);
  SynEdit.SelectedColor.Background := IniFile.ReadInteger(strKey, 'Selected Background',
    SynEdit.SelectedColor.Background);
  SynEdit.TabWidth := IniFile.ReadInteger(strKey, 'Tab Width', SynEdit.TabWidth);
End;

(**

  This method loads the synedit highlighter attributes settings from an INI file.

  @precon  SynEditHighlighter and INIFile must be valid instances.
  @postcon The highlighters attrbutes settings are loaded from the INI File.

  @param   SynEditHighlighter as a TSynCustomHighlighter
  @param   strKey             as a String as a Constant
  @param   INIFile            as a TMemIniFile

**)
Procedure TfrmDGHGrepMainForm.LoadSynEditHighlighterFromINI(
  SynEditHighlighter: TSynCustomHighlighter; const strKey: String; INIFile: TMemIniFile);

Var
  iAttribute: Integer;
  A: TSynHighlighterAttributes;

Begin
  For iAttribute := 0 To SynEditHighlighter.AttrCount - 1 Do
    Begin
      A := SynEditHighlighter.Attribute[iAttribute];
      A.Background := StringToColor(INIFile.ReadString(strKey, A.FriendlyName + '.BackColour',
        ColorToString(A.Background)));
      A.Foreground := StringToColor(INIFile.ReadString(strKey, A.FriendlyName + '.ForeColour',
        ColorToString(A.Foreground)));
      A.Style := TFontStyles(Byte(INIFile.ReadInteger(strKey, A.FriendlyName + '.FontStyle',
        Byte(A.Style))));
    End;
End;

(**

  This method saves the synedit highlighter attributes settings to an INI file.

  @precon  SynEditHighlighter and INIFile must be valid instances.
  @postcon The highlighters attrbutes settings are saved to the INI File.

  @param   SynEditHighlighter as a TSynCustomHighlighter
  @param   strKey             as a String as a Constant
  @param   INIFile            as a TMemIniFile

**)
Procedure TfrmDGHGrepMainForm.SaveSynEditHighlighterToINI(SynEditHighlighter: TSynCustomHighlighter;
  const strKey: String; INIFile: TMemIniFile);

Var
  iAttribute: Integer;
  A: TSynHighlighterAttributes;

Begin
  For iAttribute := 0 To SynEditHighlighter.AttrCount - 1 Do
    Begin
      A := SynEditHighlighter.Attribute[iAttribute];
      INIFile.WriteString(strKey, A.FriendlyName + '.BackColour', ColorToString(A.Background));
      INIFile.WriteString(strKey, A.FriendlyName + '.ForeColour', ColorToString(A.Foreground));
      INIFile.WriteInteger(strKey, A.FriendlyName + '.FontStyle', Byte(A.Style));
    End;
End;

(**

  This method checks to see if the last edited time has been changed.

  @precon  None.
  @postcon If the last edited time has changed all processing is aborted.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.CheckForAbort(Sender: TObject);

Begin
  If FLastEdited <> 0 Then
    Begin
      FLastEdited := 0;
      Abort;
    End;
End;

(**

  This method saves the SynEdits configuration to an INI File.

  @precon  SynEdit and INIFile must be valid instances.
  @postcon The SynEdits configuration is stored to the INI file.

  @param   SynEdit as a TSynEdit
  @param   strKey  as a String as a Constant
  @param   INIFile as a TMemIniFile

**)
Procedure TfrmDGHGrepMainForm.SaveSynEditToINI(SynEdit: TSynEdit; const strKey: string;
  INIFile: TMemIniFile);

Begin
  IniFile.WriteInteger(strKey, 'Colour', SynEdit.Color);
  IniFile.WriteInteger(strKey, 'Active Line Colour', SynEdit.ActiveLineColor);
  IniFile.WriteString(strKey, 'Font Name', SynEdit.Font.Name);
  IniFile.WriteInteger(strKey, 'Font Size', SynEdit.Font.Size);
  IniFile.WriteBool(strKey, 'Show Line Numbers', SynEdit.Gutter.ShowLineNumbers);
  IniFile.WriteBool(strKey, 'Wordwrap', SynEdit.WordWrap);
  IniFile.WriteInteger(strKey, 'Editor Options', Integer(SynEdit.Options));
  IniFile.WriteInteger(strKey, 'Right Edge', SynEdit.RightEdge);
  IniFile.WriteInteger(strKey, 'Right Edge Colour', SynEdit.RightEdgeColor);
  IniFile.WriteInteger(strKey, 'Selected Foreground', SynEdit.SelectedColor.Foreground);
  IniFile.WriteInteger(strKey, 'Selected Background', SynEdit.SelectedColor.Background);
  IniFile.WriteInteger(strKey, 'Tab Width', SynEdit.TabWidth);
End;

(**

  This method searches through the given path for files matching the files extensions for files that
  have regular expression matches.

  @precon  Parent must be a valid node or nil.
  @postcon Nodes are added for found matches.

  @param   Parent  as a PVirtualNode
  @param   strPath as a String as a constant
  @return  a TRegExResult

**)
Function TfrmDGHGrepMainForm.RecurseFiles(Parent: PVirtualNode;
  Const strPath: String) : TRegExResult;

Var
  iExt: Integer;
  iResult: Integer;
  recSearch: TSearchRec;
  P, N: PVirtualNode;
  RegExResult: TRegExResult;

Begin
  Result.Reset;
  P := AddNode(Parent, ExtractFileName(Copy(strPath, 1, Length(strPath) - 1)), strPath, ntPath);
  For iExt := Low(FFileExt) To High(FFileExt) Do
    Begin
      iResult := FindFirst(strPath + FFileExt[iExt], faAnyFile, recSearch);
      Try
        While iResult = 0 Do
          Begin
            N := AddNode(P, recSearch.Name, strPath + recSearch.Name, ntFile);
            RegExResult := SearchFile(strPath + recSearch.Name, N);
            Inc(Result.FMatchesFound, RegExResult.FMatchesFound);
            Result.FTimeForRegEx := Result.FTimeForRegEx + RegExResult.FTimeForRegEx;
            If RegExResult.FMatchesFound = 0 Then
              vstResults.DeleteNode(N);
            Inc(Result.FFilesFound);
            Inc(FFileCount);
            TfrmProgress.UpdateProgress(
              Format('Processing files %1.0n in %1.0n...', [Int(FFileCount), Int(FMaxFiles)]),
              FFileCount,
              FMaxFiles);
            iResult := FindNext(recSearch);
          End;
      Finally
        FindClose(recSearch);
      End;
    End;
  iResult := FindFirst(strPath + '*.*', faAnyFile, recSearch);
  Try
    While iResult = 0 Do
      Begin
        If (recSearch.Attr And faDirectory > 0) And (recSearch.Name <> '.') And
          (recSearch.Name <> '..') Then
          Begin
            RegExResult := RecurseFiles(P, strPath + recSearch.Name + '\');
            Inc(Result.FFilesFound, RegExResult.FFilesFound);
            Inc(Result.FMatchesFound, RegExResult.FMatchesFound);
            Result.FTimeForRegEx := Result.FTimeForRegEx + RegExResult.FTimeForRegEx;
          End;
        iResult := FindNext(recSearch);
      End;
  Finally
    FindClose(recSearch);
  End;
  If Result.FFilesFound = 0 Then
    vstResults.DeleteNode(P);
End;

(**

  This is an on change event handler for the RegExText control.

  @precon  None.
  @postcon Updates the last edit time so that changed can be processed.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.RegExTextChange(Sender: TObject);

Begin
  UpdateLastEdit(Sender);
End;

(**

  This is an on change event handler for the RegExText control.

  @precon  None.
  @postcon Updates the last edited time if the cursor has moved.

  @param   Sender  as a TObject
  @param   Changes as a TSynStatusChanges

**)
Procedure TfrmDGHGrepMainForm.RegExTextStatusChange(Sender: TObject; Changes: TSynStatusChanges);

Begin
  If FLastEdited <> 0 Then
    UpdateLastEdit(Sender);
  If Sender = FRegExText Then
    stbrEditorStatus.Panels[0].Text := 'RegEx'
  Else If Sender = FSynEdit Then
    stbrEditorStatus.Panels[0].Text := 'Preview'
  Else
    stbrEditorStatus.Panels[0].Text := '(unknown)';
  stbrEditorStatus.Panels[1].Text := Format('Line: %d', [(Sender As TSynEdit).CaretY]);
  stbrEditorStatus.Panels[2].Text := Format('Column: %d', [(Sender As TSynEdit).CaretX]);
  stbrEditorStatus.Panels[3].Text := Format('Index: %d', [(Sender As TSynEdit).SelStart]);
  stbrEditorStatus.Panels[4].Text := Format('Length: %d', [(Sender As TSynEdit).SelLength]);
End;

(**

  This method saves the settings to the INI File.

  @precon  None.
  @postcon The apps settings are saved to the ini file.

**)

Procedure TfrmDGHGrepMainForm.SaveSettings;

Var
  i: Integer;

Begin
  FIniFile.WriteInteger('Setup', 'Top', Top);
  FIniFile.WriteInteger('Setup', 'Left', Left);
  FIniFile.WriteInteger('Setup', 'Width', Width);
  FIniFile.WriteInteger('Setup', 'Height', Height);
  FIniFile.WriteInteger('Setup', 'Results', vstResults.Width);
  FIniFile.WriteInteger('Setup', 'GrepHeight', pnlGrepSearch.Height);
  FIniFile.WriteString('Setup', 'RegExFileName', FRegExFileName);
  FIniFile.WriteInteger('Setup', 'UpdateInterval', FUpdateInterval);
  If DirectoryExists(ExtractFilePath(FRegExFileName)) Then
    FRegExText.Lines.SaveToFile(FRegExFileName);
  FIniFile.WriteString('Setup', 'Files', edtFiles.Text);
  FIniFile.EraseSection('ExpandedNodes');
  For i := 0 To FExpandedNodes.Count - 1 Do
    If NativeUInt(FExpandedNodes.Objects[i]) > 0 Then
      FIniFile.WriteInteger('ExpandedNodes', FExpandedNodes[i],
        NativeUInt(FExpandedNodes.Objects[i]));
  SaveSynEditToINI(FRegExText, 'RegExtext', FINIFile);
  SaveSynEditToINI(FSynEdit, 'Preview',FIniFile);
  SaveSynEditHighlighterToINI(FSynRegExSyn, 'RegExHighlighter', FINIFile);
  SaveSynEditHighlighterToINI(SynPasSyn, 'PasHighlighter', FINIFile);
  SaveSynEditHighlighterToINI(SynCppSyn, 'CPPHighlighter', FINIFile);
  FIniFile.UpdateFile;
  FIniFile.Free;
End;

(**

  This method searches the given file for regular expression matches previously compiled into the
  FRegEx field.

  @precon  Node must be a valid instance.
  @postcon Matches and groups are added to the given field if found in the files.

  @param   strFileName as a String as a constant
  @param   Node        as a PVirtualNode
  @return  a TRegExResult

**)
Function TfrmDGHGrepMainForm.SearchFile(Const strFileName: String;
  Node: PVirtualNode): TRegExResult;

Var
  sl: TStringList;
  MC: TMatchCollection;
  iMatch: Integer;
  M: TMatch;
  N: PVirtualNode;
  G: TGroup;
  iGroup: Integer;
  dblStart: Double;

Begin
  Result.Reset;
  sl := TStringList.Create;
  Try
    sl.LoadFromFile(strFileName);
    dblStart := TickTime;
    MC := FRegEx.Matches(sl.Text);
    Result.FTimeForRegEx := TickTime - dblStart;
    For iMatch := 0 To MC.Count - 1 Do
      Begin
        CheckForAbort(Self);
        Inc(Result.FMatchesFound);
        M := MC.Item[iMatch];
        N := AddNode(Node, M.Value, strFileName, ntMatch, iMatch, M.Index, M.Length);
        For iGroup := 0 To M.Groups.Count - 1 Do
          Begin
            G := M.Groups.Item[iGroup];
            AddNode(N, G.Value, strFileName, ntGroup, iGroup, G.Index, G.Length);
          End;
      End;
  Finally
    sl.Free;
  End;
End;

(**

  This method re-expands all the previously expanded nodes.

  @precon  None.
  @postcon Previously expanded nodes are re-expanded.

**)

Procedure TfrmDGHGrepMainForm.SetExpandedNodes;

Var
  N: PVirtualNode;
  iNodeCount: Integer;

Begin
  N := vstResults.GetFirstChild(vstResults.RootNode);
  iNodeCount := 0;
  While N <> Nil Do
    Begin
      vstResults.IterateSubtree(N,
        Procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; Var Abort: Boolean)
        Var
          strPath: String;
          iIndex: Integer;
        Begin
          CheckForAbort(Sender);
          strPath := vstResults.Path(Node, 0, ttNormal, '|');
          If FExpandedNodes.Find(strPath, iIndex) Then
            vstResults.Expanded[Node] := NativeUInt(FExpandedNodes.Objects[iIndex]) > 0;
          If strPath = FSelectedPath Then
            Begin
              vstResults.FocusedNode := Node;
              vstResults.Selected[Node] := True;
              vstResultsChange(vstResults, Node);
            End;
          Inc(iNodeCount);
          If iNodeCount Mod 1000 = 0 Then
            TfrmProgress.UpdateProgress(
              Format('Setting expanded nodes (%1.0n in %1.0n)...', [Int(iNodeCount),
              Int(vstResults.TotalCount)]), iNodeCount, vstResults.TotalCount);
        End,
        Nil);
      N := vstResults.GetNextSibling(N);
    End;
End;

(**

  This method returns a high performance count from the system for measuring elapsed time.

  @precon  None.
  @postcon A high performance count is returned from the system.

  @return  a Double

**)
function TfrmDGHGrepMainForm.TickTime: Double;

Var
  t, f: Int64;

Begin
  QueryPerformanceCounter(t);
  QueryPerformanceFrequency(f);
  Result := 1000.0 * Int(t) / Int(f);
End;


(**

  This is an on timer event handler for the editor timer.

  @precon  None.
  @postcon If the reg ex text has been changed or the file filter (FLastEdited > 0) the files are
           reparsed and matched against the reg ex.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.tmTimerTimer(Sender: TObject);

Begin
  tmTimer.Enabled := False;
  Try
    If (FLastEdited <> 0) And (GetTickCount > FLastEdited + FUpdateInterval * 1000) And
      Not FParsing Then
      Begin
        FLastEdited := 0;
        FParsing := True;
        Try
          ParseRegEx(Sender);
        Finally
          FParsing := False;
        End;
      End;
  Finally
    tmTimer.Enabled := True;
  End;
End;

(**

  This method updates the last edited variable with the current tick count.

  @precon  None.
  @postcon The last edited variable is updated with the last tick count.

  @param   Sender as a TObject

**)
Procedure TfrmDGHGrepMainForm.UpdateLastEdit(Sender : TObject);

Begin
  FLastEdited := GetTickCount;
End;

(**

  This method adds the results of the reg ex search to the tree results.

  @precon  None.
  @postcon The results of the reg ex search are added to the tree results.

  @param   Node        as a PVirtualNode
  @param   RegExResult as a TRegExResult

**)
Procedure TfrmDGHGrepMainForm.UpdateMatches(Node: PVirtualNode; RegExResult : TRegExResult);

Var
  R: PVirtualNode;

Begin
  R := AddNode(Node, 'Results', '', ntResult);
  AddNode(R, Format('%1.0n Files', [Int(RegExResult.FFilesFound)]), '', ntResult);
  AddNode(R, Format('%1.0n Matches', [Int(RegExResult.FMatchesFound)]), '', ntResult);
  AddNode(R, Format('%1.1n ms', [RegExResult.FTimeForRegEx]), '', ntResult);
End;

(**

  This is an on change event handler for the vstResult control.

  @precon  None.
  @postcon Changes the contents of the syn edit contro based on the selected item in the tree view.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TfrmDGHGrepMainForm.vstResultsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData: PNodeData;
  NodeInfo: TNodeInfo;

Begin
  If Node <> Nil Then
    Begin
      NodeData := vstResults.GetNodeData(Node);
      NodeInfo := FNodeInfo[NodeData.FNodeIndex];
      Case NodeInfo.FNodeType Of
        ntError:
          Begin
            FLastFileName := '';
            FSynEdit.Lines.Text := NodeInfo.FValue;
            FSynEdit.Highlighter := Nil;
            FRegExText.CaretX := 1;
            FRegExText.CaretY := NodeInfo.FItemNum;
            FocusRegExTextLine(FRegExText.CaretY, FRegExText);
          End;
        ntElement: FindRegExDefinition(Node, FRegExText);
        ntPath: FindRegExDefinition(Node, FRegExText);
        ntFile:
          Begin
            If CompareText(NodeInfo.FFileName, FLastFileName) <> 0 Then
              FSynEdit.Lines.LoadFromFile(NodeInfo.FFileName);
            FLastFileName := NodeInfo.FFileName;
            FindHighlighter(NodeInfo.FFileName);
            FindRegExDefinition(Node, FRegExText);
          End;
        ntMatch, ntGroup:
          Begin
            If CompareText(NodeInfo.FFileName, FLastFileName) <> 0 Then
              FSynEdit.Lines.LoadFromFile(NodeInfo.FFileName);
            FLastFileName := NodeInfo.FFileName;
            FindHighlighter(NodeInfo.FFileName);
            FSynEdit.SelStart := Pred(NodeInfo.FIndex);
            FSynEdit.SelLength := NodeInfo.FLength;
            FocusRegExTextLine(FSynEdit.CaretY, FSynEdit);
            FindRegExDefinition(Node, FRegExText);
          End;
        ntRegEx:
          Begin
            FLastFileName := '';
            FSynEdit.Highlighter := FSynRegExSyn;
            FSynEdit.Lines.Text := FormatRegEx(NodeInfo.FValue);
            FindRegExDefinition(Node, FRegExText);
          End;
      End;
    End;
End;

(**

  This is an on click event handler for the results tree view.

  @precon  None.
  @postcon The selected files / match / group is shown in the preview for the selected result in
           the tree.

  @param   Sender         as a TBaseVirtualTree
  @param   Node           as a PVirtualNode
  @param   Column         as a TColumnIndex
  @param   LineBreakStyle as a TVTTooltipLineBreakStyle as a reference
  @param   HintText       as a String as a reference

**)
Procedure TfrmDGHGrepMainForm.vstResultsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; Var LineBreakStyle: TVTTooltipLineBreakStyle; Var HintText: String);

Const
  iMaxWidth = 120;

Var
  NodeData: PNodeData;
  sl : TStringList;
  iLine: Integer;
  strText: String;
  NodeInfo: TNodeInfo;

Begin
  NodeData := vstResults.GetNodeData(Node);
  NodeInfo := FNodeInfo[NodeData.FNodeIndex];
  sl := TstringList.Create;
  Try
    sl.Text := NodeInfo.FValue;
    iLine := 0;
    While iLine < sl.Count Do
      Begin
        If Length(sl[iLine]) > iMaxWidth Then
          Begin
            strText := sl[iLine];
            sl[iLine] := Copy(strText, 1, iMaxWidth);
            Delete(strText, 1, iMaxWidth);
            sl.Insert(iLine + 1, strText);
          End;
        Inc(iLine);
      End;
    HintText := sl.Text;
  Finally
    sl.Free;
  End;
End;

(**

  This method returns the text for the tree node.

  @precon  None.
  @postcon The text to be shown for the tree view ndoe is returned.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)

Procedure TfrmDGHGrepMainForm.vstResultsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Const
  strMatchText = 'Match #%2.2d (Value: "%s"; Index: %d; Length: %d)';
  strGroupText = 'Group #%2.2d (Value: "%s"; Index: %d; Length: %d)';

Var
  NodeData: PNodeData;
  NI: TNodeInfo;

Begin
  NodeData := Sender.GetNodeData(Node);
  NI := FNodeInfo[NodeData.FNodeIndex];
  Case NI.FNodeType Of
    ntMatch: CellText := Format(strMatchText, [NI.FItemNum, NI.FValue, NI.FIndex, NI.FLength]);
    ntGroup: CellText := Format(strGroupText, [NI.FItemNum, NI.FValue, NI.FIndex, NI.FLength]);
  Else
    CellText := NI.FValue;
  End;
End;

(**

  This method changes to font colour and style of the grep result nodes based on the node type.

  @precon  None.
  @postcon the font colour and style are changed depending on the node type.

  @param   Sender       as a TBaseVirtualTree
  @param   TargetCanvas as a TCanvas as a constant
  @param   Node         as a PVirtualNode
  @param   Column       as a TColumnIndex
  @param   TextType     as a TVSTTextType

**)
Procedure TfrmDGHGrepMainForm.vstResultsPaintText(Sender: TBaseVirtualTree;
Const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);

Var
  NodeData: PNodeData;
  strFontName: TFontName;
  iFontSize: Integer;
  NodeInfo: TNodeInfo;

Begin
  NodeData := Sender.GetNodeData(Node);
  NodeInfo := FNodeInfo[NodeData.FNodeIndex];
  strFontName := TargetCanvas.Font.Name;
  Case NodeInfo.FNodeType Of
    ntPath, ntFile, ntRegEx: TargetCanvas.Font.Name := 'Consolas';
  Else
    TargetCanvas.Font.Name := strFontName;
  End;
  iFontSize := TargetCanvas.Font.Size;
  Case NodeInfo.FNodeType Of
    ntPath, ntFile, ntRegEx: TargetCanvas.Font.Size := 11;
  Else
    TargetCanvas.Font.Size := iFontSize;
  End;
  Case NodeInfo.FNodeType Of
    ntError: TargetCanvas.Font.Color := clRed;
    ntElement: TargetCanvas.Font.Color := clNavy;
    ntPath: TargetCanvas.Font.Color := clNavy;
    ntFile: TargetCanvas.Font.Color := clNavy;
    ntMatch: TargetCanvas.Font.Color := clMaroon;
    ntGroup: TargetCanvas.Font.Color := clGrayText;
  Else
    TargetCanvas.Font.Color := clWindowText;
  End;
  Case NodeInfo.FNodeType Of
    ntElement: TargetCanvas.Font.Style := [fsBold];
    ntPath: TargetCanvas.Font.Style := [fsItalic];
  Else
    TargetCanvas.Font.Style := [];
  End;
End;

End.
