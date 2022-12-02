unit AsphyreMath3D;
////////////////////////////////////////////////////////////////////////////////
// This library provides many function to detect collisions in 3D space using //
// AsphyreMath.pas. This is a version which is not tested yet, so bugs may be //
// present. Please feel free to post bugs on the forums at www.afterwarp.net  //
////////////////////////////////////////////////////////////////////////////////
// Most functions were taken from other librarys and converted to Asphyre     //
// conventions.                                                               //
////////////////////////////////////////////////////////////////////////////////
// Created by Dirk Nordhusen aka Huehnerschaender                             //
////////////////////////////////////////////////////////////////////////////////
// I claim no copyright, no license, no whatever.                             //
// This software is distributed on an "AS IS" basis,                          //
// WITHOUT WARRANTY OF ANY KIND, either express or implied.                   //
////////////////////////////////////////////////////////////////////////////////

interface
uses AsphyreMath, AsphyreDef, AsphyreMatrix, math;

// Some constants
const BEHIND     = 0; // Classified behind the plane
      INTERSECTS = 1; // Classified intersecting the plane
      FRONT      = 2; // Classified in front of the plane

      AsphyrePI      = 3.1415926535897932384626433832795;    // = PI
      Asphyre2PI     = 6.283185307179586476925286766559;     // = 2*PI
      Asphyre_180_PI = 57.295779513082320876798154814105;    // Degrees to radient
      Asphyre_PI_180 = 0.017453292519943295769236907684886;  // radient to Degrees


type
  PBoundingBox8 = ^TBoundingBox8;
  TBoundingBox8 = record
    point: array [1..8] of TPoint3;
  end;

  PBoundingBox12 = ^TBoundingBox12;
  TBoundingBox12 = record // Box with 8 corner points plus 4 points on the sides
    point: array [1..12] of TPoint3;
  end;

  PBoxAABB=^TBoxAABB; // Axis aligned bounding box
  TBoxAABB= // Box with Min,Max and Middlepoint-Vertex
    record Min       : TPoint3;   // Lowest corner of the box
           Max       : TPoint3;   // highest corner of the box
           Middlepnt : TPoint3;   // Middlepoint (Center) of the
    end;

  PBoxOBB=^TBoxOBB; // Oriented bounding box
  TBoxOBB= // Box with axisorientation, sizes and middlepoint
    record Axis      : array[1..3] of TPoint3; // Orientation of the 3 axis (x,y,z);
           Depth     : array[1..3] of real;    // Size of the oriented box
           MiddlePnt : TPoint3;                // Middlepoint of the oriented box
    end;

  // Orientation of a plane/triangle
  TPlaneAlignment = (taYZ, taXZ, taXY, taUnknown);

  // Plane
  TPlane=
    record distance : single; // distance of the plane to origin
           case boolean of    // normal of the plane
             false: (normal   : TPoint3);
             true : (a, b, c : single);
    end;

// coverts an AABB into an OBB
function AsphyreAABBtoOBB(Box : TBoxAABB) : TBoxOBB; overload;
function AsphyreAABBtoOBB(Box : TBoxAABB; Trans, Scale, Rotate : TPoint3) : TBoxOBB; overload;

// This returns the distance the plane is from the origin (0, 0, 0)
// It takes the normal to the plane, along with ANY point that lies on the plane (any corner)
function AsphyrePlaneDistance3D(Normal, Point : TPoint3) : real;

//Min-Max-Werte einer Box in TD3DBox8 umwandeln wie von den anderen Routinen benötigt
function MinMaxToBoundingBox8 (pmin, pmax : TPoint3) : TBoundingBox8; overload;
function MinMaxToBoundingBox8 (pmin, pmax : TPoint3; m : TMatrix4) : TBoundingBox8; overload;
function MinMaxToBoundingBox12(pmin, pmax : TPoint3) : TBoundingBox12; overload;
function MinMaxToBoundingBox12(pmin, pmax : TPoint3; m : TMatrix4) : TBoundingBox12; overload;

// This returns the normal of a polygon (The direction the polygon is facing)
function AsphyrePolyNormal(vPolygon : array of TPoint3) : TPoint3;


// This takes a triangle (plane) and line and returns true if they intersected
function AsphyreIntersectedPlane(vPoly, vLine : array of TPoint3;
                                 var vNormal : TPoint3;
                                 var originDistance : real) : boolean;

// This returns the point on the line segment vA_vB that is closest to point vPoint
function AsphyreClosestPointOnLine(vA, vB, vPoint : TPoint3) : TPoint3;


// This returns an intersection point of a polygon and a line (assuming intersects the plane)
function AsphyreIntersectionPoint(vNormal : TPoint3; vLine : Array of TPoint3;
                                  distance : double) : TPoint3;

// This returns true if the intersection point is inside of the polygon
function AsphyreInsidePolygon(vIntersection : TPoint3; Poly : Array of TPoint3;
                              verticeCount : longint) : boolean;

// Use this function to test collision between a line and polygon
function AsphyreIntersectedPolygon(vPoly, vLine : Array of TPoint3;
                                   verticeCount : integer) : boolean;

// This function classifies a sphere according to a plane. (BEHIND, in FRONT, or INTERSECTS)
function AsphyreClassifySphere(var vCenter, vNormal, vPoint : TPoint3; radius : real;
                               var distance : real) : integer;

// This takes in the sphere center, radius, polygon vertices and vertex count.
// This function is only called if the intersection point failed.  The sphere
// could still possibly be intersecting the polygon, but on it's edges.
function AsphyreEdgeSphereCollision(var vCenter : TPoint3; vPolygon : array of TPoint3;
                                    vertexCount : integer; radius : real) : boolean;

// This returns true if the sphere is intersecting with the polygon.
function AsphyreSpherePolygonCollision(vPolygon : Array of TPoint3; var vCenter : TPoint3;
                                       vertexCount : integer; radius : real) : boolean;

// This returns the offset the sphere needs to move in order to not intersect the plane
function AsphyreGetCollisionOffset(var vNormal:TPoint3;radius,distance:real):TPoint3;

// This returns a point on a given bezier where t=(0..1)
function AsphyrePointOnBezier(p1, p2, p3, p4 : TPoint3; t : real) : TPoint3;

// Point in Sphere ?
function AsphyrePointinSphere  (p : TPoint3; M : TPoint3; r : single) : boolean;

// Sphere collides Sphere ?
function AsphyreSphereinSphere  (M1, M2 : TPoint3; r1, r2 : single) : boolean;

// Is Point in Ellipse? x,y,z = radius of ellipse
function AsphyrePointinEllipse(p : TPoint3; x, y, z : single; matWorld : TMatrix4) : boolean;

// Determines if a Point is in a BoundingBox
function AsphyrePointinBox(p : TPoint3; box : TBoundingBox8) : boolean; overload;
function AsphyrePointinBox(p : TPoint3; box : TBoundingBox12) : boolean; overload;
function AsphyrePointinBox(p : TPoint3; Min, Max : TPoint3) : boolean; overload;

// determines if 2 BoundingBoxes collide
function AsphyreBoxinBox(box1, box2 : TBoundingBox8; out colPoint : integer) : boolean; overload;
function AsphyreBoxinBox(box1, box2: TBoundingBox8) : boolean; overload;
function AsphyreBoxinBox(box1, box2: TBoundingBox12) : boolean; overload;
function AsphyreBoxinBox(Min1, Max1, Min2, Max2 : TPoint3) : boolean; overload;



//IntersectionPoint Line/ Plane
function AsphyreLineCutPlane(vLinestart, vLineend, vOn_Plane, vNormal : TPoint3;
                             var vIntersectionPoint : TPoint3;
                             var fPercent : single) : boolean; overload;
function AsphyreLineCutPlane(vLinestart, vLineend, vOn_Plane : TPoint3;
                             nx, ny, nz : single;
                             var vIntersectionPoint : TPoint3;
                             var fPercent : single) : boolean; overload;

// Point in Triangle?
function AsphyreVecInTriangle(vPkt, v0, v1, v2:TPoint3):boolean;

// Ray intersects Triangle?
function AsphyreRayIntersectTriangle(vOrig, vDir, v0, v1, v2 : TPoint3;
                                     BackfaceCulling : boolean = true) : boolean; overload;
