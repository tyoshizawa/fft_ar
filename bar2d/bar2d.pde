import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;

int HIST_NUM       = 25;
int BAND_NUM       = 200;
int BAND_HUE_START = 140;
int BAND_HUE_END   = 220;
int SPECTRUM_MAX   = 480;
int SPECTRUM_W     = 4;
int spc_offset     = (848 - BAND_NUM * SPECTRUM_W) / 2;

int history = 0;
int [][] spectrum = new int[BAND_NUM][HIST_NUM];

void setup()
{
  size(848, 480);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());

  noStroke();
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(30);
  background(0);

  // initialize spectrum with 0
  for (int i=0; i<BAND_NUM; i++)
  {
    for (int j=0; j<HIST_NUM; j++)
    {
      spectrum[i][j] = 0;
    }
  }
}


void draw()
{
  background(0);
  fft.forward(in.mix);
  int h;
  for(int i=0; i<BAND_NUM; i++)
  {
    // draw history
    for (int j=0; j<HIST_NUM; j++)
    {
      h = spectrum[i][j];
      fill(BAND_HUE_START+(BAND_HUE_END-BAND_HUE_START)*i/BAND_NUM, 80, 70, 100/HIST_NUM*2);
      rect(spc_offset+i*SPECTRUM_W, height-h, SPECTRUM_W-1, h);
    }
    // draw current
    h = int(fft.getBand(i) * 10);
    if (h>SPECTRUM_MAX) h=SPECTRUM_MAX;
    fill(BAND_HUE_START+(BAND_HUE_END-BAND_HUE_START)*i/BAND_NUM, 80, 100, 100);
    rect(spc_offset+i*SPECTRUM_W, height-h, SPECTRUM_W-1, h);
    // add history
    spectrum[i][history] = h;
  }
  history = (history + 1) % HIST_NUM;
}
