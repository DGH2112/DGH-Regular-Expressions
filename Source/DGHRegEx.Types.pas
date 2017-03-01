(**

  This module contains simple and record types for use throughout the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    04 Feb 2017

**)
Unit DGHRegEx.Types;

Interface

Uses
  System.RegularExpressionsCore;

Type
  (** An enumerate to define the type of data stored in a tree node. **)
  TNodeType = (ntError, ntElement, ntPath, ntFile, ntMatch, ntGroup, ntRegEx, ntResult);

  (** A record to describe the data stored in a tree node - an index into the Node Info
      collection. **)
  TNodeData = Record
    FNodeIndex: Integer;
    FFiles:     Integer;
    FMatches:   Integer;
    FTimeMS:    Int64;
  End;

  (** A record to describe te information returned for a reg ex pre-processing error. **)
  TDGHRegExError = Record
    FErrorMsg : String;
    FErrorLine : Integer;
    Constructor Create(strMsg : String; iLine : Integer);
  End;

  (** A pointer to the tree node record structure. **)
  PNodeData = ^TNodeData;

  (** An expcetion for missing Reg Ex Macros. **)
  ERegExMacroError = ERegularExpressionError;

Implementation

{ TDGHRegExError }

(**

  A constructor for the TDGHRegExError class.

  @precon  None.
  @postcon Initialises the error record.

  @param   strMsg as a String
  @param   iLine  as an Integer

**)
Constructor TDGHRegExError.Create(strMsg: String; iLine: Integer);

Begin
  FErrorMsg := strMsg;
  FErrorLine := iLine;
End;

End.
