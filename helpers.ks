// copyright PHOeNICE. Not to be redistributed for any release.
// personal use and education only. Not meant for distribution.

LIST PARTS in masterPartList.

// speed
function speedAtRadius() {
	parameter mu.
	parameter r1.
	parameter a.
	return mu * (2/r1 - 1/a).
}
// 1   2   3    4      5       6        7
// 5, 10, 50, 100, 1.000, 10.000, 100.000
set warpmode to "RAILS".
set warpmode to "PHYSICS".
set warp to 5.


SET shipSizeScalar to 20.0.
SET MinTurnSpeed to 100.
SET MinTurnAltitude to   1000.
SET HardTurnAltitude to 30000.
SET TargetAltitude  to 100000.
LOCK tOrientation to HEADING(90, 90).

FUNCTION smoothRotate {
	PARAMETER dir.
	LOCAL spd IS max(SHIP:ANGULARMOMENTUM:MAG/10,4).
	LOCAL curF IS SHIP:FACING:FOREVECTOR.
	LOCAL curR IS SHIP:FACING:TOPVECTOR.
	LOCAL dirF IS dir:FOREVECTOR.
	LOCAL dirR IS dir:TOPVECTOR.
	LOCAL axis IS VCRS(curF,dirF).
	LOCAL axisR IS VCRS(curR,dirR).
	LOCAL rotAng IS VANG(dirF,curF)/spd.
	LOCAL rotRAng IS VANG(dirR,curR)/spd.
	LOCAL rot IS ANGLEAXIS(min(2,rotAng),axis).
	LOCAL rotR IS R(0,0,0).
	IF VANG(dirF,curF) < 90 {
		SET rotR TO ANGLEAXIS(min(0.5,rotRAng),axisR).
	}
	RETURN LOOKDIRUP(rot * curF, rotR * curR).
}

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

