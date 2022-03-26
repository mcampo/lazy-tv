/********************
model of mg996r servo
*********************/

//dimensions of central box (excluding the pads)
//height is including the proruding neck around the shaft
length = 40.5;
width = 20.5;
height = 39.3;

//total_length = length + pad_length * 2 = 53.3

//distance from nearest wall to the motor shaft
wall_to_shaft = 10;

//self explanatory measuremets
//hole_length = 48;
hole_distance = 10;
hole_diameter = 4.4;

//height is from ground to bottom of pad
pad_height = 29;
//self explanatory
pad_thick = 2.5;
pad_length = 7;

shaft_height = 5.6;
shaft_diameter = 5.75;

//convexity of holes
$fn = 20;

function servo_top() = height + shaft_height;
function servo_width() = width;
function servo_length() = length;
function servo_height() = height;
function servo_shaft_to_pad() = height - pad_height + shaft_height;
function servo_shaft_to_wall() = wall_to_shaft;
function servo_pad_height() = pad_height;
function servo_pad_length() = pad_length;
function servo_pad_hole_distance() = hole_distance;
function servo_shaft_diameter() = shaft_diameter;

translate([40, -6, 0])
cube([12, 12, 32]);

module pad(){
    color("lightgrey")
    difference(){
        cube([pad_length, width, pad_thick]);
        translate([pad_length/2, width/2-hole_distance/2, -0.5])
        cylinder(d=hole_diameter,h=pad_thick + 1);
        translate([pad_length/2, width/2+hole_distance/2, -0.5])
        cylinder(d=hole_diameter,h=pad_thick + 1);
    }
}

module servo(){
    translate([-wall_to_shaft, -width / 2, 0])
    union() {
      translate([-pad_length,0,pad_height])
      pad();

      translate([length,0,pad_height])
      pad();

      color("darkgrey")
      cube([length, width, height]);
      
      color("lightgrey")
      translate([wall_to_shaft, width/2, height])
      cylinder(h=shaft_height,d=shaft_diameter);
    }
}

servo();