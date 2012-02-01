use <roundedCylinder.scad>;
use <roundedBox.scad>;
use <interpolate.scad>;
use <bewels.scad>;

//$fn=20;
$fs=0.6;
$fa=2;

mm = 1;
epsilon = 0.05;


vertebralColumnPieces(9);

module vertebralColumnPieces(number = 1,
                             startSize   = 60*mm,
                             endSize     = 40*mm,
                             startHeight = 20*mm,
                             endHeight   = 17*mm) {

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
  centerHoleSize = 6*mm,
  wireHoleSize = 4*mm,
  wallSize = 2*mm,
  socketScale = 1.2,
  baseHeight = 7*mm) 
{
  holeRad = centerHoleSize/2;
  axleTopRound = holeRad/2;
  spine = centerHoleSize + 2*wallSize + 2*axleTopRound;
  baseH = baseHeight;
  wireHoleDistance = size/2 - wireHoleSize * 0.5 - wallSize;
  socketRadius = socketScale*spine/2;
  socketDepth = wallSize;
  protuberanceSize = size * 0.35;
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
      tentacleBase(baseH, wireHoleDistance, protuberanceSize, botRounding, spineRad, spineHeight, spineTopRound);

      // Protuberances
      for (a = [0, 90, 180, 270])  
        baseProtuberance(45 + a, wireHoleDistance, protuberanceSize, baseH, wireHoleSize, botRounding);

      // Center pillar
      translate([0,0,baseH]) {
        roundedCylinder(spineRad, spineHeight, botRound=0, topRound=spineTopRound);
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

    // Holes for section control wires
    for (a = [0, 90, 180, 270])  
      rotate([0,0,a+45]) 
        translate([0,0,baseH - wallSize])
          rotate([90,0,0]) {
            cylinder(r=wireHoleSize/2, h=wireHoleDistance);
          } 

  }
}


module baseProtuberance(angle, distance, size, height, wireHoleSize, botRounding) {
  x = cos(angle)*distance;
  y = sin(angle)*distance;
  holeRad = wireHoleSize/2;
  topRoundingSize = holeRad;
  botRoundingSize = holeRad/2;

  difference() {
    union() {
      // Body
      translate([x, y, 0])
        roundedCylinder(size/2, height, botRound=height*botRounding);  
  
      /* 
      // Stem
      rotate([0, 0, angle]) 
        translate([distance/2,0,height/2])
        roundedBox([distance+size/2, size*0.75, height], height/2, false);
      */ 
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


module tentacleBase(baseH, wireHoleDistance, protuberanceSize, botRounding, spineRad, spineHeight, spineTopRound) {
  cutoutDist = wireHoleDistance/sqrt(2);
  cutoutRad = (sqrt(2)*wireHoleDistance-protuberanceSize)/2;
  baseRad = sqrt(cutoutDist*cutoutDist + cutoutRad*cutoutRad);

  difference() {
    union() {
      cylinder(r=baseRad, h=baseH); //botRound=baseH*botRounding
      translate([0,0,baseH])
        beweledRing(spineRad-epsilon,min(spineHeight-spineTopRound,cutoutDist/2) );
    }

    // Side cutouts
    for (a = [0, 90, 180, 270])  
      sideCutout(a, cutoutDist, cutoutRad, baseH, botRounding);
  }
}

module sideCutout(angle, distance, rad, height, botRounding) {
  x = cos(angle)*distance;
  y = sin(angle)*distance;
  topRoundingH = height/2;
  extraTopRound = height/4;

  translate([x, y, -epsilon]) 
    cylinder(r=rad-epsilon, h=height+2*epsilon);  
  translate([x, y, -epsilon]) 
    beweledRing(rad-epsilon*2, height*botRounding);  
  translate([x, y, height+epsilon-topRoundingH]) 
    beweledRing(rad-epsilon*2, topRoundingH, bottom=true);  
  translate([x, y, height]) 
    roundedCylinder(rad+topRoundingH+extraTopRound, height*2, topRound=0, botRound=extraTopRound);

}


