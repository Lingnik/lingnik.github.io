---
layout: post
title:  "Reverse Engineering the Yaesu VX-8DR GPS Interface"
date:   2013-02-10 02:09:00
alias: [/content/reverse-engineering-yaesu-vx-8dr-gps-interface/index.html]
---

**UPDATE 2014-04-13** [David Fannin](https://github.com/dfannin) built on this work and came up with some Arduino code that interfaces between the VX-8DR and a Ublox GPS module. You can see more information at his [project's github page](https://github.com/dfannin/arduino-vx8r-gps).

* 
{:toc}

I finally got my Technician Class amateur radio operator license (KG7BBG) last week, and I've been sitting on a Yaesu VX-8DR radio for about a year waiting to use it until now.

My first time on the air was an APRS beacon transmission, which was cool and all, getting to see my location at [aprs.fi][1]. However, the VX-8DR is notoriously cumbersome to manually enter latitude and longitude coordinates. The OEM GPS module for this radio retails at $160 for the module and mount, and the internal antenna is notorious for being mounted in such a way that if you wanted to get good coverage, you would have to lay the radio down on its back.[(Source)][2]

Sitting in one of my boxes, however, is a Garmin GPSMAP 60CSx GPS receiver with an RS232 serial interface (with a proprietary connector) for NMEA data. So naturally, I want to use this piece of equipment I already have in lieu of spending another $160 for something that doesn't work very well. This does mean that using GPS-fed APRS will be a little more cumbersome, since I'll have to carry a second piece of equipment (and also, as I think we'll see, a converter module).

## Incompatible, Proprietary, and Non-Standard

The first discovery I had was that the serial interfaces on these two devices is incompatible, and cannot be connected together directly. But before we get to that, here's some technical information on these two devices.

### Garmin GPSMAP 60CSx Serial Interface

The Garmin 60CSx has a round plug on the back with a four-pin interface. This is a proprietary interface which has several [cabling options][3], such as a bare cable (010-10082-00, $20.83 on Amazon) ready for custom wiring integrations.
![Garmin GPSMAP 60CSx Serial Interface Pinout][4]

In order to mock this up, I built a simple interface cable out of the hand-hacked equivalent of [Adafruit's female-male extension jumper wires][5]. (I only had male-male and female-female, so I soldered half of a male to half of a female.) The white wire in this photo is the transmit pin from the Garmin, and the black wire is ground.
![Garmin GPSMAP 60CSx Serial Connection Mockup to MOXA UPort 1150][6]

With this, I was able to connect this to my PC using an RS232 serial-to-USB adapter, and, using [PComm Lite Terminal Emulator from MOXA][7], capture the NMEA strings off the device. I configured the 60CSx (Setup&gt;Interfaces) to output NMEA formatted data and in the advanced settings (Menu&gt;Advanced NMEA Setup), enabled only GPS Status, Waypoint/Route, and left Lat/Lon precision at 4 digits. The 60CSx only supports 4800 baud on the NMEA serial interface, so I used the settings 4800/8/N/1 in PComm, and retrieved the following raw data. I've highlighted the relevant strings for what we'll need later.

    $GPRTE,1,1,c,*37
    $GPRMC,024006,A,1234.5678,N,12345.6789,W,3.3,26.2,100213,17.4,E,D*08
    $GPRMB,A,,,,,,,,,,,,V,D*19
    $GPGGA,024006,1234.5678,N,12345.6789,W,2,07,1.6,65.5,M,-20.2,M,,*49
    $GPGSA,A,3,,03,,,07,08,10,13,16,,23,,1.8,1.6,0.9*3C
    $GPGSV,3,1,12,02,01,290,00,03,27,101,18,05,07,327,00,06,23,079,00*72
    $GPGSV,3,2,12,07,60,277,33,08,30,259,23,10,43,280,21,13,78,098,17*79
    $GPGSV,3,3,12,16,36,050,15,19,11,120,00,23,49,123,16,48,36,194,30*7F
    $GPGLL,1234.5678,N,12345.6789,W,024006,A,D*51
    $GPBOD,,T,,M,,*47
    $GPVTG,26.2,T,8.7,M,3.3,N,6.1,K,D*18
    $HCHDG,8.7,,,17.4,E*14
    $GPRTE,1,1,c,*37


The 60CSx supports NMEA 0183 version 3.01, and the manual goes more into detail on the sentences it supports.

### Yaesu VX-8DR Serial Interface

The Yaesu VX-8DR has a round plug on the top with seven-pin interface. This is a proprietary interface with several [cabling options][8], such as a bare cable (CT-M11, $23.95 on Universal Radio) ready for custom wiring integrations.

![Pin numbers of Yaesu VX-8DR radio transceiver microphone/serial/gps connector][9]
![Pinout table of pin numbers and purpose for Yaesu VX-8DR radio transceiver microphone/serial/gps connector][10]
![Wire diagram of Yaesu CT-M11 cable connected to Yaesu VX-8DR radio transceiver][11]

In order to mock this up, I used a Maxton RPC-Y8R-UF programming cable I picked up from [G4HFQ][12] (I can't find the link to buy these cables on his site anymore, however). This is essentially an FTDI cable, which in this case is a three-wire interface (Ground, Rx, and Tx) at 3.3V levels. RS232 is a 5V%2B interface, which exposes the incompatibility between these two devices. The CT-M11 cable from Yaesu exposes all of the pins, which is useful for integrating a custom microphone/speaker interface along with GPS/programming.

![Maxton RPC-Y8R-UF cable used to connect to Yaesu VX-8DR over serial TTL][13]


At this point, I can connect the VX-8DR to my PC and, using PComm, transmit data to the radio over serial. Configuration settings are 9600/8/N/1 (NOT 4800 baud, another point of incompatibility between these two devices). Enter the APRS GPS menu (press 'MENU' once). You will see a compass with no arrow and empty coordinate fields.

### Sending GPS NMEA Strings to the Yaesu VX-8DR

Now that we can connect to the VX-8DR over 9600-baud 3.3V FTDI serial, we can send a string to the device with PComm Lite. Let's try the NMEA $GPGGA string from the Garmin directly -- paste it (CTRL%2BALT%2BP) into the session, and press ENTER to send it.

    $GPGGA,013622,1234.5678,N,12345.6789,W,2,09,0.9,00078,M,0020,M,,*49

The Yaesu spits out some information the first time you send it a serial message. Also, the Yaesu displays something on its display!

![Photo of Yaesu VX-8DR radio transceiver showing garbage data after receiving improper GPS NMEA sentence][14]

That's weird. The latitude and longitude are garbled, and speed/altitude are empty. Time to figure out what we sent means, and what we received means.

### The NMEA 0183 Standard

The NMEA 0183 standard is a product of the National Marine Electronics Association. It's a proprietary standard, and costs $250 to obtain. Thanks to the wonders of the internet, this is not a [major][15] hindrance.

As explained before, the Garmin 60CSx uses NMEA 0183 version 3.0.1. The Yaesu VX-8DR's version is not published, but we can try to infer it by doing a little research on the model used in the FGPS-2. Allegedly, the unit is a Position GPS-72(C). Datasheets are hard to find from this company, but we can find a [Position GPS-72 summary sheet][16] (translated, original in Japanese). Unfortunately, this doesn't tell us what version of NMEA it supports. Let's hope it uses something compatible with version 3.01.

From here on out, you need to understand that every NMEA sentence needs to include a carriage return (CR) and line feed (LF) at the end of each transmission. This is equivalent to hitting ENTER in a terminal session, assuming your application settings are correct.

### VX-8DR NMEA Handshake

Let's look at what the VX-8DR sends us first:

    $PSRF106,21*0F
    $PSRF103,0,0,1,1*25
    $PSRF103,1,0,0,1*25
    $PSRF103,2,0,0,1*26
    $PSRF103,3,0,0,1*27
    $PSRF103,4,0,2,1*22
    $PSRF103,5,0,0,1*21
    $PSRF103,8,0,0,1*2C

#### NMEA Address Field

$PSRFnnn: The first field is called the "address", and it is broken down as follows:

  * $: The first character in an NMEA message is either $ or !, and marks the beginning of a new sentence. $ identifies a sentence that conforms to a format of a delimited series of parameters.
  * PSRF: The second character, a P, followed by a three-character manufacturer code, indicates that this is a Proprietary Address Field registered with SRF[(Source)][17], or SiRF Technology. There are two other types of Fields: Approved Address Fields (things like GPGGA, which we sent to the radio), and Query Address Fields (which always start with a Q), which are used to ask another device to send it some information. NMEA is extremely complex in this regard. It doesn't just support GPS (it supports things like engine room monitoring, electronic chart systems, and radar), so there are a whole host of possible commands that are perfectly valid in NMEA, but would be ignored by a device that doesn't support them.
    * _The VX-8DR doesn't really have a SiRF chip inside it, although it may have code provided by SiRF. Or an engineer just emulated existing SiRF modules. There's no way to know without having access to the firmware source code._
  * nnn: The proprietary message code is the remainder of the address field. It is a unique code that indicates the type of command or message being sent.

#### Proprietary Message Codes

106/103: The proprietary message codes that the Yaesu advertises are as follows, and the meaning of the specific instances we received:

  * 106: The proprietary message code 106 is a command from the radio that specifies the GPS datum to use. 21 = WGS84[(source)][18].
  * 103: The proprietary message code 103 is a command from the radio that specifies which NMEA messages to send and how often[(source)][19]. 0=GGA, 1=GLL, 2=GSA, 3=GSV, 4=RMC, 5=VTG, 8=ZDA (if 1PPS output is supported)[(sup)][18]. The second field (0) is SetRate, the third (1, 0, 2) is the rate in seconds, and the fourth enables (1) or disables (0) the checksum. The number after the asterisk ( * ) is the checksum for the command.

The handshake sentences that the Yaesu VX-8DR sends mean it is asking the GPS receiver to use GPS datum WGS84, to transmit GGA every second, to transmit RMC every 2 seconds, and to send a checksum with those messages. We don't know whether other messages would normally be passed between the FGPS-2 and the VX-8DR, for example to negotiate a different baud rate, so we can't assume it's safe to use messages other than the ones it advertises.

Based on this, we know that the unit may support other messages, but it is expecting GGA and RMC to update its information. So let's look at what those two sentences look like.

### $GPGGA Messages - GPS Time, Position, and Fix Data

Much like the handshake, these sentences follow a fixed format as well.

As before, we have an address. This time it is an Approved Address Field. Approved Address Fields beginning with GP indicate the position is GPS based. GGA is the Sentence Formatter, specifically, the GPS Fix Data Sentence Formatter. GGA retrieves time, position, and fix related data for a GPS receiver.

It should be formatted like this:

    $--GGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh

It also must be terminated with a Line-Feed and Carriage-Return character -- in our terminal emulator, this is the equivalent of hitting the ENTER key.

#### Our Garmin $GPGGA Sample

Let's break down what we sent. The format of the GGA messages should be as follows, and I've broken down the message we were sending.[(source)][20]

    $GPGGA,013622,1234.5678,N,12345.6789,W,2,09,0.9,00078,M,0020,M,,*49
    $GPGGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*kk`

$GPGGA,|hhmmss.ss = UTC of position
013622,|llll.ll = latitude of position
1234.5678,|a = N or S
N,|yyyyy.yy = Longitude of position
12345.6789,|a = E or W
W,|x = GPS Quality indicator (0=no fix, 1=GPS fix, 2=Dif. GPS fix)
2,|xx = number of satellites in use
09,|x.x = horizontal dilution of precision
0.9,|x.x = Antenna altitude above mean-sea-level
00078,|M = units of antenna altitude, meters
M,|x.x = Geoidal separation
0020,|M = units of geoidal separation, meters
M,|x.x = Age of Differential GPS data (seconds)
,|xxxx = Differential reference station ID
*49|kk = checksum

It is worth noting that the spec says .ss, .ll, and .yy are all optional, and there are no minimum or maximum requirements on precision. Leading 0s are always required to maintain fixed length. For variables numbers (such as altitude or dilution of precision), the decimal point and decimal fractions are also optional. At this point, our sentence appears to conform to the specification.

If the sentence we sent the Yaesu was valid, but it did not extract the altitude data from the message, that must mean the VX-8DR does not conform to the NMEA standard. That is bad -- it means that now we have to figure out what the Yaesu is expecting. (This is also a poor engineering choice. Cutting corners happens all the time in software engineering, but when you have a closed interface and proprietary hardware that magically work with the device, this kind of choice is exactly how you keep it closed. Some frustrated part of me wants to say this was intentional, and that a product manager at Yaesu chose to lock consumers into their hardware to make more profit.)

We'll have to figure that sentence structure out later. Thankfully others have already done part of the job. We'll come back to that, but we have one more required and advertised sentence to examine.

### $GPRMC Messages - GNSS Time, Date, Position, Course, and Speed

RMC, Recommended Minimum Specific GNSS Data, retrieves time, date, position, course, and speed data. RMC is unique in that it is often accompanied by RMB, which handles destination waypoints. This isn't required by the Yaesu, and there's no advertisement that it is supported either.

The format for RMC messages is:

    $--RMC,hhmmss.ss,A,llll.ll,a,yyyyy.yy,a,x.x,x.x,xxxxxx,x.x,a,a*hh
    1 = UTC of position fix
    2 = Data status (V=navigation receiver warning)
    3 = Latitude of fix
    4 = N or S
    5 = Longitude of fix
    6 = E or W
    7 = Speed over ground in knots
    8 = Track made good in degrees True
    9 = UT date
    10 = Magnetic variation degrees (Easterly var. subtracts from true course)
    11 = E or W
    12 = Checksum

Again, the spec optionality, precision, and padding requirements stay the same. Let's try sending a message to the Yaesu. We'll start from scratch.

    $GPGGA,013622,1234.5678,N,12345.6789,W,2,09,0.9,00078,M,0020,M,,*49
    $GPRMC,013622,A,1234.5678,N,12345.6789,W,1.1,63.5,100213,17.4,E,D*0F

Same result as before. Garbage on the screen, and more importantly, speed is not displayed, which was a crucial part of GPRMC. The Yaesu does not conform with these messages either.

## If it doesn't conform, what is the right way to do it?

At this point, I'm wishing I had that $160 GPS module. I would hook it up and sniff the messages between the VX-8DR and the FGPS-2, because there may be 1) more to the handshake than we witnessed, and 2) some unique formatting the Yaesu expects NMEA messages to be in.

Others have picked up on 2), as we'll see shortly.

### VX8R Yahoo Group

Some very useful information can be gleaned from the work of others. In particular, [EA2CXK posted][21] some extremely helpful information. In particular, some sample raw messages from the FGPS-2:

    $GPZDA,123223.000,30,10,2011,,*55
    $GPGGA,123223.000,4131.2334,N,00021.1216,E,1,04,02.7,00123.4,M,0051.7,M,000.0,0000*41
    $GPRMC,123223.000,A,4131.2334,N,00021.1216,E,0000.00,291.33,301011,,*3E

As it turns out, the Yaesu **does** expect a certain format for its messages. Let's compare these with our original Garmin messages.

|-
|Message Type|Source|Sentence|
|-
|$GPGGA|Garmin|`$GPGGA,013622,1234.5678,N,12345.6789,W,2,09,0.9,00078,M,0020,M,,*49`|
||FGPS-2|`$GPGGA,123223.000,4131.2334,N,00021.1216,E,1,04,02.7,00123.4,M,0051.7,M,000.0,0000*41`|
|-
|$GPRMC|Garmin|`$GPRMC,013622,A,1234.5678,N,12345.6789,W,1.1,63.5,100213,17.4,E,D*0F`|
||FGPS-2|`$GPRMC,123223.000,A,4131.2334,N,00021.1216,E,0000.00,291.33,301011,,*3E`|
|-
|$GPZDA|Garmin|`We don't have one!`
||FGPS-2|`$GPZDA,123223.000,30,10,2011,,*55`|
|-

This right here is what we're looking for, as it tells us way more than any NMEA specification, or any GPS module datasheet can. Three sample lines from the FGPS-2 tell us exactly the format that the Yaesu is expecting to receive. If we can force all of our data into this format, we can communicate with the Yaesu. Let's look at it in detail to figure out the Yaesu VX-8DR NMEA format. Thank you Toni, EA2CXK, for posting what was missing in dozens of other forum and blog posts! If I ever hear you on air, I must thank you in person.

Here's proof that it works:

![Yaesu VX-8DR showing GPS status after correctly receiving a properly formatted GPS NMEA string over a serial TTL connection.][22]

### Yaesu VX-8DR $GPGGA NMEA Sentence Syntax

The Yaesu VX-8DR expects $GPGGA messages to follow the following format. This no longer follows the NMEA standard, so every character listed must be present. Numbers must be padded on the left with extra 0s to fill in any free spaces. Decimal fractions must be padded on the right with extra 0s to fill in any free spaces.

    $GPGGA,hhmmss.sss,llll.llll,a,yyyyy.yyyy,a,x,xx,xx.x,xxxxx.x,M,xxxx.x,M,xxx.x,xxxx*hh

You can see that, essentially, the Yaesu expects padded numbers of greater precision and magnitude than our Garmin was presenting.

I got curious, though, and changed the checksum to 00 on my messages. Guess what? The Yaesu still took them. Checksum can be anything. So instead of having to recalculate checksum after modifying the sentence, we can just set checksum to anything and the Yaesu should accept it. I say should because I haven't tested this thoroughly, but I'm optimistic this will work.

### Yaesu VX-8DR $GPRMC NMEA Sentence Syntax

The Yaesu VX-8DR expects $GPRMC sentences to follow the following format. The same caveats from $GPGGA apply.

    $GPRMC,hhmmss.sss,A,llll.llll,a,yyyyy.yyyy,a,xxxx.xx,xxx.xx,xxxxxx,,*hh

Once again, the Yaesu expects different padding. It is important to note that the Yaesu message also omits magnetic variation and mode indicator, and truncates one parameter position.

### Yaesu VX-8DR $GPZDA NMEA Sentence Syntax

We never talked about this one. ZDA is the "Time &amp; Date" command, and the Garmin never sent it, **but**, the Yaesu did say it supported it, even if it said it didn't require it to be sent. ZDA is the only command that we've seen so far that sends a date, which is extremely useful if we want to set a the time on a device that communicates with a GPS receiver. This is a pretty awesome thing for the Yaesu, because it is difficult to set the time on the thing because the manual is wrong. You can see [this thread][23] for information on how to set the time manually.

The Yaesu VX-8DR expects $GPZDA sentences to follow the following format. The same caveats from $GPGGA apply.

    $GPZDA,hhmmss.sss,xx,xx,xxxx,,*hh

This is beautiful. It supports date and time. It doesn't support local time zone (hours and minutes), but that's OK, because the Yaesu makes us set it manually in APRS option menu 25 - TIME ZONE anyways, if we want to use GPS time.

If you want to use GPS time on the VX-8DR, go to the APRS screens by pressing MENU from your TXO screens, enter the menu by holding down MENU for a second or two, and use the dial knob to select option 17 - GPS TIME SET. Press MENU to enter this menu item, use the dial wheel to select AUTO, and press MENU to save. Use the dial to scroll to 25 - TIME ZONE, press MENU to enter this menu item, use the dial wheel to select the UTC offset in hours and minutes, and press MENU to save. Hold down MENU for one to two seconds to exit the menu.

Once you send a ZDA message to the radio after setting these options, the radio will automatically set its time. If your GPS is not sending time as UTC, you may need to fiddle with your time zone settings to get the radio to show the right time, or fiddle with your intermediary interface to shift the time before sending it to the Yaesu.

(Also, if you decide to play with your 16 - GPS DATUM settings, be aware that if you aren't currently connected to GPS, it may cease to let you change it again. When this happened, and I got stuck in the 'Tokyo Mean' datum, I panicked a little -- would I have to wipe my unit and reprogram it? What if that didn't work? If you get in this position, send another series of valid GPS sentences to the radio, go into the menu while it still says it can see satellites, and you can change it again.)

### How different is the Yaesu from the Garmin?

Here's a visualization, to help make it clearer:


+----|----|----+
Message|Source|Sentence
+----|----|----+
$GPGGA|Garmin|`$GPGGA,013622____,1234.5678,N,12345.6789,W,2,09,_0.9,00078__,M,0020__,M,_____,____*49`
 |FGPS-2|`$GPGGA,123223.000,4131.2334,N,00021.1216,E,1,04,02.7,00123.4,M,0051.7,M,000.0,0000*41`
 |Syntax|`$GPGGA,hhmmss.sss,llll.llll,a,yyyyy.yyyy,a,x,xx,xx.x,xxxxx.x,M,xxxx.x,M,xxx.x,xxxx*hh`
$GPRMC|Garmin|`$GPRMC,013622____,A,1234.5678,N,12345.6789,W,___1.1_,_63.5_,100213,17.4,E,D*0F`
 |FGPS-2|`$GPRMC,123223.000,A,4131.2334,N,00021.1216,E,0000.00,291.33,301011,,*3E`
 |Syntax|`$GPRMC,$GPRMC,hhmmss.sss,A,llll.llll,a,yyyyy.yyyy,a,xxxx.xx,xxx.xx,xxxxxx,,*hh`
$GPZDA|Garmin|`We don't have one!`
 |FGPS-2|`$GPZDA,123223.000,30,10,2011,,*55`
 |Syntax|`$GPZDA,hhmmss.sss,xx,xx,xxxx,,*hh`

### What about those other messages the Yaesu supports?

Remember, earlier, the Yaesu told us (via $PSRF103 sentences) that it supports certain NMEA sentences. Specifically, it supports these:

|-
|NMEA Code|Sentence Formatter|NMEA Description|Available Data
|-
|0|GGA|Global Positioning System Fix Data|Time, Position, Fix Status|
|1|GLL|Geographic Position - Latitude/Longitude|Latitude, Longitude, time, status, and mode indicator|
|2|GSA|GNSS DOP and Active Satellites|GNSS receiver operating mode, satellites used in the navigation solution, and dilution of precision|
|3|GSV|GNSS Satellites in View|# of satellites in view, satellite ID numbers, elevation, azimuth, and SNR value|
|4|RMC|Recommended Minimum Specific GNSS Data|Time, date position, course, speed, magnetic variation, mode indicator|
|5|VTG|Course Over Ground and Ground Speed|Actual course and speed relative to the ground, and mode indicator|
|8|ZDA|Time &amp; Date|UTC, day, month, year, and local time zone|

I'll leave it to somebody else to figure these out, until I get my solution built. It's very possible that, despite the lack of examples, these sentences could be sent to the Yaesu in some meaningful way, for example the dilution of precision, or satellite data. I don't know enough about APRS yet to understand whether it's possible to include this information with your APRS packets.

## Summary

We now know how to connect to and send a properly formatted GPS NMEA message to the Yaesu VX-8DR. Here's the summary:

  * 9600baud TTL 3.3V serial signalling, 8/N/1
    * **NOT** RS232 5V signalling -- you need a level converter if that's all you have
  * 3-wire physical interface to the following pins:

|-
|Pin#|GPS Side Purpose|Yaesu Side Purpose|
|-
|4|GPS RX|Yaesu TX|
|5|GPS TX|Yaesu RX|
|6|GPS GND|Yaesu GND|

  * The messages need to be formatted exactly as follows:

|-
|Message|Source|Sentence
|-
|$GPGGA|Sample|`$GPGGA,123223.000,4131.2334,N,00021.1216,E,1,04,02.7,00123.4,M,0051.7,M,000.0,0000*41`|
| |Syntax|`$GPGGA,hhmmss.sss,llll.llll,a,yyyyy.yyyy,a,x,xx,xx.x,xxxxx.x,M,xxxx.x,M,xxx.x,xxxx*hh`|
|$GPRMC|Sample|`$GPRMC,123223.000,A,4131.2334,N,00021.1216,E,0000.00,291.33,301011,,*3E`|
| |Syntax|`$GPRMC,hhmmss.sss,A,llll.llll,a,yyyyy.yyyy,a,xxxx.xx,xxx.xx,xxxxxx,,*hh`|
|$GPZDA|Sample|`$GPZDA,123223.000,30,10,2011,,*55`|
| |Syntax|`$GPZDA,hhmmss.sss,xx,xx,xxxx,,*hh`|

  * The Yaesu may support other messages, in specific formats, TBD.

My Garmin GPSMAP 60CSx does not support TTL messaging at 9600 baud, nor does it support the proprietary NMEA sentence formats that the Yaesu expects. In order for me to go any further, I will need to:

  * Construct an interface proxy that has RS232 @ 4800 baud on one end and TTL @ 9600 baud on the other
  * Incorporate a micro-controller that can rewrite the NMEA sentences between the Yaesu and a GPS receiver
  * Figure out whether I want to power the microcontroller separately, such as with battery power, or invest money in the CT-M11 cable which outputs 3.3V from the VX-8DR, which should be sufficient to power, say, an ATtiny. (If I can source one that can support two serial interfaces, that is.)

This will have to wait until next time. I hope you find this useful. This research took about 10 hours in a single day of hacking.

## Yaesu VX-8DR NMEA Controller

Earlier we wanted to know what kind of NMEA chip this thing has. There's a service manual floating around for this unit. It indicates that the serial/microphone port connects to a board labeled CNTL-2 Unit, from which the GPS pins go to lines 'GPS_TXD' and 'GPS_RXD' -- which connect to pin K7 (RXD) and pin K6 (TXD) of IC HD64F2370VLP Q9024. This IC is identified elsewhere as a Renesas 16-Bit Single-Chip Microcomputer H8S Family/H8S/2300 Series. What does this mean? NMEA support is emulated in a microcontroller, and there's no easy way to dig further on this device. That was a dead end. (Unless we can somehow extract and reverse engineer the microcontroller firmware.)

We can take a parallel approach and look at the VX-8GR -- it has an integrated GPS module, and it is remotely possible that the FGPS-2 and VX-8GR have the same GPS module inside. (**Edit:** They don't, though, I found out later. The unit in the FGPS-2 is the Position GPS-72, and the unit inside the VX-8GR is the Position GPS-76. This according to an obscure reference in a [Italian forum posting][24]. It's possible they are similar enough that this doesn't matter, though.) The GPS unit sits in the place where the VX-8DR's microphone/GPS connector is, and its internal connector feeds into the CNTL board on the VX-8GR labeled J2006. Its pins are connected to GPS TXD, GPS RXD, GND, LPCTL, GPS 3V, and BACKUP 3V. GPS TXD and GPS RXD connect to the same pins on the microcontroller as the VX-8DR. The block diagram indicates the GPS antenna is AT7001, and the exploded parts diagram calls it out as Q7000642. Since these are internal part numbers, they don't do us much good. That was a dead end. (Unless we can get someone to disassemble their VX-8GR and take photos of their GPS module.)

There's no easy way to find out what version of NMEA the VX-8DR (or VX-8GR) support. (Until Yaesu support gets back to me.)

   [1]: http://aprs.fi/info/a/KG7BBG-7
   [2]: http://stuartl.longlandclan.yi.org/blog/2012/03/24/yaesu-vx8dr/
   [3]: https://buy.garmin.com/shop/shop.do?pID=310
   [4]: http://lingnik.com/assets/yaesu/garmin-gpsmap-60csx-serial-interface.png
   [5]: https://www.adafruit.com/products/824
   [6]: http://lingnik.com/assets/yaesu/Garmin_Interface_500px.jpg
   [7]: http://www.moxa.com/product/download_pcommlite_info.htm
   [8]: http://www.universal-radio.com/catalog/ht/0008.html
   [9]: http://lingnik.com/assets/yaesu/yaesu-ct-m11-cable-pin-numbers.png
   [10]: http://lingnik.com/assets/yaesu/yaesu-vx-8dr-mic-pinout.png
   [11]: http://lingnik.com/assets/yaesu/yaesu-ct-m11-cable-pinout.png
   [12]: http://www.g4hfq.co.uk/links.html
   [13]: http://lingnik.com/assets/yaesu/Yaesu_Cable_500px.jpg
   [14]: http://lingnik.com/assets/yaesu/Yaesu_Bad_500px.jpg
   [15]: https://www.google.com/search?q=nmea%2B0183%2Bversion%2B3.01%2Bfiletype%3Apdf
   [16]: http://translate.google.com/translate?hl=en&amp;sl=ja&amp;u=http://www.posit.co.jp/seihin/pdf/GPS-72_J.pdf&amp;prev=/search%3Fq%3D%2522position%2522%2B%2522gps-72%2522%2B%252251281-0894%2522%2Bfiletype:pdf%2B-garmin%26hl%3Den%26safe%3Doff%26tbo%3Dd%26biw%3D1280%26bih%3D699&amp;sa=X&amp;ei=3RsXUfe9B4z2igLTpIDoCA&amp;ved=0CDYQ7gEwAA
   [17]: http://www.nmea.org/Assets/20120830%200183%20manufacturer%20codes.pdf
   [18]: http://www.ekf.de/c/cgps/cg2/inf/nmea_reference_manual.pdf
   [19]: http://www.gpsinformation.org/dale/nmea.htm
   [20]: http://aprs.gids.nl/nmea/
   [21]: http://groups.yahoo.com/group/VX8R/message/1208
   [22]: http://lingnik.com/assets/yaesu/Yaesu_Good_500px.jpg
   [23]: http://www.worldwidedx.com/handitalkies/36965-vx-8r-setting-time-how.html
   [24]: http://www.arifidenza.it/forum/pop_printer_friendly.asp?ARCHIVE=true&amp;TOPIC_ID=161925
  
