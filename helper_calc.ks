// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

function readAtmosphericData {
	parameter tBody.
	local tAtm IS BODY(tBody):ATM.
	print "-------------------------".
	print "Atmospheric information: " + tAtm:BODY.
	print "-------------------------".
	print "Exists? " + tAtm:EXISTS.
	print "Oxygen? " + tAtm:OXYGEN.
	print "Sea level pressure: " + tAtm:SEALEVELPRESSURE.
	print "Height: " + tAtm:HEIGHT.
}.

function calcSpeedAtRadius {
	parameter mu.
	parameter r1.
	parameter a.
	return mu * (2/r1 - 1/a).
}

function calcCircularizeDV {
	parameter altit.
	// gravitational constant times focal body mass
	local mu IS SHIP:ORBIT:BODY:MU.
	// average of PERI+APO+diameter of focal body
	local a IS SHIP:ORBIT:SEMIMAJORAXIS.
	// APO+radius of focal body, larger half of the semimajor axis
	local r1 IS SHIP:ORBIT:BODY:RADIUS + altit.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	local apoV IS (mu*(2/r1 - 1/a))^(0.5).
	// the formula for circular orbit vel simplifies to:
	// r1 here instead of 'a' because 'a' is the old semi-major axis
	local circularV IS (mu / r1)^(0.5).
	print "apoV is: " + apoV.
	print "circularV is: " + circularV.
	return circularV - apoV.
}

function calcHoemannDVtoOrbit {
	parameter tOrbit.
	// mu = gravitational constant times focal body mass
	local mu IS SHIP:ORBIT:BODY:MU.
	// alt+radius of focal body, smaller half of the semimajor axis when leaving
	local r1 IS SHIP:ORBIT:BODY:RADIUS + SHIP:ALTITUDE.
	print "Local r1 is: " + r1.
	// TODO: this is technically wrong for highly eccentric orbits!!
	//       NOT a proper rendezvous!!!
	// r2 = distance of target body, let's assume the average for now
	local r2 IS SHIP:ORBIT:BODY:RADIUS + (tOrbit:PERIAPSIS + tOrbit:APOAPSIS) / 2.
	print "Target r2 is: " + r2.
	local a IS (r1 + r2) / 2.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	local periV IS (mu*(2/r1 - 1/a))^(0.5).
	print "Calculated periV to be: " + periV.
	return periV - SHIP:VELOCITY:ORBIT:MAG.
}

function calcCircularizeSpeed {
	parameter altit.
	local mu IS SHIP:ORBIT:BODY:MU.
	// APO+radius of focal body, larger half of the semimajor axis
	local r1 IS SHIP:ORBIT:BODY:RADIUS + altit.
	// the formula for circular orbit vel simplifies to:
	return (mu / r1)^(0.5).
}.

function calcOrbitPhaseAngle {
	parameter tOrbit.
	local angleBody IS tOrbit:LONGITUDEOFASCENDINGNODE + tOrbit:ARGUMENTOFPERIAPSIS + tOrbit:TRUEANOMALY.
	local angleShip IS SHIP:ORBIT:LONGITUDEOFASCENDINGNODE + SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY.
	local phaseAngle is MOD(angleBody - angleShip, 360).
	if phaseAngle < 0 { set phaseAngle TO phaseAngle + 360. }
	return phaseAngle.
}.

function calcBodyPhaseAngle {
	parameter tBody.
	return calcOrbitPhaseAngle(tBody:ORBIT).
}.

function calcFuturePhaseAngle {
	parameter tBody.
	parameter tFuture.
	local pShip IS SHIP:POSITION - SHIP:BODY:POSITION.
	local aShip IS (180 + ARCTAN2(pShip:Z, pShip:X)).
	local pBody IS POSITIONAT(tBody, tFuture) - SHIP:BODY:POSITION.
	local aBody IS (180 + ARCTAN2(pBody:Z, pBody:X)).
	//print "atan2 new body angle: " + aBody.
	local aPhase IS MOD(aBody - aShip, 360).
	if aPhase < 0 { 
		set aPhase TO aPhase + 360. 
	}.
	//print "The new phase angle will be: " + aPhase.
	return aPhase.
}.
