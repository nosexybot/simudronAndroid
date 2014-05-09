//*********************************************************************
// librerías
//*********************************************************************
import netP5.*;
import oscP5.*;
import ketai.net.*;
import ketai.sensors.*;

//*********************************************************************
// variables globales
//*********************************************************************

// ESTADOS de la aplicación
final int CONECTANDO = 0, MAIN = 1, AYUDA1 = 2, AYUDA2 = 3;
final int AYUDA3 = 4, PUNTOS = 5, AJUSTES = 6, JUEGO = 7; 
final int PAUSE = 8, MAX_ESTADOS = 9;

// variables de control de juego
int estado, nivel /*1 = novato, 2 = aspirante, 3 = experto*/;
boolean sonido, musica, control /*true = sensor, false = joystick*/;

// control de tiempo  
long tiempo_ant;  // para intermitencia de mensaje "esperando conexión"
boolean blinker;  // estado de visibilidad del mensaje de conexión

// objeto para cargar las diferentes imágenes que conforman los estados y su control
Imagenes imagen;

// control de comunicaciones
OscP5 oscP5;
KetaiSensor sensor;
NetAddress ipRemota;
String myIPAddress, ipPCRemoto = "192.168.1.2";

// sensores
float acelerometroX, acelerometroY, acelerometroZ;
float giroscopoX, giroscopoY, giroscopoZ;

//*********************************************************************
// función de incialización
//*********************************************************************
void setup() {
    // Tamaño de la imagen de background y orientación
    size(displayWidth, displayHeight, P3D);
    orientation(LANDSCAPE);
    
    // inicialización del objeto imagen con ruta y tamaño del display
    imagen = new Imagenes(width, height);
    imageMode(CENTER);
    
    // establecimiento de estado de inicio de programa
    estado = CONECTANDO;
    sonido = true;
    musica = true;
    control = true;
    nivel = 1;
    
    // inicialización de sensores
    sensor = new KetaiSensor(this);
    sensor.start();
    
    // configuración inicial de los textos
    textAlign(CENTER, CENTER);
    textSize(24);
}

