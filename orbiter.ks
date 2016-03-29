// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

wait until SHIP:UNPACKED.
set shipSizeScalar to 30.0.
set MinTurnSpeed to 100.
set MinTurnAltitude to   1000.
set HardTurnAltitude to 30000.
set TargetAltitude  to 100000.
set transferNode to NODE(TIME:SECONDS, 0, 0, 5).

run once helpers_import.

set tThrottle to 0.0.
function inflightStage {
	print "Current stage is out of fuel!".
	print "Total fuel remaining: " + (SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL).
	lock THROTTLE to 0.0.
	wait 0.5.
	STAGE.
	local nextFuel is SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL.
	if nextFuel = 0 { return false. }.
	wait 1.5.
	lock THROTTLE to tThrottle.
	print "Next stage fuel: " + nextFuel.
	return true.
}.

function executeLaunchMyVessel {
	print "=================================".
	print "Launching straight up, initially.".
	print "=================================".
	if SHIP:MAXTHRUST = 0.0 { STAGE. }.
	// G M1 M2 / (distance)^2
	lock neededUpwardThrust to CONSTANT:G * BODY:MASS * SHIP:MASS / (BODY:RADIUS + SHIP:ALTITUDE)^2.
	lock twr to MAX(0.01, SHIP:MAXTHRUST) / neededUpwardThrust.
	print "TWR estimated to be: " + twr.
	lock tThrottle to MIN(1.0, MAX(0.01, 1.8/twr)).
	lock THROTTLE to tThrottle.
	print "Initial throttle to: " + tThrottle.
	lock tOrientation to HEADING(90, 90).
	lock STEERING to smoothRotate(tOrientation).

	until SHIP:MAXTHRUST = 0.0 or SHIP:ALTITUDE > MinTurnAltitude {
		updateAngleArrows().
		wait 0.05.
		if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
	}.
	unlock STEERING.
	unlock THROTTLE.
	unlock twr.
	unlock neededUpwardThrust.
}.

function executeGravityTurn {
	//lock fancyTheta to 90 - 90*(SHIP:ALTITUDE/60000)^(2/5).
	set limiterM to (45-85)/(HardTurnAltitude-MinTurnAltitude).
	set limiterB to 85 - MinTurnAltitude *limiterM.
	lock limiterY to MAX(45, SHIP:ALTITUDE * limiterM + limiterB).
	// this was my orientation vector until I blatantly stole Dunbaratu's below
	set targetArrowOLD to VECDRAW(V(0,0,0), shipSizeScalar * HEADING(90, limiterY):FOREVECTOR, RGB(1,0,0), "", 1.0, TRUE, 0.1).
	print "==================================".
	print "Now compensating for gravity turn.".
	print "==================================".
	
	// ***************************************************************************************
	// written by Reddit user /u/Dunbaratu -- https://www.twitch.tv/dunbaratu
	lock tOrientation to HEADING(90, MAX(0, 90 - 90*(SHIP:ALTITUDE/60000)^(2/5))).
	// note I find this too aggressive for heavy craft, change the 2/5 to 4/5 etc in that case
	// ***************************************************************************************
	lock STEERING to smoothRotate(tOrientation).
	//lock tOrientation to R(SHIP:SRFPROGRADE:PITCH+2.5, 0, 0).
	print "Orienting for 5 degree initial turn.".

	lock tThrottle to 1.0.
	lock THROTTLE to tThrottle.
	until SHIP:ORBIT:APOAPSIS > TargetAltitude or SHIP:MAXTHRUST = 0 {
		set targetArrowOLD:VEC to shipSizeScalar * HEADING(90, limiterY):FOREVECTOR.
		updateAngleArrows().
		wait 0.1.
		if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
	}.
	UNSET targetArrowOLD.
	unlock limiterY.
	lock THROTTLE to 0.0.
	unlock STEERING.
}.
	
