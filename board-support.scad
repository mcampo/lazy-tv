guideHeight = 3;
guideBottomDiameter = 2.2;
guideTopDiameter = guideBottomDiameter * 0.5;
guideOffsetX = 95;
guideOffsetY = 45;

basePadding = 3;
baseHeight = 0.6;

//sample
boardSupport(supportRadius = 100);

module boardSupport(supportRadius) {
  linear_extrude(baseHeight)
  
  intersection() {
    difference() {
      offset(r = basePadding)
      square([guideOffsetX + 25, guideOffsetY]);
      
      translate([guideOffsetX / 2, guideOffsetY / 2])
      scale([0.9, 0.45])
      circle(d = guideOffsetX);
    }
    
    translate([guideOffsetX + 25 + basePadding - supportRadius, guideOffsetY / 2])
    circle(r = supportRadius);
  }

  translate([0, 0, baseHeight])
  cylinder(h = guideHeight, d1 = guideBottomDiameter, d2 = guideTopDiameter);

  translate([guideOffsetX, 0, baseHeight])
  cylinder(h = guideHeight, d1 = guideBottomDiameter, d2 = guideTopDiameter);

  translate([guideOffsetX, guideOffsetY, baseHeight])
  cylinder(h = guideHeight, d1 = guideBottomDiameter, d2 = guideTopDiameter);

  translate([0, guideOffsetY, baseHeight])
  cylinder(h = guideHeight, d1 = guideBottomDiameter, d2 = guideTopDiameter);
}
