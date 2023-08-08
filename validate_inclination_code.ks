@lazyglobal off.
clearscreen.
Parameter targetInclination is 45.
Print "TESTING DIFFERENCE BETWEEN MODIFY_ORBIT.KS AND SET_INCLINTION.KS. TARGET INCLINATION IS " + targetInclination + " DEGREES.".
// Constants and time tanking
Local spv is -SOLARPRIMEVECTOR. // modify_orbit.ks
Local unitNormal is v(0,1,0). // modify_orbit.ks
Local currentTime is TIME:SECONDS.
Local currentPosition is positionat(SHIP,currentTime) - SHIP:BODY:POSITION.
Local currentVelocity is velocityat(SHIP,currentTime):ORBIT.
Local currentTrueAnomaly is SHIP:ORBIT:TRUEANOMALY.
Local currentEccentricity is SHIP:ORBIT:ECCENTRICITY.
Local epochMeanAnomaly is SHIP:ORBIT:MEANANOMALYATEPOCH.
Local currentInclination is SHIP:ORBIT:INCLINATION.
Local currentLAN is SHIP:ORBIT:LONGITUDEOFASCENDINGNODE.
Local deltaInclination is targetInclination - currentInclination. // set_inclination.ks
Local currentEpoch is SHIP:ORBIT:EPOCH. // set_inclination.ks
Local currentPeriod is SHIP:ORBIT:PERIOD. // set_inclination.ks
Local sma is SHIP:ORBIT:SEMIMAJORAXIS.

// Methods from modify_orbit.ks to reach parity with set_inclination.ks
Local initialLAN1 is spv * angleaxis(-currentLAN,unitNormal). // modify_orbit.ks, LAN vector
Local finalLAN is spv * angleaxis(-currentLAN,unitNormal). // modify_orbit.ks, initial and final right now are the same because set_inclination does not modify final LAN, but I want to keep modify_orbit's work as identical as possible to the original
Local initialNormal1 is unitNormal * angleaxis(currentInclination,initialLAN1). // modify_orbit.ks
Local initialNormal2 is vcrs(currentVelocity,currentPosition):normalized. // set_inclination.ks
Print "modify_orbit initial normal vector: " + initialNormal1.
Print "set_inclination initial normal vector: " + initialNormal2.

// Now we can start working on comparisons
Local axis is vcrs(unitNormal,initialNormal2):normalized. // set_inclination.ks
Local finalNormal1 is unitNormal * angleaxis(targetInclination,finalLAN) // modify_orbit.ks
Local finalNormal2 is initialNormal2 * angleaxis(deltaInclination, axis). // set_inclination.ks
Print "modify_orbit final normal vector: " + finalNormal1.
Print "set_inclination final normal vector: " + finalNormal2.

Local relativeAN1 is vcrs(initialNormal1,finalNormal1). // modify_orbit.ks
Local relativeAN2 is vcrs(initialNormal2,finalNormal2). // set_inclination.ks
Print "modify_orbit relativeAN vector: " + relativeAN1.
Print "set_inclination relativeAN vector: " + relativeAN2.
Local relativeAngle1 is vang(currentPosition,relativeAN1). // modify_orbit.ks
Local relativeAngle2 is vang(currentPosition, relativeAN2). // set_inclination.ks
Local ANSign1 is vdot(vcrs(relativeAN1,currentPosition),initialNormal1). // modify_orbit.ks
Local ANSign2 is vdot(vcrs(relativeAN2,currentPosition),initialNormal2). // set_inclination.ks
Print "modify_orbit sign: " + ANSign1.
Print "set_inclination sign: " + ANSign2.
if ANSign1 < 0 { set relativeAngle1 to 360 - relativeAngle1. } // modify_orbit.ks
if ANSign2 < 0 { set relativeAngle2 to 360 - relativeAngle2. } // set_inclination.ks
Print "modify_orbit relative angle: " + relativeAngle1.
Print "set_inclination relative angle: " + relativeAngle2.

