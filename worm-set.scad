include <lib/BOSL/constants.scad>
use <lib/BOSL/threading.scad>
use <lib/BOSL/involute_gears.scad>
use <lib/BOSL/transforms.scad>

// globals
//$fn = $preview ? 30 : 150;
cut_extra = 0.2;

pitch = 5;
thread_angle = 15;
thread_depth = pitch / 2;
delta = thread_depth * tan(thread_angle);

module example() {
  worm_drive_diameter = 20;
  worm_drive_length = 20;

  wheel_height = worm_drive_diameter * 0.6;
  wheel_number_of_teeth = 53;
  wheel_radius = pitch * wheel_number_of_teeth / PI / 2;
  echo(inverse = wheel_radius / pitch * PI  * 2);
  wheel_chamfer = thread_depth; 

  base_width = worm_drive_diameter;
  base_height = 2 + worm_drive_diameter * 0.7;
  base_depth = 5;

  //bottom_half(s = 150) 
  translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), -worm_drive_length / 2, 0])
  rotate([-90, 0, 0])
  worm_drive(
    pitch = pitch,
    diameter = worm_drive_diameter,
    length = worm_drive_length
  );

  //bottom_half(s=150)
  worm_wheel(
    radius = wheel_radius,
    height = wheel_height,
    pitch = pitch,
    number_of_teeth = wheel_number_of_teeth,
    chamfer = wheel_chamfer,
    worm_drive_diameter = worm_drive_diameter,
    hole_radius = wheel_radius * 0.2
  );
  
  translate([0, 0, -worm_drive_diameter / 2 - 5])
  worm_set_base(
    wheel_radius = wheel_radius,
    wheel_height = wheel_height,
    worm_drive_diameter = worm_drive_diameter,
    worm_drive_thread_depth = thread_depth,
    base_width = base_width,
    base_height = base_height,
    base_depth = base_depth,
    worm_drive_distance = 2
  );
}

example();

function worm_drive_distance(
  wheel_radius,
  worm_drive_diameter,
  worm_drive_thread_depth
) = wheel_radius + worm_drive_diameter / 2 - worm_drive_thread_depth - __x(worm_drive_diameter);

function __x(worm_drive_diameter) = worm_drive_diameter * 0.05;

function teeth_profile(
  pitch,
  delta,
  depth
) = [
  [-pitch / 4 - delta / 2, -depth],
  [-pitch / 4 + delta / 2,  0],
  [pitch / 4 - delta / 2,  0],
  [pitch / 4 + delta / 2, -depth],
];

module worm_wheel(
  radius,
  height,
  pitch,
  number_of_teeth,
  chamfer,
  worm_drive_diameter,
  hole_radius = 0,
) {
  helix_angle = atan(pitch / (PI * worm_drive_diameter));

  difference() {
    rotate_extrude(angle = 360)
    difference() {
      polygon([
        [0, -height / 2],
        [0, height / 2],
        [radius - thread_depth, height / 2],
        [radius, height / 2 - chamfer],
        [radius, -height / 2 + chamfer],
        [radius - thread_depth, -height / 2]
      ]);
      
      translate([radius + worm_drive_diameter / 2 - thread_depth - __x(worm_drive_diameter), 0, 0])
      circle(r = worm_drive_diameter / 2 - thread_depth, $fn = 30);
    }

    zring(n=number_of_teeth)
    translate([radius + worm_drive_diameter / 2 - thread_depth - __x(worm_drive_diameter), 0, 0])
    rotate([-helix_angle, 0, 0])
    rotate([90, 0, 0])
    rotate_extrude(angle = 360)
    union() {
      rotate([0, 0, -90])
      translate([0, worm_drive_diameter / 2, 0])
      offset(delta = 0.3)
      polygon(teeth_profile(pitch = pitch, delta = delta, depth = thread_depth));

      translate([0, -(pitch / 2 + delta) / 2])
      square([worm_drive_diameter / 2 - thread_depth, pitch / 2 + delta]);
    }
    
    cylinder(r = hole_radius, h = height + cut_extra, center = true);
  }
}


module worm_drive(
  pitch,
  diameter,
  length
) {
  echo("profile", teeth_profile(pitch = pitch, delta = delta, depth = thread_depth) / pitch);
  trapezoidal_threaded_rod(
    d = diameter,
    l = length,
    pitch = pitch,
    profile = teeth_profile(pitch = pitch, delta = delta, depth = thread_depth) / pitch,
    bevel = true,
    center = false
  );
  
//  r_base = d / 2 - thread_depth;
//  translate([0, 0, length])
//  cylinder(h = r_base, r1 = r_base, r2 = r_base / 2);
//  translate([0, 0, -r_base])
//  cylinder(h = r_base, r1 = r_base / 2, r2 = r_base);
  
//  translate([0, 0, length / 2])
//  cylinder(h = length * 3, r = d / 2 - thread_depth, center = true);
}

module worm_set_base(
  wheel_radius,
  wheel_height,
  worm_drive_diameter,
  worm_drive_thread_depth,
  base_width,
  base_height,
  base_depth,
  worm_drive_distance
) {
  union() {
    linear_extrude(height = 3)
    hull() {
      translate([wheel_radius + worm_drive_diameter / 2 - worm_drive_thread_depth - __x(worm_drive_diameter), wheel_radius * 0.8, 0])
      circle(r = worm_drive_diameter / 2);

      translate([wheel_radius + worm_drive_diameter / 2 - worm_drive_thread_depth - __x(worm_drive_diameter), -wheel_radius * 0.8, 0])
      circle(r = worm_drive_diameter / 2);

      circle(r = wheel_radius * 0.7);
    }

    cylinder(r = wheel_radius * 0.7, h = 5 + worm_drive_diameter / 2 - wheel_height / 2 - 0.2);
    cylinder(r = wheel_radius * 0.2 - 0.2, h = 5 + worm_drive_diameter / 2 + wheel_height / 2);
    
    translate([wheel_radius + worm_drive_diameter / 2 - worm_drive_thread_depth - __x(worm_drive_diameter) - base_width / 2, -wheel_radius * 0.6, 3])
    rotate([90, 0, 0])
    rod_support(base_width, base_height, base_depth, worm_drive_diameter, worm_drive_diameter - thread_depth * 2, worm_drive_distance);

    translate([wheel_radius + worm_drive_diameter / 2 - worm_drive_thread_depth - __x(worm_drive_diameter) - base_width / 2, wheel_radius * 0.6 + base_depth, 3])
    rotate([90, 0, 0])
    rod_support(base_width, base_height, base_depth, worm_drive_diameter, worm_drive_diameter - thread_depth * 2, worm_drive_distance);
  }
}

module rod_support(
  base_width,
  base_height,
  base_depth,
  worm_drive_diameter,
  rod_diameter,
  worm_drive_distance,
  clearance = 0.15
) {
  linear_extrude(height = base_depth)
  union() {
    difference(){
      union() {
        offset(r = base_width * 0.1) offset(delta = -base_width * 0.1)
        square([base_width, base_height]);
        square([base_width, base_width * 0.1]);
      }
      translate([base_width / 2, worm_drive_diameter / 2 + worm_drive_distance])
      circle(r = rod_diameter / 2 + clearance);
    }
  }
}  
