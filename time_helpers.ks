// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only. Not meant for distribution.

function etaToTimeWithMinus {
	parameter etaTime.
	IF etaTime > SHIP:ORBIT:PERIOD / 2 {
		// give a negative ETA here if after it
		set etaTime to etaTime - SHIP:ORBIT:PERIOD.
	}.
	return etaTime.
}.
FUNCTION etaToApoWithMinus {
	return etaToTimeWithMinus(ETA:APOAPSIS).
}.
FUNCTION etaToPeriWithMinus {
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
			if tEnd - TIME:SECONDS > 200000 and currentWarp < 7 and shipMaxWarpAltitude() >= 7 {
				set currentWarp to 7.
			} else if tEnd - TIME:SECONDS > 20000 and currentWarp < 6 and shipMaxWarpAltitude() >= 6 {
				set currentWarp to 6.
			} else if tEnd - TIME:SECONDS > 2000 and currentWarp < 5 and shipMaxWarpAltitude() >= 5 {
				set currentWarp to 5.
			} else if tEnd - TIME:SECONDS > 200 and currentWarp < 4 and shipMaxWarpAltitude() >= 4 {
				set currentWarp to 4.
			} else if tEnd - TIME:SECONDS > 100 and currentWarp < 3 and shipMaxWarpAltitude() >= 3 {
				set currentWarp to 3.
			} else if tEnd - TIME:SECONDS > 20 and currentWarp < 2 and shipMaxWarpAltitude() >= 2 {
				set currentWarp to 2.
			} else if tEnd - TIME:SECONDS > 10 and currentWarp < 1 and shipMaxWarpAltitude() >= 1 {
				set currentWarp to 1.
			}.
			if oldWarp <> currentWarp {
				set oldWarp to currentWarp.
				set warpmode to "RAILS".
				set warp to currentWarp.
			}.
			sleep 0.1.
		}.
	}.
	set warp to 0.
	wait until tEnd < TIME:SECONDS + 1.
}.
function warpToRelTime {
	parameter tRel.
	warpToAbsTime(TIME:SECONDS + tRel).
}.
