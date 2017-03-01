(**

  This module contains a class which implements the IDGHRegExPreProcessingEng interface for
  expanding macros within regular expressions.

  @Author  David Hoyle
  @Version 1.0
  @Date    02 Feb 2017

**)
Unit DGHRegEx.RegExPreProcessingEng;

Interface

Uses
  Classes,
  DGHRegEx.Interfaces,
  DGHRegEx.Types,
  Generics.Collections,
  System.RegularExpressions;

Type
  (** A class to implement the IDGHRegExPreProcessingEng interface. **)
  TDGHRegExPreProcessingEng = Class(TInterfacedObject, IDGHRegExPreProcessingEng)
  Strict Private
    FExpandedRegExs     : TStringList;
    FRegExPreProcErrors : TList<TDGHRegExError>;
    FMacroRegExDecl     : TRegEx;
    FMacroNameRegEx     : TRegEx;
  private
    procedure RemoveCPPComments;
  Strict Protected
    // IDGHRegExPreProcessingEng
    Function  GetRegExByMacroName(const strMacroName : String) : String;
    Function  GetRegExCount: Integer;
    Function  GetRegEx(iIndex: Integer): String;
    Function  GetMacroName(iIndex : Integer) : String;
    Function  GetErrorCount: Integer;
    Function  GetError(iIndex: Integer): TDGHRegExError;
    // Other methods
    Procedure ExpandMacros;
    Procedure ExpandMacro(Match : TMatch; iLine : Integer; const strName : String;
      var strRegEx : String);
    Procedure AddErrorMsg(const strMsg : String; const iLine : Integer);
  Public
    Constructor Create(slRegExMacros: TStrings);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  CodeSiteLogging,
  System.SysUtils;

Const
  (** A regular expression to define a macro name "$(!Name)". **)
  strMacroNameDef = '\$\(!?[a-zA-Z]\w*\)';

{ TDGHRegExPreProcessingEng }

(**

  This method adds an error message and line number to the errors collection.

  @precon  None.
  @postcon An error is added to the error collection.

  @param   strMsg as a String as a Constant
  @param   iLine  as an Integer as a Constant

**)
Procedure TDGHRegExPreProcessingEng.AddErrorMsg(const strMsg: String; const iLine: Integer);

Var
  iLineNum : Integer;

Begin
  iLineNum := NativeUInt(FExpandedRegExs.Objects[iLine]);
  FRegExPreProcErrors.Add(TDGHRegExError.Create(Format(strMsg + ' (#%d)', [iLineNum]), iLineNum));
End;

(**

  This is a constructor for the TDGHRegExPreProcessingEng class.

  @precon  slRegExMacros must be a valid instance.
  @postcon The class is initialised and the macros expanded.

  @param   slRegExMacros as a TStrings

**)
Constructor TDGHRegExPreProcessingEng.Create(slRegExMacros: TStrings);

Begin
  FExpandedRegExs := TStringList.Create;
  FExpandedRegExs.Assign(slRegExMacros);
  RemoveCPPComments;
  FRegExPreProcErrors := TList<TDGHRegExError>.Create;
  FMacroRegExDecl := TRegEx.Create('^' + strMacroNameDef + '=', [roCompiled, roSingleLine]);
  FMacroNameRegEx := TRegEx.Create(strMacroNameDef, [roCompiled, roSingleLine]);
  ExpandMacros;
End;

(**

  This is a destructor for the TDGHRegExPreProcessingEng class.

  @precon  None.
  @postcon Frees the memory used by the class.

**)
Destructor TDGHRegExPreProcessingEng.Destroy;

Begin
  FRegExPreProcErrors.Free;
  FExpandedRegExs.Free;
  Inherited Destroy;
End;

(**

  This method removes C++ style comments /* ... */ from the regular expression file.

  @precon  None.
  @postcon All C++ style comments are removed from the file.

**)
Procedure TDGHRegExPreProcessingEng.RemoveCPPComments;

Var
  CommentRegEx: TRegEx;
  iLine: Integer;