//*********************************************************************
// bucle de proceso de la aplicación
//*********************************************************************
void draw() {
    // control de tiempo actual
    long tiempo = millis();
    
    // fondo general para todas las pantallas de menú
    //background(imagen.background_blur);
    image(imagen.background_blur, width*0.5, height*0.5);
    
    // ESTADOS de la aplicación
    //---------------------------------------------------------------------------------------------
    switch(estado) {
      case CONECTANDO:
        // imagen de fondo inicial del juego
        //background(imagen.background);
        image(imagen.background, width*0.5, height*0.5);
        
        // control de intermitencia de mensaje "espera de conexión"
        if (tiempo - tiempo_ant > 1000) {
            blinker = !blinker;
            tiempo_ant = tiempo;
        }
        if (blinker){
            image(imagen.vImagenes[29],
                 width+10-(imagen.vImagenes[29].width*(width/ (float)imagen.background.width))*0.5,
                 20+(imagen.vImagenes[29].height*(height/ (float)imagen.background.height))*0.5);
        }
        
        // pulsadores de "conexión y "salida"
        image(imagen.vImagenes[9], 0.9*width, 0.85*height);
        image(imagen.vImagenes[7], 0.2*width, 0.85*height);
        
        // control de pulsador de "conexión" y "salida" cambiando imagen
        if(mousePressed) {
           if(mouseY > 0.85*height - imagen.vImagenes[7].height/2 && 
              mouseY < 0.85*height + imagen.vImagenes[7].height/2 && 
              mouseX > 0.2*width - imagen.vImagenes[7].width/2 &&
              mouseX < 0.2*width + imagen.vImagenes[7].width/2)
             image(imagen.vImagenes[8], 0.2*width, 0.85*height);
           else if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
              mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
              mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
              mouseX < 0.9*width + imagen.vImagenes[9].width/2)
             image(imagen.vImagenes[10], 0.9*width, 0.85*height);
        }
        break;
      case MAIN:
        image(imagen.vImagenes[32], 0.5*width, 0.5*height);  // menu principal
        image(imagen.vImagenes[17], 0.1*width, 0.85*height); // pulsador de "ajustes"
        image(imagen.vImagenes[9], 0.9*width, 0.85*height);  // pulsador de "salida"
        
        // control de pulsador de "ajustes" y"salida" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
               mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
               mouseX < 0.9*width + imagen.vImagenes[9].width/2)
              image(imagen.vImagenes[10], 0.9*width, 0.85*height);
            else if(mouseY > 0.85*height - imagen.vImagenes[17].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[17].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[17].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[17].width/2)
              image(imagen.vImagenes[18], 0.1*width, 0.85*height);
        }
        break;
      case PUNTOS:
        image(imagen.vImagenes[21], 0.5*width, 0.1*height);  // imagen "puntación"
        // Funcion que lee de fichero
        image(imagen.vImagenes[1], 0.1*width, 0.85*height);  // pulsador "atrás"
        
        // control de pulsador "atrás" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[1].width/2)
              image(imagen.vImagenes[2], 0.1*width, 0.85*height);
        }
        break;
      case AYUDA1:
        image(imagen.vImagenes[25], 0.55*width, 0.4*height);  // imagen "ayuda 1"
        image(imagen.vImagenes[1], 0.1*width, 0.85*height);  // pulsador "atrás"
        image(imagen.vImagenes[3], 0.9*width, 0.85*height);  // pulsador "siguiente"
        
        // control de pulsador de "atrás" y "siguente" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[3].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[3].height/2 &&
               mouseX > 0.9*width - imagen.vImagenes[3].width/2 &&
               mouseX < 0.9*width + imagen.vImagenes[3].width/2)
              image(imagen.vImagenes[4], 0.9*width, 0.85*height);
            else if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[1].width/2)
              image(imagen.vImagenes[2], 0.1*width, 0.85*height);
        }
        break;
      case AYUDA2:
        image(imagen.vImagenes[26], 0.55*width, 0.4*height);  // imagen "ayuda 2"
        image(imagen.vImagenes[1], 0.1*width, 0.85*height);  // pulsador "atrás"
        image(imagen.vImagenes[3], 0.9*width, 0.85*height);  // pulsador "siguiente"
        
        // control de pulsador de "atrás" y "siguente" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[3].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[3].height/2 &&
               mouseX > 0.9*width - imagen.vImagenes[3].width/2 &&
               mouseX < 0.9*width + imagen.vImagenes[3].width/2)
              image(imagen.vImagenes[4], 0.9*width, 0.85*height);
            else if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[1].width/2)
              image(imagen.vImagenes[2], 0.1*width, 0.85*height);
        }
        break;
      case AYUDA3:
        image(imagen.vImagenes[27], 0.55*width, 0.4*height);  // imagen "ayuda 3"
        image(imagen.vImagenes[1], 0.1*width, 0.85*height);  // pulsador "atrás"
        image(imagen.vImagenes[9], 0.9*width, 0.85*height);  // pulsador de "salida"
        
        // control de pulsador de "atrás" y "salida" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
               mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
               mouseX < 0.9*width + imagen.vImagenes[9].width/2)
              image(imagen.vImagenes[10], 0.9*width, 0.85*height);
            else if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[1].width/2)
              image(imagen.vImagenes[2], 0.1*width, 0.85*height);
        }
        break;
      case AJUSTES:
        image(imagen.vImagenes[23], 0.5*width, 0.1*height);  // imagen "ajustes"
        image(imagen.vImagenes[24], 0.55*width, 0.6*height); // imagen "menu de ajustes"
        image(imagen.vImagenes[1], 0.1*width, 0.85*height);  // pulsador "atrás"
        
        if(sonido)
          image(imagen.vImagenes[19], 0.45*width, 0.3*height);
        else
          image(imagen.vImagenes[20], 0.45*width, 0.3*height);
        if(musica)
          image(imagen.vImagenes[13], 0.45*width, 0.45*height);
        else
          image(imagen.vImagenes[14], 0.45*width, 0.45*height);
          
        if(control) {
          image(imagen.vImagenes[34], 0.5*width, 0.75*height);
          image(imagen.vImagenes[33], 0.5*width, 0.9*height);
        }
        else {
          image(imagen.vImagenes[33], 0.5*width, 0.75*height);
          image(imagen.vImagenes[34], 0.5*width, 0.9*height);
        }
        
        if(nivel == 1) {
          image(imagen.vImagenes[33], 0.95*width, 0.45*height);
          image(imagen.vImagenes[33], 0.95*width, 0.6*height);
          image(imagen.vImagenes[34], 0.95*width, 0.75*height);
        }
        else if(nivel == 2) {
          image(imagen.vImagenes[33], 0.95*width, 0.45*height);
          image(imagen.vImagenes[34], 0.95*width, 0.6*height);
          image(imagen.vImagenes[33], 0.95*width, 0.75*height);
        }
        else { //nivel == 3
          image(imagen.vImagenes[34], 0.95*width, 0.45*height);
          image(imagen.vImagenes[33], 0.95*width, 0.6*height);
          image(imagen.vImagenes[33], 0.95*width, 0.75*height);
        }
        
        // control de pulsador "atrás" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
               mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[1].width/2)
              image(imagen.vImagenes[2], 0.1*width, 0.85*height);
        }
        break;
      case JUEGO:
        image(imagen.vImagenes[15], 0.1*width, 0.15*height);  // pulsador "pause"
        if(!control) {
          image(imagen.vImagenes[5], 0.2*width, 0.8*height); //Joystick izq.
          image(imagen.vImagenes[6], 0.2*width, 0.8*height);
          
          image(imagen.vImagenes[5], 0.8*width, 0.8*height); //Joystick der.
          image(imagen.vImagenes[6], 0.8*width, 0.8*height);
        }
        else {
          image(imagen.vImagenes[6], 0.2*width, 0.8*height);
          image(imagen.vImagenes[6], 0.8*width, 0.8*height);
          if(mousePressed) {
            if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                mouseX > 0.2*width - imagen.vImagenes[6].width/2 &&
                mouseX < 0.2*width + imagen.vImagenes[6].width/2) {
              //boton GIRAR pulsado
              image(imagen.vImagenes[5], 0.2*width, 0.8*height);
            }
            if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                mouseX > 0.8*width - imagen.vImagenes[6].width/2 &&
                mouseX < 0.8*width + imagen.vImagenes[6].width/2) {
              //boton Subir/bajar pulsado
              image(imagen.vImagenes[5], 0.8*width, 0.8*height);
            }  
          }
        }
        
        //envio de datos al PC por funciones de eventos de sensores
        
        // datos de los sensores
        text("Acelerómetro: " + "\n" +
             "x: " + nfp(acelerometroX, 1, 3) + "\n" +
             "y: " + nfp(acelerometroY, 1, 3) + "\n" +
             "z: " + nfp(acelerometroZ, 1, 3) + "\n\n" +
             "Giróscopo: " + "\n" +
             "x: " + nfp(giroscopoX, 1, 3) + "\n" +
             "y: " + nfp(giroscopoY, 1, 3) + "\n" +
             "z: " + nfp(giroscopoZ, 1, 3) +"\n\nLocal IP Address: \n" + myIPAddress + "\n\n", width/2, height/2);
        
        // control de pulsador "atrás" cambiando imagen
        if(mousePressed) {
            if(mouseY > 0.15*height - imagen.vImagenes[15].height/2 && 
               mouseY < 0.15*height + imagen.vImagenes[15].height/2 && 
               mouseX > 0.1*width - imagen.vImagenes[15].width/2 &&
               mouseX < 0.1*width + imagen.vImagenes[15].width/2)
              image(imagen.vImagenes[16], 0.1*width, 0.15*height);
        }
        break;
      case PAUSE:
        //Se mantiene la imagen anterior del juego
        image(imagen.vImagenes[28], 0.5*width, 0.5*height);  // imagen menú "continuar - salir"
        //se en envia un pause al PC
        break;
    }
    //---------------------------------------------------------------------------------------------
}

