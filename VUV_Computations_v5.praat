##06 April 2009: version 1. Using autocorrelation.
## 01 April 2011: version 2. A few updates (for details, see Al-Tamimi and Khattab, 2015, JASA, 138(1): 344–360).  
## 25 May 2017: version 3. Using cross-correlation pitch estimate rather than autocorrelation 
## (for details, see Al-Tamimi and Khattab, 2018, Journal of Phonetics, Special Issue on VOT, 71: 306-325) 
## Estimation of Pitch is based on the two-pass method.
## 06 February 2019: version 4. Changed voicing threshold to 0.7 (instead of default 0.45) for a better 
## detection of voiced frames.
## 29 June 2022: Minor updates
## 11 November 2022: Minor update fixing the script; error on line 51! and updates to new Praat scripting code


## Get input from the user
beginPause: "VUV computations"
comment: "Enter the voicing threshold (default 0.7):"
real: "voicingThreshold", "0.7"
comment: "Press OK below and select the directory of sound files and TextGrids."
clicked = endPause: "OK", 1
directory1$ = chooseDirectory$("Select your directory of sound files and TextGrids")

## Validate inputs
if directory1$ = ""
    exitScript: "No directory selected. Please run the script again and select a directory."
endif
if voicingThreshold < 0 or voicingThreshold > 1
    exitScript: "Invalid voicing threshold. Please run the script again with a value between 0 and 1."
endif

Create Strings as file list: "list", "'directory1$'/*.wav"

numberOfFiles = Get number of strings

for i from 1 to numberOfFiles
	selectObject: "Strings list"
   	fileName$ = Get string: i

	Read from file: "'directory1$'/'fileName$'"
	name$ = selected$ ("Sound")
	Read from file: "'directory1$'/'name$'.TextGrid"
	selectObject: "Sound 'name$'"
	Filter (pass Hann band): 0, 500, 20
	soundFiltered = selected ("Sound")
	select 'soundFiltered'
	noprogress To Pitch (cc): 0.005, 50, 15, "yes", 0.03, voicingThreshold, 0.01, 0.35, 0.14, 600
	q1 = Get quantile: 0, 0, 0.25, "Hertz"
	q3 = Get quantile: 0, 0, 0.75, "Hertz"
	minPitch = q1*0.75
	maxPitch = q3*1.5
	Remove
	select 'soundFiltered'
	noprogress To Pitch (cc): 0.005, minPitch, 15, "yes", 0.03, voicingThreshold, 0.01, 0.35, 0.14, maxPitch
	pitch = selected ("Pitch")
	select 'soundFiltered'
	plus 'pitch'
	pointProsess = noprogress To PointProcess (cc)
	meanPeriod = Get mean period: 0, 0, 0.0001, 0.02, 1.3
	To TextGrid (vuv): 0.02, meanPeriod
	Rename: "'name$'_vuv"
	selectObject: "TextGrid 'name$'"
	plusObject: "TextGrid 'name$'_vuv"
	Merge
	
	## Write filename. use voicingThreshold
	Write to text file: "'directory1$'/'name$'_VUV_'string$ (voicingThreshold)'.TextGrid"
	select all
	minusObject: "Strings list"
	Remove
endfor
echo Finished! Check your new TextGrids located in 'directory1$'
