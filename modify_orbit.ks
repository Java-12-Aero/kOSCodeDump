@lazyglobal off.
clearscreen.
Parameter targetAp is SHIP:ORBIT:APOAPSIS.
Parameter targetPE is SHIP:ORBIT:PERIAPSIS.
Parameter targetInclination is SHIP:ORBIT:INCLINATION.
Parameter targetLAN is SHIP:ORBIT:LONGITUDEOFASCENDINGNODE.

// Constants determination/runtime-proofing so that the time it takes for the code to run doesn't cause inaccuracies
Local spv is SOLARPRIMEVECTOR - SHIP:BODY:POSITION. // LAN vector of an orbit where LAN = 0 deg (poinmts from body to point)
Local unitNormal is v(0,1,0). // Normal of an uninclined orbit
Local currentTime is TIME:SECONDS. // this is now what time it is for all the code
Local currentPosition is positionat(SHIP,currentTime) - SHIP:BODY:POSITION.
Local currentTrueAnomaly is SHIP:ORBIT:TRUEANOMALY. // for some of the other components
Local currentEccentricity is SHIP:ORBIT:ECCENTRICITY.

// Step 1 - Generate the appropriate LAN postiiojn vectors
Local initialLAN is spv * angleaxis(SHIP:ORBIT:LONGITUDEOFASCENDINGNODE,unitNormal).
Local finalLAN is spv * angleaxis(targetLAN,unitNormal).

// Step 2 - generate the normal vectors 
Local initialNormal is unitNormal * angleaxis(SHIP:ORBIT:INCLINATION,initialLAN).
Local finalNormal is unitNormal * angleaxis(targetInclination,finalLAN).

// Step 3 - generate the relative ascending/descending nodes
Local relativeAN is vcrs(initialNormal,finalNormal).
Local relativeDN is vcrs(finalNormal,initialNormal).

//Step 4 - generate the anomalies (true, eccentric, mean)
Local ANSign is vdot(vcrs(relativeAN,currentPosition),initialNormal).
Local relativeAngle is vang(currentPosition,relativeAN). // intermediate variable
if ANSign < 0 { set relativeAngle to 360 - relativeAngle. } //make sure we only measure angles in one direction
Local ANTrueAnomaly is relativeAngle + currentTrueAnomaly.
Local DNTrueAnomaly is mod((ANTrueAnomaly + 180),360).
Local ANEccentricAnomaly is mod((360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(ANTrueAnomaly),1 + (currentEccentricity * cos(ANTrueAnomaly))),360).
Local DNEccentricAnomaly is mod((360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(DNTrueAnomaly),1 + (currentEccentricity * cos(DNTrueAnomaly))),360).
Local ANMeanAnomaly is ANEccentricAnomaly - (currentEccentricity * sin(ANEccentricAnomaly)).
Local DNMeanAnomaly is DNEccentricAnomaly - (currentEccentricity * sin(DNEccentricAnomaly)).

// Step 5 - generate timestamps for the nodes
Local ANTimestamp is ((ANMeanAnomaly - SHIP:ORBIT:MEANANOMALYATEPOCH)/sqrt(BODY:MU / ORBIT:SEMIMAJORAXIS^3)) + SHIP:ORBIT:EPOCH.
Local DNTimestamp is ((DNMeanAnomaly - SHIP:ORBIT:MEANANOMALYATEPOCH)/sqrt(BODY:MU / ORBIT:SEMIMAJORAXIS^3)) + SHIP:ORBIT:EPOCH.

// Step 6 - generate initial and final velocities at the intersection points.
