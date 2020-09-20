include <lib/BOSL/constants.scad>
use <lib/BOSL/threading.scad>
use <lib/BOSL/involute_gears.scad>
use <lib/BOSL/transforms.scad>

// globals
$fn = $preview ? 30 : 150;

pitch = 5;
length = 20;
d = 20;
thread_angle = 15;
thread_depth = pitch / 2;
delta = thread_depth*tan(thread_angle);
profile = [
  [-pitch / 4 - delta / 2, -thread_depth],
  [-pitch / 4 + delta / 2,  0],
  [pitch / 4 - delta / 2,  0],
  [pitch / 4 + delta / 2, -thread_depth],
];


gear_height = d * 0.6;
gear_number_of_teeth = 30;
gear_radius = pitch * gear_number_of_teeth / PI / 2;
gear_chamfer = thread_depth;
x = d * 0.05;


support_width = d;
support_height = 2 + d * 0.65;
support_depth = 5;

translate([0, 0, -d / 2 - 5])
union() {
  linear_extrude(height = 3)
  hull() {  
    translate([gear_radius + d / 2 - thread_depth - x, gear_radius * 0.8, 0])
    circle(r = d / 2);

    translate([gear_radius + d / 2 - thread_depth - x, -gear_radius * 0.8, 0])
    circle(r = d / 2);

    circle(r = gear_radius * 0.7);
  }

  cylinder(r = gear_radius * 0.7, h = 5 + d / 2 - gear_height / 2 - 0.2);
  cylinder(r = gear_radius * 0.2 - 0.2, h = 5 + d / 2 + gear_height / 2);
  
  translate([gear_radius + d / 2 - thread_depth - x - support_width / 2, -gear_radius * 0.6, 3])
  rotate([90, 0, 0])
  rod_support();

  translate([gear_radius + d / 2 - thread_depth - x - support_width / 2, gear_radius * 0.6 + support_depth, 3])
  rotate([90, 0, 0])
  rod_support();
}

module rod_support() {
  linear_extrude(height = support_depth)
  union() {
    offset(r = 1) offset(delta = -1)
    difference(){
      square([support_width, support_height]);
      translate([support_width / 2, d / 2 + 2])
      circle(r = d / 2 - thread_depth + 0.2);
    }
    square([support_width, 1]);
  }
}  

helix_angle = atan(pitch / (PI * d));
echo(helix_angle=helix_angle);


#
//bottom_half(s=150)
difference() {
  rotate_extrude(angle = 360)
  difference() {
    polygon([
      [0, -gear_height / 2],
      [0, gear_height / 2],
      [gear_radius - thread_depth, gear_height / 2],
      [gear_radius, gear_height / 2 - gear_chamfer],
      [gear_radius, -gear_height / 2 + gear_chamfer],
      [gear_radius - thread_depth, -gear_height / 2]
    ]);
    
    translate([gear_radius + d / 2 - thread_depth - x, 0, 0])
    circle(r = d / 2 - thread_depth, $fn = 30);
  }

  
//  #translate([gear_radius + d / 2 - thread_depth - x, -pitch / 2, 0])
//  rotate([-90, 180, 0])
//  trapezoidal_threaded_rod(
//    d = d,
//    l = pitch,
//    pitch = pitch,
//    profile = profile / pitch,
//    center = false
//  );  
  zring(n=gear_number_of_teeth)
  translate([gear_radius + d / 2 - thread_depth - x, 0, 0])
  rotate([-helix_angle, 0, 0])
  rotate([90, 0, 0])
  rotate_extrude(angle = 360)
  union() {
    rotate([0, 0, -90])
    translate([0, d / 2, 0])
    offset(delta = 0.3)
    polygon(profile);
    translate([0, -(pitch / 2 + delta) / 2])
    square([d / 2 - thread_depth, pitch / 2 + delta]);
  }
  
  cylinder(r = gear_radius * 0.2, h = gear_height, center = true);
}


//#translate([gear_radius - thread_depth - x, 0, 0])
//rotate([0, 0, 90])
//linear_extrude(0.01)
//offset(delta = 0.3)
//polygon(profile);


//bottom_half(s = 150)
#translate([gear_radius + d / 2 - thread_depth - x, -length / 2, 0])
rotate([-90, 0, 0])
rotate([0, 0, 0])
union() {
  trapezoidal_threaded_rod(
    d = d,
    l = length,
    pitch = pitch,
    profile = profile / pitch,
    bevel = true,
    center = false
  );
  
  r_base = d / 2 - thread_depth;
  
//  translate([0, 0, length])
//  cylinder(h = r_base, r1 = r_base, r2 = r_base / 2);
//  
//  translate([0, 0, -r_base])
//  cylinder(h = r_base, r1 = r_base / 2, r2 = r_base);
  
  translate([0, 0, length / 2])
  cylinder(h = length * 3, r = d / 2 - thread_depth, center = true);
}


//translate([0, 0, 0])
//rotate([-helix_angle, 0, 0])
//cube([50, 0.05, 50], center = true);

//rotate([0, 0, 5])
//gear(
//  mm_per_tooth = pitch,
//  number_of_teeth = 20,
//  thickness = d * 0.4,
//  hole_diameter = 0,
//  pressure_angle = thread_angle,
//  twist = -helix_angle
//);