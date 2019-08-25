cutExtra = 0.2;

// sample
addJoints(jointCenter = 20, jointWidth = 4, jointHeight = 2, jointDepth = 2);

module addJoints(jointCenter, jointWidth, jointDepth, jointHeight, clearence = 0.25) {
  difference() {
    union() {
      // joint that pops out
      translate([jointCenter - jointWidth / 2, -jointDepth, 0])
      cube([jointWidth, jointDepth, jointHeight]);

      children();
    }
    
    // hole where the other joint pops in
    rotate(120, [0, 0, 1])
    translate([jointCenter - (jointWidth + jointClearence) / 2, -(jointDepth + jointClearence), -cutExtra])
    cube([jointWidth + jointClearence, jointDepth + jointClearence + cutExtra, jointHeight + jointClearence + cutExtra]);
  }
}
