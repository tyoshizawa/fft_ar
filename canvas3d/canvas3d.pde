import processing.opengl.*;
 
int CELL_SIZE      = 20;
int BAND_NUM       = 40;
int SPECTRUM_NUM   = 32;

float cam_pos_len = BAND_NUM * CELL_SIZE;
float cam_pos_alpha = 30;
float cam_pos_theta = PI / 4;
int shift_mul = 1;


public void init() {
  /*frame.dispose();*/
  /*frame.setUndecorated(true); // works.*/

  // call PApplet.init() to take care of business
  super.init();
}

void setup()
{
  size(848,480,OPENGL);
  frame.setLocation(0,0);
  frame.setBackground(new java.awt.Color(0, 0, 0));
  frameRate(60);
  smooth();
  stroke(255);
}

void draw()
{
  move_cam();
  background(0);
  draw_bg();
}

void keyPressed()
{
  switch (keyCode){
  case 37:
    cam_pos_len += 5 * shift_mul;
    break;
  case 39:
    cam_pos_len -= 5 * shift_mul;
    break;
  case 38:
    cam_pos_theta -= PI/180 * shift_mul;
    break;
  case 40:
    cam_pos_theta += PI/180 * shift_mul;
    break;
  case 8:
    cam_pos_alpha -= 2 * shift_mul;
    break;
  case 32:
    cam_pos_alpha += 2 * shift_mul;
    break;
  case 16:
    shift_mul = 5;
    break;
  }
  println(keyCode);
}

void keyReleased()
{
  switch (keyCode){
  case 16:
    shift_mul = 1;
  }
}

void move_cam(){
  int x_bound = SPECTRUM_NUM * CELL_SIZE / 2;
  float cam_pos_l = (cam_pos_len + x_bound / 2) * sqrt(2) + cam_pos_alpha;
  float theta = atan(x_bound / cam_pos_len / 2) * 2;

  camera(cam_pos_l * cos(cam_pos_theta), cam_pos_l * sin(cam_pos_theta), 0,
      0, 0, 0, 1, -1, 0);
  perspective(theta, float(width)/float(height), 1, 2000);
}

void draw_bg()
{
  int x_bound = SPECTRUM_NUM * CELL_SIZE / 2;
  int z_bound = BAND_NUM * CELL_SIZE / 2;

  background(0);
  stroke(255);
  strokeWeight(0.4);

  // z pararel lines
  for(int i=0; i<=x_bound; i+=CELL_SIZE){
    // x plane
    line(i, 0, -z_bound, i, 0, z_bound);
    if (i != 0){
      // y plane
      line(0, i, -z_bound, 0, i, z_bound);
    }
  }
  // z parpendicular lines
  for(int i=-z_bound; i<=z_bound; i+=CELL_SIZE){
    // x plane
    line(0, 0, i, x_bound, 0, i);
    // y plane
    line(0, 0, i, 0, x_bound, i);
  }

}