Local ANTrueAnomaly1 is relativeAngle1 + currentTrueAnomaly. // modify_orbit.ks
Local ANTrueAnomaly2 is relativeAngle2 + currentTrueAnomaly. // set_inclination.ks
Print "modify_orbit AN True Anom: " + ANTrueAnomaly1.
Print "set_inclination AN true Anom: " + ANTrueAnomaly2.
Local ANEccentricAnomaly1 is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(ANTrueAnomaly1),currentEccentricity + cos(ANTrueAnomaly1)),360). // modify_orbit.ks
Local ANEccentricAnomaly2 is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(ANTrueAnomaly2),currentEccentricity + cos(ANTrueAnomaly2)),360). // set_inclination.ks
Print "modify_orbit AN Eccentric Anom: " + ANEccentricAnomaly1.
Print "set_inclination AN Eccentric Anom: " + ANEccentricAnomaly2.
Local ANMeanAnomaly1 is ANEccentricAnomaly1 - (currentEccentricity * constant:RadToDeg * sin(ANEccentricAnomaly1)). // modify_orbit.ks
Local ANMeanAnomaly2 is ANEccentricAnomaly2 - currentEccentricity * constant:RadToDeg * sin(ANEccentricAnomaly2). // set_inclination.ks
Print "modify_orbit AN mean anom: " + ANMeanAnomaly1.
Print "set_inclination AN mean anom: " + ANMeanAnomaly2.

Local DNTrueAnomaly1 is mod(ANTrueAnomaly1 + 180,360). // modify_orbit.ks
Local DNTrueAnomaly2 is mod(ANTrueAnomaly2 + 180, 360). // set_inclination.ks
Print "modify_orbit DN True Anom: " + DNTrueAnomaly1.
Print "set_inclination DN true Anom: " + DNTrueAnomaly2.
Local DNEccentricAnomaly1 is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(DNTrueAnomaly1),currentEccentricity + cos(DNTrueAnomaly1)),360). // modify_orbit.ks
Local DNEccentricAnomaly2 is mod(360 + arctan2(sqrt(1 - currentEccentricity^2) * sin(DNTrueAnomaly2),currentEccentricity + cos(DNTrueAnomaly2)),360). // set_inclination.ks
Print "modify_orbit DN Eccentric Anom: " + DNEccentricAnomaly1.
Print "set_inclination DN Eccentric Anom: " + DNEccentricAnomaly2.
Local DNMeanAnomaly1 is DNEccentricAnomaly1 - (currentEccentricity * constant:RadToDeg * sin(DNEccentricAnomaly1)). // modify_orbit.ks
Local DNMeanAnomaly2 is DNEccentricAnomaly2 - currentEccentricity * constant:RadToDeg * sin(DNEccentricAnomaly2). // set_inclination.ks
Print "modify_orbit DN mean anom: " + DNMeanAnomaly1.
Print "set_inclination DN mean anom: " + DNMeanAnomaly2.

Local baseMeanAnomaly is mod(mod(currentTime - currentEpoch,currentPeriod)/currentPeriod*360 + epochMeanAnomaly,360). // set_inclination.ks - no clue what this actually calculates
Local ANTimestamp1 is ((ANMeanAnomaly1 - epochMeanAnomaly) / sqrt(BODY:MU / sma^3)) + currentEpoch. // modify_orbit.ks
Local ANTimestamp2 is mod(360 + ANMeanAnomaly2 - baseMeanAnomaly, 360) / sqrt(BODY:MU / sma^3) / constant:RadToDeg + currentTime. // set_inclination.ks
Local ANAnomAp2 is abs(ANTrueAnomaly2 - 180). // set_inclination.ks
Print "modify_orbit AN Time: " + ANTimestamp1.
Print "set_inclination AN Time: " + ANTimestamp2.

