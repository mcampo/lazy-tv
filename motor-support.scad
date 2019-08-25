
cutExtra = 0.2;
servoHeight = 16;
servoWidth = 12.4;
servoDepth = 22.8;

// sample
motorSupport(supportRadius = 100, driveGearHorizontalPosition = 85);

module motorSupport(supportRadius, driveGearHorizontalPosition) {
  supportDepth = 34;
  supportHeight = servoHeight;
  motorHoleWidth = servoWidth + 0.2;
  motorHoleDepth = servoDepth + 0.2;
  motorHoleOffset = supportRadius - driveGearHorizontalPosition - motorHoleWidth / 2;
  supportWidth = motorHoleWidth + motorHoleOffset;

  screwHoleRadius = 1.2;
  screwHoleHeight = 6;
  screwHoleXOffset = motorHoleOffset + motorHoleWidth / 2;
  screwHoleYOffset = 28 / 2;

  cableHoleWidth = 5;
  cableHoleDepth = supportDepth / 2;
  cableHoleHeight = 2;
  cableHoleXOffset = motorHoleOffset + motorHoleWidth / 2 + cableHoleWidth / 2;

  difference() {
    // main support piece
    linear_extrude(supportHeight)
    intersection() {
      circle(supportRadius);

      translate([supportRadius- supportWidth, -supportDepth / 2])
      square([supportWidth, supportDepth]);
    }

    // screw hole 1
    translate([supportRadius - screwHoleXOffset, screwHoleYOffset, supportHeight - screwHoleHeight])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);

    // screw hole 2
    translate([supportRadius - screwHoleXOffset, -screwHoleYOffset, supportHeight - screwHoleHeight])
    cylinder(h = screwHoleHeight + cutExtra, r = screwHoleRadius);

    // motor hole
    translate([supportRadius - motorHoleWidth - motorHoleOffset - cutExtra, -motorHoleDepth / 2])
    cube([motorHoleWidth + cutExtra, motorHoleDepth, supportHeight + cutExtra]);

    // cable hole
    translate([supportRadius - cableHoleXOffset, -cableHoleDepth - cutExtra, 0])
    cube([cableHoleWidth, cableHoleDepth + cutExtra, cableHoleHeight]);
  }  
}
