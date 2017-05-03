#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

typedef struct {
	unsigned char r,g,b;
} color;

color** pixmap;
color currentColor;

const int width = 1920*2;
const int height = 1080*2;
const int squareSize = 880*2;
const int allowedRetries = 100000;
const double circleMargin = 0.005;
const double minBubbleSize = 0.0001;
const double maxBubbleSize = 0.25;

const color bg = (color){0x23,0x2c,0x33};
const color c1 = (color){0x7c,0x9f,0xa6};
const color c2 = (color){0x78,0xa0,0x90};
const color c3 = (color){0x99,0x73,0x6e};
const color c4 = (color){0xbf,0xb7,0xa1};

void putPixel(int x, int y);
void drawLine(int x0, int y0, int x1, int y1);
void drawCircle(int x, int y, int radius);

void putPixel(int x, int y) {
  if(x < 0 || y < 0 || x > width || y > height) return;
  pixmap[x][y] = currentColor;
}

void drawLine(int x0, int y0, int x1, int y1) {
  int dx = abs(x1-x0), sx = x0<x1 ? 1 : -1;
  int dy = abs(y1-y0), sy = y0<y1 ? 1 : -1; 
  int err = (dx>dy ? dx : -dy)/2, e2;
 
  for(;;){
    putPixel(x0,y0);
    if (x0==x1 && y0==y1) break;
    e2 = err;
    if (e2 >-dx) { err -= dy; x0 += sx; }
    if (e2 < dy) { err += dx; y0 += sy; }
  }
}


void plot4points( int cx, int cy, int x, int y) {
  drawLine(cx - x, cy + y, cx + x, cy+y);
  if (x != 0 && y != 0)
    drawLine(cx - x, cy - y, cx + x, cy-y);
}    

void fillCircle(int cx, int cy, int radius) {
	int error = -radius;
  int x = radius;
  int y = 0;

  while (x >= y) {
  	int lastY = y;
    error += y;
    y++;
    error += y;

     plot4points(cx, cy, x, lastY);

    if (error >= 0) {
      if (x != lastY)
        plot4points(cx, cy, lastY, x);

      error -= x;
      x--;
      error -= x;
    }
  }  
}

void drawCircle(int x, int y, int radius) {
	while(radius > 0) {
  int px = radius;
  int py = 0;
  int err = 0;

  while (px >= py) {
    drawLine(x+px, y+py, x-px, y-py);
    // putPixel(x + px, y + py);
    drawLine(x+py, y+px, x-py, y-px);
		// putPixel(x + py, y + px);
		drawLine(x-py, y+px, x+py, y-px);
    // putPixel(x - py, y + px);
		drawLine(x-px, y+py, x+px, y-py);
 		// putPixel(x - px, y + py);
		
		// putPixel(x - px, y - py);
    // putPixel(x - py, y - px);
    // putPixel(x + py, y - px);
    // putPixel(x + px, y - py);
		
    if (err <= 0) {
      py += 1;
      err += 2*py + 1;
    }
    if (err > 0) {
      px -= 1;
      err -= 2*px + 1;
    }
  }
  radius--;
  }
}

unsigned char uclerp(double d, unsigned char a, unsigned char b) {
  return ((double)1 - d) * (double)a + d * (double)b;
}

color lerp(double d, color a, color b) {
  return (color){uclerp(d, a.r, b.r), uclerp(d, a.g, b.g), uclerp(d, a.b, b.b)};
}

color bilerp(double x, double y, color a, color b, color c, color d) {
  color c1 = lerp(x, a, b);
  color c2 = lerp(x, c, d);
  return lerp(y, c1, c2);
}

typedef struct {
  double r, x, y;  
} bubble;



double dist(bubble a, bubble b) {
  double x = a.x-b.x;
  double y = a.y-b.y;
  return sqrt(x*x+y*y);
}

int intersects(bubble a, bubble b) {
  return dist(a,b) <= a.r+b.r+circleMargin;
}

double dblrand() {
	return (double)rand()/(double)RAND_MAX;
}

double delimRand(double a, double b) {return a+dblrand()*(b-a); }

typedef struct _bubbleNode {
  struct _bubbleNode* next;
  bubble b;
} bubbleNode;

void main() {
  pixmap = (color**)malloc(sizeof(color*)*width);
  for(int i = 0; i < width; i++) pixmap[i] = (color*)malloc(sizeof(color)*height);
  srand(time(NULL));
	
  currentColor = bg;
	for(int y = 0; y < height; y++) {
	  for(int x = 0; x < width; x++) {
			putPixel(x,y);
		}
	}

  /****/
  bubbleNode* b = (bubbleNode*)malloc(sizeof(bubbleNode));
  bubbleNode* first = b;
  bubbleNode* tail = b;

  double offsetx = (width-squareSize)/2;
  double offsety = (height-squareSize)/2;

  int retries = 0;
  while(1) {
    if(retries > allowedRetries)
      break;
    retries++;
    bubble b;
    b.r = delimRand(minBubbleSize, maxBubbleSize);
    b.x = delimRand(b.r, (double)1-b.r);
    b.y = delimRand(b.r, (double)1-b.r);
    
    int doesIntersect = 0;
    bubbleNode* itt = first;
    while(itt != tail) {
      if(intersects(itt->b, b)) {
        doesIntersect = 1;
        break;
      }
      itt = itt->next;
    }
    if(doesIntersect) continue;
    retries = 0;

    tail->b = b;
    tail->next = (bubbleNode*)malloc(sizeof(bubbleNode));
    tail = tail->next;

    double size = b.r*squareSize;
    currentColor = bilerp(b.x, b.y, c1,c2,c3,c4);
    fillCircle((int)(b.x*(double)squareSize+offsetx), (int)(b.y*(double)squareSize+offsety), size);
  }




  FILE* file = fopen("img.ppm", "w");
  
  fprintf(file, "P3\n%d %d\n255\n", width, height);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      fprintf(file, "%d ", pixmap[x][y].r);
      fprintf(file, "%d ", pixmap[x][y].g);
      fprintf(file, "%d ", pixmap[x][y].b);
    }
    fprintf(file, "\n");
  }

  fclose(file);
}