Local DNTimestamp1 is ((DNMeanAnomaly1 - epochMeanAnomaly) / sqrt(BODY:MU / sma^3)) + currentEpoch. // modify_orbit.ks
Local DNTimestamp2 is mod(360 + DNMeanAnomaly2 - baseMeanAnomaly, 360) / sqrt(BODY:MU / sma^3) / constant:RadToDeg + currentTime. // set_inclination.ks
Local DNAnomAp2 is abs(DNTrueAnomaly2 - 180). // set_inclination.ks
Print "modify_orbit DN Time: " + DNTimestamp1.
Print "set_inclination DN Time: " + DNTimestamp2.

Local nodeTimestamp1 is 0. // modify_orbit.ks
if ANTimestamp1 < DNTimestamp1 {
	Print "modify_orbit using AN".
	set nodeTimestamp1 to ANTimestamp1.
} else {
	Print "modify_orbit using DN".
	set nodeTimestamp1 to DNTimestamp1.
}

Local nodeTimestamp2 is 0. // set_inclination.ks
if ANAnomAp2 < DNAnomAp2 {
	Print "set_inclination using AN".
	set nodeTimestamp2 to ANTimestamp2.
} else {
	Print "set_inclination using DN".
	set nodeTimestamp2 to DNTimestamp2.
}

Print "modify_orbit timestamp: " + nodeTimestamp1.
Print "set_inclination timestamp: " + nodeTimestamp2.

// we diverge pretty significantly here for velocity calculation, we're going to jsut run them all and reconvene basically.

// modify_orbit.ks
Local targetVelocity1 is velocityat(SHIP,nodeTimestamp1):ORBIT * angleaxis(vang(initialNormal1,finalNormal1),relativeAN1).
Local deltaVelocity1 is targetVelocity1 - velocityat(SHIP,nodeTimestamp1):ORBIT.
Local radialOutVector1 is vcrs(velocityat(SHIP,nodeTimestamp1):ORBIT,initialNormal1).
Local progradeVelocity1 is vdot(velocityat(SHIP,nodeTimestamp1):ORBIT:normalized,deltaVelocity1).
Local radialVelocity1 is vdot(radialOutVector1:normalized,deltaVelocity1).
Local normalVelocity1 is vdot(initialNormal1:normalized,deltaVelocity1).

// set_inclination.ks
Local nodePosition2 is positionat(SHIP,nodeTimestamp2) - SHIP:ORBIT:BODY:POSITION.
Local nodeVelocity2 is velocityat(SHIP,nodeTimestamp2):ORBIT.
Local nodeNormal2 is vcrs(nodeVelocity2,nodePosition2):normalized.
Local axis2 is vcrs(unitNormal,nodeNormal2):normalized.
Local nodeTargetNormal2 is nodeNormal2 * angleaxis(deltaInclination,axis2).
Local initialTangentVelocity2 is vcrs(nodePosition2,nodeVelocity2) * nodeVelocity2.
Local initialRadialVelocity2 is nodePosition2:normalized * nodeVelocity2.
Local deltaVelocity2 is initialRadialVelocity2 * nodePosition2:normalized + initialTangentVelocity2 * vcrs(nodePosition2,nodeTargetNormal2):normalized - nodeVelocity2.
Local progradeVelocity2 is deltaVelocity2 * nodeVelocity2:normalized.
Local radialVelocity2 is deltaVelocity2 * vxcl(nodeVelocity2,nodePosition2):normalized.
Local normalVelocity2 is deltaVelocity2 * nodeNormal2.

// now to do the checks

Print "modify_orbit dv: " + deltaVelocity1.
Print "set_inclination dv: " + deltaVelocity2.
Print "modify_orbit prograde: " + progradeVelocity1.
Print "set_inclination prograde: " + progradeVelocity2.
Print "modify_orbit radial: " + radialVelocity1.
Print "set_inclination radial: " + radialVelocity2.
Print "modify_orbit normal: " + normalVelocity1.
Print "set_inclination normal: " + normalVelocity2.
