int gridSize = 10;
int zoomFactor = 1;

//Data Strorage
ArrayList<Point> points = new ArrayList();
ArrayList<Point> viewPort = new ArrayList();
ArrayList<Point> hull =new ArrayList();
ArrayList<Point> p =new ArrayList();
//End Data Strorage

//Point Class
public class Point {
  float x, y;
  boolean visible;
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
    this.visible = true;
  }
}
//End Point Class

//Color Class
public class Color {
  int r, g, b, a;
  public Color(int r, int g, int b, int a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  public Color(int r, int g, int b) {
    this(r, g, b, 255);
  }
}
//End Color Class

//Draw Coordinate System
void createGrid() {
  //Text Config
  fill(0, 128, 192);
  float textOffSide = gridSize / 8;
  textAlign(RIGHT, TOP);
  textSize(gridSize / 3);
  //Line Config
  stroke(0, 128, 192);
  //Draw Coordinate System
  for (int y = -height / 2, index = height / (gridSize * 2); 
    y <= height / 2; y += gridSize) {
    strokeWeight(y == 0 ? 1.2 : 0.3);
    text(index--, -textOffSide, y + textOffSide);
    ellipseMode(RADIUS);
    ellipse(0, y, gridSize / 15, gridSize / 15);
    line(-width / 2, y, width / 2, y);
  }
  for (int x = -width / 2, index = -width / (gridSize * 2); 
    x <= width / 2; x += gridSize) {
    strokeWeight(x == 0 ? 1.2 : 0.3);
    text(index++, x - textOffSide, textOffSide);
    ellipseMode(RADIUS);
    ellipse(x, 0, gridSize / 15, gridSize / 15);
    line(x, -height / 2, x, height / 2);
  }
}
//End Draw Coordinate System

//Zoom Coordinate System
float clamp(float val, float min, float max) {
  return val < min ? min : val > max ? max : val;
}

void mouseWheel(MouseEvent event) {
  zoomFactor = (int)clamp(zoomFactor - event.getCount(), 1, 4);
  gridSize = 10 * zoomFactor;
}
//End Zoom Coordinate System

//Add Point When Mouse Clicked
void mouseClicked() {
  float x = (mouseX - width / 2.0) / gridSize;
  float y = -(mouseY - height / 2.0) / gridSize;
  points.add(new Point(x, y));
}
//End Add Point When Mouse Clicked

void keyPressed() {
  if (key == 'v') {
    float x = (mouseX - width / 2.0) / gridSize;
    float y = -(mouseY - height / 2.0) / gridSize;
    viewPort.add(new Point(x, y));
  }
  if (key == 'c') {
    hull.clear();
  }
  if (key == 'x') {
    viewPort.clear();
  }
  if (key == 'p') {
    pri(p);
    println("selesai");
  }
   
}

//Draw Point on Screen
void drawPoint(ArrayList<Point> points_, Color color_) {
  Color defaultColor = new Color(0, 0, 100);
  for (Point point : points_) {
    float radius = clamp(gridSize / 12, 0.75, 5);
    Color c = point.visible ? color_ : defaultColor;
    fill(c.r, c.g, c.b, c.a);
    noStroke();
    ellipse(point.x * gridSize, point.y * gridSize, radius, radius);
    printLabel(point.x, point.y, color_);
  }
}

void printLabel(float x, float y, Color color_) {
  textSize(gridSize / 3);
  pushMatrix();
  fill(color_.r, color_.g, color_.b, color_.a);
  scale(1, -1);
  text("(" +nfc(x, 2) +", " +nfc(y, 2) +")", x * gridSize, -y * gridSize);
  popMatrix();
}
//End Draw Point on Screen

//Draw Polygon From Points
void drawPolygon(ArrayList<Point> points, Color color_) {
  if (!points.isEmpty()) {
    pushMatrix();
    stroke(color_.r, color_.g, color_.b, color_.a);
    strokeWeight(1.2);
    for (int i = 0; i < points.size() - 1; i++) {
      Point p1 = points.get(i);
      Point p2 = points.get(i + 1);
      line(p1.x * gridSize, p1.y * gridSize, p2.x * gridSize, p2.y * gridSize);
    }

    Point start = points.get(0);
    Point end = points.get(points.size() - 1);
    line(start.x * gridSize, start.y * gridSize, end.x * gridSize, end.y * gridSize);
    popMatrix();
  }
}

int orientation(Point p, Point q, Point r) {
  float val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

  if (val == 0) return 0;
  return (val > 0)? 1: 2;
}

ArrayList<Point> convexHull(ArrayList<Point> points) {
  if (points.size() < 3) return points;
  ArrayList<Point> hull = new ArrayList();

  int l = 0;
  for (int i = 1; i < points.size(); i++)
    if (points.get(i).x < points.get(l).x)
      l = i;

  int p = l, q;
  do {
    hull.add(points.get(p));
    q = (p + 1) % points.size();

    for (int i = 0; i < points.size(); i++) {
      if (orientation(points.get(p), points.get(i), points.get(q))== 2)
        q = i;
    } 
    p = q;
  } while (p != l); 
  return hull;
}
//End Draw Polygon From Points

//Draw line
void drawLine(float m, float c, Color color_) {
  pushMatrix();
  stroke(color_.r, color_.g, color_.b, color_.a);
  strokeWeight(1.2);
  float x = width / 2;
  line(-x, lineEq(m, -x, c), x, lineEq(m, x, c));
  popMatrix();
}

float lineEq(float m, float x, float c) {
  return m * x + (c * gridSize);
}
//End Draw Line

float x_intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float num = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4);
  float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  return num/den;
}