function AsphyreRayIntersectTriangle(vOrig, vDir, v0, v1, v2 : TPoint3;
                                     var Distance : real;
                                     BackfaceCulling : boolean = true) : boolean; overload;
function AsphyreRayIntersectTriangle(vOrig, vDir, v0, v1, v2 : TPoint3;
                                     var Intersect : TPoint3;
                                     BackfaceCulling : boolean = true) : boolean; overload;

// Test, if Ray from vOrig in direction vDir collides with AABB
function AsphyreRayIntersectAABB(vOrig, vDir : TPoint3; Box : TBoxAABB) : boolean; overload;
function AsphyreRayIntersectAABB(vOrig, vDir : TPoint3; Box : TBoxAABB;
                                 var Distance : real) : boolean; overload;
function AsphyreRayIntersectAABB(vOrig, vDir : TPoint3; Box : TBoxAABB;
                                 var Intersect : TPoint3) : boolean; overload;

// Test, if Ray from vOrig in direction vDir collides with OBB
function AsphyreRayIntersectOBB(vOrig, vDir : TPoint3; Box : TBoxOBB; var Distance : real) : boolean; overload;
function AsphyreRayIntersectOBB(vOrig, vDir : TPoint3; Box : TBoxOBB; var Intersect : TPoint3) : boolean; overload;

// Test, if linesegment from vOrig in direction vDir with length fLaenge collided with OBB
function AsphyreLineIntersectOBB (vOrig, vDir : TPoint3; fLaenge : real; Box : TBoxOBB ) : boolean; overload;
function AsphyreLineIntersectOBB(vStart, vEnde : TPoint3; Box : TBoxOBB) : boolean; overload;
function AsphyreLineIntersectAABB(vOrig, vDir : TPoint3; fLaenge : real; Box : TBoxAABB) : boolean; overload;
function AsphyreLineIntersectAABB(vStart, vEnde : TPoint3; Box : TBoxAABB) : boolean; overload;

// Collision box/sphere
function AsphyreCollisionSphereOBB(vOrig : TPoint3; r : real; Box : TBoxOBB) : boolean;
function AsphyreCollisionSphereAABB(vOrig : TPoint3; r : real; Box : TBoxAABB) : boolean;

// Proves if bounding boxes collided
function AsphyreCollisionOBBOBB  (BoxA, BoxB : TBoxOBB) : boolean;
function AsphyreCollisionAABBAABB(BoxA, BoxB : TBoxAABB) : boolean;
function AsphyreCollisionAABBOBB (BoxA : TBoxAABB; BoxB : TBoxOBB) : boolean;

// proves if OBB/AABB collided with a triangle
function AsphyreCollisionTriOBB (v0, v1, v2 : TPoint3; Box : TBoxOBB) : boolean;
function AsphyreCollisionTriAABB(v0, v1, v2 : TPoint3; Box : TBoxAABB) : boolean;

// returns a plane out of three given points
function AsphyrePlaneFromPoints(const v1, v2, v3 : TPoint3) : TPlane;

// returns the alignment of a triangle
function AsphyreTriangleAlignement(pVertex : array of TPoint3) : TPlaneAlignment;
// returns the alignment of a plane
function AsphyrePlaneAlignement(Plane : TPlane) : TPlaneAlignment;


implementation

function AsphyrePlaneFromPoints(const v1, v2, v3 : TPoint3) : TPlane;
var n : TPoint3;
begin
  n := VecCross3(VecSub3(v2, v1), VecSub3(v3, v1));
  with Result do
  begin
    a := n.x;
    b := n.y;
    c := n.z;
    distance := -(a*v1.x + b*v1.y + c*v1.z);
    normal := VecNorm3(normal);
  end;
end;

function AsphyreTriangleAlignement(pVertex : array of TPoint3) : TPlaneAlignment;
begin
  result := AsphyrePlaneAlignement(AsphyrePlaneFromPoints(pVertex[0], pVertex[1], pVertex[2]));
end;

function AsphyrePlaneAlignement(Plane : TPlane) : TPlaneAlignment;
begin
  result := taUnknown;
  if (Abs(Plane.Normal.x) >= Abs(Plane.Normal.y)) and
     (Abs(Plane.Normal.x) >= Abs(Plane.Normal.z)) then
    Result := taYZ;
  if (Abs(Plane.Normal.y) >= Abs(Plane.Normal.x)) and
     (Abs(Plane.Normal.y) >= Abs(Plane.Normal.z)) then
    Result := taXZ;
  if (Abs(Plane.Normal.z) >= Abs(Plane.Normal.x)) and
     (Abs(Plane.Normal.z) >= Abs(Plane.Normal.y)) then
    Result := taXY;
end;


function AsphyrePolyNormal(vPolygon:array of TPoint3):TPoint3;
var vVector1,
    vVector2:TPoint3;
begin vVector1 := VecSub3(vPolygon[2],vPolygon[0]);
      vVector2 := VecSub3(vPolygon[1],vPolygon[0]);
      // Take the cross product of our 2 vectors to get a perpendicular vector
      // Now we have a normal, but it's at a strange length, so let's make it length 1.
      // Use our function we created to normalize the normal (Makes it a length of one)
      result   := VecNorm3(VecCross3(vVector1, vVector2));
end;

function AsphyreAABBtoOBB(Box:TBoxAABB):TBoxOBB;
begin fillchar(result,sizeof(result),0);
      result.MiddlePnt := Box.Middlepnt;
      result.Axis[1]   := Point3(1,0,0);
      result.Axis[2]   := Point3(0,1,0);
      result.Axis[3]   := Point3(0,0,1);
      result.Depth[1]  := (Box.max.x-Box.Min.x)/2;
      result.Depth[2]  := (Box.max.y-Box.Min.y)/2;
      result.Depth[3]  := (Box.max.z-Box.Min.z)/2;
end;

function AsphyreAABBtoOBB(Box:TBoxAABB; Trans,Scale,Rotate : TPoint3) : TBoxOBB;
var i: integer;
    m,t : TMatrix4;
    tmpVec : TVector4;
begin
  result := AsphyreAABBtoOBB(box);
  // rotate the orientation of the box
  m := matRotateX(Rotate.x);
  t := matRotateY(Rotate.y);
  m := MatMul(m,t);
  t := MatRotateZ(Rotate.z);
  m := MatMul(m,t);
  for i := low(result.Axis) to high(result.Axis) do
  begin
    // SOMEONE PLEASE PROVE THE NEXT LINE!!!
    // Originally it was D3DXVec3TransformCoord(result.Axis[i],result.Axis[i],m);
    tmpVec := MatVecMul(Vec3to4(result.Axis[i]), m);
    result.Axis[i].x := tmpVec.x/tmpVec.w;
    result.Axis[i].y := tmpVec.y/tmpVec.w;
    result.Axis[i].z := tmpVec.z/tmpVec.w;
    result.Axis[i] := VecNorm3(result.Axis[i]);
  end;

  // Move Middlepoint of the box
  Box.Middlepnt := VecAdd3(Box.Middlepnt,Trans);
  // Scale box
  result.depth[1]:=result.depth[1]*Scale.x;
  result.depth[2]:=result.depth[2]*Scale.y;
  result.depth[3]:=result.depth[3]*Scale.z;
end;

function AsphyreClosestPointOnLine(vA, vB, vPoint:TPoint3):TPoint3;
var vVector1 ,
    vVector2 ,
    vVector3 : TPoint3;
    t        ,
    d        : real;
begin // Create the vector from end point vA to our point vPoint.
      vVector1 := VecSub3(vPoint,vA);
      // Create a normalized direction vector from end point vA to end point vB
      vVector2 := VecNorm3(VecSub3(vB,vA));
      // Use the distance formula to find the distance of the line segment (or magnitude)
      d := VecDist3(vA, vB);
      // Using the dot product, we project the vVector1 onto the vector vVector2.
      // This essentially gives us the distance from our projected vector from vA.
      t := VecDot3(vVector2, vVector1);
      // If our projected distance from vA, "t", is less than or equal to 0, it must
      // be closest to the end point vA.  We want to return this end point.
      if t <= 0 then
      begin
        result := vA;
        exit;
      end;
      // If our projected distance from vA, "t", is greater than or equal to the magnitude
      // or distance of the line segment, it must be closest to the end point vB.  So, return vB.
      if t >= d then
      begin
        result:=vB;
        exit;
      end;
      // Here we create a vector that is of length t and in the direction of vVector2
      vVector3 := VecScale3(vVector2,t);
      // To find the closest point on the line segment, we just add vVector3 to the original
      // end point vA.
      result := VecAdd3(vA,vVector3);
