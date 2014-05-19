//*********************************************************************
// librerías
//*********************************************************************
import netP5.*;
import oscP5.*;

import ketai.net.*;
import ketai.sensors.*;

import apwidgets.*;

//*********************************************************************
// variables globales
//*********************************************************************

// ESTADOS de la aplicación
final int CONECTANDO = 0, MAIN = 1, AYUDA1 = 2, AYUDA2 = 3;
final int AYUDA3 = 4, PUNTOS = 5, AJUSTES = 6, JUEGO = 7; 
final int PAUSE = 8, FIN = 9, MAX_ESTADOS = 10;

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
float acelerometroX, acelerometroY;
float giroscopoZ;
int botonIzqPulsado, botonDerPulsado;

// control de posición de joysticks
float joystickIzqX = 0.15*width;
float joystickIzqY = 0.8*height;
float joystickDerX = 0.85*width;
float joystickDerY = 0.8*height; 
boolean firstimeDer, firstimeIzq;

// puntuación
boolean[] aros = new boolean[100];
int contAros = 0;
boolean completo = true;
int puntos = 0;
double milis, tiempoJuego;
//Log log;

// música
APMediaPlayer musica1;
APMediaPlayer sonido1;
APMediaPlayer sonido2;


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
    firstimeDer = true;
    firstimeIzq = true;
    botonIzqPulsado = 0;
    botonDerPulsado = 0;
    
    // inicialización de sensores
    sensor = new KetaiSensor(this);
    sensor.start();
    
    // inicialización música
    musica1 = new APMediaPlayer(this);
    musica1.setMediaFile("musica/pokemon.mp3");  
    musica1.setLooping(true);
    musica1.setVolume(1.0, 1.0);
    
    sonido1 = new APMediaPlayer(this);
    sonido1.setMediaFile("musica/ascender.mp3");  
    sonido1.setLooping(true);
    sonido1.setVolume(1.0, 1.0);
    
    sonido2 = new APMediaPlayer(this);
    sonido2.setMediaFile("musica/descender.mp3");  
    sonido2.setLooping(true);
    sonido2.setVolume(1.0, 1.0);
    
    // fichero
    //log = new Log("puntuacion"); //Creamos el nuevo archivo
    
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
        if(musica)
          musica1.start();
          
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
            //Joystick der.
            image(imagen.vImagenes[5], 0.85*width, 0.8*height);
            //Joystick izq.
            image(imagen.vImagenes[5], 0.15*width, 0.8*height);
            
            if(mousePressed) {
                //joystick izquierdo pulsado
                if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                   mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                   mouseX > 0.15*width - imagen.vImagenes[6].width/2 &&
                   mouseX < 0.15*width + imagen.vImagenes[6].width/2) {
                  
                    if(firstimeIzq) {
                        firstimeIzq = false;
                        image(imagen.vImagenes[6], joystickIzqX, joystickIzqY);
                    }
                }
                else
                    image(imagen.vImagenes[6], joystickIzqX, joystickIzqY);

                if (!firstimeIzq) {
                    joystickIzqX += mouseX - pmouseX;
                    joystickIzqY += mouseY - pmouseY;
                    if (joystickIzqX > (0.15*width + imagen.vImagenes[6].width/2)){
                        joystickIzqX = 0.15*width + imagen.vImagenes[6].width/2;
                    }
                    else if (joystickIzqX < (0.15*width - imagen.vImagenes[6].width/2)) {
                        joystickIzqX = 0.15*width - imagen.vImagenes[6].width/2;
                    }
                    if (joystickIzqY > (0.8*height + imagen.vImagenes[6].height/2)){
                        joystickIzqY = 0.8*height + imagen.vImagenes[6].height/2;
                    }
                    else if (joystickIzqY < (0.8*height - imagen.vImagenes[6].height/2)) {
                        joystickIzqY = 0.8*height - imagen.vImagenes[6].height/2;
                    }
                    image(imagen.vImagenes[6], joystickIzqX, joystickIzqY);
                }
                
                //joystick derecho pulsado.
                if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                   mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                   mouseX > 0.85*width - imagen.vImagenes[6].width/2 &&
                   mouseX < 0.85*width + imagen.vImagenes[6].width/2) {
              
                    if(firstimeDer) {
                        firstimeDer = false;
                        image(imagen.vImagenes[6], joystickDerX, joystickDerY);
                    }
                }
                else
                    image(imagen.vImagenes[6], joystickDerX, joystickDerY);

                if (!firstimeDer) {
                    joystickDerX += mouseX - pmouseX;
                    joystickDerY += mouseY - pmouseY;
                    if (joystickDerX > (0.85*width + imagen.vImagenes[6].width/2)){
                        joystickDerX = 0.85*width + imagen.vImagenes[6].width/2;
                    }
                    else if (joystickDerX < (0.85*width - imagen.vImagenes[6].width/2)) {
                        joystickDerX = 0.85*width - imagen.vImagenes[6].width/2;
                    }
                    if (joystickDerY > (0.8*height + imagen.vImagenes[6].height/2)){
                        joystickDerY = 0.8*height + imagen.vImagenes[6].height/2;
                    }
                    else if (joystickDerY < (0.8*height - imagen.vImagenes[6].height/2)) {
                        joystickDerY = 0.8*height - imagen.vImagenes[6].height/2;
                    }
                    image(imagen.vImagenes[6], joystickDerX, joystickDerY);
                }
            }
            else {
                joystickDerX = 0.85*width;
                joystickDerY = 0.8*height;
                joystickIzqX = 0.15*width;
                joystickIzqY = 0.8*height;
                image(imagen.vImagenes[6], joystickDerX, joystickDerY);
                image(imagen.vImagenes[6], joystickIzqX, joystickIzqY);
                firstimeDer = true;
                firstimeIzq = true;
            }
            
            //envio de datos al PC
            OscMessage miMensaje1 = new OscMessage("datosJoysticks");
            miMensaje1.add(joystickIzqX);
            miMensaje1.add(joystickIzqY);
            miMensaje1.add(joystickDerX);
            miMensaje1.add(joystickDerY);
            oscP5.send(miMensaje1, ipRemota);
        
            // datos de los sensores
            text("Joystick Izquierdo: " + "\n" +
                 "x: " + nfp(joystickIzqX, 1, 3) + "\n" +
                 "y: " + nfp(joystickIzqY, 1, 3) + "\n\n" +
                 "Joystick Derecho: " + "\n" +
                 "x: " + nfp(joystickDerX, 1, 3) + "\n" +
                 "y: " + nfp(joystickDerY, 1, 3) + "\n\n" +
                 "Local IP Address: \n" + myIPAddress + "\n\n", width/2, height/2);
        }
        else {
          image(imagen.vImagenes[6], 0.2*width, 0.8*height);
          image(imagen.vImagenes[6], 0.8*width, 0.8*height);
          botonIzqPulsado = 0;
          botonDerPulsado = 0;
          if(mousePressed) {
            if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                mouseX > 0.2*width - imagen.vImagenes[6].width/2 &&
                mouseX < 0.2*width + imagen.vImagenes[6].width/2) {
              //boton GIRAR pulsado
              image(imagen.vImagenes[50], 0.2*width, 0.8*height);
              botonIzqPulsado = 1;
            }
              
            if(mouseY > 0.8*height - imagen.vImagenes[6].height/2 && 
                mouseY < 0.8*height + imagen.vImagenes[6].height/2 && 
                mouseX > 0.8*width - imagen.vImagenes[6].width/2 &&
                mouseX < 0.8*width + imagen.vImagenes[6].width/2) {
              //boton Subir/bajar pulsado
              image(imagen.vImagenes[50], 0.8*width, 0.8*height);
              botonDerPulsado = 1;
            }  
          }

          
          //envio de datos al PC
          OscMessage miMensaje2 = new OscMessage("datosAcelerometroGiroscopo");
          miMensaje2.add(acelerometroX);
          miMensaje2.add(acelerometroY);
          miMensaje2.add(giroscopoZ);
          miMensaje2.add(botonIzqPulsado);
          miMensaje2.add(botonDerPulsado);
          oscP5.send(miMensaje2, ipRemota);
      
          // datos de los sensores
          text("Acelerómetro: " + "\n" +
               "x: " + nfp(acelerometroX, 1, 3) + "\n" +
               "y: " + nfp(acelerometroY, 1, 3) + "\n\n" +
               "Giróscopo: " + "\n" +
               "z: " + nfp(giroscopoZ, 1, 3) +"\n\n" +
               "Boton izquierdo pulsado: " + botonIzqPulsado + "\n" +
               "Boton derecho pulsado: " + botonDerPulsado + "\n\n" +
               "Local IP Address: \n" + myIPAddress + "\n\n", width/2, height/2);
        }
        
        
        if(sonido)
        {
          if(joystickIzqY > 0.8*height || acelerometroX > 8)
            sonido1.start();
          else if (joystickIzqY < 0.8*height || acelerometroY < 2)
            sonido2.start();
          else {
            sonido1.pause();
            sonido2.pause();
          }
        }
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
        break;
      case FIN:
        for (int i = 0; i < contAros; i++) {
          if((i << 2) == 0)
            if(aros[i] != true)
              completo = false
        }
        
        if(completo)
        {
          for (int i = 0; i < contAros; i++) {
            if(aros[i] = true)
              puntos += 10;
          }
          image(imagen.vImagenes[49], 0.5*width, 0.5*height); 
        }
        else
          image(imagen.vImagenes[48], 0.5*width, 0.5*height); 
          
        completo = true;
        contAros = 0;
        puntos = 0;
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
  
  //log.close(); //cerrar el fichero
  exit();
}

