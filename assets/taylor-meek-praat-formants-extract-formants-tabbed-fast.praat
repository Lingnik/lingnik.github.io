! ExtractFormantsTabbedFast.praat
! (c) Taylor J. Meek, May 2008
! Uses in-built formant identification and extraction to write the formant data to a tab-delimited file.

! Future Improvements:
!  + Options to both Export and View.
!  + Ask for a file name.
!  + Include ratios in view mode.
!  + Limit number of formants to output.

preselected = selected ("Sound")

form Export Soundfile Formants
	comment The filename will be the name of the source file with the extension .txt, suitable for opening
	comment  directly with Excel or another spreadsheet program. i.e. 'ahmed-hello.wav' > 'ahmed-hello.txt'
	comment  The file will be exported to the directory Praat ran from.
	choice Data_Mode 1
	button Export Only
	button View Only
!	button View and Export
!	positive Maximum_Contiguous_Deviation_(Hz) 30
	comment The following settings match those from "Sound: To Formant (Burg method)" dialog.
	real Time_step_(s) 0.0
	positive Max._number_of_formants 5
	positive Maximum_formant_(Hz) 5500 (= adult female)
	real Window_length_(s) 0.025
	positive Pre-emphasis_from_(Hz) 50
endform

# To Formant (burg)... 0.0 5 5500 0.025 50
To Formant (burg)... 'Time_step' 'Max._number_of_formants' 'Maximum_formant' 'Window_length' 'Pre-emphasis_from'
filename$ = selected$ ("Formant")

if 'Data_Mode' = 1
  filedelete 'filename$'.txt

  ! Write the header row for the output file.
  fileappend 'filename$'.txt Sound'tab$'Time
  for iformant to 'Max._number_of_formants'
     fileappend 'filename$'.txt 'tab$'Formant'iformant''tab$'Ratio'iformant'
  endfor

  ! Parse each frame,
  numberOfFrames = Get number of frames
  for iframe to numberOfFrames
    time = Get time from frame number... iframe
    fileappend 'filename$'.txt 'newline$''filename$''tab$''time:6'
    lastpitch = -1
    for iFormant to 'Max._number_of_formants'
      pitch = Get value at time... iFormant time Hertz Linear
      if lastpitch = -1
        fileappend 'filename$'.txt 'tab$''pitch:3'
        lastpitch = pitch
      elsif pitch = undefined
        fileappend 'filename$'.txt 'tab$'0'tab$'0
      else
        pitchratio = pitch/lastpitch
        fileappend 'filename$'.txt 'tab$''pitchratio:5''tab$''pitch:3'
        lastpitch = pitch
      endif
    endfor
  endfor
  Remove
  select 'preselected'

elsif 'Data_Mode' = 2

 ! Write the header row for the output file.
 clearinfo
 print Sound'tab$'Time
 for iformant to 'Max._number_of_formants'
     printtab
     print F
     print 'iformant'
 endfor
 printline
 ! Write each frame to the info window.
 numberOfFrames = Get number of frames
  for iframe to numberOfFrames
     time = Get time from frame number... iframe
     print 'filename$''tab$''time:6'
     nFormants = 5
     for iFormant to nFormants
 	pitch = Get value at time... iFormant time Hertz Linear
 	if pitch = undefined
 	   print 'tab$'.
 	else
 	   print 'tab$''pitch:3'
 	endif
 	pitch = undefined
     endfor
     printline
 endfor
endif