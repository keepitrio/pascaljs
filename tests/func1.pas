program Sample;
  function Add(A, B: Boolean): Integer;
  begin
    Add := A or B;
  end;
var
  r: Boolean;
begin
  r := Add(true, false);
  WriteLn('A or B ', r);
end.