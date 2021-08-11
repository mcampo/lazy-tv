use <lib/BOSL/involute_gears.scad>
use <led-hole.scad>
//use <mg90s.scad>
use <servo.scad>
use <worm-set.scad>
//include <test.scad>
// colors
// 66c2a5 fc8d62 8da0cb e78ac3 a6d854 ffd92f e5c494 b3b3b3

// globals
$fn = $preview ? 30 : 120;
cutExtra = 1;

// base dimensions
baseRadius = 145 / 2;
baseHeight = 26;
baseWidth = 10;

// base padding dimensions
basePaddingClearence=0.2;
basePaddingHeight = 0.6;
basePaddingGuideWidth = 1.6;
basePaddingGuideHeight = 6;

// ball rail
railRadius = (6.34) / 2  + 0.25;
railVerticalOffset = 1.5;
railOuterPadding = 2;
railHorizontalOffset = 5;

numberOfBalls = 16;//45;
cageHeight = 1.4;

// top dimensions
topWidth = baseWidth + 0; // base width + some space for the inner gear teeth
topVerticalOffset = baseHeight + railVerticalOffset * 2;
topHeight = 12;

// gears common
gearsModule = 1;
gearsPressureAngle = 20;
gearsClearance = 0.3;
gearsTeethLength = 6;

// face gear
faceGearInnerRadius = baseRadius - baseWidth - gearsTeethLength;
faceGearNumberOfTeeth = 2 * faceGearInnerRadius / gearsModule;
faceGearOuterRadius = faceGearInnerRadius + gearsTeethLength;
faceGearOuterModule = 2 * faceGearOuterRadius / faceGearNumberOfTeeth;
faceGearBaseHeight = 2;

// drive gear dimensions
driveGearGap = 1;
driveGearHeight = gearsTeethLength - driveGearGap;
driveGearNumberOfTeeth = 19;
driveGearRadius = driveGearNumberOfTeeth * gearsModule / 2;
driveGearHorizontalOffset = baseRadius - baseWidth - driveGearHeight / 2 - driveGearGap;
driveGearVerticalOffset = topVerticalOffset + topHeight- faceGearBaseHeight - driveGearRadius  - adendum(gearsModule) - gearsClearance;
driveGearHoleRadius = 5.75 / 2;
driveGearOverlap = 3;
shaftExtensionLength = 5;
shaftExtensionThickness = 2;

mounting_screw_hole_radius = 1.15 - 0.1;
mounting_screw_hole_height = 7;
mounting_screw_connecting_hole_radius = 1.6;

servo_to_worm_gears_pitch = 3;
servo_to_worm_gears_pressure_angle = 20;
servo_to_worm_gears_thickness = 3;
servo_to_worm_gears_clearance = 0.2;
servo_to_worm_gears_backlash = 0.2;
servo_to_worm_gears_shaft_length = 12;
servo_gear_number_of_teeth = 21;
servo_gear_shaft_mount_radius = servo_shaft_diameter() / 2 + 2;
servo_gear_shaft_mount_height = 4;
servo_gear_shaft_mount_hole_radius = servo_shaft_diameter() / 2 + 0.15;
servo_gear_pitch_radius = pitch_radius(mm_per_tooth=servo_to_worm_gears_pitch, number_of_teeth=servo_gear_number_of_teeth);
gear_worm_number_of_teeth = 16;
gear_worm_pitch_radius = pitch_radius(mm_per_tooth=servo_to_worm_gears_pitch, number_of_teeth=gear_worm_number_of_teeth);


servo_holder_thickness_bottom = 2;
servo_holder_thickness_top = 2;


pitch = 5;
thread_depth = pitch / 2;

worm_drive_diameter = 10;
worm_drive_length = 20;

wheel_height = worm_drive_diameter * 0.6;
wheel_number_of_teeth = 50;//ceil((baseRadius + thread_depth + 0.3 * 2) / pitch * PI  * 2);
wheel_radius = pitch * wheel_number_of_teeth / PI / 2;
wheel_thickness = 10;
wheel_inner_radius = wheel_radius - thread_depth - wheel_thickness;
wheel_chamfer = thread_depth;
worm_drive_vertical_position = servo_width() / 2 + servo_gear_pitch_radius + gear_worm_pitch_radius + servo_holder_thickness_bottom;

