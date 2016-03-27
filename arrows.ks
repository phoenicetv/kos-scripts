// copyright PHOeNICE. Not to be redistributed for any public release.
// personal use and education only. Not meant for distribution.

// drawing arrows
LOCK tOrientation TO HEADING(90, 90).

SET drawingFacingArrows TO FALSE.
FUNCTION createFacingArrows {
	SET drawingFacingArrows TO TRUE.
	SET targetArrow TO VECDRAW(V(0,0,0), shipSizeScalar * tOrientation:FOREVECTOR, RGB(0,0,1), "", 1.0, TRUE, 0.1).
	SET facingArrow TO VECDRAW(V(0,0,0), shipSizeScalar * SHIP:FACING:FOREVECTOR, RGB(1,0,1), "", 1.0, TRUE, 0.1).
}.

SET drawingAngleArrows TO FALSE.
FUNCTION createAngleArrows {
	SET drawingAngleArrows TO TRUE.
	SET axisNorthArrow TO VECDRAW(V(0,0,0), (shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "North", 5.0, TRUE, 0.1).
	SET axisSouthArrow TO VECDRAW(V(0,0,0),-(shipSizeScalar/3) *  SHIP:NORTH:FOREVECTOR, RGB(1,1,1), "South", 5.0, TRUE, 0.1).
	SET axisRadialArrow TO VECDRAW(V(0,0,0),(shipSizeScalar/3) * (SHIP:NORTH + R(90,0,0)):FOREVECTOR, RGB(1,1,1), "Radial",  5.0, TRUE, 0.1).
	SET axisEastArrow TO VECDRAW(V(0,0,0), -(shipSizeScalar/3) * (SHIP:NORTH + R(90,90,0)):FOREVECTOR, RGB(1,1,1), "East",  5.0, TRUE, 0.1).
}.

FUNCTION updateAngleArrows {
	IF drawingFacingArrows = TRUE {
		SET facingArrow:VEC TO shipSizeScalar * SHIP:FACING:FOREVECTOR.
		SET targetArrow:VEC TO shipSizeScalar * tOrientation:FOREVECTOR.
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
