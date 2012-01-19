import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;

int CELL_SIZE      = 20;
int BAND_SIZE      = 5;
int BAND_NUM       = 40;
int SPECTRUM_NUM   = 24;
int BAND_HUE_START = 140;
int BAND_HUE_END   = 220;
float SPECTRUM_CST = 0.6;
int COUNT_MAX      = 20;
int COUNT_INVERT_R = 4;

int spc_offset     = (848 - BAND_NUM * CELL_SIZE) / 2;

int [][] spectrum = new int[BAND_NUM][SPECTRUM_NUM];

void setup()
{
  size(848, 480);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.linAverages(BAND_NUM);

  noStroke();
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(20);
  background(0);

  // initialize spectrum with 0
  reset_spectrum();
}


void draw()
{
  background(0);
  fft.forward(in.mix);
  float h;
  for(int i=0; i<BAND_NUM; i++)
  {
    // calculate this band's spetrum hight
    h = 0.0;
    for (int j=0; j<BAND_SIZE; j++)
    {
      h = max(h, fft.getBand(i*BAND_SIZE * j));
    }
    // draw current band cells
    h = h * SPECTRUM_CST;
    update_cell_count(i, h);
    draw_cells(i);
    increment_cell_count(i);
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
  return c >= 0 ? c : c/COUNT_INVERT_R;
}


void increment_cell_count(int i)
{
  Boolean higher_on = false;
  for (int j=SPECTRUM_NUM-1; j>=0; j--){
    if (spectrum[i][j] >= COUNT_MAX){
      if ( higher_on ) spectrum[i][j] = COUNT_MAX;
      else spectrum[i][j] = - COUNT_MAX * COUNT_INVERT_R;
    } else if(spectrum[i][j] != 0) {
      spectrum[i][j]++;
    }
    if (spectrum[i][j]>0) higher_on = true;
  }
}


void draw_cells(int i)
{
  for (int j=0; j<SPECTRUM_NUM; j++){
    int c = get_cell_normalized_count(i, j);
    if (c > 0){
      fill(BAND_HUE_START+(BAND_HUE_END-BAND_HUE_START)*i/BAND_NUM, 40+40*c/COUNT_MAX, 100);
    } else {
      fill(BAND_HUE_START+(BAND_HUE_END-BAND_HUE_START)*i/BAND_NUM, 80, -50*c/COUNT_MAX);
    }
    rect(spc_offset+i*CELL_SIZE, height-(j+1)*CELL_SIZE, CELL_SIZE-1, CELL_SIZE-1);
  }
}

