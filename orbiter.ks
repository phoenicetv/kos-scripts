// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only. Not meant for distribution.

SET shipSizeScalar TO 30.0.
SET MinTurnSpeed TO 100.
SET MinTurnAltitude TO   1000.
SET HardTurnAltitude TO 30000.
SET TargetAltitude  TO 100000.
SET transferNode TO NODE(TIME:SECONDS, 0, 0, 5).

RUN ONCE helpers.
WAIT UNTIL SHIP:UNPACKED.
//SET TERMINAL:HEIGHT TO 72.
//SET TERMINAL:WIDTH TO 50.

FUNCTION executeLaunchMyVessel {
	PRINT "=================================".
	PRINT "Launching straight up, initially.".
	PRINT "=================================".
	IF SHIP:MAXTHRUST = 0.0 { STAGE. }.
	LOCK NeededUpwardThrust TO CONSTANT:G * BODY:MASS * SHIP:MASS / ((BODY:RADIUS + SHIP:ALTITUDE)^2).
	LOCK TWR TO MAX(0.01, SHIP:MAXTHRUST) / NeededUpwardThrust.
	PRINT "TWR estimated TO be: " + TWR.
	LOCK THROTTLE TO MIN(1.0, MAX(0.01, 1.7/TWR)).
	PRINT "Initial throttle to: " + (MIN(1.0, MAX(0.01, 1.7/TWR))).
	LOCK tOrientation TO HEADING(90, 90).
	LOCK STEERING TO smoothRotate(tOrientation).

	UNTIL SHIP:MAXTHRUST = 0.0 OR SHIP:ALTITUDE > MinTurnAltitude {
		updateAngleArrows().
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL).
			LOCK THROTTLE TO 0.0.
			WAIT 0.5.
			STAGE.
			IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { BREAK. }
			WAIT 1.5.
			LOCK THROTTLE TO MIN(1.0, MAX(0.01, 1.7/TWR)).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	UNLOCK NeededUpwardThrust.
	UNLOCK TWR.
}.

FUNCTION executeGravityTurn {
	//LOCK fancyTheta TO 90 - 90*(SHIP:ALTITUDE/60000)^(2/5).
	SET limiterM TO (45-85)/(HardTurnAltitude-MinTurnAltitude).
	SET limiterB TO 85 - MinTurnAltitude *limiterM.
	LOCK limiterY TO MAX(45, SHIP:ALTITUDE * limiterM + limiterB).
	SET targetArrowOLD TO VECDRAW(V(0,0,0), shipSizeScalar * HEADING(90, limiterY):FOREVECTOR, RGB(1,0,0), "", 1.0, TRUE, 0.1).
	PRINT "==================================".
	PRINT "Now compensating for gravity turn.".
	PRINT "==================================".
	//LOCK tOrientation TO HEADING(90,85).
	LOCK tOrientation TO HEADING(90, MAX(0, 90 - 90*(SHIP:ALTITUDE/60000)^(4/5))). // limiterY
	LOCK STEERING TO smoothRotate(tOrientation).
	//LOCK tOrientation TO R(SHIP:SRFPROGRADE:PITCH+2.5, 0, 0).
	PRINT "Orienting for 5 degree initial turn.".

	LOCK THROTTLE TO 1.0.
	UNTIL SHIP:ORBIT:APOAPSIS > TargetAltitude OR SHIP:MAXTHRUST = 0 {
		SET targetArrowOLD:VEC TO shipSizeScalar * HEADING(90, limiterY):FOREVECTOR.
		updateAngleArrows().
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE TO 0.0.
			WAIT 0.5.
			STAGE.
			IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { BREAK. }
			WAIT 1.5.
			LOCK THROTTLE TO 1.0.
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
			LOCAL NeededUpwardThrust IS CONSTANT:G * BODY:MASS * SHIP:MASS / ((BODY:RADIUS + SHIP:ALTITUDE)^2).
			LOCAL TWR IS MAX(0.01, SHIP:MAXTHRUST) / NeededUpwardThrust.
			PRINT "Estimated TWR is: " + TWR.
		}.
	}.
	UNSET targetArrowOLD.
	UNLOCK limiterY.
	LOCK THROTTLE TO 0.0.
	UNLOCK STEERING.
}.
	
