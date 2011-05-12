SVGLAB version 1.0

SVGLAB moudle draws SVG pictures in MATLAB style.
There is no difficulty if you never heard of SVG, or never once used MATLAB.

The following script draws two SVG figures:

#!/usr/bin/perl 
use SVGLAB;
figure;
	$x=[200,450,500,250];
	$y=[300,100,150,300];
	polygon($x,$y,'red',2,'yellow');
figend;
#Generates SVGLAB1.svg
figure;
	line(100,300,400,300,2,'red');
	rect(500,400,100,300,10,10,'red',2,'yellow');
	circle(200,200,50,'red',2,'yellow');
	ellipse(300,200,50,30,'red',2,'yellow');
figend;
#Generates SVGLAB2.svg



See manual in doc/

by Zhang Shichao, China, zhshchao@163.com
