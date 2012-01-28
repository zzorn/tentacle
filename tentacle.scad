use <roundedCylinder.scad>;
use <roundedBox.scad>;
use <interpolate.scad>;

$fn=40;

mm = 1;
epsilon = 0.1;

startSize   = 60*mm;
endSize     = 40*mm;
startHeight = 17*mm;
endHeight   = 15*mm;


separation = 0.9 * max(startSize, endSize) + 10*mm;
numPerSize = 4;

for (x = [0:numPerSize-1]) {
  for (y = [0:numPerSize-1]) {
    translate([x*separation, y*separation, 0]) 
      vertebralColumnPiece(y / numPerSize + x / (numPerSize * numPerSize), 
                           startSize, endSize, startHeight, endHeight); 
  }
}


module vertebralColumnPiece(relativePos, startSize, maxSize, startHeight, maxHeight) {
  s = lerp(relativePos, startSize, maxSize); 
  h = lerp(relativePos, startHeight, maxHeight); 
  vertebrae(s, h);
}

module vertebrae(
  size = 60*mm,
  height = 20*mm,
  centerHoleSize = 5*mm,
  wireHoleSize = 4*mm,
  wallSize = 3*mm,
  socketScale = 1.3) 
{
  spine = centerHoleSize + 2 * wallSize;
  baseH = wallSize * 2;
  wireHoleDistance = size/2 - wireHoleSize * 0.5 - wallSize;
  socketRadius = socketScale*spine/2;
  socketDepth = wallSize;
  protuberanceSize = 4 *  wallSize + size * 0.1;

  difference() {

    // Body
    union() {
      // Base 
      roundedCylinder(size/4, baseH);

      // Protuberances
      for (a = [0, 90, 180, 270])  
        baseProtuberance(45 + a, wireHoleDistance, protuberanceSize, baseH, wireHoleSize);

      // Center pillar
      translate([0,0,baseH])
        roundedCylinder(spine/2, height-baseH, botRound=0);
    }

    // Center hole
    translate([0,0,-epsilon])
      cylinder(r=centerHoleSize/2, h=height+2*epsilon);

    // Ball joint socket
    translate([0,0,-socketRadius+socketDepth])
      sphere(r=socketRadius);

  }
}


module baseProtuberance(angle, distance, size, height, wireHoleSize) {
  x = cos(angle)*distance;
  y = sin(angle)*distance;

  difference() {
    union() {
      // Body
      translate([x, y, 0])
        roundedCylinder(size/2, height);  
  
      // Stem
      rotate([0, 0, angle]) 
        translate([distance/2,0,height/2])
        roundedBox([distance+size/2, size*0.75, height], height/2, false);
    } 

    // Hole
    translate([x, y, -epsilon])
      cylinder(r=wireHoleSize/2, h=height+2*epsilon);
  }
}