end;

// Creates a BoundingBox out of max and min values of 2 points
function MinMaxToBoundingBox8(pmin, pmax : TPoint3) : TBoundingBox8;
begin
  fillchar(result, sizeof(result),0);
  result.point[1] := Point3(pmin.x, pmin.y, pmin.z);
  result.point[2] := Point3(pmax.x, pmin.y, pmin.z);
  result.point[3] := Point3(pmax.x, pmin.y, pmax.z);
  result.point[4] := Point3(pmin.x, pmin.y, pmax.z);
  result.point[5] := Point3(pmin.x, pmax.y, pmin.z);
  result.point[6] := Point3(pmax.x, pmax.y, pmin.z);
  result.point[7] := Point3(pmax.x, pmax.y, pmax.z);
  result.point[8] := Point3(pmin.x, pmax.y, pmax.z);
end;

function MinMaxToBoundingBox8(pmin ,pmax : TPoint3; m : TMatrix4) : TBoundingBox8;
var i : integer;
    TmpVec : TVector4;
begin
  result := MinMaxToBoundingBox8(pmin,pmax);
  for i := low(result.point) to high(result.point) do
  begin
    tmpVec := MatVecMul(Vec3to4(result.point[i]), m);
    result.point[i].x := tmpVec.x/tmpVec.w;
    result.point[i].y := tmpVec.y/tmpVec.w;
    result.point[i].z := tmpVec.z/tmpVec.w;
  end;
//    D3DXVec3TransformCoord(result.point[i],result.point[i],m);
end;

function AsphyrePlaneDistance3D(Normal, Point:TPoint3):real;
begin // Use the plane equation to find the distance (Ax + By + Cz + D = 0)  We want to find D.
      // So, we come up with D = -(Ax + By + Cz)
      result := - ((Normal.x * Point.x) +
                   (Normal.y * Point.y) +
                   (Normal.z * Point.z));
end;

function AsphyreIntersectedPlane(vPoly, vLine : array of TPoint3; var vNormal : TPoint3; var originDistance : real) : boolean;
var distance1 ,
    distance2 : real;
begin // The distances from the 2 points of the line from the plane
      distance1:=0;
      distance2:=0;
      // We need to get the normal of our plane to go any further
      vNormal := AsphyrePolyNormal(vPoly);
      // Let's find the distance our plane is from the origin.  We can find this value
      // from the normal to the plane (polygon) and any point that lies on that plane (Any vertex)
      originDistance := AsphyrePlaneDistance3D(vNormal, vPoly[0]);
      // Get the distance from point1 from the plane using: Ax + By + Cz + D = (The distance from the plane)
      distance1 := ((vNormal.x * vLine[0].x)  +			// Ax +
                    (vNormal.y * vLine[0].y)  +			// Bx +
		    (vNormal.z * vLine[0].z)) + originDistance;	// Cz + D

	// Get the distance from point2 from the plane using Ax + By + Cz + D = (The distance from the plane)

	distance2 := ((vNormal.x * vLine[1].x)  +		  // Ax +
      		      (vNormal.y * vLine[1].y)  +		  // Bx +
		            (vNormal.z * vLine[1].z)) + originDistance; // Cz + D

	// Now that we have 2 distances from the plane, if we times them together we either
	// get a positive or negative number.  If it's a negative number, that means we collided!
	// This is because the 2 points must be on either side of the plane (IE. -1 * 1 = -1).

        // Check to see if both point's distances are both negative or both positive
        // Return false if each point has the same sign.  -1 and 1 would mean each point is on either side of the plane.  -1 -2 or 3 4 wouldn't...
	if distance1 * distance2 >= 0 then
  begin
    result:=false;
    exit;
  end;
  // The line intersected the plane, Return TRUE
	result:=true;
end;


// Function to find out if a 3D point is within a 3D box
function AsphyrePointinBox(p: TPoint3; box: TBoundingBox8): boolean;

var normal: TPoint3;
    collision: boolean;
begin

  collision := true;

  // Test each plane of the cube by calculating it's normal and the dot product
  // with the point. if the Dot product of one plane is > 0 then the point is
  // not in the cube

  //Lower Plane
  normal := VecCross3(VecSub3(box.point[2], box.point[1]),
                      VecSub3(box.point[3], box.point[1]));
  if VecDot3(normal, VecSub3(p, box.point[1])) > 0 then collision := false;

  //Upper Plane
  if collision then
  begin
    normal := VecCross3(VecSub3(box.point[7], box.point[5]),
                        VecSub3(box.point[6], box.point[5]));
    if VecDot3(normal, VecSub3(p, box.point[5])) > 0 then collision := false;
  end;

  //Front Plane
  if collision then
  begin
    normal := VecCross3(VecSub3(box.point[7], box.point[3]),
                        VecSub3(box.point[4], box.point[3]));
    if VecDot3(normal, VecSub3(p, box.point[3])) > 0 then collision := false;
  end;

  //Back Plane
  if collision then
  begin
    normal := VecCross3(VecSub3(box.point[5], box.point[1]),
                        VecSub3(box.point[2], box.point[1]));
    if VecDot3(normal, VecSub3(p, box.point[1])) > 0 then collision := false;
  end;

  //Right Plane
  if collision then
  begin
    normal := VecCross3(VecSub3(box.point[6], box.point[2]),
                        VecSub3(box.point[3], box.point[2]));
    if VecDot3(normal, VecSub3(p, box.point[2])) > 0 then collision := false;
  end;

  //Left Plane
  if collision then
  begin
    normal := VecCross3(VecSub3(box.point[4], box.point[1]),
                        VecSub3(box.point[5], box.point[1]));
    if VecDot3(normal, VecSub3(p, box.point[1])) > 0 then collision := false;
  end;

  result := collision;
end;

// Test if a box is collided with a box
// colPoint gives back the nr of the point of the boxes
// 1..4 are the lower 4 points of box 1
// 2..8 are the upper 4 points of box 1
// 9..12 are the lower 4 points of box 2
// 13..16 are the upper 4 points of box 2
// Just by investigating this nr we can say on which side the box collided

function AsphyreBoxinBox(box1, box2: TBoundingBox8; out colPoint : integer): boolean;
var collision: boolean;
    i: integer;
begin
  collision := false;

  // Test all 8 points of the first box
  for i := 1 to 8 do
    if AsphyrePointinBox(box1.point[i], box2) then
    begin
      collision := true;
      colPoint := i;
      break;
    end;

  // if there was no collision yet, test the points of box 2 too!
  if not collision then
    for i := 1 to 8 do
      if AsphyrePointinBox(box2.point[i], box1) then
      begin
        collision := true;
        colPoint := 8+i;
	  	  break;
      end;

  result := collision;
end;




















/////////////////////////////////// INTERSECTION POINT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This returns the intersection point of the line that intersects the plane
/////
/////////////////////////////////// INTERSECTION POINT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreIntersectionPoint(vNormal:TPoint3;vLine:Array of TPoint3;distance:double):TPoint3;
var vPoint, vLineDir : TPoint3;
    Denominator      ,
    Dist             ,
    Numerator        : double;
