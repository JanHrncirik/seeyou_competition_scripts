Program Racing_task_with_handicap_Alternative_Scoring;
// Version 1.00 Date November 10, 2022 by Jan Hrncirik
//   .Alternative Scoring – Gliding, FOR NATIONAL, CONTINENTAL, AND WORLD GLIDING CHAMPIONSHIPS CLASS D (gliders) Including Class DM (motorgliders). 7 February 2022
//   .Modified from the version below. Changes are marked in capital letters.
// Version 7
//   . Support for new Annex A rules for minimum distance & 1000 points allocation per class
// Version 6 made by Wojciech for EGC 2019 Turbia
// Version 5.02, Date 25.04.2018
//   . Bugfix in Fcr formula
// Version 5.01, Date 03.04.2018
//   . Bugfix division by zero
// Version 5.00, Date 23.03.2018
//   . Task Completion Ratio factor added according to SC03 2017 Edition valid from 1 October 2017, updated 4 January 2018
// Version 4.00, Date 22.03.2017
//   . Support for Designated start scoring (start gate intervals)
//   . Enter "Interval=10" in DayTag to have 10 minute gate time intervals
//   . Enter "NumIntervals=7" in DayTag to have 7 possible start gates (last one is exactly one hour after start gate opens). 
//   . Separate Tags with ; (required)
//   . Example of the above two with 13:00:00 entered as start gate. DayTag: "Inteval=10;NumIntervals=7" gives possible start times at 13:00, 13:10, 13:20, 13:30, 13:40, 13:50 and 14:00
//   . Buffer zone as a script parameter
// Version 3.20, Date 04.07.2008
//   . added warnings when Exit appears
// Version 3.01
//   . Changed If Pilots[i].takeoff > 0 to If Pilots[i].takeoff >= 0. It is theoretically possible that one takes off at 00:00:00 UTC
// Version 2.08, Date 13.08.2003

var
//Dt, Td, n1, n2, N, D0, V0, T0, Dm, Hmin, Pm, Pdm, Pvm, Pn, F, Fcr, Day: Double; CORRECTED; DELETED Dt, Td, Pdm, Pvm, Pn; ADDED Sp0, Spm
          n1, n3, N, D0, V0, T0, Dm, Hmin, Pm, F, Fcr, Sp0, Spm, Day: Double;
  
//D, D1, H, Dh, Dg, M, T, Dc, Pd, V, Vh, Pv, S : double; CORRECTED; DELETED Dg, M, Dc, ; ADDED Sp, S
  D, D1, H, Dh, T, Pd, V, Vh, Pv, Sp, S : double;
  
  PmaxDistance, PmaxTime : double;
  
  i,j,k : integer; //ADDED "k" variable for the number of racers that will have points <> 0
  str : String;
  Interval, NumIntervals, GateIntervalPos, NumIntervalsPos, PilotStartInterval, PilotStartTime, PilotPEVStartTime, StartTimeBuffer : Integer;

Function MinValue( a,b,c : double ) : double;
var m : double;
begin
  m := a;
  If b < m Then m := b;
  If c < m Then m := c;

  MinValue := m;
end;

// ADDED MaxValue function
Function MaxValue( a,b : double ) : double;
var m : double;
begin
  m := a;
  If b > m Then m := b;

  MaxValue := m;
end;