Begin
  For iLine := 0 To FExpandedRegExs.Count - 1 Do
    FExpandedRegExs[iLine] := Format('%4.4d:', [Succ(iLine)]) + FExpandedRegExs[iLine];
  CommentRegEx := TRegEx.Create(
    '/\*\*?\s*(?<BlockCommentText>.*?)\s*\*?\*/|//\s*(?<LineCommentText>.*?)$',
    [roMultiLine, roCompiled, roSingleLine, roExplicitCapture]);
  FExpandedRegExs.Text := CommentRegEx.Replace(FExpandedRegExs.Text, '');
  For iLine := 0 To FExpandedRegExs.Count - 1 Do
    Begin
      FExpandedRegExs.Objects[iLine] := TObject(StrToInt(Copy(FExpandedRegExs[iLine], 1, 4)));
      FExpandedRegExs[iLine] := Copy(FExpandedRegExs[iLine], 6, Length(FExpandedRegExs[iLine]) - 5);
    End;
End;

(**

  This method replaces a singl macro founding in the regular expression (Match).

  @precon  Match must be a valid TMatch instances.
  @postcon The matched macro is replaced with its equivalent regular expression.

  @param   Match    as a TMatch
  @param   iLine    as an Integer
  @param   strName  as a String as a constant
  @param   strRegEx as a String as a reference

**)
Procedure TDGHRegExPreProcessingEng.ExpandMacro(Match : TMatch; iLine : Integer;
  const strName : String; var strRegEx : String);

Var
  iIndex: Integer;
  strMacroName: String;

Begin
  strMacroName := Match.Value;
  If CompareText(strName, strMacroName) = 0 Then
    AddErrorMsg(Format('Macro "%s" is self referencing!',
      [StringReplace(strMacroName, '!', '', [])]), iLine);
  iIndex := FExpandedRegExs.IndexOfName(strMacroName);
  If iIndex = - 1 Then
    Begin
      If Pos('!', Match.Value) > 0 Then
        strMacroName := StringReplace(Match.Value, '$(!', '$(', [])
      Else
        strMacroName := StringReplace(Match.Value, '$(', '$(!', []);
      iIndex := FExpandedRegExs.IndexOfName(strMacroName);
    End;
  If iIndex = - 1 Then
    AddErrorMsg(Format('Macro "%s" was not found!',
      [StringReplace(strMacroName, '!', '', [])]), iLine)
  Else If iIndex > FExpandedRegExs.IndexOfName(strName) Then
    AddErrorMsg(Format('Macro "%s" was defined after',
      [StringReplace(strMacroName, '!', '', [])]), iLine);
  // ONLY expand macro is there is some regular expression text.
  If FExpandedRegExs.Values[strMacroName] <> '' Then
    strRegEx :=
      Copy(strRegEx, 1, Match.Index - 1) +
      FExpandedRegExs.Values[strMacroName] +
      Copy(strRegEx, Match.Index + Match.Length, Length(strRegEx) - Match.Index + Match.Length);
End;

(**

  This method expands the macros found in the collection of macros provided in the constructor so
  that each macro definition should end up only containing a regular expression.

  @precon  None.
  @postcon All macros in the regular expressions are replaced with their definitions.

**)
Procedure TDGHRegExPreProcessingEng.ExpandMacros;

Var
  iLine: Integer;
  strName: String;
  strRegEx: String;
  MC: TMatchCollection;
  iMatch: Integer;
  ValidRegEx : TRegEx;

