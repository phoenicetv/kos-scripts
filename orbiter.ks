// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

wait until SHIP:UNPACKED.
set shipSizeScalar to 10.0.
set MinTurnSpeed to 100.
set MinTurnAltitude to 1000.
set HardTurnAltitude to 30000.
set TargetAltitude to 80000.
set transferNode to NODE(TIME:SECONDS, 0, 0, 5).

run once helpers_import.

function shouldStageEngines {
	if SHIP:MAXTHRUST = 0 { return true. }.
	list ENGINES IN myEngines.
	FOR e in myEngines {
		if e:FLAMEOUT { return true. }.
	}.
	return false.
}.
function shouldJettisonEngines {
	if SHIP:MAXTHRUST > 0 { return true. }.
	list ENGINES IN myEngines.
	if myEngines:LENGTH > 0 { return true. }.
	return false.
}.
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
		if shouldStageEngines() and inflightStage() = false { BREAK. }
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
		if shouldStageEngines() and inflightStage() = false { BREAK. }
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
	lock tThrottle to MIN(0.1, MAX(0, (TargetAltitude - SHIP:APOAPSIS)/10000)). 
	lock THROTTLE to tThrottle.
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
		//print "Current throttle: " + tThrottle.
		//print "Alt diff: " + ((TargetAltitude - SHIP:APOAPSIS)/10000).
	}.
	print "Exit atmosphere at ALTITUDE: " + SHIP:ALTITUDE.
	print "Apoapsis is: " + SHIP:APOAPSIS.
	set WARP to 0.
	wait 0.1.
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
		wait 0.05.
		if shouldStageEngines() and inflightStage() = false { BREAK. }
	}.
	lock THROTTLE to 0.0.
	unlock THROTTLE.
	unlock tThrottle.
	unlock STEERING.
	REMOVE circularizeNode.
}.

function executeDescentSafeguard {
	print "Awaiting descent...".
	until SHIP:VERTICALSPEED < 0 and SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT
	{
		wait 0.1.
	}.
	until shouldJettisonEngines() = false {
		if inflightStage() = false { BREAK. }
		wait 0.5.
	}.
	print "Done jettisoning stages.".

	lock tOrientation to SHIP:SRFRETROGRADE.
	lock STEERING to tOrientation.
	until ALT:RADAR < 8000 
	      and (SHIP:VERTICALSPEED > -700 and SHIP:VERTICALSPEED < 0) {
		updateAngleArrows().
		wait 0.1.
	}.
	unlock STEERING.
	local totalDrogues is deployDrogueChutes().
	print "Deploying Drogue chutes.".
	until (ALT:RADAR < 1000 and totalDrogues > 0) 
	      or (ALT:RADAR < 4000 and totalDrogues = 0) {
		updateAngleArrows().
		wait 0.1.
	}.
	deployParachutes().
	print "Deploying parachutes.".
}.

function smartRocket {
	createFacingArrows().
	createAngleArrows().
	// do we launch?
	if ALT:RADAR < 200
	   and ABS(SHIP:VELOCITY:SURFACE:MAG) < 1 
		 and ABS(SHIP:VERTICALSPEED) < 1
	{
		executeLaunchMyVessel().
	}.
	// wait until APO
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
	//deployScienceExperiments().
	executeDescentSafeguard().
}.

smartRocket().
