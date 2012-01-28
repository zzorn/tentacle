// --------------------------------------------------
// Rounded cylinder module 
// Author: Hans Häggström (hans.haggstrom at iki dot fi)
// Version: 1.0
// Created: 2012
// License: (New) BSD

// --------------------------------------------------
// (Recommended number of circle segments at least around 50 for smooth models):
// $fn = 50; 

// Examples:

// Default rounding is maximum possible rounding (pill shape)
translate([-50, 0,0])
  roundedCylinder(r=10, h=30);

// Same rounding on top and bottom
translate([0, 50,0])
  roundedCylinder(r=25, h=10, round=2);

// Different top and bottom rounding
translate([50, 0,0])
  roundedCylinder(r=30, h=30, topRound = 30, botRound=5);


// --------------------------------------------------
/** 
  Creates a rounded cyliner
  Defaults to full rounding (pill-shape).
  If the round parameter is specified, it is used for both the top and bottom edge.
  Otherwise uses botRound and topRound parameters for the top / bottom 
  edges of the cylinder.
*/
module roundedCylinder(r = 10, h = 10, round=-1, topRound=-1, botRound=-1) {

  // Don't allow rounding more than half of shortest side  
  maxRound = min(r*2, h)/2;

  if (round == -1 && topRound == -1 && botRound == -1) {
    // Default case, no rounding at all specified, use maximum
    differentlyRoundedCylinder(r, h, maxRound, maxRound);
  } 
  else if (round != -1) {
    // Rounding specified specified, use it for both
    differentlyRoundedCylinder(r, h, min(round, maxRound), min(round, maxRound));
  } 
  else if (topRound != -1 && botRound == -1) {
    // Top rounding specified, use default value for bottom
    differentlyRoundedCylinder(r, h, min(topRound, maxRound), maxRound);
  } 
  else if (topRound == -1 && botRound != -1) {
    // Bottom rounding specified, use default value for top
    differentlyRoundedCylinder(r, h, maxRound, min(botRound, maxRound));
  } 
  else {
    // Both bottom and top rounding specified
    differentlyRoundedCylinder(r, h, min(topRound, maxRound), min(botRound, maxRound));
  } 
}

/** Called by roundedCylinder, no need to call directly from user code. */
module differentlyRoundedCylinder(r, h, topRound, botRound) {
  // Construct cross shape as 2D, then rotate extrude it.   
  rotate_extrude(convexity=4)
    union() {
      // Top rounding
      quartCircle(r-topRound, h-topRound, topRound, true);
      translate([0,h-topRound]) square([r-topRound, topRound]);

      // Mid segment
      translate([0,botRound]) square([r, h-topRound-botRound]);

      // Bot rounding
      square([r-botRound, botRound]);
      quartCircle(r-botRound, botRound, botRound, false);
    }
}

/** Utility module to create a quarter of a circle. */
module quartCircle(x, y, r, top) {
  translate([x, y]) 
    intersection() { 
      circle(r=r);
      translate([0,top ? 0 : -r]) square([r, r]);
    }
}


