// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only.

// drawing arrows
lock tOrientation to HEADING(90, 90).

set drawingFacingArrows to false.
function createFacingArrows {
	set drawingFacingArrows to true.
	set targetArrow to VECDRAW(V(0,0,0), shipSizeScalar * tOrientation:FOREVECTOR, RGB(0,0,1), "", 1.0, true, 0.1).
	set facingArrow to VECDRAW(V(0,0,0), shipSizeScalar * SHIP:FACING:FOREVECTOR, RGB(1,0,1), "", 1.0, true, 0.1).
}.

set drawingAngleArrows to false.
function createAngleArrows {
	set drawingAngleArrows to true.
	set axisNorthArrow to VECDRAW(V(0,0,0), (shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "North", 5.0, true, 0.1).
	set axisSouthArrow to VECDRAW(V(0,0,0),-(shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "South", 5.0, true, 0.1).
	set axisRadialArrow to VECDRAW(V(0,0,0),(shipSizeScalar/3) * (SHIP:NORTH + R(90,0,0)):FOREVECTOR, RGB(1,1,1), "Radial",  5.0, true, 0.1).
	set axisEastArrow to VECDRAW(V(0,0,0), -(shipSizeScalar/3) * (SHIP:NORTH + R(90,90,0)):FOREVECTOR, RGB(1,1,1), "East",  5.0, true, 0.1).
}.

function updateAngleArrows {
	if drawingFacingArrows = true {
		set facingArrow:VEC to shipSizeScalar * SHIP:FACING:FOREVECTOR.
		set targetArrow:VEC to shipSizeScalar * tOrientation:FOREVECTOR.
	}.
	if drawingAngleArrows = true {
		set axisNorthArrow:VEC to (shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR.
		set axisSouthArrow:VEC to -(shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR.
		set axisRadialArrow:VEC to (shipSizeScalar/3) * (SHIP:NORTH + R(90,0,0)):FOREVECTOR.
		set axisEastArrow:VEC to -(shipSizeScalar/3) * (SHIP:NORTH + R(90,90,0)):FOREVECTOR.
	}.
}.

function clearFacingArrows {
	if drawingFacingArrows = true {
		unset targetArrow.
		unset facingArrow.
	}.
	set drawingFacingArrows to false.
}.

function clearAngleArrows {
	if drawingAngleArrows = true {
		unset axisRadialArrow.
		unset axisEastArrow.
		unset axisNorthArrow.
		unset axisSouthArrow.
	}.
	set drawingAngleArrows to false.
}.