function executeCoastToApo {
	if SHIP:ALTITUDE > SHIP:ORBIT:BODY:ATM:HEIGHT { RETURN. }.
	
	print "=====================".
	print "Coasting to APOAPSIS.".
	print "=====================".
	lock THROTTLE to MIN(0.1, MAX(0, (TargetAltitude - SHIP:APOAPSIS)/10000)).
	lock tOrientation to SHIP:PROGRADE.
	lock DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	lock STEERING to smoothRotate(tOrientation).
	print "Aligning with prograde as we coast..".
	until DifferenceMag < 0.5 {
		updateAngleArrows().
		wait 0.1.
	}.
	set WARPMODE to "PHYSICS".
	set WARP to 3.
	print "Physics warping through the atmosphere..".
	until SHIP:ALTITUDE > SHIP:ORBIT:BODY:ATM:HEIGHT {
		updateAngleArrows().
		wait 0.1.
	}.
	print "Exit atmosphere at ALTITUDE: " + SHIP:ALTITUDE.
	print "Apoapsis is: " + SHIP:APOAPSIS.
	set WARP to 0.
	wait 0.5.
	deployPanels().
	deployAntenna().	
	unlock STEERING.
	lock THROTTLE to 0.0.
	unlock THROTTLE.
	unlock DifferenceMag.
}.