servo_to_worm_gears_shaft_diameter = worm_drive_diameter - thread_depth * 2;



echo(driveGearRadius=driveGearRadius);

color("LightBlue")
base();

color("Wheat")
cage();

color("LightSteelBlue")
top();

translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), -servo_top() + worm_drive_length / 2 + servo_to_worm_gears_shaft_length, servo_width() / 2 + servo_holder_thickness_bottom])
rotate(180, [0, 0, 1])
rotate(90, [1, 0, 0])
servo();

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), -worm_drive_length / 2, worm_drive_vertical_position])
rotate([-90, 0, 0])
worm_drive(
  pitch = pitch,
  diameter = worm_drive_diameter,
  length = worm_drive_length
);

wheel_connector_thickness = 2;
wheel_connector_length = baseRadius - wheel_inner_radius - 1;
wheel_connector_width = 10;
wheel_connector_vertical_offset = topVerticalOffset + topHeight - wheel_connector_thickness;
wheel_connector_joint_radius = 3;
wheel_connector_joint_insert = 2;
wheel_connector_joint_clearance = 0.3;

color("MediumAquamarine")
translate([0, 0, worm_drive_vertical_position])
worm_wheel_assembly();

module worm_wheel_assembly() {
  difference() {
    worm_wheel(
      radius = wheel_radius,
      height = wheel_height,
      pitch = pitch,
      number_of_teeth = wheel_number_of_teeth,
      chamfer = wheel_chamfer,
      worm_drive_diameter = worm_drive_diameter,
      hole_radius = wheel_inner_radius
    );
    
    for(i = [0:2]) {
      rotate(i * 360 / 3, [0, 0, 1])
      translate([0, wheel_inner_radius + wheel_thickness / 2, wheel_height / 2 - wheel_connector_joint_insert - wheel_connector_joint_clearance])
      cylinder(r = wheel_connector_joint_radius + wheel_connector_joint_clearance / 2, h = wheel_connector_joint_insert + wheel_connector_joint_clearance);
    }
  }
}

module wheel_connector() {
  translate([0, 0, wheel_connector_vertical_offset])
  union() {
    translate([-wheel_connector_width / 2, wheel_inner_radius, 0])
    cube([wheel_connector_width, wheel_connector_length, wheel_connector_thickness]);
  }
  
  translate([0, 0, -wheel_connector_joint_insert])
  translate([0, wheel_inner_radius + wheel_thickness / 2, worm_drive_vertical_position + wheel_height / 2])
  cylinder(r = wheel_connector_joint_radius, h = wheel_connector_vertical_offset - (worm_drive_vertical_position + wheel_height / 2) + wheel_connector_joint_insert);
}

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), worm_drive_length / 2, worm_drive_vertical_position])
rotate(-90, [1, 0, 0])
cylinder(d = servo_to_worm_gears_shaft_diameter, h = servo_to_worm_gears_shaft_length);

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), -worm_drive_length / 2, worm_drive_vertical_position])
rotate(90, [1, 0, 0])
cylinder(d = servo_to_worm_gears_shaft_diameter, h = servo_to_worm_gears_shaft_length / 2);



rod_support_width = worm_drive_diameter * 0.8;
rod_support_worm_drive_distance = worm_drive_vertical_position - servo_width() - worm_drive_diameter / 2 - servo_holder_thickness_bottom - servo_holder_thickness_top;
rod_support_height = worm_drive_diameter * 0.75 + rod_support_worm_drive_distance;
rod_support_depth = 4;
rod_support_clearance = 0.1;

rod_support_top_depth_position = worm_drive_length / 2 + 2;
rod_support_bottom_depth_position = -worm_drive_length / 2 - 2;
rod_support_base_depth = rod_support_top_depth_position - rod_support_bottom_depth_position + rod_support_depth * 2;

