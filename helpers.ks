// copyright PHOeNICE. Not to be redistributed for any release.
// personal use and education only. Not meant for distribution.

// 1   2   3    4      5       6        7
// 5, 10, 50, 100, 1.000, 10.000, 100.000
function warpToTime {
	if SHIP:ALTITUDE < SHIP:BODY:ATM:HEIGHT {
		set warpmode to "PHYSICS".
	} else {
		set warpmode to "RAILS".
	}.
	set warp to 5.
}

function deployScienceExperiments {
	// SCIENCE EXPERIMENTS
	// title: "SC-9001 Science Jr."
	local scScienceModules is SHIP:PARTSNAMED("science.module").
	for p in scScienceModules {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 {
			pm:DOEVENT("observe materials bay").
			break.
		}.
	}.
	// title: "Mystery Goo Containment Unit"
	local scGooContainers is SHIP:PARTSNAMED("GooExperiment").
	for p in scGooContainers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 {
			pm:DOEVENT("observe mystery goo").
			break.
		}.
	}.
	// title: "2HOT Thermometer"
	local scThermometers is SHIP:PARTSNAMED("sensorThermometer").
	for p in scThermometers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 {
			pm:DOEVENT("log temperature").
			break.
		}.
	}.
	// title: "PresMat Barometer"
	local scBarometers is SHIP:PARTSNAMED("sensorBarometer").
	for p in scBarometers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 {
			pm:DOEVENT("log pressure data").
			break.
		}.
	}.
}.

function deployLandingLegs {
	// LANDING LEGS
	
	// title: LT-05 Micro Landing Strut
	local llMiniLandingLeg is SHIP:PARTSNAMED("miniLandingLeg").
	for p in llMiniLandingLeg {
		local pm is p:GETMODULE("ModuleLandingLeg").
		if pm:HASEVENT("lower legs") {
			pm:DOEVENT("lower legs").
		}.
	}.
}.

function deployParachutes {
	// PARACHUTES
	
	// title: Mk16 Parachute
	local pcInlineSmall is SHIP:PARTSNAMED("parachuteSingle").
	for p in pcInlineSmall {
		local pm is p:GETMODULE("ModuleParachute").
		if pm:HASEVENT("deploy chute") {
			pm:DOEVENT("deploy chute").
		}.
	}.
	// title: Mk-2 Radial-Mount Parachute
	local pcRadialSmall is SHIP:PARTSNAMED("parachuteRadial").
	for p in pcRadialSmall {
		local pm is p:GETMODULE("ModuleParachute").
		if pm:HASEVENT("deploy chute") {
			pm:DOEVENT("deploy chute").
		}.
	}.
}.


