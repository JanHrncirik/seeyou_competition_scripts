![SeeYou Competition Scoring Scripts](https://www.naviter.com/scoring_scripts_github.png)

### Table of contents
<!--ts-->
* [Writing your own scripts](#writing-your-own-scripts)
	* [Available variables for daily points scripts](#available-variables-for-daily-points-scripts)
	* [Available variables for total results script](#available-variables-for-total-results-script)
* [Contributing Guidelines](#contributing-guidelines)
<!--te-->

# Writing your own scripts

**Scripts for daily results**

SeeYou will calculate the day performance items like Marking Distance, speed, start and finish times etc.  It is the responsibility of the script to determine how many POINTS are awarded for the achieved  performance. 

SeeYou Competition scripts are implemented using the Innerfuse [Pascal Scripts](http://www.carlo-kok.com). They are very basic Pascal routines with some exceptions. 

You can write scripts in Notepad or any other Text  editor of your choice. You can assign scripts to each class of competition separately through Edit > Competition Properties > Scripts. 

![img](https://d33v4339jhl8k0.cloudfront.net/docs/assets/5a1c4392042863319924c769/images/5cf8efcc2c7d3a3837133075/file-TKhMl28z6o.png)

It is important to keep the general structure of the script: 

```pascal
Program Scoring_Script_Name;

begin

	// Your script here

end.
```

There are many variables available to the scoring script. See "Available variables for daily points script".

**Scripts for total rsults**

You can also write a script for Total results. Procedure is the same way as for daily scripts except that they are located in Edit > Competition Properties > Total Script. See "Available variables for total points script".

**How does it work?**

A TPilots record is provided by SeeYou to the Scoring script. TPilots record and a couple other fields determine all the information required to calculate the scoring for a given contest day. This is the definition of the TPilot record: 

## Available variables for daily points scripts

All variable values are **double** if not indicated otherwise
All times are **seconds since midnight** if not indicated otherwise

### TPilots
Type: Record
Information about pilot's performance. Typically used as Pilots[i].Hcap where i is a running integer in a loop.

| Variable                        | Description                                                  | Unit | Remarks                                       |
| ------------------------------- | :----------------------------------------------------------- | ---- | --------------------------------------------- |
| sstart                          | start time displayed in results sets                         | s    |                                               |
| sfinish                         | finish time displayed in results sets                        | s    | negative values - no finish                   |
| sdis                            | distance shown in results                                    | m    | negative values will be shown in parenthesis  |
| sspeed                          | speed shown in results                                       | m/s  | negative values will be shown in parenthesis  |
| points                          | points shown in results                                      |      |                                               |
| pointString                     | a string representation of points for custom output          |      | string                                        |
| Hcap                            | handicap factor as declared in pilot setup                   |      |                                               |
| penalty                         | penalty points defined in "Day performance" dialog           |      |                                               |
| start                           | start time of task                                           | s    | -1 if no start                                |
| finish                          | finish time of task                                          | s    | -1 if no finish                               |
| dis                             | flown distance                                               | m    |                                               |
| speed                           | speed of finished taks                                       | m/s  | -1 if no finish, takes into account task time |
| tstart                          | start time of task with time                                 | s    | -1 if no start                                |
| tfinish                         | finish time of task with time                                | s    |                                               |
| tdis                            | flown distance in task time                                  | m    |                                               |
| tspeed                          | flown distance divided by task time                          | m/s  |                                               |
| takeoff                         | takeoff time                                                 | s    | -1 if no takeoff                              |
| landing                         | landing time                                                 | s    | -1 if no landing                              |
| phototime                       | outlanding time                                              | s    | -1 if no outlanding                           |
| isHc                            | set to TRUE if not competing is used                         |      | bool                                          |
| FinishAlt                       | altitude of task finish                                      | m    |                                               |
| DisToGoal                       | distance between Task landing point and flight landing point | m    |                                               |
| Tag                             | string value as defined in Day performace dialog             |      | string                                        |
| Leg, LegT                       | array of TLeg records                                        |      | array                                         |
| Warning                         | used to set up a user warning                                |      | string                                        |
| CompID                          | Competition ID of the glider                                 |      | string                                        |
| PilotTag                        | string value as defined in Pilot edit dialog                 |      | string                                        |
| user_str1, user_str2, user_str3 | user strings, use for anything                               |      | string                                        |
| td1, td2, td3                   | temprary variables, use for anything                         |      |                                               |
| Markers                         | array of TMarker (see definition for TMarker below)          |      | array                                         |
| PotStarts                       | Array of all valid crossings of the start line. In seconds since midnight | s    | array of integers                             |

### TFix

Type: record

Information about each recorded position in the IGC file. This data is only available if the switch in Edit > Contest properties > Options > Expose fixes in scripts is enabled.

Typical use: QNH_Altitiude := Pilots[i].Fix[j].AltQNH; where i and j are running integeres in loops.

| Entry  | Description     | Unit | Remarks |
| ------ | --------------- | ---- | ------- |
| Tsec   | time of fix     | s    | integer        |
| AltQnh | Altitude above mean sea level | m    | double        |
| AltQne | Altitude above standard pressure level    | m    | double        |
| Gsp    | Ground speed    | m/s  | double        |
| DoT    | Distance on task| m    | double        |
| Cur    | Current current consumption | A | double; Requires LXNAV FES Bridge data stored in IGC file |
| Vol    | Current battery voltage      | V | double; Requires LXNAV FES Bridge data stored in IGC file |
| Enl    | Current value stored in ENL field | | double        |
| Mop    | Current value stored in MOP field | | double        |
| EngineOn | Wheter SeeYou determined that engine was running or not  |  | boolean        |

### TLeg 

Type: record

Task leg information for each Pilot's performance.

Typical use: Leg_distance := Pilots[i].Leg[j].d; where i and j are running integers in loops.

| Entry  | Description     | Unit | Remarks |
| ------ | --------------- | ---- | ------- |
| start  | leg start time  | s    |         |
| finish | leg finish time | s    |         |
| d      | leg distance    | m    |         |
| crs    | leg course      | rad  |         |

### TMarkers

Type: record 

Records of Pilot Event Marker (PEM) events - created when pilot depressed "Event Marker" button.

Typical use: PEV_time := Pilots[i].Markers[j].Tsec; where i and j are running integers in loops.

| Entry        | Description                                      | Unit | Remarks |
| ------------ | ------------------------------------------------ | ---- | ------- |
| Tsec         | time of the PEM                                  | s    | integer |
| Msg          | optional message stored with the PEM in IGC file |      | string  |
| info1, info2 | information shown in the results                 |      | string  |
| DatTag       | value as defined in "Day properties" dialog      |      | string  |
| ShowMessage  | string for debugging purposes                    |      | string  |

### Task 

Type: record

Basic information about task

Typical use: Task_Distance := Task.TotalDis;

| Entry             | Description                     | Unit | Remarks |
| ----------------- | ------------------------------- | ---- | ------- |
| TotalDis          | task distance                   | m    |         |
| TaskTime          | task time                       | s    | integer |
| NoStartBeforeTime | start time                      | s    | integer |
| Point             | array of TTaskPoints            |      | array   |
| ClassID           | enum of existing glider classes |      | string  |

ClassID enum:

- world
- club
- standard
- 13_5_meter
- 15_meter
- 18_meter
- double_seater
- open
- hang_glider_flexible
- hang_glider_rigid
- paraglider
- unknown

- ClassName: string; 
  Optional nice name for the given class - as entered at Soaring Spot.

### TTaskPoint

Type: record

Basic information about taskpoint which defines the task. Note that in Assigned Area Tasks these are not the optimal points which pilot achieved, but the points which define the task.

Typical use: Distance_to_next_TP_center := Task.TaskPoint[i].d; where i is a running integer in a loop.

| Entry         | Description                           | Unit | Remarks |
| ------------- | ------------------------------------- | ---- | ------- |
| lon           | longitude                             |      |         |
| lat           | lattitude                             |      |         |
| d             | distance to next point                | m    |         |
| crs           | course to next point                  | rad  |         |
| td1, td2, td3 | optional, used as temporary variables |      |         |

## Available variables for total results script

### Pilots

Type:  record

This record is used only in scripts which calculate total results. These are separate scripts from the scripts which compute results for each competition day. 

If Total script is empty, the daily points for each pilot are simply added together to create the pilot's total score. If you write a total script, then you can do advanced calculations for the pilot's total like dropping the worst day, or even calculating FTV in paragliding competitions. Let loose your creativity.

Typical use: Pilots[i].Total := Pilots[i].Total + Pilots[i].DayPts; where i is a running integer in a loop. 

| Entry        | Description                                         | Unit | Remarks                                  |
| ------------ | --------------------------------------------------- | ---- | ---------------------------------------- |
| Total        | total points                                        |      | default value is sum of DayPoints, not 0 |
| TotalString  | format of the total points when shown as string     |      | string                                   |
| DayPts       | Points from each day as calculated in daily scripts |      | array of doubles                         |
| DayPtsString | format of the day points when shown as string       |      | string                                   |

# Contributing guidelines

You wrote a great script, found a bug and corrected it? Great! To incorportate changes to existing scripts or adding your own scripts, please fork the repo, make your changes in a new branch and create a pull request. Pull requests from forks are described in [pull request from fork](https://help.github.com/en/articles/creating-a-pull-request-from-a-fork) article.
