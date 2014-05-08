! ExtractFormantsTabbed.praat
! (c) Taylor J. Meek, May 2008
! Uses in-built formant identification and extraction to write the formant data to a tab-delimited file.
! Slow: Puts information to the info window before writing to the file. Could be dramatically improved by
!  turning that into an option, and by default writing the data to the file only.

! Future Improvements:
!  + Options to Export/View/Both.
!  + Ask for a file name.
!  + Limit number of formants to output.

form Export Soundfile Formants
	comment The filename will be the name of the source file with the extension .txt, suitable for opening
	comment  directly with Excel or another spreadsheet program. i.e. 'ahmed-hello.wav' > 'ahmed-hello.txt'
	comment  The file will be exported to the directory Praat ran from.
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

! Write the info window to the file.
filedelete 'filename$'.txt
fappendinfo 'filename$'.txt