begin
  // Minimum Distance to validate the Day, depending on the class [meters]
  Dm := 100000;
  if Task.ClassID = 'club' Then Dm := 100000;
  if Task.ClassID = '13_5_meter' Then Dm := 100000;
  if Task.ClassID = 'standard' Then Dm := 120000;
  if Task.ClassID = '15_meter' Then Dm := 120000;
  if Task.ClassID = 'double_seater' Then Dm := 120000;
  if Task.ClassID = '18_meter' Then Dm := 140000;
  if Task.ClassID = 'open' Then Dm := 140000;
  
  // Minimum distance for 1000 points, depending on the class [meters]
  if Task.ClassID = 'club' Then D1 := 250000;
  if Task.ClassID = '13_5_meter' Then D1 := 250000;
  if Task.ClassID = 'standard' Then D1 := 300000;
  if Task.ClassID = '15_meter' Then D1 := 300000;
  if Task.ClassID = 'double_seater' Then D1 := 300000;
  if Task.ClassID = '18_meter' Then D1 := 350000;
  if Task.ClassID = 'open' Then D1 := 350000;
  
  // DESIGNATED START PROCEDURE
  // Read Gate Interval info from DayTag. Return zero if Intervals and NumIntervals are unparsable or missing
  
  StartTimeBuffer := 30; // Start time buffer zone. If one starts 30 seconds too early he is scored by his actual start time
  
  GateIntervalPos := Pos('Interval=',DayTag);
  NumIntervalsPos := Pos('NumIntervals=',DayTag);								// One separator is assumed and it is assumed that Interval will be the first parameter in DayTag.

  Interval := StrToInt( Copy(DayTag,GateIntervalPos+9,(NumIntervalsPos-GateIntervalPos-10)), 0 )*60;		// Interval length in seconds. Second parameter in IntToStr is fallback value
  NumIntervals := StrToInt( Copy(DayTag,NumIntervalsPos+13,5), 0 );						// Number of intervals

  if NumIntervals > 0 then Info3 := 'Start time interval = '+IntToStr(Interval div 60)+'min';                   //ADEDD IF Only display number of intervals if it is not zero
  if NumIntervals > 0 then Info4 := 'Number of intervals = '+IntToStr(NumIntervals);				// Only display number of intervals if it is not zero
  
  // Adjust Pilot start times and speeds if Start Gate intervals are used
  if NumIntervals > 0 Then
  begin
    for i:=0 to GetArrayLength(Pilots)-1 do
	begin
	  PilotStartInterval := Round(Pilots[i].start - Task.NoStartBeforeTime) div Interval;					// Start interval used by pilot. 0 = first interval = opening of the start line
	  PilotStartTime := Task.NoStartBeforeTime + PilotStartInterval * Interval;

	  If PilotStartInterval > (NumIntervals-1) Then PilotStartInterval := NumIntervals-1;					// Last start interval if pilot started late
	  If (Pilots[i].start > 0) and ((PilotStartTime + Interval - Pilots[i].start) > StartTimeBuffer) Then		// Check for buffer zone to next start interval
	  begin
        Pilots[i].start := PilotStartTime;
		if Pilots[i].speed > 0 Then
		  Pilots[i].speed := Pilots[i].dis / (Pilots[i].finish - Pilots[i].start);
	  end;														// Else not required. If started in buffer zone actual times are used
	end;
  end;

  // Calculation of basic parameters
  N := 0;  // Number of pilots having had a competition launch
  N1 := 0;  // Number of pilots with Marking distance greater than Dm - normally 100km
  Hmin := 100000;  // Lowest Handicap of all competitors in the class
  n3 := 0; //ADDED; The number of competitors who reached the goal
  
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    If not Pilots[i].isHC Then
    begin
      If Pilots[i].Hcap < Hmin Then Hmin := Pilots[i].Hcap; // Lowest Handicap of all competitors in the class
    end;
  end;
  If Hmin=0 Then begin
	  Info1 := 'Error: Lowest handicap is zero!';
  	Exit;
  end;

  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    If not Pilots[i].isHC Then
    begin
      If Pilots[i].dis*Hmin/Pilots[i].Hcap >= Dm Then n1 := n1+1;  // Competitors who have achieved at least Dm
      If Pilots[i].takeoff >= 0 Then N := N+1;    // Number of competitors in the class having had a competition launch that Day
      If Pilots[i].sfinish >= 0 then n3 := n3 + 1 //ADDED; The number of competitors who reached the goal
    end;
  end;
  If N=0 Then begin
	  Info1 := 'Warning: Number of competition pilots launched is zero';
  	Exit;
  end;
  
  D0 := 0;
  T0 := 0;
  V0 := 0;
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    If not Pilots[i].isHC Then
    begin
      // Find the highest Corrected distance
      If Pilots[i].dis*Hmin/Pilots[i].Hcap > D0 Then D0 := Pilots[i].dis*Hmin/Pilots[i].Hcap;
      
      // Find the highest finisher's speed of the day
      // and corresponding Task Time
      If Pilots[i].finish >= 0 Then
      begin
        If Pilots[i].speed*Hmin/Pilots[i].Hcap > V0 Then 
        begin
          V0 := Pilots[i].speed*Hmin/Pilots[i].Hcap;
          T0 := Pilots[i].finish-Pilots[i].start;
        end;
      end;
    end;
  end;
  If D0=0 Then begin
	  Info1 := 'Warning: Longest handicapped distance is zero';
  	Exit;
  end;
  
  // Maximum available points for the Day
  PmaxDistance := 1250*(D0/D1)-250;
  PmaxTime := (400*T0/3600.0)-200;
  If T0 <= 0 Then PmaxTime := 1000;
  Pm := MinValue( PmaxDistance, PmaxTime, 1000.0 );
  
  // Day Factor
  //F := 1.25* n1/N; CORRECTED to formula below
  F := Pm/1000;
  If F>1 Then F := 1;
  
 // Number of competitors who have achieved at least 2/3 of best speed for the day V0; DELETED
 // n2 := 0; DELETED
 // for i:=0 to GetArrayLength(Pilots)-1 do; DELETED
 // begin; DELETED
 //   If not Pilots[i].isHC Then; DELETED
 //   begin; DELETED
 //     If Pilots[i].speed*Hmin/Pilots[i].Hcap > (2.0/3.0*V0) Then; DELETED
 //     begin; DELETED
 //       n2 := n2+1; DELETED
 //    end; DELETED
 //   end; DELETED
 // end; DELETED
  
  // Completion Ratio Factor
  Fcr := 1;
  If n1 > 0 then
