// copyright PHOeNICE. Not to be redistributed for any release.
// personal use and education only.

function deployScienceExperiments {
	// SCIENCE EXPERIMENTS
	
	// title: "SC-9001 Science Jr."
	local scScienceModules is SHIP:PARTSNAMED("science.module").
	for p in scScienceModules {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("observe materials bay") {
			pm:DOEVENT("observe materials bay").
			break.
		}.
	}.
	// title: "Mystery Goo Containment Unit"
	local scGooContainers is SHIP:PARTSNAMED("GooExperiment").
	for p in scGooContainers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("observe mystery goo") {
			pm:DOEVENT("observe mystery goo").
			break.
		}.
	}.
	// title: "2HOT Thermometer"
	local scThermometers is SHIP:PARTSNAMED("sensorThermometer").
	for p in scThermometers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("log temperature") {
			pm:DOEVENT("log temperature").
			break.
		}.
	}.
	// title: "PresMat Barometer"
	local scBarometers is SHIP:PARTSNAMED("sensorBarometer").
	for p in scBarometers {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("log pressure data") {
			pm:DOEVENT("log pressure data").
			break.
		}.
	}.
	// title: "Double-C Seismic Accelerometer"
	local scSeismic is SHIP:PARTSNAMED("sensorAccelerometer").
	for p in scSeismic {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 {
			pm:DOEVENT("log seismic data").
			break.
		}.
	}.
	// title: "Atmosperic Fluid Spectro-Variometer"
	local scAtmospheric is SHIP:PARTSNAMED("sensorAtmosphere").
	for p in scAtmospheric {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("run atmosphere analysis") {
			pm:DOEVENT("run atmosphere analysis").
			break.
		}.
	}.
	// title: "Dual Technique Magnetometer"
	local scMagnetosphere is SHIP:PARTSNAMED("DTMagnetometer").
	for p in scMagnetosphere {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("log magnetopsheric data") {
			pm:DOEVENT("log magnetopsheric data").
			break.
		}.
	}.
	// title: "GRAVMAX Negative Gravioli Detector"
	local scGravity is SHIP:PARTSNAMED("sensorGravimeter").
	for p in scGravity {
		local pm is p:GETMODULE("ModuleScienceExperiment").
		if pm:ALLEVENTNAMES:LENGTH = 1 and pm:HASEVENT("log gravity data") {
			pm:DOEVENT("log gravity data").
			break.
		}.
	}.	
}.

function deployLandingLegs {
	// LANDING LEGS
	
	// title: LT-05 Micro Landing Strut
	local llSmallLandingLeg is SHIP:PARTSNAMED("miniLandingLeg").
	for p in llSmallLandingLeg {
		local pm is p:GETMODULE("ModuleLandingLeg").
		if pm:HASEVENT("lower legs") {
			pm:DOEVENT("lower legs").
		}.
	}.
	// title: LT-1 Landing Struts
	local llMediumLandingLeg is SHIP:PARTSNAMED("landingLeg1").
	for p in llMediumLandingLeg {
		local pm is p:GETMODULE("ModuleLandingLeg").
		if pm:HASEVENT("lower legs") {
			pm:DOEVENT("lower legs").
		}.
	}.
	// title: LT-2 Landing Strut
	local llLargeLandingLeg is SHIP:PARTSNAMED("landingLeg1-2").
	for p in llLargeLandingLeg {
		local pm is p:GETMODULE("ModuleLandingLeg").
		if pm:HASEVENT("lower legs") {
			pm:DOEVENT("lower legs").
		}.
	}.
}.

