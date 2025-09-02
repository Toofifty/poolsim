class Polygon
{
  PVector points[];
  
  Polygon(PVector[] points)
  {
    this.points = points;
  }
  
  boolean pointInPolygon(PVector point)
  {
    boolean inside = false;
    for (int i = 0, j = points.length - 1; i < points.length; j = i++)
    {
      float xi = this.points[i].x, yi = this.points[i].y;
      float xj = this.points[j].x, yj = this.points[j].y;
      boolean intersect = ((yi > point.y) != (yj > point.y))
        && (point.x < (xj - xi) * (point.y - yi) / (yj - yi + 0.0f) + xi);
      if (intersect)
      {
        inside = !inside;
      }
    }
    return inside;
  }
  
  PVector[] computeOffsetVertices(float radius)
  {
    int n = this.points.length;
    PVector[] offsetVertices = new PVector[n];
    
    for (int i = 0; i < n; i++)
    {
      PVector prev = this.points[(i - 1 + n) % n];
      PVector curr = this.points[i];
      PVector next = this.points[(i + 1) % n];
      
      // edge normals
      PVector e1 = PVector.sub(curr, prev).normalize();
      PVector n1 = new PVector(-e1.y, e1.x);
      PVector mid1 = PVector.add(prev, curr).mult(0.5f);
      if (pointInPolygon(PVector.add(mid1, n1)))
      {
        n1.mult(-1);
      }
      
      PVector e2 = PVector.sub(next, curr).normalize();
      PVector n2 = new PVector(-e2.y, e2.x);
      PVector mid2 = PVector.add(curr, next).mult(0.5f);
      if (pointInPolygon(PVector.add(mid2, n2)))
      {
        n2.mult(-1);
      }
      
      // offset lines
      PVector a1 = PVector.add(prev, PVector.mult(n1, radius));
      PVector b1 = PVector.add(curr, PVector.mult(n1, radius));
      PVector a2 = PVector.add(curr, PVector.mult(n2, radius));
      PVector b2 = PVector.add(next, PVector.mult(n2, radius));
      
      PVector intersect = lineIntersection(a1, b1, a2, b2);
      if (intersect == null)
      {
        intersect = b1.copy();
      }
      
      offsetVertices[i] = intersect;
    }
    return offsetVertices;
  }
  
  Hit intersect(PVector ro, PVector rd, float radius)
  {
    Hit closest = null;
    PVector[] offsets = this.computeOffsetVertices(radius);
    int n = offsets.length;
    
    for (int i = 0; i < n; i++)
    {
      PVector a = offsets[i];
      PVector b = offsets[(i + 1) % n];
      
      PVector edge = PVector.sub(b, a);
      PVector normal = new PVector(-edge.y, edge.x).normalize();
      if (rd.dot(normal) >= 0)
      {
        normal.mult(-1);
      }
      
      // ray-segment intersection
      PVector v1 = PVector.sub(ro, a);
      PVector v2 = PVector.sub(b, a);
      PVector v3 = new PVector(-rd.y, rd.x);
      float denom = v2.dot(v3);
      if (abs(denom) < 1e-6)
      {
        continue;
      }
      
      float tLine = v2.cross(v1).z / denom;
      float u = v1.dot(v3) / denom;
      if (tLine >= 0 && u >= 0 && u <= 1)
      {
        PVector hitPoint = PVector.add(ro, PVector.mult(rd, tLine));
        Hit hit = new Hit(hitPoint, normal.copy(), tLine);
        if (closest == null || hit.t < closest.t)
        {
          closest = hit;
        }
      }
    }
    return closest;
  }
  
  void drawOffsetEdges(float radius)
  {
    PVector[] offsets = this.computeOffsetVertices(radius);
    stroke(0, 200, 200);
    strokeWeight(2);
    int n = offsets.length;
    for (int i = 0; i < n; i++)
    {
      PVector a = offsets[i];
      PVector b = offsets[(i + 1) % n];
      line(a.x, a.y, b.x, b.y);
    }
  }
}

