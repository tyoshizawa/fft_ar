import processing.opengl.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;

int CELL_SIZE      = 40;
int CELL_HEIGHT    = 40;
int BAND_NUM       = 20;
int BAND_SIZE      = 10;
int SPECTRUM_NUM   = 16;
int BAND_HUE_START = 140;
int BAND_HUE_END   = 220;
int COUNT_MAX      = 15;
int COUNT_INVERT_R = 4;
float SPECTRUM_CST = 0.5;
// base color 0, 0, 50

Boolean started     = false;
float cam_pos_len   = BAND_NUM * CELL_SIZE;
float cam_pos_alpha = 30;
float cam_pos_theta = PI / 4;
int shift_mul       = 1;
int [][] spectrum   = new int[BAND_NUM][SPECTRUM_NUM];

void setup()
{
  size(848,480,OPENGL);
  frameRate(60);
  smooth();
  rectMode(CORNER);

  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.linAverages(BAND_NUM);

  colorMode(HSB, 360, 100, 100);

  // initialize spectrum with 0
  reset_spectrum();
}


void draw()
{
  if (started){
    float h;
    fft.forward(in.mix);
    move_cam();
    draw_bg(false);
    for(int i=0; i<BAND_NUM; i++)
    {
      // calculate this band's spetrum hight
      h = 0.0;
      for (int j=0; j<BAND_SIZE; j++)
      {
        h += fft.getBand(i*BAND_SIZE * j);
      }
      // draw current band cells
      h = h * SPECTRUM_CST;
      update_cell_count(i, h);
      draw_cells(i);
      increment_cell_count(i);
    }
  } else {
    move_cam();
    draw_bg(true);
  }

}


void keyPressed()
{
  if (started) return;
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
  case 10:
    started = true;
    break;
  case 16:
    shift_mul = 5;
    break;
  }
}


void keyReleased()
{
  if (started) return;
  switch (keyCode){
  case 16:
    shift_mul = 1;
  }
}

void reset_spectrum()
{
  for (int i=0; i<BAND_NUM; i++)
  {
    for (int j=0; j<SPECTRUM_NUM; j++)
    {
      spectrum[i][j] = 0;
    }
  }
}


void update_cell_count(int i, float h)
{
  for (int j=0; j<int(h) && j<SPECTRUM_NUM; j++) {
    spectrum[i][j] = abs(get_cell_normalized_count(i, j)) + 1;
  }
}


int get_cell_normalized_count(int i, int j)
{
  int c = spectrum[i][j];
  c =  c >= 0 ? c : c/COUNT_INVERT_R;
  if (c > COUNT_MAX) return COUNT_MAX;
  if (c < -COUNT_MAX) return -COUNT_MAX;
  return c;
}


void increment_cell_count(int i)
{
  Boolean higher_on = false;
  for (int j=SPECTRUM_NUM-1; j>=0; j--){
    if (spectrum[i][j] >= COUNT_MAX){
      if ( higher_on ) spectrum[i][j] = COUNT_MAX;
      else spectrum[i][j] = - COUNT_MAX * COUNT_INVERT_R;
      /*spectrum[i][j] = - COUNT_MAX * COUNT_INVERT_R;*/
    } else if(spectrum[i][j] != 0) {
      spectrum[i][j]++;
    }
    if (spectrum[i][j]>0) higher_on = true;
  }
}


void move_cam(){
  int x_bound = SPECTRUM_NUM * CELL_SIZE / 2;
  float cam_pos_l = (cam_pos_len + x_bound / 2) * sqrt(2) + cam_pos_alpha;
  float theta = atan(x_bound / cam_pos_len / 2) * 2;
  float cam_pos_x = cam_pos_l * cos(cam_pos_theta);
  float cam_pos_y = cam_pos_l * sin(cam_pos_theta);

  camera(cam_pos_x, cam_pos_y, 0, 0, 0, 0, 1, -1, 0);
  perspective(theta, float(width)/float(height), 1, 4000);

  // lighting
  ambientLight(50, 30, 50);
  directionalLight(0,0,60,-1,-1.5,-1);
  pointLight(0,0,50,cam_pos_x * 2, cam_pos_y * 2, 0);
  spotLight(0,20,30, cam_pos_x * 2, cam_pos_y * 2, 0, -1, -1, 0, PI/4, 10);
}


void draw_bg(Boolean calib)
{
  int x_bound = SPECTRUM_NUM * CELL_SIZE / 2;
  int z_bound = BAND_NUM * CELL_SIZE / 2;

  background(0);

  if (calib) {
    stroke(255);
    // z pararel lines
    for(int i=0; i<=x_bound; i+=CELL_SIZE * 2){
      if (i == 0){
        stroke(0,100,100);
        strokeWeight(3);
        line(0, i, -z_bound, 0, i, z_bound);
        stroke(255);
        strokeWeight(1);
      } else {
        // x plane
        line(i, 0, -z_bound, i, 0, z_bound);
        // y plane
        line(0, i, -z_bound, 0, i, z_bound);
      }
    }
    // z parpendicular lines
    for(int i=-z_bound; i<=z_bound; i+=CELL_SIZE * 2){
      // x plane
      line(0, 0, i, x_bound, 0, i);
      // y plane
      line(0, 0, i, 0, x_bound, i);
    }
  } else {
    noStroke();
    // bg
    fill(0, 0, 50);
    pushMatrix();
    rotateX(-PI/2);
    // x plane
    rect(0, -z_bound - 200, x_bound + 200, z_bound * 2 + 400);
    rotateY(-PI/2);
    // y plane
    rect(0, -z_bound - 200, x_bound + 200, z_bound * 2 + 400);
    popMatrix();
    // z axis
    line(0.5, 0.5, -z_bound, 1, 1, z_bound);
  }
}


void draw_cells(int i)
{
  int z = (i - BAND_NUM / 2) * CELL_SIZE;
  stroke(0,0,50);
  pushMatrix();
  translate(-CELL_SIZE / 2, - CELL_HEIGHT / 2, z + CELL_SIZE / 2);
  for (int j=0; j<SPECTRUM_NUM; j++){
    int c = get_cell_normalized_count(i, j);
    float count_racio = float(abs(c)) / COUNT_MAX;
    int hue = BAND_HUE_START+(BAND_HUE_END-BAND_HUE_START)*i/BAND_NUM;
    // set color
    if (c > 0){
      fill(hue, 90, 80 + 20 * count_racio);
    } else {
      fill(hue, 20 * count_racio, 50 + 5 * count_racio);
    }
    if (j < SPECTRUM_NUM / 2) {
      // x plane
      translate(CELL_SIZE, 0, 0);
      pushMatrix();
      translate(0, CELL_HEIGHT * abs(count_racio), 0);
      box(CELL_SIZE, CELL_HEIGHT, CELL_SIZE);
      popMatrix();
    } else {
      if (j == SPECTRUM_NUM / 2){
        translate(-SPECTRUM_NUM/2 * CELL_SIZE -(CELL_HEIGHT - CELL_SIZE) / 2, CELL_SIZE, 0);
        box(CELL_SIZE);
      } else {
        // y plane
        translate(0, CELL_SIZE, 0);
        pushMatrix();
        translate(CELL_HEIGHT * abs(count_racio),0, 0);
        box(CELL_HEIGHT, CELL_SIZE, CELL_SIZE);
        popMatrix();
      }
    }
  }
  popMatrix();
}

