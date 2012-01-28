

function lerp(t, a, b) = a * (1 - t) + b * t;

function interpolate(pos, inStartPos, inEndPos, outStartPos, outEndPos) = inStartPos == inEndPos ? (outStartPos + outEndPos) / 2 : lerp((pos - inStartPos) / (inEndPos - inStartPos), outStartPos, outEndPos);


 
