
cutExtra = 0.2;
servoHeight = 39.3;
servoMountHeight = 28;
servoMountCableWidth = 9;
servoMountingScrewHolesYDistance = 49;
servoMountingScrewHolesZDistance = 9.8;
servoWidth = 20;
servoDepth = 40.5;
servoDriveGearOffset = 5.6;

// sample
motorSupport(supportRadius = 100, driveGearVerticalPosition = 25);

module motorSupport(supportRadius, driveGearVerticalPosition) {
  driveGearGap = 8;
  baseHeight = 5;
  baseWidth = servoHeight + driveGearGap;
  baseDepth = servoDepth + 7.5 * 2;
  
  supportHeight = servoWidth + driveGearVerticalPosition - baseHeight - servoWidth / 2;
  supportWidth = servoMountHeight - servoMountCableWidth;
  supportDepth = baseDepth;

  motorHoleWidth = supportWidth + cutExtra;
  motorHoleDepth = servoDepth + cutExtra;

  screwHoleRadius = 1.1;
  screwHoleHeight = 6;
  screwHoleXOffset = supportRadius - baseWidth + servoMountCableWidth + supportWidth - screwHoleHeight;
  screwHoleYOffset = servoMountingScrewHolesYDistance / 2;
  screwHoleZOffset = driveGearVerticalPosition;

  // base
  linear_extrude(baseHeight)
  intersection() {
    circle(supportRadius);

    translate([supportRadius - baseWidth, -baseDepth / 2 - servoDriveGearOffset])
    square([baseWidth, baseDepth]);
  }

  translate([0, -servoDriveGearOffset, 0])
  difference() {
    // support
    translate([supportRadius - baseWidth + servoMountCableWidth, -supportDepth / 2, baseHeight])
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
    translate([supportRadius - baseWidth + servoMountCableWidth - cutExtra, -motorHoleDepth / 2, baseHeight + (supportHeight - servoWidth)])
    cube([motorHoleWidth + cutExtra * 2, motorHoleDepth, servoWidth + cutExtra]);
  }
}
