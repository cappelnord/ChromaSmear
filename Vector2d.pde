class Vector2d {
  public double x;
  public double y;
  
  public Vector2d(double a, double b) {
    x = a;
    y = b;
  }
  
  public Vector2d(double hue) {
    double value = hue / 255.0 * PI * 2.0;
    x = sin((float) value);
    y = cos((float) value);
  }
  
  public void add(Vector2d other) {
    x += other.x;
    y += other.y;
  }
  
  public void sub(Vector2d other) {
    x -= other.x;
    y -= other.y;
  }
  
  public void div(double d) {
    x = x / d;
    y = y / d;
  }
  
  public float radius() {
    return dist((float) x, (float) y, 0.0, 0.0);
  }
  
  public float hue() {
    float angle = atan2((float) x, (float) y);
    if(angle < 0) angle = angle + (2.0 * PI);
    angle = angle / (2.0 * PI) * 255;
    
    return angle;
  }
}