float y_intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float num = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4);
  float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  return num/den;
}

ArrayList<Point> suthHodgClip(ArrayList<Point> polygonPoints_, ArrayList<Point> clipperPoints) {
  ArrayList<Point> polygonPoints = new ArrayList<Point>(polygonPoints_);
  for (int i = 0; i < clipperPoints.size(); i++) {
    int k = (i+1) % clipperPoints.size();
    polygonPoints_ = clip(polygonPoints_, clipperPoints.get(i), clipperPoints.get(k));
  }
  return polygonPoints_;
}

ArrayList<Point> clip(ArrayList<Point> polygonPoints, Point clipperPointA, Point clipperPointB) {
  ArrayList<Point> new_points = new ArrayList<Point>();
  for (int i = 0; i < polygonPoints.size(); i++) {

    int k = (i+1) % polygonPoints.size();
    Point polygonPointA = polygonPoints.get(i);
    Point polygonPointB = polygonPoints.get(k);
    float ix = polygonPointA.x, iy = polygonPointA.y;
    float kx = polygonPointB.x, ky = polygonPointB.y;

    float i_pos = (clipperPointB.x - clipperPointA.x) * (iy - clipperPointA.y) - (clipperPointB.y - clipperPointA.y) * (ix - clipperPointA.x);
    float k_pos = (clipperPointB.x - clipperPointA.x) * (ky - clipperPointA.y) - (clipperPointB.y - clipperPointA.y) * (kx - clipperPointA.x);

    if (i_pos < 0 && k_pos < 0) {
      new_points.add(new Point(kx, ky));
    } else if (i_pos >= 0 && k_pos < 0) {
      float intersect_x = x_intersect(clipperPointA.x, clipperPointA.y, clipperPointB.x, clipperPointB.y, ix, iy, kx, ky);
      float intersect_y = y_intersect(clipperPointA.x, clipperPointA.y, clipperPointB.x, clipperPointB.y, ix, iy, kx, ky);
      new_points.add(new Point(intersect_x, intersect_y));
      new_points.add(new Point(kx, ky));
    } else if (i_pos < 0 && k_pos >= 0) {
      float intersect_x = x_intersect(clipperPointA.x, clipperPointA.y, clipperPointB.x, clipperPointB.y, ix, iy, kx, ky);
      float intersect_y = y_intersect(clipperPointA.x, clipperPointA.y, clipperPointB.x, clipperPointB.y, ix, iy, kx, ky);
      new_points.add(new Point(intersect_x, intersect_y));
  } else {
        
    }
  }
  return new_points;
}


void setup() {
  size(1200, 720);
}

int visibility=0;
void draw() {
  background(255);
  translate(width/ 2, height/ 2);
  createGrid();
  scale(1, -1);
  //clipPoints(viewPort, points);
  drawPoint(viewPort, new Color(0, 200, 0));
  drawPolygon(viewPort, new Color(0, 200, 0));

  
   hull = convexHull(points);
   if(visibility==0){
  drawPoint(points, new Color(255, 0, 0));
  drawPolygon(hull, new Color(255, 0, 0)); 
   }
  // hull = suthHodgClip(hull, viewPort);
  
  //////p = convexHull(p);
  // drawPoint(hull, new Color(255, 0, 0));
  // hull = convexHull(hull);
   
  // drawPolygon(hull, new Color(255, 0, 0));
   
  //hull = clipPolygon(hull);
  //print(viewPort.size()+"\n");
  // drawLine(2, 3, new Color(255, 155, 100));
}
void pri(ArrayList<Point> points_){
for (Point point : points_) {
    float radius = clamp(gridSize / 12, 0.75, 5);
    println(point.x, point.y);
  }
  visibility=1;
  p = suthHodgClip(hull, viewPort);
  ////p = convexHull(p);
   drawPoint(p, new Color(0, 0, 0));
   p = convexHull(p);
   drawPolygon(p, new Color(0, 0, 0));
}