function executeCircularize {
	// F = m*v^2 / r
	// F = ma, Kerbin is 9.81m/s^2
	// F = G*m1*m2/(r1+r2)^2
	// 100km orbit should be 7.2073 m/s^2
	// 2246.1 m/s
	// lock OrbitalSpeed to SHIP:MASS * (SHIP:GROUNDSPEED * SHIP:GROUNDSPEED) / (BODY:RADIUS + SHIP:ALTITUDE).
	//set myNode to NODE( TIME:SECONDS + ETA:APOAPSIS, 0, 0, 2246.1 - SHIP:GROUNDSPEED ).
	//ADD myNode.
	//lock timeToBurn to myNode:PROGRADE / MAX(1.0, (SHIP:MAXTHRUST / SHIP:MASS)).
	//print "Calculated time to burn is: " + timeToBurn.

	//lock Fg to CONSTANT:G * BODY:MASS * SHIP:MASS / (SHIP:ALTITUDE+BODY:RADIUS)^2.
	//print "Fg is: " + Fg.
	//lock sinTheta to MIN(1.0, MAX(0.0, Fg / (MAX(1, SHIP:MAXTHRUST)))).
	//print "sinTheta is: " + sinTheta.
	//lock VertAdjust to MAX(-Fg, MIN(SHIP:VERTICALSPEED, Fg)) / Fg.
	//print "vertAdjust is: " + VertAdjust.
	//lock theta to (ARCSIN(sinTheta) * (0.5 - VertAdjust)).
	//print "theta is: " + theta.

	print "=====================".
	print "Increasing PERIAPSIS.".
	print "=====================".
	local circularBurn is calcCircularizeDV(SHIP:ORBIT:APOAPSIS).
	// needed deltaV divided by our acceleration gives us a time
	print "Need to burn m/s: " + circularBurn.
	local burnTime is circularBurn / (SHIP:MAXTHRUST / SHIP:MASS).
	print "Estimated burn time is: " + burnTime.
	local circularizeNode to NODE( TIME:SECONDS + etaToApoWithMinus(), 0, 0, circularBurn ).
	ADD circularizeNode.
	set WARP to 0.
	lock tThrottle to 0.0.
	lock THROTTLE to tThrottle.
	lock tOrientation to circularizeNode:BURNVECTOR:DIRECTION.
	lock STEERING to smoothRotate(tOrientation).
	lock DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	until DifferenceMag < 0.5 {
		updateAngleArrows().
		wait 0.1.
	}.
	unlock DifferenceMag.
	
	warpToRelTime(etaToApoWithMinus() - (burnTime/2 + 5)).
	print "Using wait until loop.." + TIME:SECONDS.
	until etaToApoWithMinus() < burnTime/2 + 1 {
		updateAngleArrows().
		wait 0.1.
	}.
	print "Firing engines to circularize.".
	//lock THROTTLE to MAX(0.1, MIN(1.0, 3 * SHIP:ORBIT:ECCENTRICITY)).
	// 3 seconds before we're done, slow it down to be more accurate
	lock tThrottle to MAX(0.05, MIN(1.0, 0.2 * (circularizeNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	lock THROTTLE to tThrottle.
	until (SHIP:APOAPSIS - SHIP:PERIAPSIS) < 1000 or SHIP:ORBIT:SEMIMAJORAXIS > (BODY:RADIUS + TargetAltitude) or SHIP:MAXTHRUST = 0 {
		updateAngleArrows().
		wait 0.01.
		if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
	}.
	lock THROTTLE to 0.0.
	unlock THROTTLE.
	unlock tThrottle.
	unlock STEERING.
	REMOVE circularizeNode.
}.

function executeSearchAndBurnToMoon {
  parameter targetName.
	local tBody is BODY(targetName).
	set TARGET to tBody.
	print "----------------------------------".
	print "Gathering information about: " + tBody:NAME.
	print "----------------------------------".
	local pAngle is calcBodyPhaseAngle(tBody).
	local dv is calcHoemannDVtoOrbit(tBody:ORBIT).
  print "First stab at transfer.".
	print "dv to target orbit is: " + dv.
	local timeToBurn is dv / MAX(1, SHIP:MAXTHRUST / SHIP:MASS).
	local timePerDegree is SHIP:ORBIT:PERIOD / 360.
	print "Generating rendezvous.".
	local tBurn is TIME:SECONDS + timeToBurn / 2.
	set transferNode to NODE(tBurn - TIME:SECONDS, 0, 0, dv).
	ADD transferNode.
	local timeToTransfer is (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	print "Estimated trip time: " + timeToTransfer.
	// BUG: this is causing a "Must attach node first" error and I don't know why
	//      probably something to do with locked variables and scope?
	//local pCurrent is tBody:ORBIT:POSITION - SHIP:BODY:POSITION.
	//local pFuture is POSITIONAT(tBody, TIME:SECONDS + timeToTransfer) - SHIP:BODY:POSITION.
	//local estimateAltitude is (pFuture:MAG / pCurrent:MAG) * tBody:ALTITUDE.
	//if tBody:ALTITUDE <> estimateAltitude {
	//	// TODO: target is eccentric, we may not be compensating properly
	//	print "Ratio between orbit altitudes:".
	//	print "tBody:ALTITUDE   = " + tBody:ALTITUDE.
	//	print "estimateAltitude = " + estimateAltitude.
	//	print "future=" + pFuture:MAG + " -- current=" + pCurrent:MAG.
	//	print "Ratio = " + (pFuture:MAG / pCurrent:MAG).
	//	set dv to calcHoemannDVtoAlt(estimateAltitude).
	//	print "New dv adjusted is: " + dv.
	//}.
	// step forward until we reach an encounter with the target moon
	// TODO: inclination may prevent this entirely
	print "Searching for first encounter by angle..".
	set mapview to true.
	until transferNode:ORBIT:TRANSITION = "ENCOUNTER" or tBurn - TIME:SECONDS > SHIP:ORBIT:PERIOD {
		set tBurn to tBurn + timePerDegree.
		set transferNode:ETA to tBurn - TIME:SECONDS.
		wait 0.05.
	}.
	local fOrbit is ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
	local lowestETA is tBurn.
	local lowestDV is dv * 1.02.
	local dvOffset is 0.
	local lastTransitionCount is 1.
	local transitionCount is 0.
	
	// fine tune to cheapest RETURN TRAJECTORY
	print "Fine tuning search. Watch on your map view!".
	until lastTransitionCount = 0 {
		if dvOffset < -0.02 * lowestDV {
			set dvOffset to 0.
			set tBurn to tBurn + timePerDegree.
			set transferNode:ETA to tBurn - TIME:SECONDS.
			set lastTransitionCount to transitionCount.
			set transitionCount to 0.
		}
		set dvOffset to dvOffset - 0.1.
		set transferNode:PROGRADE to lowestDV + dvOffset.
		if transferNode:ORBIT:TRANSITION = "ENCOUNTER" {
			set transitionCount to transitionCount + 1.
			set fOrbit to ORBITAT(SHIP, TIME:SECONDS + transferNode:ORBIT:PERIOD).
			if fOrbit:PERIAPSIS > 25000 and fOrbit:PERIAPSIS < 35000 { 
				set dBestSoFar to transferNode:BURNVECTOR:DIRECTION.
				lock tOrientation to dBestSoFar.
				lock STEERING to smoothRotate(tOrientation).
				set lowestETA to tBurn.
				set lowestDV to lowestDV + dvOffset.
				print "New min found: " + lowestDV.
			}.
		}.
		wait 0.001.
	}.
	set transferNode:ETA to lowestETA - TIME:SECONDS.
	set transferNode:PROGRADE to lowestDV.
	print "Lowest dv required to return found is: " + lowestDV.
	set pAngle to calcFuturePhaseAngle(tBody, tBurn).
	print "Identified return encounter at phase angle: " + pAngle.
	
	// execute the return trajectory node
	lock tOrientation to transferNode:BURNVECTOR:DIRECTION.
	lock STEERING to smoothRotate(tOrientation).
	lock DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
	until DifferenceMag < 0.5 {
		wait 0.1.
	}.
	set timeToBurn to lowestDV / MAX(1, SHIP:MAXTHRUST / SHIP:MASS).
	print "Estimated time to burn is: " + timeToBurn.
	if transferNode:ETA > 50 + (timeToBurn/2) {
		print "Time warping to node: " + transferNode:ETA.
		set WARPMODE to "RAILS".
		local tWarpSpeed is 3.
		set WARP to tWarpSpeed.
		until transferNode:ETA < 15 + (timeToBurn/2) {
			if tWarpSpeed = 3 and transferNode:ETA < 55 + (timeToBurn/2) {
				set tWarpSpeed to 2.
				set WARP to tWarpSpeed.
			}.
			if tWarpSpeed = 2 and transferNode:ETA < 25 + (timeToBurn/2) {
				set tWarpSpeed to 1.
				set WARP to tWarpSpeed.
			}.
			wait 0.1.
		}
		set WARP to 0.
	}.
	print "Done warping. ETA: " + transferNode:ETA.
	until transferNode:ETA < timeToBurn/2 + 1 {
		wait 0.1.
	}.
	print "To the " + targetName + "!".
	local haveRemovedNode to false.
	set tThrottle to 1.0.
	lock THROTTLE to tThrottle.
	set fOrbit to ORBITAT(SHIP, TIME:SECONDS + SHIP:ORBIT:PERIOD).
	local tVel is SHIP:VELOCITY:ORBIT:MAG + transferNode:DELTAV:MAG.
	until (haveRemovedNode and fOrbit:PERIAPSIS > 0 and fOrbit:PERIAPSIS < SHIP:BODY:ATM:HEIGHT) or SHIP:MAXTHRUST = 0.0 {
		wait 0.01.
		if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
		// failsafe if we missed the node
		if haveRemovedNode and SHIP:VELOCITY:ORBIT:MAG > tVel { 
			print "We missed the node, immediately aborting!".
			BREAK. 
		}.
		if haveRemovedNode = false and transferNode:DELTAV:MAG < 2 * (SHIP:MAXTHRUST / SHIP:MASS) {
			print "Within 2 seconds of thrust. Slowing down...".
			set tVel to SHIP:VELOCITY:ORBIT:MAG + transferNode:DELTAV:MAG.
			lock tThrottle to MAX(0.05, MIN(1.0, 0.5 * ((tVel - SHIP:VELOCITY:ORBIT:MAG) / (MAX(1, SHIP:MAXTHRUST) / SHIP:MASS)) ) ).
			set dBestSoFar to transferNode:BURNVECTOR:DIRECTION.
			lock tOrientation to dBestSoFar.
			lock STEERING to smoothRotate(tOrientation).
			REMOVE transferNode.
			set haveRemovedNode to true.
		}.
		set fOrbit to ORBITAT(SHIP, TIME:SECONDS + SHIP:ORBIT:PERIOD).
	}.
	lock THROTTLE to 0.0.
	unlock tThrottle.
	unlock THROTTLE.
	
	unlock STEERING.
	unlock tOrientation.
}.

function executeBurnToMoon {
  parameter targetName.
  parameter targetPhaseAngle.
  parameter additionalDV.
	local tBody is BODY(targetName).
	set TARGET to tBody.
	print "----------------------------------".
	print "Gathering information about: " + tBody:NAME.
	print "----------------------------------".
	local pAngle is calcBodyPhaseAngle(tBody).
	if pAngle < targetPhaseAngle - 1 or pAngle > targetPhaseAngle + 1 {
		// wait -- cannot warp under acceleration, we just cut throttle..
		wait 0.5.
		print "Warping until phase angle is 111~.".
		set WARPMODE to "RAILS".
		set WARP to 3.
		local timePerDegree is 1.
		local lastAngle is pAngle.
		local tLastPrint is TIME:SECONDS.
		until pAngle > targetPhaseAngle - 1 and pAngle < targetPhaseAngle + 1 {
			if tLastPrint + 50 < TIME:SECONDS {
				print "pAngle is now: " + pAngle + " -- waiting: " + timePerDegree.
				set tLastPrint to TIME:SECONDS.
			}.
			wait timePerDegree / 2.
			set lastAngle to pAngle.
			set pAngle to calcBodyPhaseAngle(tBody).
			set timePerDegree to MIN(50, MAX(0.1, 0.5 * timePerDegree / ABS(pAngle - lastAngle))).
		}.
	}.
	set WARP to 0.
	
  print "First stab at transfer.".
	local dv is calcHoemannDVtoOrbit(tBody:ORBIT) + additionalDV.
	local timeToBurn is dv / MAX(1.0, SHIP:MAXTHRUST / SHIP:MASS).
	set transferNode to NODE(TIME:SECONDS + timeToBurn/2, 0, 0, dv).
	ADD transferNode.

	local timeToTransfer is (timeToBurn + transferNode:ORBIT:PERIOD / 2).
	print "Estimated trip time: " + timeToTransfer.
	local aPhase is calcFuturePhaseAngle(tBody, TIME:SECONDS + timeToTransfer).
	print "Estimated future phase angle is: " + aPhase.

	lock STEERING to smoothRotate(transferNode:BURNVECTOR:DIRECTION).
	lock tThrottle to MAX(0.1, MIN(1.0, 0.2 * (transferNode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS)) ) ).
	lock THROTTLE to tThrottle.
	until transferNode:DELTAV:MAG < 1.0 or SHIP:MAXTHRUST = 0.0 {
		wait 0.1.
		if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
	}.
	lock THROTTLE to 0.0.
	unlock THROTTLE.
	
	unlock STEERING.
	unlock tOrientation.
}.

function executeTunePeriAndReturn {
	parameter tBody.
	print "Waiting until final transition..".
	local targetHeight is 0.
	local allDone is false.
	local lastTransition is "NONE".
	local currentWarp is 1.
	local lastWarp is currentWarp.
	local checkEvery is 0.1.
	// we probably just fired our engines for the transition,
	// give our acceleration a moment before warping
	wait 1.
	local speedingUp is TRUE.
	
	until false { // only quit when we BREAK - when entering atmosphere
		local projectedChange is checkEvery * SHIP:VERTICALSPEED * getWarpSpeedModifier(currentWarp).
		local projectedAlt is SHIP:ALTITUDE + projectedChange.
		if SHIP:ORBIT:TRANSITION = "ENCOUNTER" {
			local estTime is checkEvery * getWarpSpeedModifier(currentWarp).
			local pEstMoon is (tBody:POSITION + estTime*tBody:VELOCITY:ORBIT).
			local pEstShip is (SHIP:POSITION + estTime*SHIP:VELOCITY:ORBIT).
			// heading UP to the target body/moon
			if (pEstMoon - pEstShip):MAG  < tBody:SOIRADIUS {
				if currentWarp > 4 {
					set currentWarp to currentWarp - 1.
					print "Slowing down time to warp: " + currentWarp.
					set speedingUp to false.
				}.
			} else if speedingUp and currentWarp < 5 and shipMaxWarpAltitude() > currentWarp {
				set currentWarp to currentWarp + 1.
				print "Speeding up time to warp: " + currentWarp.
			}.
		} else if SHIP:ORBIT:TRANSITION = "FINAL" and SHIP:ORBIT:HASNEXTPATCH = false {
			// heading to Kerbin
			if SHIP:VERTICALSPEED < 0 and SHIP:MAXTHRUST > 0 {
				print "We've left " + tBody:NAME + ", adjusting heading home.".
				set WARP to 0.
				// we are heading home and we have fuel
				// let's correct our periapsis and dump our engine
				if SHIP:PERIAPSIS > 30000 {
					lock tOrientation to SHIP:RETROGRADE.
				} else {
					lock tOrientation to SHIP:PROGRADE.
				}.
				lock STEERING to smoothRotate(tOrientation).
				lock DifferenceMag to VECTORANGLE(tOrientation:FOREVECTOR, SHIP:FACING:FOREVECTOR).
				print "Pointing to adjust peri..".
				until DifferenceMag < 0.5 {
					wait 1.
				}.
				unlock DifferenceMag.
				// TODO: calculate a Hoehmann speed for the desired periapsis
				lock altDiff to ABS(SHIP:PERIAPSIS - 27500)/1000000.
				lock tThrottle to MAX(0.05, MIN(1.0, altDiff)).
				lock THROTTLE to tThrottle.
				print "Firing to adjust peri..".
				until altDiff < 0.0175 { // 30km is 0.035 roughly, so half that difference? 25-30km
					wait 0.01.
					if SHIP:MAXTHRUST = 0 and inflightStage() = false { BREAK. }
				}.
				lock THROTTLE to 0.0.
				wait 1. // we don't want the lower stages to ram us like they did in the simulation...
				unlock THROTTLE.
				unlock STEERING.
				unlock altDiff.
				
				print "Done adjusting.".
				until SHIP:LIQUIDFUEL + SHIP:SOLIDFUEL = 0 {
					print "Dumping stages. We're going home!".
					STAGE.
					wait 2.
				}.
			}.
			// this is our quit condition for entering atmosphere
			if SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT { BREAK. }.
			
			if projectedAlt < SHIP:BODY:ATM:HEIGHT and currentWarp > 4 {
				set currentWarp to currentWarp - 1.
			} else if speedingUp and projectedAlt > SHIP:BODY:ATM:HEIGHT and currentWarp < 5 {
				set currentWarp to currentWarp + 1.
			}.
		} else if SHIP:ORBIT:TRANSITION = "ESCAPE" {
			// at the moon, leaving
			if currentWarp > 0 {
				print "We're at the " + tBody:NAME + "!".
				print "Science! Get your science!".
				set WARP to 0.
				deployScienceExperiments().
				wait 5.
				set WARP to 5.
				set currentWarp to 0.
				// reset allowing speeding up so we can return quickly
				set speedingUp to TRUE.
			}
		} else {
			print "Unknown state!".
			print "Transition: " + SHIP:ORBIT:TRANSITION.
			print "VertVelocity: " + SHIP:VERTICALSPEED.
			print "Projected change: " + projectedChange.
			print "Projected alt: " + projectedAlt.
			print "Current warp: " + currentWarp.
		}.
		if lastWarp <> currentWarp {
			set lastWarp to currentWarp.
			if currentWarp > 0 { 
				set WARPMODE to "RAILS".
				set WARP to currentWarp.
			}.
		}.
		wait checkEvery.
	}.
	
	print "Now entering atmosphere.".
	print "Altitude is: " + SHIP:ALTITUDE.
	print "VertVelocity is: " + SHIP:VERTICALSPEED.
	lock tOrientation to SHIP:SRFRETROGRADE.
	lock STEERING to smoothRotate(tOrientation).
	until ALT:RADAR < 3000 {
		wait 0.1.
	}.
	if deployDrogueChutes() > 0 {
		print "Deploying drogue chutes at altitude: " + SHIP:ALTITUDE.
		print "Because radar says we're at: " + ALT:RADAR.
	}.
	until ALT:RADAR < 1500 {
		wait 0.1.
	}.
	deployParachutes().
	print "Deploying parachutes at altitude: " + SHIP:ALTITUDE.
	print "Because radar says we're at: " + ALT:RADAR.
	// and now we drift to the surface
	unlock STEERING.
}.

//set transferNode is NODE(TIME:SECONDS + 600, 0, 0, 800).
//ADD transferNode.

function readOutManeuverNode {
	if SHIP:HASNODE {
		local tNode is SHIP:NEXTNODE.
		local fOrbit is ORBITAT(SHIP, TIME:SECONDS + tNode:ORBIT:PERIOD).
		local fPeri is fOrbit:PERIAPSIS.
		print "Future periapsis will be: " + fPeri.
		print "DeltaV needed is: " + tNode:PROGRADE.
		print "Maneuver phase angle is: " + calcManeuverPhaseAngle(BODY("Mun")).
		local tETA is tNode:ETA.
		if tETA > (tNode:ORBIT:PERIOD / 2) {
			set tETA to tETA - tNode:ORBIT:PERIOD.
		}.
		print "ETA is:" + tETA.
	}.
}.

function smartRocket {
	parameter bodyName.
	local tBody is BODY(bodyName).

	createFacingArrows().
	createAngleArrows().
	// do we launch?
	if SHIP:ALTITUDE < 200
	   and ABS(SHIP:VELOCITY:SURFACE:MAG) < 1 
		 and ABS(SHIP:VERTICALSPEED) < 1
	{
		executeLaunchMyVessel().
	}.
	if SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT
		 and SHIP:APOAPSIS < TargetAltitude
		 and SHIP:VERTICALSPEED > 98
	{
		executeGravityTurn().
		executeCoastToApo().
	}.
	if SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT
	{
		executeCircularize().
	}.
	clearFacingArrows().
	clearAngleArrows().
	if SHIP:APOAPSIS > SHIP:BODY:ATM:HEIGHT
	   and SHIP:PERIAPSIS > SHIP:BODY:ATM:HEIGHT
	{
		executeSearchAndBurnToMoon(bodyName).
	}.
	// if ship's (boosted) apo is greater than the Mun's orbital distance
	// then assume we're out there, let's come home
	if SHIP:APOAPSIS * 1.5 > tBody:ALTITUDE
	{
		executeTunePeriAndReturn(tBody).
	}.
}.

smartRocket("Mun").

print "Press H to get updated readout.".
set keyPressed to false.
when SHIP:CONTROL:PILOTFORE > 0.0 and keyPressed = false then {
	print "-- You pressed H! Yay!".
	print " ".
	print " ".
	local tBody is BODY("Mun").
	local pAngle is calcBodyPhaseAngle(tBody).
	readOutManeuverNode().
	set keyPressed to TRUE.
	preserve.
}.
when keyPressed and SHIP:CONTROL:PILOTFORE = 0.0 then {
	set keyPressed to false.
	preserve.
}.
wait until SHIP:CONTROL:PILOTSTARBOARD > 0.0.
//until false {
//	clearscreen.
//	foo().
//	wait 5.
//}.