begin // Variables to hold the point and the line's direction
      Numerator := 0;
      Denominator := 0;
      dist := 0;

      // 1)  First we need to get the vector of our line, Then normalize it so it's a length of 1
      // Get the Vector of the line
      // Normalize the lines vector
      vLineDir := VecNorm3(VecSub3(vLine[1],vLine[0]));

      // 2) Use the plane equation (distance = Ax + By + Cz + D) to find the
      // distance from one of our points to the plane.
      // Use the plane equation with the normal and the line
      Numerator := - (vNormal.x * vLine[0].x +
                      vNormal.y * vLine[0].y +
		      vNormal.z * vLine[0].z + distance);

      // 3) If we take the dot product between our line vector and the normal of the polygon,
      // Get the dot product of the line's vector and the normal of the plane
      Denominator := VecDot3(vNormal, vLineDir);

      // Since we are using division, we need to make sure we don't get a divide by zero error
      // If we do get a 0, that means that there are INFINATE points because the the line is
      // on the plane (the normal is perpendicular to the line - (Normal.Vector = 0)).
      // In this case, we should just return any point on the line.

      // Check so we don't divide by zero
      if IsZero(Denominator) then begin result:=vLine[0]; // Return an arbitrary point on the line
                                        exit;
                                  end;

      // Divide to get the multiplying (percentage) factor
      dist := Numerator / Denominator;

      // Now, like we said above, we times the dist by the vector, then add our arbitrary point.
      result:=Point3((vLine[0].x + (vLineDir.x * dist)),
                     (vLine[0].y + (vLineDir.y * dist)),
                     (vLine[0].z + (vLineDir.z * dist)));
end;

/////////////////////////////////// INSIDE POLYGON \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This checks to see if a point is inside the ranges of a polygon
/////
/////////////////////////////////// INSIDE POLYGON \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreInsidePolygon(vIntersection:TPoint3;Poly:Array of TPoint3;verticeCount:longint):boolean;
const MATCH_FACTOR:double = 0.99; // Used to cover up the error in realing point
var   Angle  : double;
      vA, vB : TPoint3; // Create temp vectors
      i      : integer;
begin // Initialize the angle
      Angle := 0;
      // Go in a circle to each vertex and get the angle between
      for i:=0 to verticeCount-1 do
	begin // Subtract the intersection point from the current vertex
              vA := VecSub3(Poly[i],vIntersection);
              vB := VecSub3(Poly[(i + 1) mod verticeCount],vIntersection);
              // Find the angle between the 2 vectors and add them all up as we go along
              Angle:=Angle+VecAngle3(vA, vB);
	end;
      // If the angle is greater than 2 PI, (360 degrees)
      if Angle>=MATCH_FACTOR * (2 * PI) then
        begin result:=true; // The point is inside of the polygon
              exit;
        end;
      // If you get here, it obviously wasn't inside the polygon, so Return FALSE
      result:=false;
end;

/////////////////////////////////// INTERSECTED POLYGON \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This checks if a line is intersecting a polygon
/////
/////////////////////////////////// INTERSECTED POLYGON \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreIntersectedPolygon(vPoly,vLine:Array of TPoint3;verticeCount:integer):boolean;
var vIntersection  ,
    vNormal        : TPoint3;
    originDistance : real;
begin result:=false;
      originDistance := 0;
      // First, make sure our line intersects the plane
      if not AsphyreIntersectedPlane(vPoly, vLine,   vNormal,   originDistance) then exit;

      // Now that we have our normal and distance passed back from IntersectedPlane(),
      // we can use it to calculate the intersection point.
      vIntersection := AsphyreIntersectionPoint(vNormal, vLine, originDistance);

      // Now that we have the intersection point, we need to test if it's inside the polygon.
      result:=AsphyreInsidePolygon(vIntersection, vPoly, verticeCount);
end;

///////////////////////////////// CLASSIFY SPHERE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This tells if a sphere is BEHIND, in FRONT, or INTERSECTS a plane, also it's distance
/////
///////////////////////////////// CLASSIFY SPHERE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreClassifySphere(var vCenter,vNormal, vPoint:TPoint3;radius:real;var distance:real):integer;
var d : real;
begin // First we need to find the distance our polygon plane is from the origin.
      d := AsphyrePlaneDistance3D(vNormal, vPoint);

      // Here we use the famous distance formula to find the distance the center point
      // of the sphere is from the polygon's plane.
      distance := (vNormal.x * vCenter.x +
                   vNormal.y * vCenter.y +
                   vNormal.z * vCenter.z + d);

      // If the absolute value of the distance we just found is less than the radius,
      // the sphere intersected the plane.
      if abs(distance) < radius then begin result:=INTERSECTS;
                                           exit;
                                     end
	// Else, if the distance is greater than or equal to the radius, the sphere is
	// completely in FRONT of the plane.
	                            else if distance >= radius then begin result:=FRONT;
                                                                          exit;
                                                                    end;

	// If the sphere isn't intersecting or in FRONT of the plane, it must be BEHIND
	result:=BEHIND;
end;

///////////////////////////////// EDGE SPHERE COLLSIION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This returns true if the sphere is intersecting any of the edges of the polygon
/////
///////////////////////////////// EDGE SPHERE COLLSIION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreEdgeSphereCollision(var vCenter:TPoint3;vPolygon:array of TPoint3;vertexCount:integer;radius:real):boolean;
var vPoint   : TPoint3;
    i        : integer;
    distance : real;
begin // This function takes in the sphere's center, the polygon's vertices, the vertex count
      // and the radius of the sphere.  We will return true from this function if the sphere
      // is intersecting any of the edges of the polygon.

      // Go through all of the vertices in the polygon
      for i:=0 to vertexCount-1 do
	begin // This returns the closest point on the current edge to the center of the sphere.
	      vPoint := AsphyreClosestPointOnLine(vPolygon[i], vPolygon[(i + 1) mod vertexCount], vCenter);
              // Now, we want to calculate the distance between the closest point and the center
	      distance := VecDist3(vPoint, vCenter);
              // If the distance is less than the radius, there must be a collision so return true
	      if distance < radius then begin result:=true;
                                              exit;
                                        end;
	end;
	// The was no intersection of the sphere and the edges of the polygon
	result:=false;
end;

////////////////////////////// SPHERE POLYGON COLLISION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////	This returns true if our sphere collides with the polygon passed in
/////
////////////////////////////// SPHERE POLYGON COLLISION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreSpherePolygonCollision(vPolygon:Array of TPoint3;var vCenter:TPoint3;vertexCount:integer;radius:real):boolean;
var vPosition,
    vOffset  ,
    vNormal  : TPoint3;
    distance : real;
    classification:integer;
begin // 1) STEP ONE - Finding the sphere's classification
      // Let's use our Normal() function to return us the normal to this polygon
      vNormal := AsphyrePolyNormal(vPolygon);
      // This will store the distance our sphere is from the plane
      distance := 0;
      // This is where we determine if the sphere is in FRONT, BEHIND, or INTERSECTS the plane
      classification := AsphyreClassifySphere(vCenter, vNormal, vPolygon[0], radius, distance);
      // If the sphere intersects the polygon's plane, then we need to check further
      if classification = INTERSECTS then
	begin // 2) STEP TWO - Finding the psuedo intersection point on the plane
	      // Now we want to project the sphere's center onto the polygon's plane
	      vOffset := VecScale3(vNormal,distance);
              // Once we have the offset to the plane, we just subtract it from the center
	      // of the sphere.  "vPosition" now a point that lies on the plane of the polygon.
              vPosition := VecSub3(vCenter,vOffset);
              // 3) STEP THREE - Check if the intersection point is inside the polygons perimeter
	      // If the intersection point is inside the perimeter of the polygon, it returns true.
	      // We pass in the intersection point, the list of vertices and vertex count of the poly.
	      if AsphyreInsidePolygon(vPosition, vPolygon, 3) then
                     begin result:=true;
                           exit;
                     end
		else begin // 4) STEP FOUR - Check the sphere intersects any of the polygon's edges
			   // If we get here, we didn't find an intersection point in the perimeter.
			   // We now need to check collision against the edges of the polygon.
			   if AsphyreEdgeSphereCollision(vCenter, vPolygon, vertexCount, radius) then
			     begin result:=true;
                                   exit;
                             end;
                     end;
	end;
	// If we get here, there is obviously no collision
	result:=false;
end;

//	This returns the offset to move the center of the sphere off the collided polygon
function AsphyreGetCollisionOffset(var vNormal : TPoint3; radius, distance : real) : TPoint3;
var vOffset      : TPoint3;
    distanceOver : real;