servo_to_worm_gears_shaft_stopper_diameter = rod_support_width;
servo_to_worm_gears_shaft_stopper_height = 3;

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), rod_support_top_depth_position + rod_support_depth, worm_drive_vertical_position])
servo_to_worm_gears_shaft_stopper();

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), rod_support_bottom_depth_position - rod_support_depth - servo_to_worm_gears_shaft_stopper_height, worm_drive_vertical_position])
servo_to_worm_gears_shaft_stopper();

module servo_to_worm_gears_shaft_stopper() {
  translate([0, servo_to_worm_gears_shaft_stopper_height, 0])
  rotate(90, [1, 0, 0])
  union(){
  cylinder(d1 = servo_to_worm_gears_shaft_diameter, d2 = servo_to_worm_gears_shaft_stopper_diameter, h = servo_to_worm_gears_shaft_stopper_height / 3);

  translate([0, 0, servo_to_worm_gears_shaft_stopper_height / 3])
  cylinder(d = servo_to_worm_gears_shaft_stopper_diameter, h = servo_to_worm_gears_shaft_stopper_height / 3);

  translate([0, 0, 2 * servo_to_worm_gears_shaft_stopper_height / 3])
  cylinder(d1 = servo_to_worm_gears_shaft_stopper_diameter, d2 = servo_to_worm_gears_shaft_diameter, h = servo_to_worm_gears_shaft_stopper_height / 3);
  }
}

color("PaleGreen")
servo_gear();

module servo_gear() {
  translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), worm_drive_length / 2 + servo_to_worm_gears_shaft_length, 0])
  translate([0, servo_to_worm_gears_thickness / 2, worm_drive_vertical_position - servo_gear_pitch_radius - gear_worm_pitch_radius])
  rotate(90, [1, 0, 0])
  union() {
    gear(mm_per_tooth=servo_to_worm_gears_pitch, number_of_teeth=servo_gear_number_of_teeth, thickness=servo_to_worm_gears_thickness, hole_diameter=0, pressure_angle=servo_to_worm_gears_pressure_angle, clearance = servo_to_worm_gears_clearance, backlash = servo_to_worm_gears_backlash);

    translate([0, 0, servo_to_worm_gears_thickness / 2])
    difference() {
      cylinder(r = servo_gear_shaft_mount_radius, h = servo_gear_shaft_mount_height);
      cylinder(r = servo_gear_shaft_mount_hole_radius, h = servo_gear_shaft_mount_height + cutExtra);
    }
  }
}

color("PowderBlue")
translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth), worm_drive_length / 2 + servo_to_worm_gears_shaft_length, worm_drive_vertical_position])
translate([0, servo_to_worm_gears_thickness / 2, 0])
rotate(360 / gear_worm_number_of_teeth / 2, [0, 1, 0])
rotate(90, [1, 0, 0])
gear(mm_per_tooth=servo_to_worm_gears_pitch, number_of_teeth=gear_worm_number_of_teeth, thickness=servo_to_worm_gears_thickness, hole_diameter=0, pressure_angle=servo_to_worm_gears_pressure_angle, clearance = servo_to_worm_gears_clearance, backlash = servo_to_worm_gears_backlash);

servo_holder_thickness_sides = servo_pad_length();
servo_holder_width = servo_length() + servo_holder_thickness_sides * 2;
servo_holder_depth = 20;
servo_holder_height = servo_width() + servo_holder_thickness_bottom + servo_holder_thickness_top;
servo_holder_bottom_connector_height = 10;
servo_holder_bottom_connector_clearance = 0.1;
servo_holder_clearance = 0.4;
servo_holder_mounting_screw_hole_radius = 1.15 - 0.1;
servo_holder_mounting_screw_hole_height = 7;
servo_holder_top_screw_hole_radius = 2;

color("Coral")
servo_holder();


module servo_holder() {
  servo_holder_top();
  servo_holder_bottom();
}


module servo_holder_top() {
  
  translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth) + servo_shaft_to_wall() - servo_holder_width / 2 - servo_length() / 2, -servo_holder_depth + worm_drive_length / 2 + servo_to_worm_gears_shaft_length - servo_shaft_to_pad(), servo_holder_height - servo_holder_thickness_top + servo_holder_clearance / 2])
  difference() {
    cube([servo_holder_width, servo_holder_depth, servo_holder_thickness_top - servo_holder_clearance / 2]);
    
    translate([servo_holder_thickness_sides / 2, servo_holder_depth / 2, 0])
    translate([0, 0, -cutExtra / 2])
    cylinder(r = servo_holder_top_screw_hole_radius, h = servo_holder_thickness_top + cutExtra);

    translate([servo_holder_width - servo_holder_thickness_sides / 2, servo_holder_depth / 2, 0])
    translate([0, 0, -cutExtra / 2])
    cylinder(r = servo_holder_top_screw_hole_radius, h = servo_holder_thickness_top + cutExtra);
  }

  translate([worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth) -rod_support_width / 2, 0, 0])
  union() {
    translate([0, rod_support_bottom_depth_position - rod_support_depth, servo_holder_height - servo_holder_thickness_top + servo_holder_clearance / 2])
    cube([rod_support_width, rod_support_base_depth, servo_holder_thickness_top - servo_holder_clearance / 2]);

    translate([0, rod_support_top_depth_position, worm_drive_vertical_position])
    translate([0, rod_support_depth, -worm_drive_diameter / 2 - rod_support_worm_drive_distance])
    rotate([90, 0, 0])
    rod_support(rod_support_width, rod_support_height, rod_support_depth, worm_drive_diameter, thread_depth, rod_support_worm_drive_distance, rod_support_clearance);

    translate([0, rod_support_bottom_depth_position, worm_drive_vertical_position])
    translate([0, 0, -worm_drive_diameter / 2 - rod_support_worm_drive_distance])
    rotate([90, 0, 0])
    rod_support(rod_support_width, rod_support_height, rod_support_depth, worm_drive_diameter, thread_depth, rod_support_worm_drive_distance, rod_support_clearance);
  }  
}

module servo_holder_bottom() {
  x_offset = worm_drive_distance(wheel_radius, worm_drive_diameter, thread_depth) + servo_shaft_to_wall() - servo_holder_width / 2 - servo_length() / 2;
  y_offset = -servo_holder_depth + worm_drive_length / 2 + servo_to_worm_gears_shaft_length - servo_shaft_to_pad();
  translate([x_offset, y_offset, 0])
  difference() {
    cube([servo_holder_width, servo_holder_depth, servo_holder_height]);
    
    translate([servo_holder_thickness_sides - servo_holder_clearance / 2, -cutExtra / 2, servo_holder_thickness_bottom - servo_holder_clearance / 2])
    cube([servo_length() + servo_holder_clearance, servo_holder_depth + cutExtra, servo_width() + servo_holder_clearance]);
    
    translate([-cutExtra / 2, -cutExtra / 2, servo_holder_height - servo_holder_thickness_top + servo_holder_clearance / 2])
    cube([servo_holder_width + cutExtra, servo_holder_depth + cutExtra, servo_holder_thickness_top + cutExtra]);
        
    translate([servo_pad_length() / 2, servo_holder_depth, servo_holder_height - servo_pad_hole_distance() / 2 - servo_holder_thickness_bottom])
    rotate(90, [1, 0, 0])
    cylinder(r = servo_holder_mounting_screw_hole_radius, h = servo_holder_mounting_screw_hole_height);

    translate([servo_holder_width - servo_pad_length() / 2, servo_holder_depth, servo_holder_height - servo_pad_hole_distance() / 2 - servo_holder_thickness_bottom])
    rotate(90, [1, 0, 0])
    cylinder(r = servo_holder_mounting_screw_hole_radius, h = servo_holder_mounting_screw_hole_height);
    
    translate([servo_holder_width - servo_holder_thickness_sides / 2, servo_holder_depth / 2, servo_holder_height - servo_holder_thickness_top + servo_holder_clearance / 2 - servo_holder_mounting_screw_hole_height])
    cylinder(r = servo_holder_mounting_screw_hole_radius, h = servo_holder_mounting_screw_hole_height);
    
   translate([servo_holder_thickness_sides / 2, servo_holder_depth / 2, servo_holder_height - servo_holder_thickness_top + servo_holder_clearance / 2 - servo_holder_mounting_screw_hole_height])
    cylinder(r = servo_holder_mounting_screw_hole_radius, h = servo_holder_mounting_screw_hole_height);
  }
  
