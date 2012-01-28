use <roundedCylinder.scad>;
use <roundedBox.scad>;
use <interpolate.scad>;
use <bewels.scad>;

//$fn=20;
$fs=0.6;
$fa=2;

mm = 1;
epsilon = 0.1;


vertebralColumnPieces(4);

module vertebralColumnPieces(number = 1,
                             startSize   = 60*mm,
                             endSize     = 40*mm,
                             startHeight = 17*mm,
                             endHeight   = 15*mm) {

  separation = 1 * max(startSize, endSize) + 2*mm;
  numPerSize = round(sqrt(number));

  for (x = [0:numPerSize-1]) {
    for (y = [0:numPerSize-1]) {
      translate([x*separation, y*separation, 0]) 
        vertebralColumnPiece(y / numPerSize + x / (numPerSize * numPerSize), 
                             startSize, endSize, startHeight, endHeight); 
    }
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
  socketScale = 1.2) 
{
  holeRad = centerHoleSize/2;
  axleTopRound = holeRad/2;
  spine = centerHoleSize + 2*wallSize + 2*axleTopRound;
  baseH = wallSize * 2;
  wireHoleDistance = size/2 - wireHoleSize * 0.5 - wallSize;
  socketRadius = socketScale*spine/2;
  socketDepth = wallSize;
  protuberanceSize = 4 *  wallSize + size * 0.1;
  spineRad = spine/2;
  spineHeight = height-baseH;
  baseRad = max(spine + wallSize, size/4);
  spineTopRound = spineRad-holeRad; 
  socketGap = wallSize/4;
  botRounding = 0.25;
  

  difference() {

    // Body
    union() {
      // Base 
      roundedCylinder(baseRad, baseH, botRound=baseH*botRounding);

      // Protuberances
      for (a = [0, 90, 180, 270])  
        baseProtuberance(45 + a, wireHoleDistance, protuberanceSize, baseH, wireHoleSize, botRounding);

      // Center pillar
      translate([0,0,baseH]) {
        roundedCylinder(spineRad, spineHeight, botRound=0, topRound=spineTopRound);
        beweledRing(spineRad-epsilon, min(baseRad-spineRad-wallSize, spineHeight-spineTopRound));
      }
    }

    // Center hole
    translate([0,0,-epsilon])
      cylinder(r=holeRad, h=height+2*epsilon);
    translate([0,0, height-axleTopRound+epsilon])
      beweledRing(holeRad-epsilon, axleTopRound, bottom=true);

    // Ball joint socket
    translate([0,0,-height+socketDepth])
      roundedCylinder(spineRad+socketGap, height, botRound=0, topRound=spineTopRound);
    translate([0,0, socketDepth-epsilon])
      beweledRing(holeRad-epsilon, socketGap);

  }
}


module baseProtuberance(angle, distance, size, height, wireHoleSize, botRounding) {
  x = cos(angle)*distance;
  y = sin(angle)*distance;
  holeRad = wireHoleSize/2;
  topRoundingSize = holeRad*2;
  botRoundingSize = holeRad/2;

  difference() {
    union() {
      // Body
      translate([x, y, 0])
        roundedCylinder(size/2, height, botRound=height*botRounding);  
  
      // Stem
      rotate([0, 0, angle]) 
        translate([distance/2,0,height/2])
        roundedBox([distance+size/2, size*0.75, height], height/2, false);
    } 

    // Hole
    translate([x, y, -epsilon]) 
      cylinder(r=holeRad, h=height+2*epsilon);  
    translate([x, y, height-topRoundingSize+epsilon]) 
      beweledRing(holeRad-epsilon, topRoundingSize, bottom=true);
    translate([x, y, -epsilon]) 
      beweledRing(holeRad-epsilon, botRoundingSize);
  }
}