begin
  vOffset := Point3(0,0,0);
  if distance > 0 then
  begin // Find the distance that our sphere is overlapping the plane, then
        // find the direction vector to move our sphere.
    distanceOver := radius - distance;
    vOffset      := VecScale3(vNormal,distanceOver);
  end
	else
  begin // Else colliding from behind the polygon
        // Find the distance that our sphere is overlapping the plane, then
        // find the direction vector to move our sphere.
    distanceOver := radius + distance;
	  vOffset      := VecScale3(vNormal,-distanceOver);
  end;
	result:=vOffset;
end;

//	This returns a point on a given bezier where t=(0..1)
function AsphyrePointOnBezier(p1,p2,p3,p4:TPoint3;t:real):TPoint3;
var var1, var2, var3 : real;
begin
  result := Point3(0,0,0);
  var1 := 1 - t;
  var2 := var1 * var1 * var1;
  var3 := t * t * t;
  result:=Point3(var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x,
                 var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y,
                 var2*p1.z + 3*t*var1*var1*p2.z + 3*t*t*var1*p3.z + var3*p4.z);
end;

// Is the Point in Sphere ?
function AsphyrePointinSphere(p: TPoint3; M: TPoint3; r: single): boolean;
begin
  result := (sqr(p.x - m.x) + sqr(p.y - m.y) + sqr(p.z - m.z)) < sqr(r);
end;

// Sphere collides Sphere ?
function AsphyreSphereinSphere(M1, M2: TPoint3; r1, r2: single): boolean;
begin
  result := (sqr(m1.x - m2.x) + sqr(m1.y - m2.y) + sqr(m1.z - m2.z)) < sqr(r1 + r2);
end;


// Is the Point in box ?
function AsphyrePointinBox(p : TPoint3; Min, Max : TPoint3) : boolean;
begin
  result := AsphyrePointinBox(p, MinMaxToBoundingBox8(Min, Max));
end;

function AsphyrePointinBox(p: TPoint3; box: TBoundingBox12): boolean;
var normal: TPoint3;
begin
  result:=false;
  normal:=VecCross3(VecSub3(box.point[2], box.point[1]),
                      VecSub3(box.point[3], box.point[1]));
  if VecDot3(normal, VecSub3(p, box.point[1])) >= 0 then exit;

  normal:=VecCross3(VecSub3(box.point[7], box.point[5]),
                      VecSub3(box.point[6], box.point[5]));
  if VecDot3(normal, VecSub3(p, box.point[5])) >= 0 then exit;

  normal:=VecCross3(VecSub3(box.point[7], box.point[3]),
                      VecSub3(box.point[4], box.point[3]));
  if VecDot3(normal,VecSub3(p, box.point[3])) >= 0 then exit;

  normal:=VecCross3(VecSub3(box.point[5], box.point[1]),
                      VecSub3(box.point[2], box.point[1]));
  if VecDot3(normal,VecSub3(p, box.point[1])) >= 0 then exit;

  normal:=VecCross3(VecSub3(box.point[6], box.point[2]),
                      VecSub3(box.point[3], box.point[2]));
  if VecDot3(normal,VecSub3(p, box.point[2])) >= 0 then exit;

  normal:=VecCross3(VecSub3(box.point[4], box.point[1]),
                      VecSub3(box.point[5], box.point[1]));
  if VecDot3(normal,VecSub3(p, box.point[1])) >= 0 then exit;
  result := true;
end;

// Is Box in Box?
function AsphyreBoxinBox(Min1, Max1, Min2, Max2 : TPoint3) : boolean;
begin
  result := AsphyreBoxinBox(MinMaxToBoundingBox8(Min1, Max1), MinMaxToBoundingBox8(Min2, Max2));
end;

function AsphyreBoxinBox(box1, box2 : TBoundingBox8): boolean;
var i: integer;
begin
  result:=true;
  for i := 1 to 8 do
    if AsphyrePointinBox(box1.point[i], box2) then
      exit;

  for i := 1 to 8 do
    if AsphyrePointinBox(box2.point[i], box1) then
      exit;
  result := false;
end;

function AsphyreBoxinBox (box1, box2: TBoundingBox12): boolean;overload;
var i: integer;
begin
  result:=true;
  for i := 1 to 12 do //Alle Pointe von Box1 mit Box2 testen
    if AsphyrePointinBox(box1.point[i], box2) then
      exit;
  for i := 1 to 12 do //Wenn noch keine Collision, dann auch Box2 mit Box1 testen
    if AsphyrePointinBox(box2.point[i], box1) then
      exit;
  result := false;
end;

function MinMaxToBoundingBox12(pmin, pmax : TPoint3) : TBoundingBox12;overload;
begin fillchar(result,sizeof(result),0);
      result.point[ 1] := Point3(pmin.x, pmin.y, pmin.z);
      result.point[ 2] := Point3(pmax.x, pmin.y, pmin.z);
      result.point[ 3] := Point3(pmax.x, pmin.y, pmax.z);
      result.point[ 4] := Point3(pmin.x, pmin.y, pmax.z);
      result.point[ 5] := Point3(pmin.x, pmax.y, pmin.z);
      result.point[ 6] := Point3(pmax.x, pmax.y, pmin.z);
      result.point[ 7] := Point3(pmax.x, pmax.y, pmax.z);
      result.point[ 8] := Point3(pmin.x, pmax.y, pmax.z);
      result.point[ 9] := Point3((pmin.x + pmax.x)/2, (pmin.y + pmax.y)/2, pmin.z); //front
      result.point[10] := Point3(pmax.x, (pmin.y + pmax.y)/2, (pmin.z + pmax.z)/2); //right
      result.point[11] := Point3((pmin.x + pmax.x)/2, (pmin.y + pmax.y)/2,pmax.z); //back
      result.point[12] := Point3(pmin.x, (pmin.y + pmax.y)/2, (pmin.z + pmax.z)/2); //left
end;

function MinMaxToBoundingBox12(pmin, pmax : TPoint3; m : TMatrix4) : TBoundingBox12;
var i:integer;
    tmpVec : TVector4;
begin
  result := MinMaxToBoundingBox12(pmin, pmax);
  for i := low(result.point) to high(result.point) do
  begin
    tmpVec := MatVecMul(Vec3to4(result.point[i]), m);
    result.point[i].x := tmpVec.x/tmpVec.w;
    result.point[i].y := tmpVec.y/tmpVec.w;
    result.point[i].z := tmpVec.z/tmpVec.w;
  end;
end;

function AsphyreLineCutPlane(vLinestart, vLineend, vOn_Plane : TPoint3;
                             nx, ny, nz : single;
                             var vIntersectionPoint : TPoint3;
                             var fPercent : single) : boolean;
begin
  result := AsphyreLineCutPlane(vLinestart, vLineend, vOn_Plane, Point3(nx, ny, nz), vIntersectionPoint, fPercent);
end;


function AsphyreLineCutPlane(vLinestart, vLineend, vOn_Plane, vNormal : TPoint3;
                             var vIntersectionPoint : TPoint3;
                             var fPercent : single) : boolean;
var
   vDirection  : TPoint3; // Vector from vLinestart to vLineEnd
   V1          : TPoint3; // Vector from vLinestart to vOn_Plane
   fLength,
   fDistance : single;
begin
   result:=false;
   vDirection := Point3(vLineend.x - vLinestart.x,
                       vLineend.y - vLinestart.y,
                       vLineend.z - vLinestart.z);

   fLength := vDirection.x * vNormal.x
            + vDirection.y * vNormal.y
            + vDirection.z * vNormal.z;

   if abs(fLength) < 0.0001 then
     exit;

   V1 := Point3(vOn_Plane.x - vLinestart.x,
                vOn_Plane.y - vLinestart.y,
                vOn_Plane.z - vLinestart.z);

   fDistance := V1.x * vNormal.x
                + V1.y * vNormal.y
                + V1.z * vNormal.z;
   fPercent := fDistance / fLength;

   if fPercent < 0.0 then
     exit
   else
     if fPercent > 1.0 then
       exit
     else
     begin
       vIntersectionPoint := Point3(vLinestart.x + vDirection.x*fPercent,
                                    vLinestart.y + vDirection.y*fPercent,
                                    vLinestart.z + vDirection.z*fPercent);
       result := true;
     end;
end;