function deployPanels {
	// SOLAR PANELS
	
	// title: SP-W 3x2 Photovoltaic Panels
	local spShielded3x2 is SHIP:PARTSNAMED("solarPanels1").
	for p in spShielded3x2 {
		local pm is p:GETMODULE("ModuleDeployableSolarPanel").
		if pm:HASEVENT("extend panels") {
			pm:DOEVENT("extend panels").
		}.
	}.
	// title: SP-L 1x6 Photovoltaic Panels
	local spShielded1x6 is SHIP:PARTSNAMED("solarPanels2").
	for p in spShielded1x6 {
		local pm is p:GETMODULE("ModuleDeployableSolarPanel").
		if pm:HASEVENT("extend panels") {
			pm:DOEVENT("extend panels").
		}.
	}.
	// title: OX-4W 3x2 Photovoltaic Panels
	local spExposed3x2 is SHIP:PARTSNAMED("solarPanels3").
	for p in spExposed3x2 {
		local pm is p:GETMODULE("ModuleDeployableSolarPanel").
		if pm:HASEVENT("extend panels") {
			pm:DOEVENT("extend panels").
		}.
	}.
	// title: OX-4L 1x6 Photovoltaic Panels
	local spExposed1x6 is SHIP:PARTSNAMED("solarPanels4").
	for p in spExposed1x6 {
		local pm is p:GETMODULE("ModuleDeployableSolarPanel").
		if pm:HASEVENT("extend panels") {
			pm:DOEVENT("extend panels").
		}.
	}.
	// title: Gigantor XL Solar Array
	local spGigantor is SHIP:PARTSNAMED("largeSolarPanel").
	for p in spGigantor {
		local pm is p:GETMODULE("ModuleDeployableSolarPanel").
		if pm:HASEVENT("extend panels") {
			pm:DOEVENT("extend panels").
		}.
	}.
	
	// RADIATORS
	
	// title: Thermal Control System (small)
	local trSmallTCS is SHIP:PARTSNAMED("foldingRadSmall").
	for p in trSmallTCS {
		local pm is p:GETMODULE("ModuleDeployableRadiator").
		if pm:HASEVENT("extend radiator") {
			pm:DOEVENT("extend radiator").
		}.
	}.
	// title: Thermal Control System (medium)
	local trMediumTCS is SHIP:PARTSNAMED("foldingRadMed").
	for p in trMediumTCS {
		local pm is p:GETMODULE("ModuleDeployableRadiator").
		if pm:HASEVENT("extend radiator") {
			pm:DOEVENT("extend radiator").
		}.
	}.
	// title: Thermal Control System (large)
	local trLargeTCS is SHIP:PARTSNAMED("foldingRadLarge").
	for p in trLargeTCS {
		local pm is p:GETMODULE("ModuleDeployableRadiator").
		if pm:HASEVENT("extend radiator") {
			pm:DOEVENT("extend radiator").
		}.
	}.
}.

function deployAntenna {
	// title: "Communotron 16"
	local oa2MM is SHIP:PARTSNAMED("longAntenna").
	for p in oa2MM {
		local pm is p:GETMODULE("ModuleRTAntenna").
		if pm:HASACTION("activate") {
			pm:DOEVENT("activate").
		}.
	}.
	// title: "Communotron 32"
	local oa5MM is SHIP:PARTSNAMED("RTLongAntenna2").
	for p in oa5MM {
		local pm is p:GETMODULE("ModuleRTAntenna").
		if pm:HASACTION("activate") {
			pm:DOEVENT("activate").
		}.
	}.
	// title: "Comms DTS-M1"
	local da50MM is SHIP:PARTSNAMED("mediumDishAntenna").
	for p in da50MM {
		local pm is p:GETMODULE("ModuleRTAntenna").
		if pm:HASACTION("activate") {
			pm:DOEVENT("activate").
			pm:SETFIELD("target", "mission-control").
		}.
	}.
	// title: "Reflectron KR-7"
	local da90MM is SHIP:PARTSNAMED("RTShortDish2").
	for p in da90MM {
		local pm is p:GETMODULE("ModuleRTAntenna").
		if pm:HASACTION("activate") {
			pm:DOEVENT("activate").
			pm:SETFIELD("target", "mission-control").
		}.
	}.
	// title: "Reflectron KR-14"
	local da60GM is SHIP:PARTSNAMED("RTLongDish2").
	for p in da60GM {
		local pm is p:GETMODULE("ModuleRTAntenna").
		if pm:HASACTION("activate") {
			pm:DOEVENT("activate").
			pm:SETFIELD("target", "mission-control").
		}.
	}.
}.

function readShipParts {
	// generate a list of all ship parts
	local masterPartList is SHIP:PARTS.

	// SCIENCE EXPERIMENTS
	// LANDING LEGS
	// PARACHUTES
	// SOLAR PANELS
	// RADIATORS
	// COMM Antenna
}.


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

function etaToTimeWithMinus {
	parameter etaTime.
	IF etaTime > SHIP:ORBIT:PERIOD / 2 {
		// give a negative ETA here if after it
		set etaTime to etaTime - SHIP:ORBIT:PERIOD.
	}.
	return etaTime.
}

FUNCTION etaToApoWithMinus {
	return etaToTimeWithMinus(ETA:APOAPSIS).
}

FUNCTION etaToPeriWithMinus {
	return etaToTimeWithMinus(ETA:PERIAPSIS).
}

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

deployScienceExperiments().
deployLandingLegs().
deployPanels().
deployAntenna().
deployParachutes().