  linear_extrude(height = servo_holder_bottom_connector_height)
  intersection() {
    translate([x_offset + servo_holder_width, y_offset])
    square([baseRadius - baseWidth - servo_holder_width - x_offset, servo_holder_depth]);
    circle(r = baseRadius - baseWidth - servo_holder_bottom_connector_clearance);
  }


}


module basePadding() {
  basePaddingWidth = baseWidth + basePaddingGuideWidth + basePaddingClearence;
  basePaddingRadius = baseRadius;
  basePaddingGuideRadius = baseRadius - baseWidth - basePaddingClearence;

  translate([0, 0, -basePaddingHeight])
  ring(width = basePaddingWidth, height = basePaddingHeight, radius = basePaddingRadius);

  translate([0, 0, -basePaddingHeight])
  ring(width = basePaddingGuideWidth, height = basePaddingGuideHeight, radius = basePaddingGuideRadius);
}

module base() {
  difference() {
    // base ring
    ring(width = baseWidth, height = baseHeight, radius = baseRadius);

    // rail
    translate([0, 0, baseHeight + railVerticalOffset])
    rail();

    // power jack hole
    rotate(60, [0, 0, 1])
    translate([baseRadius, 0, 2])
    rotate(90, [0, 0, 1])
    powerJackHole();

    // led hole
    rotate(180, [0, 0, 1])
    translate([baseRadius, 0, 2])
    rotate(90, [0, 0, 1])
    ledHole(width = baseWidth);
  }
}

module ring(height, width, radius) {
  rotate_extrude(angle = 360)
  translate([radius - width, 0])
  square([width, height]);
}

module rail() {
  rotate_extrude()
  translate([baseRadius - railHorizontalOffset, 0])
  circle(railRadius);
}

module powerJackHole() {
  clearence=0.25;
  holeWidth=9 + clearence;
  holeHeight=11 + clearence;
  holeDepth=14;

  cube([holeWidth, holeDepth, holeHeight]);
}

module cage() {
  cageHoleClearance = 0.3;
  cageHoleRadius = railRadius + cageHoleClearance / 2;
  translate([0, 0, baseHeight]) {
    difference() {
      ring(width = topWidth, height = cageHeight, radius = baseRadius);
      for (i = [0:numberOfBalls - 1]) {
        rotate(i * 360 / numberOfBalls, [0, 0, 1])
        translate([baseRadius - railHorizontalOffset, 0, -cutExtra / 2])
        cylinder(r = cageHoleRadius, h = cageHeight + cutExtra);
      }
    }
  }
}

module top() {
  translate([0, 0, topVerticalOffset])
  difference() {
    // top ring
    ring(width = topWidth, height = topHeight, radius = baseRadius);
    
    // rail
    translate([0, 0, -railVerticalOffset])
    rail();

  }

  for (i = [0 : 2])
    rotate(i * 360 / 3, [0, 0, 1])
    wheel_connector();
}

module slice(sliceNumber = 0, sliceCount = 3) {
  radius = baseRadius * 1.1;
  height = (topVerticalOffset + topHeight) * 1.2;
  angle = 360 / sliceCount;
  angleOffset = angle * sliceNumber;

  difference() {
    intersection() {
      translate([0, 0, -height * 0.1])
      rotate(angleOffset, [0, 0, 1])
      rotate_extrude(angle = angle)
      square([radius, height]);

      children();
    }
  }
}