class Hit
{
  PVector point, normal;
  float t; // ?
  
  Hit(PVector point, PVector normal, float t)
  {
    this.point = point;
    this.normal = normal;
    this.t = t;
  }
}

class Ray
{
  PVector origin, dir;
  List<PVector> path = new ArrayList<>();
  Ball hitBall = null;
  
  Ray(PVector origin, float angle)
  {
    this.origin = origin;
    this.dir = new PVector(cos(angle), sin(angle));
  }
  
  Ray(PVector origin, PVector dir)
  {
    this.origin = origin;
    this.dir = dir;
  }
  
  void cast(List<Polygon> polygons, List<Ball> balls, float radius, int maxBounces)
  {
    this.path.clear();
    this.path.add(this.origin.copy());
    PVector ro = this.origin.copy();
    PVector rd = this.dir.copy().normalize();
    
    for (int bounce = 0; bounce < maxBounces; bounce++)
    {
      Hit closestPolygonHit = null;
      for (Polygon polygon : polygons)
      {
        Hit hit = polygon.intersect(ro, rd, radius);
        if (hit != null 
          && (closestPolygonHit == null || hit.t < closestPolygonHit.t))
        {
          closestPolygonHit = hit;
        }
      }
      
      Hit ballHit = null;
      for (Ball ball : balls)
      {
        Hit hit = rayCircleIntersect(ro, rd, ball.position, ball.radius + radius);
        if (hit != null
          && (ballHit == null || hit.t < ballHit.t))
        {
          ballHit = hit;
          this.hitBall = ball;
        }
      }
      
      if (ballHit != null
        && (closestPolygonHit == null || ballHit.t < closestPolygonHit.t))
      {
        this.path.add(ballHit.point);
        return;
      }
      
      if (closestPolygonHit != null)
      {
        this.path.add(closestPolygonHit.point);
        rd = reflect(rd, closestPolygonHit.normal).normalize();
        ro = PVector.add(closestPolygonHit.point, PVector.mult(rd, 0.001f));
      }
      else
      {
        path.add(PVector.add(ro, PVector.mult(rd, 5000)));
        return;
      }
    }
  }
  
  void draw()
  {
    stroke(255, 200, 50);
    strokeWeight(2);
    noFill();
    
    for (int i = 1; i < this.path.size(); i++)
    {
      PVector a = this.path.get(i - 1);
      PVector b = this.path.get(i);
      
      line(a.x, a.y, b.x, b.y);
    }
    
    //beginShape(POINTS);
    //for (PVector point : this.path)
    //{
    //  vertex(point.x, point.y);
    //}
    //endShape(CLOSE);
  }
}

Hit rayCircleIntersect(PVector ro, PVector rd, PVector centre, float radius)
{
  PVector oc = PVector.sub(ro, centre);
  float b = 2 * oc.dot(rd);
  float c = oc.dot(oc) - radius * radius;
  float disc = b * b - 4 * c;
  if (disc < 0)
  {
    return null;
  }
  
  float t = (-b - sqrt(disc)) / 2.0;
  if (t < 0)
  {
    return null;
  }
  
  return new Hit(PVector.add(ro, PVector.mult(rd, t)), null, t);
}

PVector reflect(PVector dir, PVector normal)
{
  return dir.copy().sub(normal.copy().mult(2 * dir.dot(normal))).normalize();
}

PVector lineIntersection(PVector p1, PVector p2, PVector q1, PVector q2)
{
  float a1 = p2.y - p1.y, b1 = p1.x - p2.x, c1 = a1 * p1.x + b1 * p1.y;
  float a2 = q2.y - q1.y, b2 = q1.x - q2.x, c2 = a2 * q1.x + b2 * q1.y;
  float det = a1 * b2 - a2 * b1;
  if (abs(det) < 1e-6)
  {
    return null;
  }
  
  return new PVector((b2 * c1 - b1 * c2) / det, (a1 * c2 - a2 * c1) / det);
}
