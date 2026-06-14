from math import sin, cos, PI, degToRad

type
    Coordinate* = tuple[x: float, y: float]

    Vector* = tuple[x: float, y: float]

    Size* = tuple[w: float, h: float]

    Rotation* = distinct float

    TransformObject* = ref object of RootObj
        loc*: Coordinate = (x: 0.0, y: 0.0)
        rot*: Rotation = 0.Rotation
        parent*: TransformObject

proc `+`*(a: Coordinate, b: Coordinate): Coordinate =
    return (x:a.x + b.x, y:a.y + b.y)

proc `-`*(a: Coordinate, b: Coordinate): Coordinate =
    return (x:a.x - b.x, y:a.y - b.y)

proc getGlobalLocation*(self: TransformObject): Coordinate =
    if self.parent != nil:
        return self.loc + self.parent.getGlobalLocation()
    else:
        return self.loc

proc rotationCast(x: float): Rotation =
    if x > 360.0:
        return Rotation(x - 360.0)
    if x < 0.0:
        return Rotation(x + 360.0)
    return Rotation(x)

proc `+`*(a: Rotation, b: float): Rotation =
    return rotationCast((float)a + b)

proc `-`*(a: Rotation, b: float): Rotation =
    return rotationCast((float)a - b)

proc `*`*(a: Rotation, b: float): Rotation =
    return rotationCast((float)a * b)

proc `*`*(a: float, b: Rotation): Rotation =
    return rotationCast(a * (float)b)

proc `*`*(a: Rotation, b: Vector): Vector =
    return (x: float(a) * b.x, y: float(a) * b.y)

proc getVector*(a: Rotation): Vector =
    # Note: 0 degrees points vertically up with this system
    var radians = math.degToRad(float(a))
    return (x: math.sin(radians), y: -math.cos(radians))
