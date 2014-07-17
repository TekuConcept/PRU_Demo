PRU_Demo
========

Gathering a collection of demonstrations using the PRU peripheral on the Beaglebone Black



Motivation:
As part of an Autonomous Underwater Vehicle (AUV) research project for the annual AUVSI competition, our team decided to use two to four bones to be the brains and controls. Though these bones alone, running Debian Linux, would be sufficient for our needs, it is the concern of some members that there may be a rare glitch in the operating system or that a process would enter into a spinlock causing a significant delay resulting in faulty predictions - with that they highly recommended scientific precision (a real-time system). It has come to my attention that the bone also comes equipped with two programmable real time units (PRUs). To reduce the amount of hardware used and space occupied, I have taken on the task of further looking into PRU designs.

Credit Given Where Credit is Due:
Thanks to the following for their contributions online (saved me quite a bit of time from reading 4000+ pages of documentation):
Working seed (sample code): Shabaz www.element14.com/community
Additional Demos: Jadonk www.github.com/beagleboard/am335x_pru_package ;
Lyren Brown www.groups.google.com
Quick Assembly Training: TutorialsPoint www.tutorialspoint.com/assembly_programming ;
Texas Instruments www.processors.wiki.ti.com/index.php/PRU_Assembly_Instructions

Note: This repo is not complete and will be built up over time the more I use PRUs in my projects.
