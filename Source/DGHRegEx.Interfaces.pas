(**

  This module contains interfaces for implementing functionality within the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    24 Jan 2017

**)
Unit DGHRegEx.Interfaces;

Interface

Uses
  DGHRegEx.Types;

Type
  (** This interfaces defines the functionality of the Regular Expression Pre-Processing engine. **)
  IDGHRegExPreProcessingEng = Interface
  ['{490AF09A-39CB-4AC0-A2FE-B8D7C2BF2273}']
    Function  GetRegExByMacroName(const strMacroName : String) : String;
    Function  GetRegExCount : Integer;
    Function  GetRegEx(iIndex : Integer) : String;
    Function  GetMacroName(iIndex : Integer) : String;
    Function  GetErrorCount : Integer;
    Function  GetError(iIndex : Integer) : TDGHRegExError;
    (**
      This property returns the regular expression associated with the given macro name.
      @precon  None.
      @postcon Return the regular expression associated with the macro name.
      @param   strMacroName as a String as a constant
      @return  a String
    **)
    Property RegExByMacroName[const strMacroName : String] : String Read GetRegExByMacroName; Default;
    (**
      This property returns the number of regular expressions stored in the engine.
      @precon  None.
      @postcon Returns the number of regular expressions stored in the engine.
      @return  an Integer
    **)
    Property RegExCount : Integer Read GetRegExCount;
    (**
      This property returns the regular expression associated with the indexed macro.
      @precon  iIndex must be a valid index into the collection.
      @postcon Returns the regular expression associated with the given indexed macro.
      @param   iIndex as an Integer
      @return  a String
    **)
    Property RegEx[iIndex : Integer] : String Read GetRegEx;
    (**
      This property returns the macro name associated with the indexed macro.
      @precon  iIndex must be a valid index into the collection.
      @postcon Returns the macro name associated with the given indexed macro.
      @param   iIndex as an Integer
      @return  a String
    **)
    Property MacroName[iIndex : Integer] : String Read GetMacroName;
    (**
      This property returns the number of errors associated with the processing of the macros
      while expanding them.
      @precon  None.
      @postcon Returns the number of errors associated with expanding the macros.
      @return  an Integer
    **)
    Property ErrorCount : Integer Read GetErrorCount;
    (**
      This property returns a record describing the error associated with the given index.
      @precon  iIndex must be a valid index.
      @postcon Returns a record describing the error associated with the given index.
      @param   iIndex as an Integer
      @return  a TDGHRegExError
    **)
    Property Errors[iIndex : Integer] : TDGHRegExError Read GetError;
  End;

Implementation

End.