FUNCTION executeCoastToApo {
	IF SHIP:ALTITUDE > SHIP:ORBIT:BODY:ATM:HEIGHT { RETURN. }.
	
	PRINT "=====================".
	PRINT "Coasting TO APOAPSIS.".
	PRINT "=====================".
	LOCK tOrientation TO SHIP:PROGRADE.
	LOCK DifferenceMag TO VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	LOCK THROTTLE TO 0.0.
	LOCK STEERING TO smoothRotate(tOrientation).
	UNTIL DifferenceMag < 0.5 {
		updateAngleArrows().
		WAIT 0.1.
	}.
	SET WARPMODE TO "PHYSICS".
	SET WARP TO 3.
	UNTIL SHIP:ALTITUDE > SHIP:ORBIT:BODY:ATM:HEIGHT {
		updateAngleArrows().
		WAIT 0.1.
	}.
	PRINT "Exit atmosphere at ALTITUDE: " + SHIP:ALTITUDE.
	PRINT "Apoapsis is: " + SHIP:APOAPSIS.
	SET WARP TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	UNLOCK DifferenceMag.
}.

FUNCTION executeCircularize {
	// F = m*v^2 / r
	// F = ma, Kerbin is 9.81m/s^2
	// F = G*m1*m2/(r1+r2)^2
	// 100km orbit should be 7.2073 m/s^2
	// 2246.1 m/s
	// LOCK OrbitalSpeed TO SHIP:MASS * (SHIP:GROUNDSPEED * SHIP:GROUNDSPEED) / (BODY:RADIUS + SHIP:ALTITUDE).
	//SET myNode TO NODE( TIME:SECONDS + ETA:APOAPSIS, 0, 0, 2246.1 - SHIP:GROUNDSPEED ).
	//ADD myNode.
	//LOCK timeToBurn TO myNode:PROGRADE / MAX(1.0, (SHIP:MAXTHRUST / SHIP:MASS)).
	//PRINT "Calculated time TO burn is: " + timeToBurn.

	//LOCK Fg TO CONSTANT:G * BODY:MASS * SHIP:MASS / (SHIP:ALTITUDE+BODY:RADIUS)^2.
	//PRINT "Fg is: " + Fg.
	//LOCK sinTheta TO MIN(1.0, MAX(0.0, Fg / (MAX(1, SHIP:MAXTHRUST)))).
	//PRINT "sinTheta is: " + sinTheta.
	//LOCK VertAdjust TO MAX(-Fg, MIN(SHIP:VERTICALSPEED, Fg)) / Fg.
	//PRINT "vertAdjust is: " + VertAdjust.
	//LOCK theta TO (ARCSIN(sinTheta) * (0.5 - VertAdjust)).
	//PRINT "theta is: " + theta.

	PRINT "=====================".
	PRINT "Increasing PERIAPSIS.".
	PRINT "=====================".
	LOCAL circularBurn IS calcCircularizeDV(SHIP:ORBIT:APOAPSIS).
	// needed deltaV divided by our acceleration gives us a time
	PRINT "Need TO burn m/s: " + circularBurn.
	LOCAL burnTime IS circularBurn / (SHIP:MAXTHRUST / SHIP:MASS).
	PRINT "Estimated burn time is: " + burnTime.
	LOCAL circularizeNode TO NODE( TIME:SECONDS + etaToApoWithMinus(), 0, 0, circularBurn ).
	ADD circularizeNode.
	LOCK tOrientation TO circularizeNode:BURNVECTOR:DIRECTION.
	LOCK STEERING TO smoothRotate(tOrientation).
	LOCK DifferenceMag TO VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	UNTIL DifferenceMag < 0.5 {
		updateAngleArrows().
		WAIT 0.1.
	}.
	UNLOCK DifferenceMag.
	
	PRINT "Using WarpTo()" + TIME:SECONDS.
	// TODO: make a warpto that doesn't overshoot
	WARPTO(TIME:SECONDS + etaToApoWithMinus() + burnTime/2 + 15).
	PRINT "Using wait until loop.." + TIME:SECONDS.
	UNTIL etaToApoWithMinus() < burnTime/2 + 1 {
		updateAngleArrows().
		WAIT 0.1.
	}.
	PRINT "Firing engines TO circularize.".
	//LOCK THROTTLE TO MAX(0.1, MIN(1.0, 3 * SHIP:ORBIT:ECCENTRICITY)).
	// 3 seconds before we're done, slow it down TO be more accurate
	LOCK circularThrottle TO MAX(0.05, MIN(1.0, 0.2 * (circularizeNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	LOCK THROTTLE TO circularThrottle.
	UNTIL (SHIP:APOAPSIS - SHIP:PERIAPSIS) < 1000 OR SHIP:ORBIT:SEMIMAJORAXIS > (BODY:RADIUS + TargetAltitude) OR SHIP:MAXTHRUST = 0 {
		updateAngleArrows().
		WAIT 0.01.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE TO 0.0.
			WAIT 0.5.
			STAGE.
			IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { BREAK. }
			WAIT 1.5.
			LOCK THROTTLE TO circularThrottle.
			//LOCK THROTTLE TO MAX(0.1, MIN(1.0, 3 * SHIP:ORBIT:ECCENTRICITY)).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	LOCK THROTTLE TO 0.0.
	UNLOCK THROTTLE.
	UNLOCK circularThrottle.
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
	PRINT "dv TO target orbit is: " + dv.
	LOCAL timeToBurn IS dv / MAX(1, SHIP:MAXTHRUST / SHIP:MASS).
	LOCAL timePerDegree IS SHIP:ORBIT:PERIOD / 360.
	PRINT "Generating rendezvous.".
	LOCAL tBurn IS TIME:SECONDS + timeToBurn / 2.
	SET transferNode TO NODE(tBurn - TIME:SECONDS, 0, 0, dv).
	ADD transferNode.
	LOCAL timeToTransfer IS (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	PRINT "Estimated trip time: " + timeToTransfer.
	// BUG: this is causing a "Must attach node first" error and I don't know why
	//LOCAL pCurrent IS tBody:ORBIT:POSITION - SHIP:BODY:POSITION.
	//LOCAL pFuture IS POSITIONAT(tBody, TIME:SECONDS + timeToTransfer) - SHIP:BODY:POSITION.
	//LOCAL estimateAltitude IS (pFuture:MAG / pCurrent:MAG) * tBody:ALTITUDE.
	//IF tBody:ALTITUDE <> estimateAltitude {
	//	// TODO: target is eccentric, we may not be compensating properly
	//	PRINT "Ratio between orbit altitudes:".
	//	PRINT "tBody:ALTITUDE   = " + tBody:ALTITUDE.
	//	PRINT "estimateAltitude = " + estimateAltitude.
	//	PRINT "future=" + pFuture:MAG + " -- current=" + pCurrent:MAG.
	//	PRINT "Ratio = " + (pFuture:MAG / pCurrent:MAG).
	//	SET dv TO calcHoemannDVtoAlt(estimateAltitude).
	//	PRINT "New dv adjusted is: " + dv.
	//}.
	// step forward until we reach an encounter with the target moon
	// TODO: inclination may prevent this entirely
	PRINT "Searching for first encounter by angle..".
	UNTIL transferNode:ORBIT:TRANSITION = "ENCOUNTER" OR tBurn - TIME:SECONDS > SHIP:ORBIT:PERIOD {
		SET tBurn TO tBurn + timePerDegree.
		SET transferNode:ETA TO tBurn - TIME:SECONDS.
		WAIT 0.05.
	}.
	LOCAL fOrbit IS ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
	LOCAL lowestETA IS tBurn.
	LOCAL lowestDV IS dv * 1.02.
	LOCAL dvOffset IS 0.
	LOCAL lastTransitionCount IS 1.
	LOCAL transitionCount IS 0.
	
	// fine tune TO cheapest RETURN TRAJECTORY
	PRINT "Fine tuning search. Watch on your map view!".
	UNTIL lastTransitionCount = 0 {
		IF dvOffset < -0.02 * lowestDV {
			SET dvOffset TO 0.
			SET tBurn TO tBurn + timePerDegree.
			SET transferNode:ETA TO tBurn - TIME:SECONDS.
			SET lastTransitionCount TO transitionCount.
			SET transitionCount TO 0.
		}
		SET dvOffset TO dvOffset - 0.1.
		SET transferNode:PROGRADE TO lowestDV + dvOffset.
		IF transferNode:ORBIT:TRANSITION = "ENCOUNTER" {
			SET transitionCount TO transitionCount + 1.
			SET fOrbit TO ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
			IF fOrbit:PERIAPSIS > 25000 AND fOrbit:PERIAPSIS < 35000 { 
				SET dBestSoFar TO transferNode:BURNVECTOR:DIRECTION.
				LOCK tOrientation TO dBestSoFar.
				LOCK STEERING TO smoothRotate(tOrientation).
				SET lowestETA TO tBurn.
				SET lowestDV TO lowestDV + dvOffset.
				PRINT "New min found: " + lowestDV.
			}.
		}.
		WAIT 0.001.
	}.
	SET transferNode:ETA TO lowestETA - TIME:SECONDS.
	SET transferNode:PROGRADE TO lowestDV.
	PRINT "Lowest dv required TO return found is: " + lowestDV.
	SET pAngle TO calcFuturePhaseAngle(tBody, tBurn).
	PRINT "Identified return encounter at phase angle: " + pAngle.
	
	// execute the return trajectory node
	LOCK tOrientation TO transferNode:BURNVECTOR:DIRECTION.
	LOCK STEERING TO smoothRotate(tOrientation).
	LOCK DifferenceMag TO VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	UNTIL DifferenceMag < 0.5 {
		WAIT 0.1.
	}.
	SET timeToBurn TO lowestDV / MAX(1, SHIP:MAXTHRUST / SHIP:MASS).
	PRINT "Estimated time TO burn is: " + timeToBurn.
	IF transferNode:ETA > 50 + (timeToBurn/2) {
		PRINT "Time warping TO node: " + transferNode:ETA.
		SET WARPMODE TO "RAILS".
		LOCAL tWarpSpeed IS 3.
		SET WARP TO tWarpSpeed.
		UNTIL transferNode:ETA < 15 + (timeToBurn/2) {
			IF tWarpSpeed = 3 AND transferNode:ETA < 55 + (timeToBurn/2) {
				SET tWarpSpeed TO 2.
				SET WARP TO tWarpSpeed.
			}.
			IF tWarpSpeed = 2 AND transferNode:ETA < 25 + (timeToBurn/2) {
				SET tWarpSpeed TO 1.
				SET WARP TO tWarpSpeed.
			}.
			WAIT 0.1.
		}
		SET WARP TO 0.
	}.
	PRINT "Done warping. ETA: " + transferNode:ETA.
	UNTIL transferNode:ETA < timeToBurn/2 + 1 {
		WAIT 0.1.
	}.
	PRINT "To the " + targetName + "!".
	LOCAL haveRemovedNode TO false.
	SET tThrottle TO 1.0.
	LOCK THROTTLE TO tThrottle.
	SET fOrbit TO ORBITAT(SHIP, TIME:SECONDS + SHIP:ORBIT:PERIOD).
	LOCAL tVel IS SHIP:VELOCITY:ORBIT:MAG + transferNode:DELTAV:MAG.
	UNTIL (haveRemovedNode AND fOrbit:PERIAPSIS > 0 AND fOrbit:PERIAPSIS < SHIP:BODY:ATM:HEIGHT) OR SHIP:MAXTHRUST = 0.0 {
		WAIT 0.01.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE TO 0.0.
			WAIT 0.5.
			STAGE.
			IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { BREAK. }
			WAIT 1.5.
			LOCK THROTTLE TO tThrottle.
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
		// failsafe if we missed the node
		IF haveRemovedNode AND SHIP:VELOCITY:ORBIT:MAG > tVel { 
			PRINT "We missed the node, immediately aborting!".
			BREAK. 
		}.
		IF haveRemovedNode = FALSE AND transferNode:DELTAV:MAG < 2 * (SHIP:MAXTHRUST / SHIP:MASS) {
			PRINT "Within 2 seconds of thrust. Slowing down...".
			SET tVel TO SHIP:VELOCITY:ORBIT:MAG + transferNode:DELTAV:MAG.
			LOCK tThrottle TO MAX(0.05, MIN(1.0, 0.5 * ((tVel - SHIP:VELOCITY:ORBIT:MAG) / (MAX(1, SHIP:MAXTHRUST) / SHIP:MASS)) ) ).
			SET dBestSoFar TO transferNode:BURNVECTOR:DIRECTION.
			LOCK tOrientation TO dBestSoFar.
			LOCK STEERING TO smoothRotate(tOrientation).
			REMOVE transferNode.
			SET haveRemovedNode TO true.
		}.
		SET fOrbit TO ORBITAT(SHIP, TIME:SECONDS + SHIP:ORBIT:PERIOD).
	}.
	LOCK THROTTLE TO 0.0.
	UNLOCK tThrottle.
	UNLOCK THROTTLE.
	
	UNLOCK STEERING.
	UNLOCK tOrientation.
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
	IF pAngle < targetPhaseAngle - 1 OR pAngle > targetPhaseAngle + 1 {
		// wait -- cannot warp under acceleration, we just cut throttle..
		WAIT 0.5.
		PRINT "Warping until phase angle is 111~.".
		SET WARPMODE TO "RAILS".
		SET WARP TO 3.
		LOCAL timePerDegree IS 1.
		LOCAL lastAngle IS pAngle.
		LOCAL tLastPrint IS TIME:SECONDS.
		UNTIL pAngle > targetPhaseAngle - 1 AND pAngle < targetPhaseAngle + 1 {
			IF tLastPrint + 50 < TIME:SECONDS {
				PRINT "pAngle is now: " + pAngle + " -- waiting: " + timePerDegree.
				SET tLastPrint TO TIME:SECONDS.
			}.
			WAIT timePerDegree / 2.
			SET lastAngle TO pAngle.
			SET pAngle TO calcBodyPhaseAngle(tBody).
			SET timePerDegree TO MIN(50, MAX(0.1, 0.5 * timePerDegree / ABS(pAngle - lastAngle))).
		}.
	}.
	SET WARP TO 0.
	
  PRINT "First stab at transfer.".
	LOCAL dv IS calcHoemannDVtoOrbit(tBody:ORBIT) + additionalDV.
	LOCAL timeToBurn IS dv / MAX(1.0, SHIP:MAXTHRUST / SHIP:MASS).
	SET transferNode TO NODE(TIME:SECONDS + timeToBurn/2, 0, 0, dv).
	ADD transferNode.

	LOCAL timeToTransfer IS (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	PRINT "Estimated trip time: " + timeToTransfer.
	LOCAL aPhase IS calcFuturePhaseAngle(tBody, TIME:SECONDS + timeToTransfer).
	PRINT "Estimated future phase angle is: " + aPhase.

	LOCK STEERING TO smoothRotate(transferNode:BURNVECTOR:DIRECTION).
	LOCK THROTTLE TO MAX(0.1, MIN(1.0, 0.2 * (transferNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	UNTIL transferNode:DELTAV:MAG < 1.0 OR SHIP:MAXTHRUST = 0.0 {
		WAIT 0.1.
		IF SHIP:MAXTHRUST = 0 {
			PRINT "Current stage is out of fuel!".
			PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
			LOCK THROTTLE TO 0.0.
			WAIT 0.5.
			STAGE.
			IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { BREAK. }
			WAIT 1.5.
			LOCK THROTTLE TO MAX(0.1, MIN(1.0, 0.2 * (transferNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
			PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
		}.
	}.
	LOCK THROTTLE TO 0.0.
	UNLOCK THROTTLE.
	
	UNLOCK STEERING.
	UNLOCK tOrientation.
}.

FUNCTION executeTunePeriAndReturn {
	PARAMETER tBody.
	PRINT "Waiting until final transition..".
	LOCAL targetHeight IS 0.
	LOCAL allDone IS FALSE.
	LOCAL lastTransition IS "NONE".
	LOCAL currentWarp IS 1.
	LOCAL lastWarp IS currentWarp.
	LOCAL checkEvery IS 0.1.
	// we probably just fired our engines for the transition,
	// give our acceleration a moment before warping
	WAIT 1.
	LOCAL speedingUp IS TRUE.
	
	UNTIL FALSE { // only quit when we BREAK - when entering atmosphere
		LOCAL projectedChange IS checkEvery * SHIP:VERTICALSPEED * getWarpSpeedModifier(currentWarp).
		LOCAL projectedAlt IS SHIP:ALTITUDE + projectedChange.
		IF SHIP:ORBIT:TRANSITION = "ENCOUNTER" {
			LOCAL estTime IS checkEvery * getWarpSpeedModifier(currentWarp).
			LOCAL pEstMoon IS (tBody:POSITION + estTime*tBody:VELOCITY:ORBIT).
			LOCAL pEstShip IS (SHIP:POSITION + estTime*SHIP:VELOCITY:ORBIT).
			// heading UP to the target body/moon
			IF (pEstMoon - pEstShip):MAG  < tBody:SOIRADIUS {
				IF currentWarp > 4 {
					SET currentWarp TO currentWarp - 1.
					PRINT "Slowing down time to warp: " + currentWarp.
					SET speedingUp TO FALSE.
				}.
			} ELSE IF speedingUp AND currentWarp < 6 {
				SET currentWarp TO currentWarp + 1.
				PRINT "Speeding up time to warp: " + currentWarp.
			}.
		} ELSE IF SHIP:ORBIT:TRANSITION = "FINAL" AND SHIP:ORBIT:HASNEXTPATCH = FALSE {
			// heading to Kerbin
			IF SHIP:VERTICALSPEED < 0 AND SHIP:MAXTHRUST > 0 {
				PRINT "We've left " + tBody:NAME + ", adjusting heading home.".
				SET WARP TO 0.
				// we are heading home and we have fuel
				// let's correct our periapsis and dump our engine
				IF SHIP:PERIAPSIS > 30000 {
					LOCK tOrientation TO SHIP:RETROGRADE.
				} ELSE {
					LOCK tOrientation TO SHIP:PROGRADE.
				}.
				LOCK STEERING TO smoothRotate(tOrientation).
				LOCK DifferenceMag TO VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
				PRINT "Pointing to adjust peri..".
				UNTIL DifferenceMag < 0.5 {
					WAIT 1.
				}.
				UNLOCK DifferenceMag.
				// TODO: calculate a Hoehmann speed for the desired periapsis
				LOCK altDiff TO ABS(SHIP:PERIAPSIS - 30000)/1000000.
				LOCK THROTTLE TO MAX(0.05, MIN(1.0, altDiff)).
				PRINT "Firing to adjust peri..".
				UNTIL altDiff < 0.0175 { // 35km is 0.035 roughly, so half that difference? 27-33km
					WAIT 0.01.
					IF SHIP:MAXTHRUST = 0 {
						PRINT "Current stage is out of fuel!".
						PRINT "Total fuel remaining: " + (SHIP:LIQUIDFUEL+SHIP:SOLIDFUEL).
						LOCK THROTTLE TO 0.0.
						WAIT 0.5.
						STAGE.
						IF SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 { 
							PRINT "We're out of fuel! We didn't make it!".
							BREAK.
						}
						WAIT 1.5.
						LOCK THROTTLE TO MAX(0.05, MIN(1.0, altDiff)).
						PRINT "Next stage fuel: " + (STAGE:LIQUIDFUEL + STAGE:SOLIDFUEL).
					}.
				}.
				LOCK THROTTLE TO 0.0.
				WAIT 1. // we don't want the lower stages to ram us like they did in the simulation...
				UNLOCK THROTTLE.
				UNLOCK STEERING.
				UNLOCK altDiff.
				
				PRINT "Done adjusting.".
				UNTIL SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 {
					PRINT "Dumping stages. We're going home!".
					STAGE.
					WAIT 2.
				}.
			}.
			// this is our quit condition for entering atmosphere
			IF SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT { BREAK. }.
			
			IF projectedAlt < SHIP:BODY:ATM:HEIGHT AND currentWarp > 4 {
				SET currentWarp TO currentWarp - 1.
			} ELSE IF speedingUp AND projectedAlt > SHIP:BODY:ATM:HEIGHT AND currentWarp < 6 {
				SET currentWarp TO currentWarp + 1.
			}.
		} ELSE IF SHIP:ORBIT:TRANSITION = "ESCAPE" {
			// at the moon, leaving
			IF currentWarp > 0 {
				PRINT "We're at the " + tBody:NAME + "!".
				PRINT "Science! Get your science!".
				SET currentWarp TO 0.
				// reset allowing speeding up so we can return quickly
				SET speedingUp TO TRUE.
			}
		} ELSE {
			PRINT "Unknown state!".
			PRINT "Transition: " + SHIP:ORBIT:TRANSITION.
			PRINT "VertVelocity: " + SHIP:VERTICALSPEED.
			PRINT "Projected change: " + projectedChange.
			PRINT "Projected alt: " + projectedAlt.
			PRINT "Current warp: " + currentWarp.
		}.
		IF lastWarp <> currentWarp {
			SET lastWarp TO currentWarp.
			IF currentWarp > 0 { 
				SET WARPMODE TO "RAILS".
				SET WARP TO currentWarp.
			}.
		}.
		WAIT checkEvery.
	}.
	
	PRINT "Now entering atmosphere.".
	PRINT "Altitude is: " + SHIP:ALTITUDE.
	PRINT "VertVelocity is: " + SHIP:VERTICALSPEED.
	LOCK tOrientation TO SHIP:RETROGRADE.
	LOCK STEERING TO smoothRotate(tOrientation).
	UNTIL ALT:RADAR < 2500 {
		WAIT 0.1.
	}.
	PRINT "Deploying parachutes at altitude: " + SHIP:ALTITUDE.
	PRINT "Because radar says we're at: " + ALT:RADAR.
	// and now we drift to the surface
	STAGE.
	UNLOCK STEERING.
}.

//SET transferNode IS NODE(TIME:SECONDS + 600, 0, 0, 800).
//ADD transferNode.

FUNCTION readOutManeuverNode {
	LOCAL fOrbit IS ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
	LOCAL fPeri IS fOrbit:PERIAPSIS.
	PRINT "Future periapsis will be: " + fPeri.
	PRINT "DeltaV needed is: " + transferNode:PROGRADE.
	PRINT "Maneuver phase angle is: " + calcManeuverPhaseAngle(BODY("Mun")).
	LOCAL tETA IS transferNode:ETA.
	IF tETA > (transferNode:ORBIT:PERIOD / 2) {
		SET tETA TO tETA - transferNode:ORBIT:PERIOD.
	}.
	PRINT "ETA is:" + tETA.
}.

FUNCTION smartRocket {
	PARAMETER bodyName.
	LOCAL tBody IS BODY(bodyName).

	createFacingArrows().
	createAngleArrows().
	// do we launch?
	IF SHIP:ALTITUDE < 200
	   AND ABS(SHIP:VELOCITY:SURFACE:MAG) < 1 
		 AND ABS(SHIP:VERTICALSPEED) < 1
	{
		executeLaunchMyVessel().
	}.
	IF SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT
		 AND SHIP:APOAPSIS < TargetAltitude
		 AND SHIP:VERTICALSPEED > 98
	{
		executeGravityTurn().
		executeCoastToApo().
	}.
	IF SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT
	{
		executeCircularize().
	}.
	clearFacingArrows().
	clearAngleArrows().
//	IF SHIP:APOAPSIS > SHIP:BODY:ATM:HEIGHT
//	   AND SHIP:PERIAPSIS > SHIP:BODY:ATM:HEIGHT
//	{
//		searchBurnToMoon(bodyName).
//		//executeBurnToMoon("Mun", 92, 2).
//	}.
//	IF SHIP:APOAPSIS * 1.5 > tBody:ALTITUDE
//	{
//		executeTunePeriAndReturn(tBody).
//	}.
}.

smartRocket("Mun").

PRINT "Press H TO get updated readout.".
SET keyPressed TO FALSE.
WHEN SHIP:CONTROL:PILOTFORE > 0.0 AND keyPressed = FALSE THEN {
	PRINT "-- You pressed H! Yay!".
	PRINT " ".
	PRINT " ".
	LOCAL tBody IS BODY("Mun").
	LOCAL pAngle IS calcBodyPhaseAngle(tBody).
	readOutManeuverNode().
	SET keyPressed TO TRUE.
	PRESERVE.
}.
WHEN keyPressed AND SHIP:CONTROL:PILOTFORE = 0.0 THEN {
	SET keyPressed TO FALSE.
	PRESERVE.
}.
WAIT UNTIL SHIP:CONTROL:PILOTSTARBOARD > 0.0.
//until FALSE {
//	clearscreen.
//	foo().
//	wait 5.
//}.