function deployDrogueChutes {
	// DROGUE CHUTES
	
	// title: Mk12-R Radial-Mount Drogue Chute
	local pcRadialDrogue is SHIP:PARTSNAMED("radialDrogue").
	for p in pcRadialDrogue {
		local pm is p:GETMODULE("ModuleParachute").
		if pm:HASEVENT("deploy chute") {
			pm:DOEVENT("deploy chute").
		}.
	}.
	// title: Mk25 Parachute
	local pcInlineDrogue is SHIP:PARTSNAMED("parachuteDrogue").
	for p in pcInlineDrogue {
		local pm is p:GETMODULE("ModuleParachute").
		if pm:HASEVENT("deploy chute") {
			pm:DOEVENT("deploy chute").
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
	// title: Mk16-XL Parachute
	local pcInlineLarge is SHIP:PARTSNAMED("parachuteLarge").
	for p in pcInlineLarge {
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


function smoothRotate {
	parameter dir.
	local spd is max(SHIP:ANGULARMOMENTUM:MAG/10,4).
	local curF is SHIP:FACING:FOREVECTOR.
	local curR is SHIP:FACING:TOPVECTOR.
	local dirF is dir:FOREVECTOR.
	local dirR is dir:TOPVECTOR.
	local axis is VCRS(curF,dirF).
	local axisR is VCRS(curR,dirR).
	local rotAng is VANG(dirF,curF)/spd.
	local rotRAng is VANG(dirR,curR)/spd.
	local rot is ANGLEAXIS(min(2,rotAng),axis).
	local rotR is R(0,0,0).
	if VANG(dirF,curF) < 90 {
		set rotR to ANGLEAXIS(min(0.5,rotRAng),axisR).
	}
	return LOOKDIRUP(rot * curF, rotR * curR).
}

function readAtmosphericData {
	parameter tBody.
	local tAtm is BODY(tBody):ATM.
	print "-------------------------".
	print "Atmospheric information: " + tAtm:BODY.
	print "-------------------------".
	print "Exists? " + tAtm:EXISTS.
	print "Oxygen? " + tAtm:OXYGEN.
	print "Sea level pressure: " + tAtm:SEALEVELPRESSURE.
	print "Height: " + tAtm:HEIGHT.
}.

function etaToTimeWithMinus {
	parameter etaTime.
	if etaTime > SHIP:ORBIT:PERIOD / 2 {
		// give a negative ETA here if after it
		set etaTime to etaTime - SHIP:ORBIT:PERIOD.
	}.
	return etaTime.
}

function etaToApoWithMinus {
	return etaToTimeWithMinus(ETA:APOAPSIS).
}

function etaToPeriWithMinus {
	return etaToTimeWithMinus(ETA:PERIAPSIS).
}

function calcSpeedAtRadius {
	parameter mu.
	parameter r1.
	parameter a.
	return mu * (2/r1 - 1/a).
}

function calcCircularizeDV {
	parameter altit.
	// gravitational constant times focal body mass
	local mu is SHIP:ORBIT:BODY:MU.
	// average of PERI+APO+diameter of focal body
	local a is SHIP:ORBIT:SEMIMAJORAXIS.
	// APO+radius of focal body, larger half of the semimajor axis
	local r1 is SHIP:ORBIT:BODY:RADIUS + altit.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	local apoV is (mu*(2/r1 - 1/a))^(0.5).
	// the formula for circular orbit vel simplifies to:
	// r1 here instead of 'a' because 'a' is the old semi-major axis
	local circularV is (mu / r1)^(0.5).
	print "apoV is: " + apoV.
	print "circularV is: " + circularV.
	return circularV - apoV.
}

function calcHoemannDVtoOrbit {
	parameter tOrbit.
	// mu = gravitational constant times focal body mass
	local mu is SHIP:ORBIT:BODY:MU.
	// alt+radius of focal body, smaller half of the semimajor axis when leaving
	local r1 is SHIP:ORBIT:BODY:RADIUS + SHIP:ALTITUDE.
	print "Local r1 is: " + r1.
	// TODO: this is technically wrong for highly eccentric orbits!!
	//       NOT a proper rendezvous!!!
	// r2 = distance of target body, let's assume the average for now
	local r2 is SHIP:ORBIT:BODY:RADIUS + (tOrbit:PERIAPSIS + tOrbit:APOAPSIS) / 2.
	print "Target r2 is: " + r2.
	local a is (r1 + r2) / 2.
	// oval orbit velocity at any given r is ( sqrt(mu*(2/r1 - 1/a)) )
	local periV is (mu*(2/r1 - 1/a))^(0.5).
	print "Calculated periV to be: " + periV.
	return periV - SHIP:VELOCITY:ORBIT:MAG.
}

function calcCircularizeSpeed {
	parameter altit.
	local mu is SHIP:ORBIT:BODY:MU.
	// APO+radius of focal body, larger half of the semimajor axis
	local r1 is SHIP:ORBIT:BODY:RADIUS + altit.
	// the formula for circular orbit vel simplifies to:
	return (mu / r1)^(0.5).
}.

function calcOrbitPhaseAngle {
	parameter tOrbit.
	local angleBody is tOrbit:LONGITUDEOFASCENDINGNODE + tOrbit:ARGUMENTOFPERIAPSIS + tOrbit:TRUEANOMALY.
	local angleShip is SHIP:ORBIT:LONGITUDEOFASCENDINGNODE + SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY.
	local phaseAngle is MOD(angleBody - angleShip, 360).
	if phaseAngle < 0 { set phaseAngle to phaseAngle + 360. }
	return phaseAngle.
}.

function calcBodyPhaseAngle {
	parameter tBody.
	return calcOrbitPhaseAngle(tBody:ORBIT).
}.

function calcFuturePhaseAngle {
	parameter tBody.
	parameter tFuture.
	local pShip is SHIP:POSITION - SHIP:BODY:POSITION.
	local aShip is (180 + ARCTAN2(pShip:Z, pShip:X)).
	local pBody is POSITIONAT(tBody, tFuture) - SHIP:BODY:POSITION.
	local aBody is (180 + ARCTAN2(pBody:Z, pBody:X)).
	//print "atan2 new body angle: " + aBody.
	local aPhase is MOD(aBody - aShip, 360).
	if aPhase < 0 { 
		set aPhase to aPhase + 360. 
	}.
	//print "The new phase angle will be: " + aPhase.
	return aPhase.
}.

deployScienceExperiments().
deployLandingLegs().
deployPanels().
deployAntenna().
deployDrogueChutes().
deployParachutes().