void mouseReleased() {
  if(estado == CONECTANDO) {
    if(mouseY > 0.85*height - imagen.vImagenes[7].height/2 && 
        mouseY < 0.85*height + imagen.vImagenes[7].height/2 && 
        mouseX > 0.2*width - imagen.vImagenes[7].width/2 &&
        mouseX < 0.2*width + imagen.vImagenes[7].width/2) {
      //estado = MAIN; 
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
        mouseX < 0.45*width + imagen.vImagenes[19].width/2) {
      sonido = !sonido;
    }
    else if(mouseY > 0.45*height - imagen.vImagenes[13].height/2 && 
        mouseY < 0.45*height + imagen.vImagenes[13].height/2 && 
        mouseX > 0.45*width - imagen.vImagenes[13].width/2 &&
        mouseX < 0.45*width + imagen.vImagenes[13].width/2) {
      if(musica) {   
        musica1.pause();
        musica1.seekTo(0);
      }
      else
        musica1.start();
      musica = !musica;
    }
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
        mouseX < 0.95*width + imagen.vImagenes[19].width/2) {
      nivel = 3;
      cambiarEstadoPC(12);
    }
    else if(mouseY > 0.6*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.6*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.95*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.95*width + imagen.vImagenes[19].width/2) {
      nivel = 2;
      cambiarEstadoPC(11);
    }
    else if(mouseY > 0.75*height - imagen.vImagenes[19].height/2 && 
        mouseY < 0.75*height + imagen.vImagenes[19].height/2 && 
        mouseX > 0.95*width - imagen.vImagenes[19].width/2 &&
        mouseX < 0.95*width + imagen.vImagenes[19].width/2) {
      nivel = 1;
      cambiarEstadoPC(10);
    }
  }
  else if(estado == JUEGO) {
    if(mouseY > 0.15*height - imagen.vImagenes[15].height/2 && 
        mouseY < 0.15*height + imagen.vImagenes[15].height/2 && 
        mouseX > 0.1*width - imagen.vImagenes[15].width/2 &&
        mouseX < 0.1*width + imagen.vImagenes[15].width/2) {
      // envio de cambio de estado en PC a PAUSE
      cambiarEstadoPC(3);
      sonido1.pause();
      sonido2.pause();
      estado = PAUSE;
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
  else if (estado == FIN) {
    if(completo) {
      estado == MAIN;
      // envio de cambio de estado en PC a ESPERANDO INICIO JUEGO
      cambiarEstadoPC(1);
    }
    else {
      estado == JUEGO;
      // envio de cambio de estado en PC a JUEGO
      cambiarEstadoPC(2);
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
}

void onGyroscopeEvent(float x, float y, float z)
{
  giroscopoZ = z;
}

void oscEvent(OscMessage theOscMessage) {
  // El PC se ha conectado correctamente
  if (theOscMessage.checkTypetag("i")) {
    if(theOscMessage.get(0).intValue() == 2)
      //vibrar
      estado = estado;
    else
      estado = MAIN;
  }
  
  // Datos para calcular la puntuación
  if (theOscMessage.checkTypetag("ii")) {
    aros[theOscMessage.get(0).intValue()] = true;
    contAros++;
    if(theOscMessage.get(1).intValue() == 1) {
      estado = FIN;
    }
  }
}

void intToMensaje(int n, float altura) {
  int num;
  for(int i = 0; i != 0; i++) {
    num = n % 10;
    image(imagen.vImagenes[i+37], 0.1 * i + 0.3*width, altura*height);
    n = n/10;
  }  
}

