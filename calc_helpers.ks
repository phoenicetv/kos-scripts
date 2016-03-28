// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only. Not meant for distribution.

FUNCTION readAtmosphericData {
	PARAMETER tBody.
	LOCAL tAtm IS BODY(tBody):ATM.
	PRINT "-------------------------".
	PRINT "Atmospheric information: " + tAtm:BODY.
	PRINT "-------------------------".
	PRINT "Exists? " + tAtm:EXISTS.
	PRINT "Oxygen? " + tAtm:OXYGEN.
	PRINT "Sea level pressure: " + tAtm:SEALEVELPRESSURE.
	PRINT "Height: " + tAtm:HEIGHT.
}.

function calcSpeedAtRadius {
	parameter mu.
	parameter r1.
	parameter a.
	return mu * (2/r1 - 1/a).
}

FUNCTION calcCircularizeDV {
	PARAMETER altit.
	// gravitational constant times focal body mass
	LOCAL mu IS SHIP:ORBIT:BODY:MU.
	// average of PERI+APO+diameter of focal body
	LOCAL a IS SHIP:ORBIT:SEMIMAJORAXIS.
	// APO+radius of focal body, larger half of the semimajor axis
	LOCAL r1 IS SHIP:ORBIT:BODY:RADIUS + altit.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	LOCAL apoV IS (mu*(2/r1 - 1/a))^(0.5).
	// the formula for circular orbit vel simplifies to:
	// r1 here instead of 'a' because 'a' is the old semi-major axis
	LOCAL circularV IS (mu / r1)^(0.5).
	PRINT "apoV is: " + apoV.
	PRINT "circularV is: " + circularV.
	RETURN circularV - apoV.
}

FUNCTION calcHoemannDVtoOrbit {
	PARAMETER tOrbit.
	// mu = gravitational constant times focal body mass
	LOCAL mu IS SHIP:ORBIT:BODY:MU.
	// alt+radius of focal body, smaller half of the semimajor axis when leaving
	LOCAL r1 IS SHIP:ORBIT:BODY:RADIUS + SHIP:ALTITUDE.
	PRINT "Local r1 is: " + r1.
	// TODO: this is technically wrong for highly eccentric orbits!!
	//       NOT a proper rendezvous!!!
	// r2 = distance of target body, let's assume the average for now
	LOCAL r2 IS SHIP:ORBIT:BODY:RADIUS + (tOrbit:PERIAPSIS + tOrbit:APOAPSIS) / 2.
	PRINT "Target r2 is: " + r2.
	LOCAL a IS (r1 + r2) / 2.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	LOCAL periV IS (mu*(2/r1 - 1/a))^(0.5).
	PRINT "Calculated periV to be: " + periV.
	return periV - SHIP:VELOCITY:ORBIT:MAG.
}

FUNCTION calcCircularizeSpeed {
	PARAMETER altit.
	LOCAL mu IS SHIP:ORBIT:BODY:MU.
	// APO+radius of focal body, larger half of the semimajor axis
	LOCAL r1 IS SHIP:ORBIT:BODY:RADIUS + altit.
	// the formula for circular orbit vel simplifies to:
	RETURN (mu / r1)^(0.5).
}.

FUNCTION calcOrbitPhaseAngle {
	PARAMETER tOrbit.
	LOCAL angleBody IS tOrbit:LONGITUDEOFASCENDINGNODE + tOrbit:ARGUMENTOFPERIAPSIS + tOrbit:TRUEANOMALY.
	LOCAL angleShip IS SHIP:ORBIT:LONGITUDEOFASCENDINGNODE + SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY.
	LOCAL phaseAngle is MOD(angleBody - angleShip, 360).
	IF phaseAngle < 0 { SET phaseAngle TO phaseAngle + 360. }
	return phaseAngle.
}.

FUNCTION calcBodyPhaseAngle {
	PARAMETER tBody.
	return calcOrbitPhaseAngle(tBody:ORBIT).
}.

FUNCTION calcFuturePhaseAngle {
	PARAMETER tBody.
	PARAMETER tFuture.
	LOCAL pShip IS SHIP:POSITION - SHIP:BODY:POSITION.
	LOCAL aShip IS (180 + ARCTAN2(pShip:Z, pShip:X)).
	LOCAL pBody IS POSITIONAT(tBody, tFuture) - SHIP:BODY:POSITION.
	LOCAL aBody IS (180 + ARCTAN2(pBody:Z, pBody:X)).
	//PRINT "atan2 new body angle: " + aBody.
	LOCAL aPhase IS MOD(aBody - aShip, 360).
	IF aPhase < 0 { 
		SET aPhase TO aPhase + 360. 
	}.
	//PRINT "The new phase angle will be: " + aPhase.
	RETURN aPhase.
}.
