#include <cairo.h>
#include <gtk/gtk.h>

typedef struct _cairo_toy_font_face {
    char base[7*4];
    const char *family;
    cairo_bool_t owns_family;
    cairo_font_slant_t slant;
    cairo_font_weight_t weight;

    cairo_font_face_t *impl_face; /* The non-toy font face this actually uses */
} cairo_toy_font_face_t;

static gboolean
on_expose_event(GtkWidget *widget,
    GdkEventExpose *event,
    gpointer data)
{
  cairo_t *cr;
  
  printf("cr = gdk_cairo_create(widget->window);\n");
  cr = gdk_cairo_create(widget->window);
  printf("---> return status: %d \n", cairo_status(cr));
  
  printf("cairo_set_source_rgb(cr, 0.1, 0.1, 0.1); \n");
  cairo_set_source_rgb(cr, 0.1, 0.1, 0.1); 
  printf("---> return status: %d \n", cairo_status(cr));
  
  printf("cairo_select_font_face(...)\n");
  cairo_font_face_t *pft = cairo_select_font_face(cr, "STKaiti",
      CAIRO_FONT_SLANT_NORMAL,
      CAIRO_FONT_WEIGHT_BOLD);
  printf("---> return status: %d \n", cairo_status(cr));
  printf("---> fontface : %s \n", ((cairo_toy_font_face_t *) pft)->family );
  
  cairo_font_face_t *pff = cairo_get_font_face(cr);
  printf("---> fontface status: %d \n", cairo_font_face_status(pff) );
  
  printf("cairo_set_font_size(cr, 13);\n");
  cairo_set_font_size(cr, 13);
  printf("---> return status: %d \n", cairo_status(cr));
  
  cairo_move_to(cr, 20, 30);
  printf("cairo_show_text(...);\n");
  cairo_show_text(cr, "钓鱼岛是中国的！");  
  printf("---> return status: %d \n", cairo_status(cr));
  
  cairo_move_to(cr, 20, 60);
  cairo_show_text(cr, "They're all good but not the permanent one");
  
  cairo_move_to(cr, 20, 120);
  cairo_show_text(cr, "Who doesn't long for someone to hold");
  
  cairo_move_to(cr, 20, 150);
  cairo_show_text(cr, "Who knows how to love you without being told");
  cairo_move_to(cr, 20, 180);
  cairo_show_text(cr, "Somebody tell me why I'm on my own");
  cairo_move_to(cr, 20, 210);
  cairo_show_text(cr, "If there's a soulmate for everyone");
  
  cairo_destroy(cr);
  
  return FALSE;
}
  
  
  
int main (int argc, char *argv[])
{
  GtkWidget *window;
  
  gtk_init(&argc, &argv);
  
  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  
  g_signal_connect(window, "expose-event",
      G_CALLBACK(on_expose_event), NULL);
  g_signal_connect(window, "destroy",
      G_CALLBACK(gtk_main_quit), NULL);
  
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 420, 250); 
  gtk_window_set_title(GTK_WINDOW(window), "Soulmate");
  gtk_widget_set_app_paintable(window, TRUE);
  
  gtk_widget_show_all(window);
  
  gtk_main();
  
  return 0;
}