Begin
  iLine := 0;
  ValidRegEx := TRegEx.Create('^' + strMacroNameDef + '=', [roCompiled, roSingleLine]);
  While iLine < FExpandedRegExs.Count Do
    If ValidRegEx.IsMatch(FExpandedRegExs[iLine]) Then
      Begin
        strName := FExpandedRegExs.Names[iLine];
        strRegEx := FExpandedRegExs.Values[strName];
        If strRegEx = '' Then
          AddErrorMsg(Format('Empty macro definiton "%s"!', [strName]), iLine);
        MC := FMacroNameRegEx.Matches(strRegEx);
        If MC.Count > 0 Then
          Begin
            For iMatch := MC.Count - 1 Downto 0 Do
              ExpandMacro(MC.Item[iMatch], iLine, strName, strRegEx);
            FExpandedRegExs.Values[strName] := strRegEx;
            If strRegEx = '' Then
              FRegExPreProcErrors.Add(TDGHregExError.Create(
                Format('Macro "%s" was removed due to being empty!', [strName, Succ(iLine)]),
                Succ(iLine)
                ))
            Else
              Inc(iLine);
          End Else
            Inc(iLine);
      End Else
      Begin
        If FExpandedRegExs[iLine] <> '' Then
          AddErrorMsg(Format('Invalid macro definition "%s"!',
            [FExpandedRegExs[iLine]]), iLine);
        Inc(iLine);
      End;
End;

(**

  This is a getter method for the Error property.

  @precon  iIndex must be a valid index.
  @postcon Return an error record corresponding to the given index.

  @param   iIndex as an Integer
  @return  a TDGHRegExError

**)
Function TDGHRegExPreProcessingEng.GetError(iIndex: Integer): TDGHRegExError;

Begin
  Result := FRegExPreProcErrors[iIndex];
End;

(**

  This is a getter method for the ErrorCount property.

  @precon  None.
  @postcon Returns the number of errors found while expanding the macro list.

  @return  an Integer

**)
Function TDGHRegExPreProcessingEng.GetErrorCount: Integer;

Begin
  Result := FRegExPreProcErrors.Count;
End;

(**

  This is a getter method for the MacroName property.

  @precon  iIndex must be a valid index.
  @postcon Returns the name of the macro associated with the index.

  @param   iIndex as an Integer
  @return  a String

**)
Function TDGHRegExPreProcessingEng.GetMacroName(iIndex: Integer): String;

Var
  iCounter : Integer;
  iLine : Integer;

Begin
  Result := '';
  iCounter := -1;
  For iLine := 0 To FExpandedRegExs.Count - 1 Do
    If FMacroRegExDecl.IsMatch(FExpandedRegExs[iLine]) Then
      Begin
        Inc(iCounter);
        If iCounter = iIndex Then
          Begin
            Result := FExpandedRegExs.Names[iLine];
            Break;
          End;
      End;
End;

(**

  This is a getter method for the RegEx property.

  @precon  iIndex must be a vald index.
  @postcon Returns the regular expression associated with the index.

  @param   iIndex as an Integer
  @return  a String

**)
Function TDGHRegExPreProcessingEng.GetRegEx(iIndex: Integer): String;

Var
  iCounter : Integer;
  iLine : Integer;

Begin
  Result := '';
  iCounter := -1;
  For iLine := 0 To FExpandedRegExs.Count - 1 Do
    If FMacroRegExDecl.IsMatch(FExpandedRegExs[iLine]) Then
      Begin
        Inc(iCounter);
        If iCounter = iIndex Then
          Begin
            Result := FExpandedRegExs.ValueFromIndex[iLine];
            Break;
          End;
      End;
End;

(**

  This is a getter method for the RegExByMacroName property.

  @precon  None.
  @postcon Returns the regular expression associated with the given name if found else returns an
           empty string.

  @param   strMacroName as a String as a constant
  @return  a String

**)
Function TDGHRegExPreProcessingEng.GetRegExByMacroName(const strMacroName : String) : String;

Begin
  Result := FExpandedRegExs.Values[strMacroName];
End;

(**

  This is a getter method for the RegExCount property.

  @precon  None.
  @postcon Returns the number of regular expression macros in the collection.

  @return  an Integer

**)
Function TDGHRegExPreProcessingEng.GetRegExCount: Integer;

Var
  iLine: Integer;

Begin
  Result := 0;
  For iLine := 0 To FExpandedRegExs.Count - 1 Do
    If FMacroRegExDecl.IsMatch(FExpandedRegExs[iLine]) Then
      Inc(Result);
End;

End.