////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Liegt der Point innerhalb des Dreiecks? Beide müssen im selben
///// Koordinatensystem definiert sein.
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreVecInTriangle(vPkt, v0, v1, v2:TPoint3):boolean;
var vc1, vc2 : TPoint3;
begin
  result:=false;
  vc1 := VecCross3(VecSub3(v2,   v1),VecSub3(vPkt, v1));
  vc2 := VecCross3(VecSub3(v2,   v1),VecSub3(v0,   v1));
  if VecDot3(vc1, vc2) < 0 then exit;

  vc1 := VecCross3(VecSub3(v2,   v0),VecSub3(vPkt, v0));
  vc2 := VecCross3(VecSub3(v2,   v0),VecSub3(v1,   v0));
  if VecDot3(vc1, vc2) < 0 then exit;

  vc1 := VecCross3(VecSub3(v1,   v0),VecSub3(vPkt, v0));
  vc2 := VecCross3(VecSub3(v1,   v0),VecSub3(v2,   v0));
  if VecDot3(vc1, vc2) < 0 then exit;

  result:=true;
end;

////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Kollisionsabfrage zwischen einem Strahl und einen Triangle. Strahl
///// und Triangle müssen im selben Koordinatensystem sein. [s. Möller,
///// Trumbore]
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreRayIntersectTriangle(vOrig, vDir,v0, v1, v2:TPoint3;var Distance:real;BackfaceCulling:boolean=true):boolean;
var pvec, tvec, qvec, edge1, edge2 : TPoint3;
    det,u,v:real;
begin result:=false;
      Distance:=0;
      edge1 := VecSub3(v1, v0);
      edge2 := VecSub3(v2, v0);
      pvec  := VecCross3(vDir, edge2);
      // Wenn nahe 0, dann ist Strahl parallel
      det := VecDot3(edge1, pvec);
      if BackfaceCulling and (det < 0.0001) then exit
        else if (det < 0.0001) and (det > -0.0001) then exit;
      // Entfernung zur Ebene, < 0 = hinter Ebene
      tvec := VecSub3(vOrig, v0);
      u    := VecDot3(tvec, pvec);
      if (u < 0.0) or (u > det) then exit;
      qvec := VecCross3(tvec, edge1);
      v := VecDot3(vDir, qvec);
      if (v < 0.0) or (u+v > det) then exit;
      Distance:=VecDot3(edge2,qvec)*(1/det);
end;

function AsphyreRayIntersectTriangle(vOrig, vDir,v0, v1, v2:TPoint3;var Intersect:TPoint3;BackfaceCulling:boolean=true):boolean;
var distance:real;
begin fillchar(Intersect,sizeof(Intersect),0);
      result:=AsphyreRayIntersectTriangle(vOrig, vDir,v0, v1, v2,Distance,BackfaceCulling);
      if result then
        Intersect:=VecAdd3(vOrig,VecScale3(vDir,distance));
end;

function AsphyreRayIntersectTriangle(vOrig, vDir,v0, v1, v2:TPoint3;BackfaceCulling:boolean=true):boolean;
var distance:real;
begin result:=AsphyreRayIntersectTriangle(vOrig, vDir,v0, v1, v2,Distance,BackfaceCulling);
end;

////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Testet, ob der Strahl von vOrig in Richtung vDir mit der Box kollidiert
///// ist. Strahl und Box müssen im Weltkoordinatenraum angegeben sein. Bei
///// einer Kollision wird die Entfernung zum KollisionsPoint im letzten
///// Parameter gespeichert, falls gewünscht.[Slapmethode, s.Möller, Haines]
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreRayIntersectAABB(vOrig,vDir:TPoint3;Box:TBoxAABB):boolean;
var Distance:real;
begin result:=AsphyreRayIntersectOBB(vOrig,vDir,AsphyreAABBtoOBB(box),Distance);
end;

function AsphyreRayIntersectAABB(vOrig,vDir:TPoint3;Box:TBoxAABB;var Distance:real):boolean;
begin result:=AsphyreRayIntersectOBB(vOrig,vDir,AsphyreAABBtoOBB(box),Distance);
end;

function AsphyreRayIntersectAABB(vOrig,vDir:TPoint3;Box:TBoxAABB;var Intersect:TPoint3):boolean;
var Distance:real;
begin fillchar(Intersect,sizeof(Intersect),0);
      result:=AsphyreRayIntersectAABB(vOrig,vDir,Box,Distance);
      if result then
        Intersect:=VecAdd3(vOrig,VecScale3(vDir,distance));
end;

////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Testet, ob der Strahl von vOrig in Richtung vDir mit der OBB kollidiert
///// ist. Strahl und OBB müssen im Weltkoordinatenraum angegeben sein. Bei
///// einer Kollision wird die Entfernung zum KollisionsPoint im letzten
///// Parameter gespeichert, falls gewünscht.[Slapmethode, s.Möller, Haines]
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreRayIntersectOBB(vOrig,vDir:TPoint3;Box:TBoxOBB;var Distance:real):boolean;
var e, f, t1, t2, temp,
    tmin,tmax: real;
    i:integer;
    vP:TPoint3;
begin result:=false;
      tmin := -99999.9;
      tmax := +99999.9;
      vP   := VecSub3(Box.Middlepnt, vOrig);
      for i:=1 to 3 do
        begin e    := VecDot3(Box.axis[i], vP);
              f    := VecDot3(Box.Axis[i], vDir);
              if abs(f) > 0.00001 then
                     begin t1  := (e + box.depth[i]) / f;
                           t2  := (e - box.depth[i]) / f;
                           if t1 > t2 then
                             begin temp:=t1;
                                   t1:=t2;
                                   t2:=temp;
                             end;
                           if t1 > tmin then tmin := t1;
                           if t2 < tmax then tmax := t2;
                           if (tmin > tmax) or (tmax<0) then exit;
                   end
               else if (-e - box.depth[i] > 0) or (-e + box.depth[i]< 0) then exit;
        end;
   if tmin > 0 then
          Distance:=tmin
     else Distance:=tmax;
   result:=true;
end;

function AsphyreRayIntersectOBB(vOrig,vDir:TPoint3;Box:TBoxOBB;var Intersect:TPoint3):boolean;
var Distance:real;
begin fillchar(Intersect,sizeof(Intersect),0);
      result:=AsphyreRayIntersectOBB(vOrig,vDir,Box,Distance);
      if result then
        Intersect:=VecAdd3(vOrig,VecScale3(vDir,distance));
end;

////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Testet, ob das Liniensegment von vOrig in Richtung vDir der Länge
///// fLaenge mit der OBB kollidiert ist. Das Segment und die OBB müssen
///// in Weltkoordinaten angegeben sein. [SepartionsAxisn, s.Eberly]
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreLineIntersectOBB(vOrig,vDir:TPoint3;fLaenge:real;Box:TBoxOBB):boolean;
var fAvDir_vA ,
    fAvDif_vA ,
    fADxD_A   : array[0..2] of real;
    _vHL_     ,
    fRhs      : real;
    vDxD      ,
    vHL       ,
    vLM       ,
    vDiff     : TPoint3;
begin
   result:=false;
   // Halbe Länge und MittelPoint der Box
   vHL:=VecScale3(vDir,0.5*FLaenge);
   vLM:=VecAdd3(vOrig,vHL);
   vDiff:=VecSub3(vLM,box.Middlepnt);

   fAvDir_vA[0] := ABS(VecDot3(vHL,Box.Axis[1]));
   fAvDif_vA[0] := ABS(VecDot3(vDiff,Box.Axis[1]));
   fRhs := Box.Depth[1] + fAvDir_vA[0];
   if fAvDif_vA[0] > fRhs then exit;

   fAvDir_vA[1] := ABS(VecDot3(vHL,Box.Axis[2]));
   fAvDif_vA[1] := ABS(VecDot3(vDiff,Box.axis[2]));
   fRhs := Box.Depth[2] + fAvDir_vA[1];
   if  fAvDif_vA[1] > fRhs then exit;

   fAvDir_vA[2] := ABS(VecDot3(vHL,Box.axis[3]));
   fAvDif_vA[2] := ABS(VecDot3(vDiff,Box.axis[3]));
   fRhs := Box.Depth[3] + fAvDir_vA[2];
   if  fAvDif_vA[2] > fRhs then exit;

   vDxD :=VecCross3(vHL, vDiff);

   _vHL_ := 1.0;//xxxD3DMathe_VBetrag(vHL);

   fADxD_A[0] := ABS(VecDot3(vDxD, Box.Axis[1]))/_vHL_;
   fRhs := (Box.depth[2]*fAvDir_vA[2] + Box.depth[3]*fAvDir_vA[1])/_vHL_;
   if  fADxD_A[0] > fRhs  then exit;

   fADxD_A[1] := ABS(VecDot3(vDxD, Box.Axis[2]))/_vHL_;
   fRhs := (Box.depth[1]*fAvDir_vA[2] + Box.depth[3]*fAvDir_vA[0])/_vHL_;
   if fADxD_A[1] > fRhs then exit;

   fADxD_A[2] := ABS(VecDot3(vDxD, Box.Axis[3]))/_vHL_;
   fRhs := (Box.depth[1]*fAvDir_vA[1] + Box.depth[2]*fAvDir_vA[0])/_vHL_;
   if fADxD_A[2] > fRhs then exit;

   result:=true;
