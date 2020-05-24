clearance = 0.25;
cutExtra = 0.2;
servoHeight = 20;
servoDepth = 40.5;
servoSupportWidth = 18;
servoDriveGearOffset = 10;
servoMountingScrewHolesYDistance = 49;
servoMountingScrewHolesZDistance = 10;
servoMountingScrewHoleBaseDepth = 7;
servoMountingScrewRadius = 1.15;
servoSupportToDriveWidth = 15.9;

sample();

module motorSupport(supportRadius, driveGearVerticalPosition, driveGearHorizontalPosition, driveGearOverlap) {
  
  baseHeight = 5;
  baseWidth = servoSupportWidth + servoSupportToDriveWidth + supportRadius - driveGearHorizontalPosition - driveGearOverlap;
  baseDepth = servoDepth + (servoMountingScrewHoleBaseDepth + 1) * 2;
  
  supportHeight = servoHeight + driveGearVerticalPosition - baseHeight - servoHeight / 2;
  supportWidth = servoSupportWidth;
  supportDepth = baseDepth;
  supportYOffset = servoDepth / 2 - servoDriveGearOffset;

  motorHoleWidth = supportWidth + cutExtra * 2;
  motorHoleDepth = servoDepth + clearance;

  screwHoleRadius = servoMountingScrewRadius - 0.05;
  screwHoleHeight = 7;
  screwHoleXOffset = supportRadius - baseWidth + supportWidth - screwHoleHeight;
  screwHoleYOffset = servoMountingScrewHolesYDistance / 2;
  screwHoleZOffset = driveGearVerticalPosition;

  // base
  linear_extrude(baseHeight)
  intersection() {
    circle(supportRadius);

    translate([supportRadius - baseWidth, -baseDepth / 2 - supportYOffset])
    square([baseWidth, baseDepth]);
  }

  translate([0, -supportYOffset, 0])
  difference() {
    // support
    translate([supportRadius - baseWidth, -supportDepth / 2, baseHeight])
    cube([supportWidth, supportDepth, supportHeight]);
    
    // screw hole 1.1
    translate([screwHoleXOffset, screwHoleYOffset, screwHoleZOffset + servoMountingScrewHolesZDistance / 2])
    rotate(90, [0, 1, 0])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);

    // screw hole 1.2
    translate([screwHoleXOffset, screwHoleYOffset, screwHoleZOffset - servoMountingScrewHolesZDistance / 2])
    rotate(90, [0, 1, 0])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);
    
    // screw hole 2.1
    translate([screwHoleXOffset, -screwHoleYOffset, screwHoleZOffset + servoMountingScrewHolesZDistance / 2])
    rotate(90, [0, 1, 0])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);

    // screw hole 2.2
    translate([screwHoleXOffset, -screwHoleYOffset, screwHoleZOffset - servoMountingScrewHolesZDistance / 2])
    rotate(90, [0, 1, 0])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);

    // motor hole
    translate([supportRadius - baseWidth - cutExtra, -motorHoleDepth / 2, baseHeight + (supportHeight - servoHeight)])
    cube([motorHoleWidth, motorHoleDepth, servoHeight + cutExtra]);
  }
}

use <servo.scad>;
module sample() {
  supportRadius = 100;
  servoBottomToPad = 29;
  driveGearHorizontalPosition = supportRadius - 5;
  driveGearOverlap = 3;

  motorSupport(supportRadius = supportRadius, driveGearVerticalPosition = 25, driveGearHorizontalPosition = driveGearHorizontalPosition, driveGearOverlap = driveGearOverlap);
  
  color("#c55")
  translate([driveGearHorizontalPosition - servoBottomToPad - servoSupportToDriveWidth + driveGearOverlap, 0, 25])
  rotate(180, [1, 0, 0])
  rotate(90, [0, 1, 0])
  rotate(90, [0, 0, 1])
  servo();
}
