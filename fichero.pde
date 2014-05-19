/*//Inicia clase Log
class Log {
  private PrintWriter output;  //Permite la creacion de archivos
  private BufferedReader reader;
  private String path = sketchPath;  //Variable para guardar ruta de archivo 
  private String fileName;  //Variable para el nombre del archivo
 
  //Constructor de la clase
  Log(String fileName) {
    this.fileName = fileName;  //Asigamos nombre del archivo
    if (!exist(this.fileName)) {  //comprobamos si ya existe el nombre del archivo con la funcion exist()
      output = createWriter(this.fileName); //Si no existe, se crea
      reader = createReader(this.fileName);
    }
  }
 
  //Crea una lista de los archivos existentes en el directorio actual
  /*private String[] listFileNames(String dir) {  //recibe como parametro la ruta actual
    File file = new File(dir);  //Crea un objeto de la clase File
    if (file.isDirectory()) {  //Comprobamos que sea un directorio y no un archivo
      String names[] = file.list();  //Cargamos la lista de archivos en el vector names[]
      return names;  //regresamos names[]
    } 
    else {
      return null;  //En caso de que sea un archivo se regresa null
    }
  }
 
  //Comprueba si el archivo ya existe
  private boolean exist(String fileName) {  //recibe como parametro el nombre del archivo
    String[] filenames = listFileNames(path);  //llama a la funcion listFileNames para obtener la lista de archivos
    for (int x=0; x<=filenames.length-1;x++) {  //Se comprueba por medio de un for la existencia del archivo, recorre todo el vector
      if (fileName.equals(filenames[x])) {  //Si el nombre de un archivo existente coincide con el que se propuso
        return true;  //Regresa verdadero
      }
    }
    return false;  //Regresa falso
  }
   
  //Cierra el archivo, para que sea utilizable
  public void close() {
    output.flush();  //Vaciamos buffer de escritura
    output.close();  //Cerramos el archivo
    reader.close();  //Cerramos el archivo
  }
 
  //Escribe datos nuevos
  public void write(String data) {
    output.println(data);  //Concatena los datos nuevos y asigna fin de linea
  }
  
  //Escribe datos nuevos
  public String read() {
    return reader.readLine();
  }
}//Termina clase*/

/*
int num;
  for(int i = 0; i != 0; i++) {
    num = n % 10;
    image(imagen.vImagenes[i+37], 0.1 * i + 0.3*width, altura*height);
    n = n/10;
  }  
*/