end;

function AsphyreLineIntersectAABB(vOrig,vDir:TPoint3;fLaenge:real;Box:TBoxAABB):boolean;
begin result:=AsphyreLineIntersectOBB(vOrig,vDir,fLaenge,AsphyreAABBtoOBB(Box));
end;

function AsphyreLineIntersectOBB(vStart,vEnde:TPoint3;Box:TBoxOBB):boolean;
var vDir    : TPoint3;
    fLaenge : real;
begin vDir:=VecNorm3(VecSub3(vEnde,vStart));
      flaenge:=VecAbs3(VecSub3(vEnde,vStart));
      result:=AsphyreLineIntersectOBB(vStart,vDir,fLaenge,box);
end;

function AsphyreLineIntersectAABB(vStart,vEnde:TPoint3;Box:TBoxAABB):boolean;
begin result:=AsphyreLineIntersectOBB(vStart,vEnde,AsphyreAABBtoOBB(Box));
end;


////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Prüft ob die Sphäre mit Radius r um vOrig mit der Box kollidiert
///// oder nicht. Alle Angaben in Weltkoordinaten. Erzeugt ein Strahlen-
///// segment vom MittelPoint der Sphäre in Richtung des MittelPointes
///// der Box und prüft auf Kollision.
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreCollisionSphereOBB(vOrig:TPoint3;r:real;Box:TBoxOBB):boolean;
var vDir : TPoint3;
begin
   vDir   := VecNorm3(VecSub3(Box.Middlepnt, vOrig));
   result := AsphyreLineIntersectOBB(vOrig, vDir, r, Box);
end;

function AsphyreCollisionSphereAABB(vOrig:TPoint3;r:real;Box:TBoxAABB):boolean;
begin result:=AsphyreCollisionSphereOBB(vOrig,r,AsphyreAABBtoOBB(box));
end;


////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
///// Prüft ob die beiden in Weltkoordinaten angegebenen OBBs miteinander
///// kollidiert sind. [SeparationsAxisn, s.Gottschalk|Eberly|Gomez]
/////
////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
function AsphyreCollisionOBBOBB(BoxA,BoxB:TBoxOBB):boolean;
var t    : array[0..2] of real;
    vcd  : TPoint3;
    matM : array[0..2,0..2] of real; // B's axis in relation to A
    ra   ,                            // Radius A
    rb   ,                            // Radius B
    tt   : real;
begin result:=false;
      vcD := VecSub3(BoxB.Middlepnt, BoxA.Middlepnt);
      // test axis of Box A as separation axis
      // =============================================
      // First axis A1
      matM[0,0] := VecDot3(BoxA.Axis[1], BoxB.Axis[1]);
      matM[0,1] := VecDot3(BoxA.Axis[1], BoxB.Axis[2]);
      matM[0,2] := VecDot3(BoxA.Axis[1], BoxB.Axis[3]);
      ra := BoxA.depth[1];
      rb := BoxB.depth[1] * ABS(matM[0,0]) +
            BoxB.depth[2] * ABS(matM[0,1]) +
            BoxB.depth[3] * ABS(matM[0,2]);
      T[0] := VecDot3(vcD, BoxA.Axis[1]);
      tt   := ABS(T[0]);
      if tt> ra + rb then exit;

      // Second Axis A2
      matM[1,0] := VecDot3(BoxA.Axis[2], BoxB.Axis[1]);
      matM[1,1] := VecDot3(BoxA.Axis[2], BoxB.Axis[2]);
      matM[1,2] := VecDot3(BoxA.Axis[2], BoxB.Axis[3]);
      ra := BoxA.Depth[2];
      rb := BoxB.depth[1] * ABS(matM[1,0]) +
            BoxB.depth[2] * ABS(matM[1,1]) +
            BoxB.depth[3] * ABS(matM[1,2]);
      T[1] := VecDot3(vcD, BoxA.Axis[2]);
      tt   := ABS(T[1]);
      if tt> ra + rb then exit;

      // Third Axis A3
      matM[2,0] := VecDot3(BoxA.Axis[3], BoxB.Axis[1]);
      matM[2,1] := VecDot3(BoxA.Axis[3], BoxB.Axis[2]);
      matM[2,2] := VecDot3(BoxA.Axis[3], BoxB.Axis[3]);
      ra   := BoxA.depth[3];
      rb   := BoxB.depth[1] * ABS(matM[2,0]) +
              BoxB.depth[2] * ABS(matM[2,1]) +
              BoxB.depth[3] * ABS(matM[2,2]);
      T[2] := VecDot3(vcD, BoxA.Axis[3]);
      tt   := ABS(T[2]);
      if tt> ra + rb then exit;

      // Test Axis of Box B as Separation axis
      // =====================================
      // First Axis A1
      ra := BoxA.depth[1] * ABS(matM[0,0]) +
            BoxA.depth[2] * ABS(matM[1,0]) +
            BoxA.depth[3] * ABS(matM[2,0]);
      rb := BoxB.depth[1];
      tt:= ABS( T[0]*matM[0,0] + T[1]*matM[1,0] + T[2]*matM[2,0] );
      if tt> ra + rb then exit;

      // Second Axis A2
      ra := BoxA.depth[1] * ABS(matM[0,1]) +
            BoxA.depth[2] * ABS(matM[1,1]) +
            BoxA.depth[3] * ABS(matM[2,1]);
      rb := BoxB.depth[2];
      tt:= ABS( T[0]*matM[0,1] + T[1]*matM[1,1] + T[2]*matM[2,1] );
      if tt> ra + rb then exit;

       // Third Axis A3
      ra := BoxA.depth[1] * ABS(matM[0,2]) +
            BoxA.depth[2] * ABS(matM[1,2]) +
            BoxA.depth[3] * ABS(matM[2,2]);
      rb := BoxB.depth[3];
      tt:= ABS( T[0]*matM[0,2] + T[1]*matM[1,2] + T[2]*matM[2,2] );
      if tt> ra + rb then exit;

      // Axis A1xB1
      ra := BoxA.depth[2]*ABS(matM[2,0]) + BoxA.depth[3]*ABS(matM[1,0]);
      rb := BoxB.depth[2]*ABS(matM[0,2]) + BoxB.depth[3]*ABS(matM[0,1]);
      tt:= ABS( T[2]*matM[1,0] - T[1]*matM[2,0] );
      if tt> ra + rb  then exit;

      // Axis A1xB2
      ra := BoxA.depth[2]*ABS(matM[2,1]) + BoxA.depth[3]*ABS(matM[1,1]);
      rb := BoxB.depth[1]*ABS(matM[0,2]) + BoxB.depth[3]*ABS(matM[0,0]);
      tt:= ABS( T[2]*matM[1,1] - T[1]*matM[2,1] );
      if tt> ra + rb  then exit;

      // Axis A1xB3
      ra := BoxA.depth[2]*ABS(matM[2,2]) + BoxA.depth[3]*ABS(matM[1,2]);
      rb := BoxB.depth[1]*ABS(matM[0,1]) + BoxB.depth[2]*ABS(matM[0,0]);
      tt:= ABS( T[2]*matM[1,2] - T[1]*matM[2,2] );
      if  tt> ra + rb  then exit;

      // Axis A2xB1
      ra := BoxA.depth[1]*ABS(matM[2,0]) + BoxA.depth[3]*ABS(matM[0,0]);
      rb := BoxB.depth[2]*ABS(matM[1,2]) + BoxB.depth[3]*ABS(matM[1,1]);
      tt:= ABS( T[0]*matM[2,0] - T[2]*matM[0,0] );
      if tt> ra + rb  then exit;

      // Axis A2xB2
      ra := BoxA.depth[1]*ABS(matM[2,1]) + BoxA.depth[3]*ABS(matM[0,1]);
      rb := BoxB.depth[1]*ABS(matM[1,2]) + BoxB.depth[3]*ABS(matM[1,0]);
      tt:= ABS( T[0]*matM[2,1] - T[2]*matM[0,1] );
      if tt> ra + rb then exit;

      // Axis A2xB3
      ra := BoxA.depth[1]*ABS(matM[2,2]) + BoxA.depth[3]*ABS(matM[0,2]);
      rb := BoxB.depth[1]*ABS(matM[1,1]) + BoxB.depth[2]*ABS(matM[1,0]);
      tt:= ABS( T[0]*matM[2,2] - T[2]*matM[0,2] );
      if tt> ra + rb then exit;

      // Axis A3xB1
      ra := BoxA.depth[1]*ABS(matM[1,0]) + BoxA.depth[2]*ABS(matM[0,0]);
      rb := BoxB.depth[2]*ABS(matM[2,2]) + BoxB.depth[3]*ABS(matM[2,1]);
      tt:= ABS( T[1]*matM[0,0] - T[0]*matM[1,0] );
      if tt> ra + rb  then exit;

      // Axis A3xB2
      ra := BoxA.depth[1]*ABS(matM[1,1]) + BoxA.depth[2]*ABS(matM[0,1]);
      rb := BoxB.depth[1]*ABS(matM[2,2]) + BoxB.depth[3]*ABS(matM[2,0]);
      tt:= ABS( T[1]*matM[0,1] - T[0]*matM[1,1] );
      if tt> ra + rb then exit;

      // Axis A3xB3
      ra := BoxA.depth[1]*ABS(matM[1,2]) + BoxA.depth[2]*ABS(matM[0,2]);
      rb := BoxB.depth[1]*ABS(matM[2,1]) + BoxB.depth[2]*ABS(matM[2,0]);
      tt:= ABS( T[1]*matM[0,2] - T[0]*matM[1,2] );
      if tt> ra + rb then exit;

      // No seperation axis found => COLLISION
      result:=true;
