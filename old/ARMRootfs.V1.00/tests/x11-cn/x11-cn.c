#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>
#include <locale.h>
 
int main(void) {
   Display *d;
   Window w;
   XEvent e;
   char *msg = "Hello, 你好，世界！Hello, World! ";
   char *strOut = (char *) malloc(255);
   memset(strOut, 0, 255);
   size_t l1 = strlen(msg);
   size_t l2 = 120;
   int s;
   
   if (!setlocale(LC_CTYPE, "")) {
   	printf("error setting locale \n");
   	return -1;
   }
   iconv_t convUTF8 = iconv_open("UTF-8", "GB2312");
   l1 = iconv(convUTF8, (char **) &msg, &l1, &strOut, &l2 );
   iconv_close(convUTF8);
   printf("你好\n");
   printf("msg=%s \n" , msg);
   printf("strOut=%s \n" , strOut);
   printf("l2=%d \n" , l2);
   int sz = 120 - l2;
 	fflush(stdout);
 	
   d = XOpenDisplay(NULL);
   if (d == NULL) {
      fprintf(stderr, "Cannot open display\n");
      exit(1);
   }
 
   s = DefaultScreen(d);
   w = XCreateSimpleWindow(d, RootWindow(d, s), 10, 10, 200, 200, 1,
                           BlackPixel(d, s), WhitePixel(d, s));
   XSelectInput(d, w, ExposureMask | KeyPressMask);
   XMapWindow(d, w);
   
   XftDraw *xftdraw = XftDrawCreate (d, w, DefaultVisual (d, DefaultScreen(d)), DefaultColormap (d, DefaultScreen(d)));
 
   XftColor xftColor;
   XRenderColor renderColor;
   renderColor.red = 0xEEEE;
   renderColor.green = 0xAAAA;
   renderColor.blue = 0xDDDD;
   renderColor.alpha = 0xFFFF;
   XftColorAllocValue (d, DefaultVisual (d, DefaultScreen(d)), DefaultColormap (d, DefaultScreen(d)), &renderColor, &xftColor);
 
 
 	XftPattern *pattern = XftPatternCreate();
 	XftPatternAddString( pattern, "family", "STKaiti,SimHei,Normal" );
 	XftPatternAddInteger( pattern, "pixelsize", 50 );
 	XftResult result;
 	XftFont *xftFont = XftFontOpenPattern( d, XftFontMatch(d, 1, pattern, &result ) );
 	
   while (1) {
      XNextEvent(d, &e);
      if (e.type == Expose) {
         XftDrawStringUtf8 (xftdraw, &xftColor, xftFont, 
              10, 50, strOut, sz );
      }
      if (e.type == KeyPress)
         break;
   }
 
   XCloseDisplay(d);
   return 0;
}
