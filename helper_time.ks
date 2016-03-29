// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

function etaToTimeWithMinus {
	parameter etaTime.
	IF etaTime > SHIP:ORBIT:PERIOD / 2 {
		// give a negative ETA here if after it
		set etaTime to etaTime - SHIP:ORBIT:PERIOD.
	}.
	return etaTime.
}.
function etaToApoWithMinus {
	return etaToTimeWithMinus(ETA:APOAPSIS).
}.
function etaToPeriWithMinus {
	return etaToTimeWithMinus(ETA:PERIAPSIS).
}.

function shipMaxWarpAltitude {
	// KERBIN
	//             70km,120km
	// MUN
	//        10km,25km, 50km,  100km,   200km
	// MINMUS
	//    3km,      6km, 12km,   24km,    48km,    60km
	if SHIP:VELOCITY:SURFACE:MAG < 0.1 { return 7. }.
	// BUG: is this right?
	if SHIP:BODY:NAME = "Kerbin" {
		if SHIP:ALTITUDE < 70000 { return 0. }
		else if SHIP:ALTITUDE < 120000 { return 3. }
		else { return 7. }.
	}
	if SHIP:BODY:NAME = "Mun" {
		if SHIP:ALTITUDE < 5000 { return 0. }
		else if SHIP:ALTITUDE < 10000 { return 2. }
		else if SHIP:ALTITUDE < 25000 { return 3. }
		else if SHIP:ALTITUDE < 50000 { return 4. }
		else if SHIP:ALTITUDE < 100000 { return 5. }
		else if SHIP:ALTITUDE < 200000 { return 6. }
		else { return 7. }.
	}
	if SHIP:BODY:NAME = "Minmus" {
		if SHIP:ALTITUDE < 3000 { return 0. }
		else if SHIP:ALTITUDE < 6000 { return 2. }
		else if SHIP:ALTITUDE < 12000 { return 3. }
		else if SHIP:ALTITUDE < 24000 { return 4. }
		else if SHIP:ALTITUDE < 48000 { return 5. }
		else if SHIP:ALTITUDE < 60000 { return 6. }
		else { return 7. }.
	}
	return -1.
}.

function getWarpSpeedModifier {
	parameter speed.
	if speed = 7 { return 100000. }
	else if speed = 6 { return 10000. }
	else if speed = 5 { return 1000. }
	else if speed = 4 { return 100. }
	else if speed = 3 { return 50. }
	else if speed = 2 { return 10. }
	else if speed = 1 { return 5. }
	else if speed = 0 { return 1. }
	else { return 0. }.
}

function warpToAbsTime {
	parameter tEnd.
	local tStart is TIME:SECONDS.
	//  0,  1    2    3     4       5        6         7
	// 1x, 5x, 10x, 50x, 100x, 1.000x, 10.000x, 100.000x

	local oldWarp is 0.
	local currentWarp is 0.
	until tEnd - TIME:SECONDS < 5 {
		if SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT {
			if tEnd - TIME:SECONDS > 20 and currentWarp < 3 {
				set currentWarp to 3.
			} else if tEnd - TIME:SECONDS > 15 and currentWarp < 2 {
				set currentWarp to 2.
			} else if tEnd - TIME:SECONDS > 10 and currentWarp < 1 {
				set currentWarp to 1.
			}.
			if oldWarp <> currentWarp {
				set oldWarp to currentWarp.
				set warpmode to "PHYSICS".
				set warp to currentWarp.
			}.
		} else {
			from { local potentialWarp is 7. }
			until potentialWarp = 0 
			step { set potentialWarp to potentialWarp - 1. }
			do {
				if tEnd - TIME:SECONDS > 5*getWarpSpeedModifier(potentialWarp) and currentWarp < potentialWarp and shipMaxWarpAltitude() >= potentialWarp {
					set currentWarp to potentialWarp.
					print "Warping to speed: " + currentWarp.
					break.
				}.
			}.
			if oldWarp <> currentWarp {
				set oldWarp to currentWarp.
				set warpmode to "RAILS".
				set warp to currentWarp.
			}.
			wait 0.01.
		}.
	}.
	set warp to 0.
	wait until tEnd < TIME:SECONDS + 1.
}.
function warpToRelTime {
	parameter tRel.
	print "Warping for " + tRel + " seconds.".
	warpToAbsTime(TIME:SECONDS + tRel).
}.