//***********************************************************************************
// control de ordenes sobre pulsaciones de botón
//***********************************************************************************
void mouseDragged() {
  if(estado == JUEGO) {
  //movimiento del joystick
  }
}

void salir()
{
  // envio de cambio de estado en PC a CONECTANDO
  OscMessage miMensaje = new OscMessage("cambioEstado");
  miMensaje.add(0);
  oscP5.send(miMensaje, ipRemota);
  
  exit();
}

void mouseReleased() {
  if(estado == CONECTANDO) {
    if(mouseY > 0.85*height - imagen.vImagenes[7].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[7].height/2 && 
        mouseX > 0.2*width - imagen.vImagenes[7].width/2 &&
        mouseX < 0.2*width + imagen.vImagenes[7].width/2) {
      estado = MAIN; 
      // Llamada a la función de conexion
      initNetworkConnection();
      // envio de cambio de estado en PC a ESPERANDO INICIO JUEGO
      cambiarEstadoPC(1);
    }
    else if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
        mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
        mouseX < 0.9*width + imagen.vImagenes[9].width/2)
      salir();
  }
  else if(estado == MAIN) {
    if(mouseY > 0.5*height - imagen.vImagenes[32].height/2 && 
        mouseY < 0.5*height - imagen.vImagenes[32].height/6 &&
        mouseX > 0.5*width - imagen.vImagenes[32].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[32].width/2) {
      // envio de cambio de estado en PC a JUEGO
      cambiarEstadoPC(2);
      estado = JUEGO;
    }
    else if(mouseY > 0.5*height - imagen.vImagenes[32].height/6 && 
        mouseY < 0.5*height + imagen.vImagenes[32].height/6&&
        mouseX > 0.5*width - imagen.vImagenes[32].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[32].width/2)
      estado = PUNTOS;
    else if(mouseY > 0.5*height + imagen.vImagenes[32].height/6 && 
        mouseY < 0.5*height + imagen.vImagenes[32].height/2&&
        mouseX > 0.5*width - imagen.vImagenes[32].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[32].width/2)
      estado = AYUDA1;
    else if(mouseY > 0.85*height - imagen.vImagenes[17].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[17].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[17].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[17].width/2)
      estado = AJUSTES;
    else if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
        mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
        mouseX < 0.9*width + imagen.vImagenes[9].width/2)
      salir();
  }
  else if(estado == PUNTOS) {
    if(mouseY > 0.85*height - imagen.vImagenes[1].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[1].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[1].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[1].width/2)
      estado = MAIN;
  }
  else if(estado == AYUDA1 || estado == AYUDA2) {
    if(mouseY > 0.85*height - imagen.vImagenes[17].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[17].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[17].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[17].width/2)
      estado--;
    else if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
        mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
        mouseX < 0.9*width + imagen.vImagenes[9].width/2)
      estado++;
  }
  else if(estado == AYUDA3) {
    if(mouseY > 0.85*height - imagen.vImagenes[17].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[17].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[17].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[17].width/2)
      estado--;
    else if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
        mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
        mouseX < 0.9*width + imagen.vImagenes[9].width/2)
      estado = MAIN;
  }
  else if(estado == AJUSTES) {
    if(mouseY > 0.85*height - imagen.vImagenes[17].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[17].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[17].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[17].width/2)
      estado = MAIN;
    else if(mouseY > 0.3*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.3*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.45*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.45*width + imagen.vImagenes[19].width/2)
      sonido = !sonido;
    else if(mouseY > 0.45*height - imagen.vImagenes[13].height/2 && 
        mouseY < 0.45*height + imagen.vImagenes[13].height/2 && 
        mouseX > 0.45*width - imagen.vImagenes[13].width/2 &&
        mouseX < 0.45*width + imagen.vImagenes[13].width/2)
      musica = !musica;
    else if(mouseY > 0.75*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.75*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.5*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[19].width/2)
      control = true;
    else if(mouseY > 0.9*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.9*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.5*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[19].width/2)
      control = false;
    else if(mouseY > 0.45*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.45*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.95*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.95*width + imagen.vImagenes[19].width/2)
      nivel = 3;
    else if(mouseY > 0.6*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.6*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.95*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.95*width + imagen.vImagenes[19].width/2)
      nivel = 2;
    else if(mouseY > 0.75*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.75*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.95*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.95*width + imagen.vImagenes[19].width/2)
      nivel = 1;
  }
  else if(estado == JUEGO) {
    if(mouseY > 0.15*height - imagen.vImagenes[15].height/2 && 
        mouseY < 0.15*height + imagen.vImagenes[15].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[15].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[15].width/2) {
      // envio de cambio de estado en PC a PAUSE
      cambiarEstadoPC(3);
      estado = PAUSE;
    }
    if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
        mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
        mouseX > 0.2*width - imagen.vImagenes[6].width/2 &&
        mouseX < 0.2*width + imagen.vImagenes[6].width/2) {
      //GIRAR
    }
    if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
        mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
        mouseX > 0.8*width - imagen.vImagenes[6].width/2 &&
        mouseX < 0.8*width + imagen.vImagenes[6].width/2) {
      //Subir/bajar
    }
      
    
  }
  else if(estado == PAUSE) {
    if(mouseY > 0.5*height - imagen.vImagenes[28].height/2 && 
        mouseY < 0.5*height &&
        mouseX > 0.5*width - imagen.vImagenes[28].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[28].width/2) {
      // envio de cambio de estado en PC a JUEGO
      cambiarEstadoPC(2);
      estado = JUEGO;
    }
    else if(mouseY > 0.5*height && 
        mouseY < 0.5*height + imagen.vImagenes[28].height/2 &&
        mouseX > 0.5*width - imagen.vImagenes[28].width/2 &&
        mouseX < 0.5*width + imagen.vImagenes[28].width/2) {
      // envio de cambio de estado en PC a ESPERANDO INICIO JUEGO
      cambiarEstadoPC(1);
      estado = MAIN;
    }
  }
}

