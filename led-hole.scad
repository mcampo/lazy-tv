cutExtra = 1;

// sample
ledHole(width = 10);

module ledHole(width, clearence = 0.25) {
  //caja led: w=7 h=7.7 d=5.3
  hole1Width = 7 + clearence;
  hole1Height = 7.7 + clearence;
  hole1Depth = 2;

  hole2Width = hole1Width + 2;
  hole2Height = 13;
  hole2Depth = width - hole1Depth + cutExtra;

  translate([-(hole2Width - hole1Width) / 2, hole1Depth, 0])
  cube([hole2Width, hole2Depth, hole2Height]);

  cube([hole1Width, hole1Depth, hole1Height]);
}
