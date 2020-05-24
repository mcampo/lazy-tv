/********************
model of mg996r servo
*********************/

//dimensions of central box (excluding the pads)
//height is including the proruding neck around the shaft
length = 40.5;
width = 20;
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
shaft_diameter = 5.7;

//convexity of holes
$fn = 20;

module pad(){
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
      cube([length, width, height]);
      translate([wall_to_shaft, width/2, height])
      cylinder(h=shaft_height,d=shaft_diameter);
    }
}

servo();