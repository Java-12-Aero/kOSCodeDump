@lazyglobal off.
clearscreen.
Parameter targetInclination is SHIP:ORBIT:INCLINATION.
Parameter targetLAN is SHIP:ORBIT:LONGITUDEOFASCENDINGNODE.
Parameter targetAp is SHIP:ORBIT:APOAPSIS.
Parameter targetPE is SHIP:ORBIT:PERIAPSIS.

// Constants determination/runtime-proofing so that the time it takes for the code to run doesn't cause inaccuracies
Local spv is -SOLARPRIMEVECTOR. // LAN vector of an orbit where LAN = 0 deg (the name is too long)
Local unitNormal is v(0,1,0). // Normal of an uninclined orbit
Local currentTime is TIME:SECONDS. // this is now what time it is for all the code
Local currentPosition is positionat(SHIP,currentTime) - SHIP:BODY:POSITION.
Local currentTrueAnomaly is SHIP:ORBIT:TRUEANOMALY. // for some of the other components
Local currentEccentricity is SHIP:ORBIT:ECCENTRICITY.

// Step 1 - Generate the appropriate LAN postiiojn vectors
Local initialLAN is spv * angleaxis(-SHIP:ORBIT:LONGITUDEOFASCENDINGNODE,unitNormal).
Local finalLAN is spv * angleaxis(-targetLAN,unitNormal).

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
Local ANEccentricAnomaly is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(ANTrueAnomaly),currentEccentricity + cos(ANTrueAnomaly)),360).
Local DNEccentricAnomaly is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(DNTrueAnomaly),currentEccentricity + cos(DNTrueAnomaly)),360).
Local ANMeanAnomaly is ANEccentricAnomaly - (currentEccentricity * constant:RadToDeg * sin(ANEccentricAnomaly)).
Local DNMeanAnomaly is DNEccentricAnomaly - (currentEccentricity * constant:RadToDeg * sin(DNEccentricAnomaly)).

// Step 5 - generate timestamps for the nodes
Local ANTimestamp is ((ANMeanAnomaly - SHIP:ORBIT:MEANANOMALYATEPOCH)/sqrt(BODY:MU / ORBIT:SEMIMAJORAXIS^3)) + SHIP:ORBIT:EPOCH.
Local DNTimestamp is ((DNMeanAnomaly - SHIP:ORBIT:MEANANOMALYATEPOCH)/sqrt(BODY:MU / ORBIT:SEMIMAJORAXIS^3)) + SHIP:ORBIT:EPOCH.


//Function calculate_maneuver {Parameter inputTime, initialNormal, finalNormal, relativeNode, }
// Step 6 - generate initial and final velocities at the intersection points.
Local ANTargetVelocity is velocityat(SHIP,ANTimestamp):ORBIT * angleaxis(vang(initialNormal,finalNormal),relativeAN).
Local DNTargetVelocity is velocityat(SHIP,DNTimestamp):ORBIT * angleaxis(vang(initialNormal,finalNormal),relativeAN).

// Step 7 - Project velocities for node creation
// node velocities are radial, normal, then prograde
Local ANVelocityDifference is ANTargetVelocity - velocityat(SHIP,ANTimestamp):ORBIT.
Local ANRadialOutVector is vcrs(velocityat(SHIP,ANTimestamp):ORBIT,initialNormal).
Local ANProgradeVelocity is vdot(velocityat(SHIP,ANTimestamp):ORBIT:normalized,ANVelocityDifference).
Local ANRadialVelocity is vdot(ANRadialOutVector:normalized,ANVelocityDifference).
Local ANNormalVelocity is vdot(initialNormal:Normalized,ANVelocityDifference).
Local ANManeuverNode is NODE(ANTimestamp,ANRadialVelocity,ANNormalVelocity,ANProgradeVelocity).

Local DNVelocityDifference is DNTargetVelocity - velocityat(SHIP,DNTimestamp):ORBIT.
Local DNRadialOutVector is vcrs(velocityat(SHIP,DNTimestamp):ORBIT,initialNormal).
Local DNProgradeVelocity is vdot(velocityat(SHIP,DNTimestamp):ORBIT:normalized,DNVelocityDifference).
Local DNRadialVelocity is vdot(DNRadialOutVector:normalized,DNVelocityDifference).
Local DNNormalVelocity is vdot(initialNormal:Normalized,DNVelocityDifference).
Local DNManeuverNode is NODE(DNTimestamp,DNRadialVelocity,DNNormalVelocity,DNProgradeVelocity).

// Step 8 - add node to flight plan
Local nodeHolder is 0.
if ANTimestamp < DNTimestamp {
	print "using AN".
	set nodeHolder to ANManeuverNode.
} else {
	print "using DN".
	set nodeHolder to DNManeuverNode.
}
ADD nodeHolder.
runpath("1:/Javastuff/execute_maneuver.ks").
