use <involute_gears.scad>;
use <motor-support.scad>;
use <led-hole.scad>;

// globals
//$fn=80; // use 150 to export stl
cutExtra = 1;

// base dimensions
baseRadius = 110;
baseHeight=20;
baseWidth=10;

// ball rail
railRadius=3.15;
railVerticalOffset=1.5;
railOuterPadding=2;
railHorizontalOffset=5;

// top dimensions
topWidth = baseWidth + 5; // base width + some space for the inner gear teeth
topVerticalOffset = baseHeight + railVerticalOffset * 2;
topHeight = 12;

// inner gear dimensions
innerGearHeight = topHeight;
innerGearNumberOfTeeth = 120;
innerGearPitchRadius = (baseRadius - topWidth) + 3; // inner radius + some space for the addendum
innerGearDiametralPitch = innerGearNumberOfTeeth / (innerGearPitchRadius * 2);

// drive gear dimensions
driveGearVerticalOffset = 28;
driveGearHeight = 4;
driveGearNumberOfTeeth = 14;
driveGearPitchRadius = driveGearNumberOfTeeth / (innerGearDiametralPitch * 2);
driveGearHorizontalOffset = innerGearPitchRadius - driveGearPitchRadius - 0.8;


base1();
base2();
base3();

top1();
top2();
top3();

driveGear();

motorSupport(supportRadius = (baseRadius - baseWidth), driveGearHorizontalPosition = driveGearHorizontalOffset);


// base 1: with power jack hole
module base1() {
  difference() {  
    base();
    // power jack hole
    rotate(60, [0, 0, 1])
    translate([baseRadius, 0, 2])
    rotate(90, [0, 0, 1])
    powerJackHole();
  }
}

// base 2: simple
module base2() {
  rotate(120, [0,0,1])
  base();
}

// base 3: with led hole
module base3() {
  rotate(240, [0,0,1])
  difference() {  
    base();
    // led hole
    rotate(60, [0, 0, 1])
    translate([baseRadius, 0, 2])
    rotate(90, [0, 0, 1])
    ledHole(width = baseWidth);
  }
}

module base() {
  difference() {
    // base ring
    ring(width = baseWidth, height = baseHeight, radius = baseRadius);

    // rail
    translate([0, 0, baseHeight + railVerticalOffset])
    rail();
  }
}

module ring(height, width, radius) {
  rotate_extrude(angle = 120)
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

module top1() {
  top();
}

module top2() {
  rotate(120, [0, 0, 1])
  top();
}

module top3() {
  rotate(240, [0, 0, 1])
  top();
}

module top() {
  translate([0, 0, topVerticalOffset])
  difference() {
    // top ring
    ring(width = topWidth, height = topHeight, radius = baseRadius);
    
    // rail
    translate([0, 0, -railVerticalOffset])
    rail();

    // gear
    gear(
      number_of_teeth = innerGearNumberOfTeeth,
      diametral_pitch = innerGearDiametralPitch,
      pressure_angle = 20,
      gear_thickness = innerGearHeight + cutExtra,
      rim_thickness = innerGearHeight + cutExtra,
      hub_thickness = innerGearHeight + cutExtra,
      bore_diameter = 0,
      clearance = 0);
  }
}

module driveGear() {
  translate([driveGearHorizontalOffset, 0, driveGearVerticalOffset])
  gear (
    number_of_teeth = driveGearNumberOfTeeth,
    diametral_pitch = innerGearDiametralPitch,
    pressure_angle = 20,
    gear_thickness = driveGearHeight,
    rim_thickness = driveGearHeight,
    hub_thickness = driveGearHeight,
    bore_diameter = 4.8);
}

echo(innerGearDiametralPitch=innerGearDiametralPitch);