FUNCTION etaToApoWithMinus {
	LOCAL val IS ETA:APOAPSIS.
	IF val > SHIP:ORBIT:PERIOD / 2 {
		// give a negative ETA here if after APO
		SET val TO val - SHIP:ORBIT:PERIOD.
	}.
	RETURN val.
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

SET drawingFacingArrows to FALSE.
FUNCTION createFacingArrows {
	SET drawingFacingArrows to TRUE.
	SET targetArrow TO VECDRAW(V(0,0,0), shipSizeScalar * tOrientation:FOREVECTOR, RGB(0,0,1), "", 1.0, TRUE, 0.1).
	SET facingArrow TO VECDRAW(V(0,0,0), shipSizeScalar * SHIP:FACING:FOREVECTOR, RGB(1,0,1), "", 1.0, TRUE, 0.1).
}.

SET drawingAngleArrows to FALSE.
FUNCTION createAngleArrows {
	SET drawingAngleArrows TO TRUE.
	SET axisNorthArrow TO VECDRAW(V(0,0,0), (shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "North", 5.0, TRUE, 0.1).
	SET axisSouthArrow TO VECDRAW(V(0,0,0),-(shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "South", 5.0, TRUE, 0.1).
	SET axisRadialArrow TO VECDRAW(V(0,0,0),(shipSizeScalar/3) * (SHIP:NORTH + R(90,0,0)):FOREVECTOR, RGB(1,1,1), "Radial",  5.0, TRUE, 0.1).
	SET axisEastArrow TO VECDRAW(V(0,0,0), -(shipSizeScalar/3) * (SHIP:NORTH + R(90,90,0)):FOREVECTOR, RGB(1,1,1), "East",  5.0, TRUE, 0.1).
}.

FUNCTION updateAngleArrows {
	IF drawingFacingArrows = TRUE {
		SET facingArrow:VEC to shipSizeScalar * SHIP:FACING:FOREVECTOR.
		SET targetArrow:VEC to shipSizeScalar * tOrientation:FOREVECTOR.
	}.
	IF drawingAngleArrows = TRUE {
		SET axisNorthArrow:VEC TO (shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR.
		SET axisSouthArrow:VEC TO -(shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR.
		SET axisRadialArrow:VEC TO (shipSizeScalar/3) * (SHIP:NORTH + R(90,0,0)):FOREVECTOR.
		SET axisEastArrow:VEC TO -(shipSizeScalar/3) * (SHIP:NORTH + R(90,90,0)):FOREVECTOR.
	}.
}.

FUNCTION clearFacingArrows {
	IF drawingFacingArrows = TRUE {
		UNSET targetArrow.
		UNSET facingArrow.
	}.
	SET drawingFacingArrows TO FALSE.
}.

FUNCTION clearAngleArrows {
	IF drawingAngleArrows = TRUE {
		UNSET axisRadialArrow.
		UNSET axisEastArrow.
		UNSET axisNorthArrow.
		UNSET axisSouthArrow.
	}.
	SET drawingAngleArrows TO FALSE.
}.


FUNCTION executeLaunchMyVessel {
	PRINT "=================================".
	PRINT "Launching straight up, initially.".
	PRINT "=================================".
	IF SHIP:MAXTHRUST = 0.0 { STAGE. }.
	LOCK NeededUpwardThrust TO CONSTANT:G * BODY:MASS * SHIP:MASS / ((BODY:RADIUS + SHIP:ALTITUDE)^2).
	LOCK TWR to MAX(0.01, SHIP:MAXTHRUST) / NeededUpwardThrust.
	PRINT "TWR estimated to be: " + TWR.
	LOCK THROTTLE to MIN(1.0, MAX(0.01, 1.7/TWR)).
	PRINT "Initial throttle to: " + (MIN(1.0, MAX(0.01, 1.7/TWR))).
	LOCK tOrientation to HEADING(90, 90).
	LOCK STEERING to smoothRotate(tOrientation).

	UNTIL SHIP:MAXTHRUST = 0.0 OR SHIP:ALTITUDE > MinTurnAltitude {
		updateAngleArrows().
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL).
			LOCK THROTTLE to 0.0.
			WAIT 0.5.
			STAGE.
			WAIT 1.5.
			LOCK THROTTLE to MIN(1.0, MAX(0.01, 1.7/TWR)).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	UNLOCK NeededUpwardThrust.
	UNLOCK TWR.
}.

FUNCTION executeGravityTurn {
	//LOCK fancyTheta to 90 - 90*(SHIP:ALTITUDE/60000)^(2/5).
	SET limiterM to (45-85)/(HardTurnAltitude-MinTurnAltitude).
	SET limiterB to 85 - MinTurnAltitude *limiterM.
	LOCK limiterY to MAX(45, SHIP:ALTITUDE * limiterM + limiterB).
	SET targetArrowOLD TO VECDRAW(V(0,0,0), shipSizeScalar * HEADING(90, limiterY):FOREVECTOR, RGB(1,0,0), "", 1.0, TRUE, 0.1).
	PRINT "==================================".
	PRINT "Now compensating for gravity turn.".
	PRINT "==================================".
	//LOCK tOrientation to HEADING(90,85).
	LOCK tOrientation to HEADING(90, MAX(0, 90 - 90*(SHIP:ALTITUDE/60000)^(2/5))). // limiterY
	LOCK STEERING to smoothRotate(tOrientation).
	//LOCK tOrientation to R(SHIP:SRFPROGRADE:PITCH+2.5, 0, 0).
	PRINT "Orienting for 5 degree initial turn.".

	LOCK THROTTLE to 1.0.
	UNTIL SHIP:ORBIT:APOAPSIS > TargetAltitude OR SHIP:MAXTHRUST = 0 {
		SET targetArrowOLD:VEC to shipSizeScalar * HEADING(90, limiterY):FOREVECTOR.
		updateAngleArrows().
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
		LOCK THROTTLE to 0.0.
		WAIT 0.5.
			STAGE.
		WAIT 1.5.
		LOCK THROTTLE to 1.0.
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	UNSET targetArrowOLD.
	UNLOCK limiterY.
	LOCK THROTTLE to 0.0.
	UNLOCK STEERING.
}.
	
FUNCTION executeCoastToApo {
	PRINT "=====================".
	PRINT "Coasting to APOAPSIS.".
	PRINT "=====================".
	IF SHIP:ALTITUDE < SHIP:ORBIT:BODY:ATM:HEIGHT {
		LOCK tOrientation to SHIP:PROGRADE.
		LOCK DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
		LOCK STEERING to smoothRotate(tOrientation).
		UNTIL DifferenceMag < 1 {
			updateAngleArrows().
			WAIT 0.1.
		}.
		SET WARPMODE to "PHYSICS".
		SET WARP to 3.
		UNTIL SHIP:ALTITUDE > SHIP:ORBIT:BODY:ATM:HEIGHT {
			updateAngleArrows().
			WAIT 0.1.
		}.
		PRINT "Exit atmosphere at ALTITUDE: " + SHIP:ALTITUDE.
		PRINT "Apoapsis is: " + SHIP:APOAPSIS.
		SET WARP to 0.
	}.
	
	LOCK tOrientation to HEADING(90, 0).
	LOCK DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	LOCK STEERING to smoothRotate(tOrientation).
	UNTIL DifferenceMag < 1 {
		updateAngleArrows().
		WAIT 0.1.
	}.
	UNLOCK DifferenceMag.
	UNLOCK STEERING.
	SET WARPMODE to "RAILS".
	SET WARP to 2.
	// needed deltaV divided by our acceleration gives us a time
	LOCAL circularSpeedNeeded IS calcCircularizeSpeed(SHIP:ORBIT:APOAPSIS).
	LOCAL circularBurn IS calcCircularizeDV(SHIP:ORBIT:APOAPSIS).
	PRINT "Need to burn m/s: " + circularBurn.
	SET burnTime TO circularBurn / (SHIP:MAXTHRUST / SHIP:MASS).
	PRINT "Estimated burn time is: " + burnTime.

	UNTIL etaToApoWithMinus() < 20 + (burnTime / 2) {
		updateAngleArrows().
		WAIT 0.1.
	}.
	SET WARP to 0.
}.

FUNCTION executeCircularize {
	// F = m*v^2 / r
	// F = ma, Kerbin is 9.81m/s^2
	// F = G*m1*m2/(r1+r2)^2
	// 100km orbit should be 7.2073 m/s^2
	// 2246.1 m/s
	// LOCK OrbitalSpeed to SHIP:MASS * (SHIP:GROUNDSPEED * SHIP:GROUNDSPEED) / (BODY:RADIUS + SHIP:ALTITUDE).
	//SET myNode to NODE( TIME:SECONDS + ETA:APOAPSIS, 0, 0, 2246.1 - SHIP:GROUNDSPEED ).
	//ADD myNode.
	//LOCK timeToBurn to myNode:PROGRADE / (SHIP:MAXTHRUST / SHIP:MASS).
	//PRINT "Calculated time to burn is: " + timeToBurn.

	//LOCK Fg to CONSTANT:G * BODY:MASS * SHIP:MASS / (SHIP:ALTITUDE+BODY:RADIUS)^2.
	//PRINT "Fg is: " + Fg.
	//LOCK sinTheta to MIN(1.0, MAX(0.0, Fg / (MAX(1, SHIP:MAXTHRUST)))).
	//PRINT "sinTheta is: " + sinTheta.
	//LOCK VertAdjust to MAX(-Fg, MIN(SHIP:VERTICALSPEED, Fg)) / Fg.
	//PRINT "vertAdjust is: " + VertAdjust.
	//LOCK theta to (ARCSIN(sinTheta) * (0.5 - VertAdjust)).
	//PRINT "theta is: " + theta.

	PRINT "=====================".
	PRINT "Increasing PERIAPSIS.".
	PRINT "=====================".
	LOCAL circularBurn IS calcCircularizeDV(SHIP:ORBIT:APOAPSIS).
	LOCAL circularizeNode to NODE( TIME:SECONDS + etaToApoWithMinus(), 0, 0, circularBurn ).
	ADD circularizeNode.
	LOCK tOrientation to circularizeNode:BURNVECTOR:DIRECTION.
	LOCK STEERING to smoothRotate(tOrientation).
	UNTIL etaToApoWithMinus() < burnTime/2 + 1 {
		updateAngleArrows().
		WAIT 0.1.
	}.
	PRINT "Firing engines to circularize.".
	//LOCK THROTTLE to MAX(0.1, MIN(1.0, 3 * SHIP:ORBIT:ECCENTRICITY)).
		// 3 seconds before we're done, slow it down to be more accurate
	LOCK THROTTLE to MAX(0.05, MIN(1.0, 0.2 * (circularizeNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	UNTIL SHIP:ORBIT:SEMIMAJORAXIS > (BODY:RADIUS + TargetAltitude) or SHIP:MAXTHRUST = 0 {
		updateAngleArrows().
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE to 0.0.
			WAIT 0.5.
			STAGE.
			WAIT 1.5.
			LOCK THROTTLE to circularThrottle.
			//LOCK THROTTLE to MAX(0.1, MIN(1.0, 3 * SHIP:ORBIT:ECCENTRICITY)).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	LOCK THROTTLE to 0.0.
	UNLOCK THROTTLE.
	UNLOCK STEERING.
	REMOVE circularizeNode.
}.

FUNCTION searchBurnToMoon {
  PARAMETER targetName.
	LOCAL tBody IS BODY(targetName).
	SET TARGET TO tBody.
	PRINT "----------------------------------".
	PRINT "Gathering information about: " + tBody:NAME.
	PRINT "----------------------------------".
	LOCAL pAngle IS calcBodyPhaseAngle(tBody).
	LOCAL dv IS calcHoemannDVtoOrbit(tBody:ORBIT).
  PRINT "First stab at transfer.".
	LOCAL timeToBurn IS dv / (SHIP:MAXTHRUST / SHIP:MASS).
	PRINT "Generating rendezvous.".
	LOCAL tOffset IS TIME:SECONDS.
	LOCAL tBurn IS tOffset + timeToBurn / 2.
	SET transferNode TO NODE(tBurn, 0, 0, dv).
	ADD transferNode.
	LOCAL timeToTransfer IS (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	PRINT "Estimated trip time: " + timeToTransfer.
	LOCAL timePerDegree IS SHIP:ORBIT:PERIOD / 360.
	// step forward until we encounter the target moon
	// TODO: inclination may prevent this entirely
	UNTIL transferNode:ORBIT:TRANSITION = "ENCOUNTER" OR (tBurn - tOffset) > SHIP:ORBIT:PERIOD {
		SET tBurn TO tBurn + timePerDegree.
		SET transferNode:ETA TO tBurn.
		WAIT 0.5.
	}.
	SET pAngle TO calcFuturePhaseAngle(tBody, tBurn).
	PRINT "Identified earliest encounter at phase angle: " + pAngle.
	LOCAL pCurrent IS tBody:ORBIT:POSITION - SHIP:BODY:POSITION.
	LOCAL pFuture IS POSITIONAT(tBody, TIME:SECONDS + timeToTransfer) - SHIP:BODY:POSITION.
	LOCAL estimateAltitude IS (pFuture:MAG / pCurrent:MAG) * tBody:ALTITUDE.
	IF tBody:ALTITUDE <> estimateAltitude {
		// target must be eccentric
		// TODO: Hoehmann adjustment based on new target altitude
		PRINT "Ratio between altitudes of initial and projected orbits: ".
		PRINT "future=" + pFuture:MAG + " -- current=" + pCurrent:MAG.
		PRINT "Ratio = " + (pFuture:MAG / pCurrent:MAG).
		PRINT "TODO: we need a Hoehmann function for a given altitude, not orbit".
	}.
	readOutManeuverNode().
	PRINT "Press H to get updated readout.".
}.

FUNCTION executeBurnToMoon {
  PARAMETER targetName.
  PARAMETER targetPhaseAngle.
  PARAMETER additionalDV.
	LOCAL tBody IS BODY(targetName).
	SET TARGET TO tBody.
	PRINT "----------------------------------".
	PRINT "Gathering information about: " + tBody:NAME.
	PRINT "----------------------------------".
	LOCAL pAngle IS calcBodyPhaseAngle(tBody).
	IF pAngle < targetPhaseAngle - 1 or pAngle > targetPhaseAngle + 1 {
		// wait -- cannot warp under acceleration, we just cut throttle..
		WAIT 0.5.
		PRINT "Warping until phase angle is 111~.".
		SET WARPMODE to "RAILS".
		SET WARP to 3.
		LOCAL timePerDegree IS 1.
		LOCAL lastAngle IS pAngle.
		LOCAL tLastPrint IS TIME:SECONDS.
		UNTIL pAngle > targetPhaseAngle - 1 and pAngle < targetPhaseAngle + 1 {
			IF tLastPrint + 50 < TIME:SECONDS {
				PRINT "pAngle is now: " + pAngle + " -- waiting: " + timePerDegree.
				SET tLastPrint to TIME:SECONDS.
			}.
			WAIT timePerDegree / 2.
			SET lastAngle TO pAngle.
			SET pAngle TO calcBodyPhaseAngle(tBody).
			SET timePerDegree TO MIN(50, MAX(0.1, 0.5 * timePerDegree / ABS(pAngle - lastAngle))).
		}.
	}.
	SET WARP to 0.
	
  PRINT "First stab at transfer.".
	LOCAL dv IS calcHoemannDVtoOrbit(tBody:ORBIT) + additionalDV.
	LOCAL timeToBurn IS dv / (SHIP:MAXTHRUST / SHIP:MASS).
	SET transferNode TO NODE(TIME:SECONDS + timeToBurn/2, 0, 0, dv).
	ADD transferNode.

	LOCAL timeToTransfer IS (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	PRINT "Estimated trip time: " + timeToTransfer.
	LOCAL aPhase IS calcFuturePhaseAngle(tBody, TIME:SECONDS + timeToTransfer).
	PRINT "Estimated future phase angle is: " + aPhase.

	LOCK STEERING to smoothRotate(transferNode:BURNVECTOR:DIRECTION).
	LOCK THROTTLE to MAX(0.1, MIN(1.0, 0.2 * (transferNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	UNTIL transferNode:DELTAV:MAG < 1.0 or SHIP:MAXTHRUST = 0.0 {
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE to 0.0.
			WAIT 0.5.
			STAGE.
			WAIT 1.5.
			LOCK THROTTLE to MAX(0.1, MIN(1.0, 0.2 * (transferNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	LOCK THROTTLE to 0.0.
	UNLOCK THROTTLE.
	
	UNLOCK STEERING.
	UNLOCK tOrientation.
}.

//SET transferNode IS NODE(TIME:SECONDS + 600, 0, 0, 800).
//ADD transferNode.

FUNCTION readOutManeuverNode {
	LOCAL fOrbit IS ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
	LOCAL fPeri IS fOrbit:PERIAPSIS.
	PRINT "Future periapsis will be: " + fPeri.
	PRINT "DeltaV needed is: " + transferNode:PROGRADE.
	LOCAL tETA IS transferNode:ETA.
	IF tETA > (transferNode:ORBIT:PERIOD / 2) {
		SET tETA TO tETA - transferNode:ORBIT:PERIOD.
	}.
	PRINT "ETA is:" + tETA.
}.

createFacingArrows().
createAngleArrows().
executeLaunchMyVessel().
executeGravityTurn().
executeCoastToApo().
executeCircularize().
clearFacingArrows().
clearAngleArrows().
//executeBurnToMoon("Mun", 92, 2).
searchBurnToMoon("Mun").

SET keyPressed TO FALSE.
WHEN SHIP:CONTROL:PILOTFORE > 0.0 AND keyPressed = FALSE THEN {
	PRINT "-- You pressed H! Yay!".
	PRINT " ".
	PRINT " ".
	LOCAL tBody IS BODY("Mun").
	LOCAL pAngle IS calcBodyPhaseAngle(tBody).
	PRINT "Current phase angle is: " + pAngle.
	readOutManeuverNode().
	SET keyPressed TO TRUE.
	PRESERVE.
}.
WHEN keyPressed AND SHIP:CONTROL:PILOTFORE = 0.0 THEN {
	SET keyPressed TO FALSE.
	PRESERVE.
}.
WAIT UNTIL SHIP:CONTROL:PILOTSTARBOARD > 0.0.
//until false {
//	clearscreen.
//	foo().
//	wait 5.
//}.
