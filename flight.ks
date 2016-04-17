// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

wait until SHIP:UNPACKED.
set shipSizeScalar   to     10.0.
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
	//lock tOrientation to HEADING(90, MIN(90, MAX(45, 90-(SHIP:ALTITUDE / 2000)*10))).
	lock tOrientation to HEADING(90, 90).
	lock STEERING to smoothRotate(tOrientation).

	until SHIP:MAXTHRUST = 0.0 {
		updateAngleArrows().
		wait 0.05.
		if shouldStageEngines() and inflightStage() = false { BREAK. }
	}.
	unlock STEERING.
	unlock THROTTLE.
	unlock twr.
	unlock neededUpwardThrust.
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
	lock tOrientation to SHIP:SRFPROGRADE.
	until SHIP:VERTICALSPEED < 0
	{
		wait 0.1.
	}.
	lock tOrientation to SHIP:SRFRETROGRADE.
	lock STEERING to tOrientation.
	deployScienceExperiments().
	until ALT:RADAR < 8000 
	      and (SHIP:VERTICALSPEED > -600 and SHIP:VERTICALSPEED < 0) {
		updateAngleArrows().
		wait 0.1.
	}.
	local totalDrogueChutes is deployDrogueChutes().
	until (ALT:RADAR < 1000 and totalDrogueChutes > 0) 
	      or (ALT:RADAR < 4000 and totalDrogueChutes = 0) {
		updateAngleArrows().
		wait 0.1.
	}.
	clearFacingArrows().
	clearAngleArrows().
	deployParachutes().
}.

smartRocket().
