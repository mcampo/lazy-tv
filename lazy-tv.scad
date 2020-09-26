use <lib/BOSL/involute_gears.scad>
use <led-hole.scad>
use <servo.scad>
include <test.scad>
// colors
// 66c2a5 fc8d62 8da0cb e78ac3 a6d854 ffd92f e5c494 b3b3b3

// globals
$fn = $preview ? 50 : 150;

cutExtra = 1;

// base dimensions
baseRadius = 110;
baseHeight = 18;
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

numberOfBalls = 45;
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

echo(driveGearRadius=driveGearRadius);

color("#fc8d62")
base();

color("#ffd92f")
cage();

color("#8da0cb")
top();

translate([50, -15 + baseRadius - baseWidth - 6, 10])
rotate(180, [0, 1, 0])
rotate(90, [1, 0, 0])
servo();

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
