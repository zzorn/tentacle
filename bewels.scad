
/** 
  Circular beweled cutout.
*/
module beweledRing(r, size, inner=false, bottom=false) {
  // Construct cross shape as 2D, then rotate extrude it.   
  rotate_extrude(convexity=4)
    difference() {
      translate([r, 0, 0]) square([size, size]);
      translate([r + (inner ? 0 : size), bottom ? 0 : size]) circle(r=size);
    }
}
