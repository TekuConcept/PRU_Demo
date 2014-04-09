PRU_Demo
========

Gathering a collection of demonstrations using the PRU peripheral on the Beaglebone Black



Motivation:
As part of an Autonomous Underwater Vehicle (AUV) research project for the annual AUVSI competition, our team decided to use two to four Beaglebone Black devices to be the brains and the controls. Though these BBBs alone, running Debian Linux, would be sufficient for our needs, it the concern of some of the members that there may be a rare glitch in the operating system that would cause a delay for an extensive amount of time, resulting in faulty predictions - in which they highly recommended scientific precision (a real-time system). For our primary RTS we will use the simple Arduino Uno R3 model. However, it has come to my attention that the BBB device also comes equipped with two programmable real time units (PRUs). To reduce the amount of hardware used and space occupied, I have taken on the task of further looking into PRU designs.

Credit Given Where Credit is Due:
Thanks to the following for their contributions online (saved me quite a bit of time from reading 4000+ pages of documentation):
Working seed (sample code):	Shabaz		      	www.element14.com/community
Additional Demos:		        Jadonk			      github.com/beagleboard/am335x_pru_package
						              	Lyren Brown	      groups.google.com
Quick Assembly Training:		TutorialsPoint		www.tutorialspoint.com/assembly_programming
							              Texas Instruments	processors.wiki.ti.com/index.php/PRU_Assembly_Instructions

Note: This repo is not complete and will be built up over time the more I use PRUs in my projects.