end;

///// Proves if an AABB and an OBB collide
function AsphyreCollisionAABBOBB(BoxA : TBoxAABB; BoxB : TBoxOBB) : boolean;
begin
  result := AsphyreCollisionOBBOBB(AsphyreAABBtoOBB(BoxA), BoxB);
end;

function AsphyreCollisionAABBAABB(BoxA, BoxB : TBoxAABB) : boolean;
begin
  result := AsphyreCollisionOBBOBB(AsphyreAABBtoOBB(BoxA), AsphyreAABBtoOBB(BoxB));
end;

function AsphyreCollisionTriOBB(v0,v1,v2:TPoint3;Box:TBoxOBB):boolean;

  // helper function for: xxxCollisionTriOBB()
  // Separation axis in direction vV
  procedure Tri_Projektion(v0, v1, v2,vV:TPoint3;var pfMin,pfMax:real);
  var fPktPrdt : real;
  begin pfMin := VecDot3(vV, v0);
        pfMax := pfMin;
        fPktPrdt := VecDot3(vV, v1);
        if fPktPrdt < pfMin then
               pfMin := fPktPrdt
          else if fPktPrdt > pfMax then
                 pfMax := fPktPrdt;
        fPktPrdt := VecDot3(vV, v2);
        if fPktPrdt < pfMin then
               pfMin := fPktPrdt
          else if fPktPrdt > pfMax then
                 pfMax := fPktPrdt;
  end;

  // helper function for: xxxCollision_Tri_OBB()
  // Separation axis in direction vV
  procedure OBB_Projektion(Box:TBoxOBB;vV:TPoint3;var pfMin,pfMax:real);
  var fPktPrdt,fR:real;
  begin
     fPktPrdt := VecDot3(vV, Box.Middlepnt);

     fR := Box.depth[1] * ABS(VecDot3(vV, Box.Axis[1])) +
           Box.depth[2] * ABS(VecDot3(vV, Box.Axis[2])) +
           Box.depth[3] * ABS(VecDot3(vV, Box.Axis[3]));
     pfMin := fPktPrdt - fR;
     pfMax := fPktPrdt + fR;
  end;

var fMin0, fMax0, fMin1, fMax1,
    fD_C                      : real;
    vV                        : TPoint3;
    vTriEdge, vA              : array[0..2] of TPoint3;
    j,k                       : integer;
begin
   result:=false;
   vA[0] := Box.Axis[1];
   vA[1] := Box.Axis[2];
   vA[2] := Box.Axis[3];

   // direction of triangle normals
   vTriEdge[0] := VecSub3(v1, v0);
   vTriEdge[1] := VecSub3(v2, v0);

   vV := VecCross3(vTriEdge[0], vTriEdge[1]);

   fMin0 := VecDot3(vV, v0);
   fMax0 := fMin0;

   OBB_Projektion(Box, vV, fMin1, fMax1);

   if ( fMax1 < fMin0) or (fMax0 < fMin1 ) then exit;

   // directions of OBB planes
   // ========================
   // Axis 1:
   vV := Box.Axis[1];
   Tri_Projektion(v0, v1, v2, vV, fMin0, fMax0);
   fD_C := VecDot3(vV, Box.Middlepnt);
   fMin1 := fD_C - Box.depth[1];
   fMax1 := fD_C + Box.depth[1];
   if ( fMax1 < fMin0) or (fMax0 < fMin1 ) then exit;

   // Axis 2:
   vV := Box.Axis[2];
   Tri_Projektion(v0, v1, v2, vV, fMin0, fMax0);
   fD_C := VecDot3(vV, Box.Middlepnt);
   fMin1 := fD_C - Box.depth[2];
   fMax1 := fD_C + Box.depth[2];
   if ( fMax1 < fMin0) or (fMax0 < fMin1 ) then exit;

   // Axis 3:
   vV := Box.axis[3];
   Tri_Projektion(v0, v1, v2, vV, fMin0, fMax0);
   fD_C := VecDot3(vV, Box.Middlepnt);
   fMin1 := fD_C - Box.depth[3];
   fMax1 := fD_C + Box.depth[3];
   if ( fMax1 < fMin0) or (fMax0 < fMin1 ) then exit;

   vTriEdge[2] := VecSub3(vTriEdge[1], vTriEdge[0]);
   for j:=0 to 2 do
      for k:=0 to 2 do
        begin
          vV := VecCross3(vTriEdge[j], vA[k]);
          Tri_Projektion(v0, v1, v2, vV, fMin0, fMax0);
          OBB_Projektion(Box, vV, fMin1, fMax1);
          if (fMax1 < fMin0) or (fMax0 < fMin1) then exit;
        end;
   result:=true;
end;

function AsphyreCollisionTriAABB(v0, v1, v2 : TPoint3; Box : TBoxAABB) : boolean;
begin
  result := AsphyreCollisionTriOBB(v0, v1, v2, AsphyreAABBtoOBB(Box));
end;


///// Is given point in ellipse (x,y,z = different radius of the ellipse)
function AsphyrePointinEllipse(p : TPoint3; x, y, z : single; matWorld : TMatrix4) : boolean;
var mScale : TMatrix4;
    newposition : TPoint3;
    tmpVec : TVector4;
begin
  mScale := MatScale(Vector4(x,y,z,1));
  mScale := MatMul(mScale, matWorld);
  mScale := MatInverse(mScale);

  tmpVec := MatVecMul(Vec3to4(p), mScale);
  newposition.x := tmpVec.x/tmpVec.w;
  newposition.y := tmpVec.y/tmpVec.w;
  newposition.z := tmpVec.z/tmpVec.w;
  result := sqr(newposition.x) + sqr(newposition.y) + sqr(newposition.z) < 1;
end;

end.
