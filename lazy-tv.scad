use <lib/BOSL/involute_gears.scad>
use <lib/scad-lib/face-gear/face-gear.scad>
use <motor-support.scad>
use <led-hole.scad>

// colors
// 66c2a5 fc8d62 8da0cb e78ac3 a6d854 ffd92f e5c494 b3b3b3


// globals
$fn = $preview ? 80 : 150;

cutExtra = 1;

// base dimensions
baseRadius = 110;
baseHeight = 20;
baseWidth = 10;

// ball rail
railRadius = 6.34 / 2;
railVerticalOffset = 1.5;
railOuterPadding = 2;
railHorizontalOffset = 5;

numberOfBalls = 57;
cageHeight = 1.4;

// top dimensions
topWidth = baseWidth + 0; // base width + some space for the inner gear teeth
topVerticalOffset = baseHeight + railVerticalOffset * 2;
topHeight = 12;

// gears common
gearsModule = 1;
gearsPressureAngle = 20;
gearsClearance = 0.3;
gearsTeethLength = 8;

// face gear
faceGearInnerRadius = baseRadius - baseWidth - gearsTeethLength;
faceGearNumberOfTeeth = 2 * faceGearInnerRadius / gearsModule;
faceGearOuterRadius = faceGearInnerRadius + gearsTeethLength;
faceGearOuterModule = 2 * faceGearOuterRadius / faceGearNumberOfTeeth;
faceGearBaseHeight = 2;


// drive gear dimensions
driveGearGap = 1;
driveGearHeight = gearsTeethLength - driveGearGap;
driveGearNumberOfTeeth = 23;
driveGearRadius = driveGearNumberOfTeeth * gearsModule / 2;
driveGearHorizontalOffset = baseRadius - baseWidth - driveGearHeight / 2 - driveGearGap;
driveGearVerticalOffset = topVerticalOffset + topHeight- faceGearBaseHeight - driveGearRadius  - adendum(gearsModule) - gearsClearance;
driveGearHoleRadius = 5.75 / 2;

echo(driveGearRadius=driveGearRadius);

color("#fc8d62")
base();

color("#ffd92f")
cage();

color("#8da0cb")
top();

color("#66c2a5")
driveGear();

color("#a6d854")
motorSupport(supportRadius = (baseRadius - baseWidth), driveGearVerticalPosition = driveGearVerticalOffset);

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
    translate([0, 0, baseHeight]) {
      difference() {
        ring(width = topWidth, height = cageHeight, radius = baseRadius);
        for (i = [0:numberOfBalls - 1]) {
          rotate(i * 360 / numberOfBalls, [0, 0, 1])
          translate([baseRadius - railHorizontalOffset, 0, -cutExtra / 2])
          cylinder(r = railRadius * 1.01, h = cageHeight + cutExtra);
        }
      }
    }
}

module top() {
  translate([0, 0, topVerticalOffset])
  union() {
    difference() {
      // top ring
      ring(width = topWidth, height = topHeight, radius = baseRadius);
      
      // rail
      translate([0, 0, -railVerticalOffset])
      rail();
    }
    
    translate([0, 0, topHeight - faceGearBaseHeight])
    ring(width = gearsTeethLength, height = faceGearBaseHeight, radius = baseRadius - topWidth);
    
    translate([0, 0, topHeight - faceGearBaseHeight])
    rotate(180, [1, 0, 0])
    faceGear(gearsModule, gearsPressureAngle, faceGearNumberOfTeeth, gearsTeethLength, clearance = 0);
  }
}

module driveGear() {
  translate([driveGearHorizontalOffset, 0, driveGearVerticalOffset])
  rotate(90, [0, 1, 0])
  rotate(360/driveGearNumberOfTeeth/4, [0, 0, 1])
  difference() {
    gear(
      mm_per_tooth = PI * gearsModule,
      number_of_teeth = driveGearNumberOfTeeth,
      thickness = driveGearHeight,
      pressure_angle = gearsPressureAngle,
      hole_diameter = 0
    );
    
    cylinder(r = driveGearHoleRadius + 0.05, h = driveGearHeight + cutExtra, center = true);
  }
}


module slice(sliceNumber = 0) {
  textSize = 4;
  textWidth = textSize / 3; // approx
  textPadding = 2;
  textDepth = 1;
  
  radius = baseRadius * 1.1;
  height = (topVerticalOffset + topHeight) * 1.1;
  sliceCount = 3;

  render() {
    difference() {
      intersection() {
        rotate(360 * sliceNumber / sliceCount, [0, 0, 1])
        rotate_extrude(angle = 360 / sliceCount)
        square([radius, height]);

        children();
      }

      rotate(360 * sliceNumber / sliceCount, [0, 0, 1])
      translate([baseRadius - (baseWidth / 2) - textWidth, textDepth, topVerticalOffset + topHeight - textSize - textPadding])
      rotate(90, [1, 0, 0])
      linear_extrude(textDepth)
      text(str(sliceNumber), size = textSize, font = "Liberation Mono");
    }
  }
}