//  Fcr := 1.2*(n2/n1)+0.6; CORRECTED to formula below
    Fcr := 1.2*(n3/n1)+0.6;
  If Fcr>1 Then Fcr := 1; //IF IT DOES not reach 33 or more percent, points will be deducted by the Fcr coefficient

//Pvm := 2.0/3.0 * (n2/N) * Pm;  // maximum available Speed Points for the Day; DELETED
//Pdm := Pm-Pvm;                 // maximum available Distance Points for the Day; DELETED
  
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    // For any finisher
    If Pilots[i].finish > 0 Then
    begin
    //Pv := Pvm * (Pilots[i].speed*Hmin/Pilots[i].Hcap - 2.0/3.0*V0)/(1.0/3.0*V0); CORRECTED to formula below
      Pv := 1000 * ((Pilots[i].speed*Hmin/Pilots[i].Hcap)/V0);
    //If Pilots[i].speed*Hmin/Pilots[i].Hcap < (2.0/3.0*V0) Then Pv := 0; DELETED
    //Pd := Pdm; CORRECTED to formula below
      Pd := 750*((Pilots[i].dis*Hmin/Pilots[i].Hcap)/D0);
    end
    Else
    //For any non-finisher
    begin
      Pv := 0;
    //Pd := Pdm * (Pilots[i].dis*Hmin/Pilots[i].Hcap/D0); CORRECTED to formula below
      Pd := 750 * (Pilots[i].dis*Hmin/Pilots[i].Hcap/D0);
    end;
    
    // Pilot's score
    //Pilots[i].Points := Round( F*Fcr*(Pd+Pv) - Pilots[i].Penalty ); CORRECTED to formula below
    Pilots[i].Points := F*Fcr*MaxValue( Pv, Pd);
  end;

//CALCULATION of Sp0- points of the winner and Spm- average points without those who have 0 points; 
  Sp0 := 0;
  Spm := 0;
  k   := 0;
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    if Sp0 < Pilots[i].Points then Sp0 := Pilots[i].Points;
    if Pilots[i].Points > 0 then 
    begin
      k := k + 1;
      Spm := Spm + Pilots[i].Points;
    end;
  end;

  if k > 0 then Spm := Spm/k;

// CALCULATION of competitor's points with correction for average points and penalty  
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
   if Sp0 = Spm then
      begin
        Pilots[i].Points := Pilots[i].Points - Pilots[i].Penalty;
        Info1 := 'Warning: Sp0 = Spm';
      end
    Else
     begin
        Pilots[i].Points := Pilots[i].Points * MinValue(1,200/(Sp0-Spm),10000) - Pilots[i].Penalty;
        Pilots[i].Points := Round(Pilots[i].Points);
     end;
  //  end;
  end;

  // Data which is presented in the score-sheets
  for i:=0 to GetArrayLength(Pilots)-1 do
  begin
    Pilots[i].sstart:=Pilots[i].start;
    Pilots[i].sfinish:=Pilots[i].finish;
    Pilots[i].sdis:=Pilots[i].dis;
    Pilots[i].sspeed:=Pilots[i].speed;
  end;
  
  // Info fields, also presented on the Score Sheets; ADDED display of variables n3, S0, V0 and Sm
  Info1 := Info1+' Maximum Points: '+IntToStr(Round(Pm))+', Dm: '+IntToStr(Round(Dm/1000))+' km, D0: '+FormatFloat('# #00.0', D0/1000)+' km, D1: '+IntToStr(Round(D1/1000))+' km, T0: '+FormatFloat('0.000',T0/3600)+' h, n1: '+FormatFloat('0.',n1)+', n3: '+ FormatFloat('0.',n3);
  Info2 := 'Day factor = '+FormatFloat('0.000',F)+', Completion factor = '+FormatFloat('0.000',Fcr)+', Sp0 = '+FormatFloat('# #00',Sp0)+', Spm = '+FormatFloat('# #00',Spm)+', V0 = '+FormatFloat('##0.0',V0*3.6)+' km/h';
end.