void cambiarEstadoPC(int estado) {
  OscMessage miMensaje = new OscMessage("cambioEstado");
  miMensaje.add(estado);
  oscP5.send(miMensaje, ipRemota);
}
//***********************************************************************************
// establecimiento de las comunicaciones
//***********************************************************************************
void initNetworkConnection() {
    oscP5 = new OscP5(this, 12000);
    ipRemota = new NetAddress(ipPCRemoto, 12000);
    myIPAddress = KetaiNet.getIP();
}

//***********************************************************************************
// atención a cambios en sensores y envio de datos a PC
//***********************************************************************************
void onAccelerometerEvent(float x, float y, float z)
{
  acelerometroX = x;
  acelerometroY = y;
  acelerometroZ = z;
  
  if (estado == JUEGO) {
    OscMessage miMensaje = new OscMessage("datosAcelerometro");
    miMensaje.add(acelerometroX);
    miMensaje.add(acelerometroY);
    miMensaje.add(acelerometroZ);
    miMensaje.add(1);
    //oscP5.send(miMensaje, ipRemota);
  }
}

void onGyroscopeEvent(float x, float y, float z)
{
  giroscopoX = x;
  giroscopoY = y;
  giroscopoZ = z;
  
  if (estado == JUEGO) {
    OscMessage miMensaje = new OscMessage("datosGiroscopo");
    miMensaje.add(giroscopoX);
    miMensaje.add(giroscopoY);
    miMensaje.add(giroscopoZ);
    //oscP5.send(miMensaje, ipRemota);
  }
}

void oscEvent(OscMessage theOscMessage) {
  // El PC se ha conectado correctamente
  if (theOscMessage.checkTypetag("i")) {
    estado = MAIN;
  }
}

