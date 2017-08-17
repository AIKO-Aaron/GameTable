import java.io.*;
import java.net.*;
import java.util.regex.*;

// Wieso schrieb ich das ganze zeugs und benutze ned eifach en library? Ich weiss es Nöd!

public interface ReceiveEventHandler {
  public boolean onConnect(ServerClient client, String initialData); // return true to close the socket
  public void onReceive(ServerClient client, String data);
}

/**
 A single client
 */
public class ServerClient extends Thread {

  private Socket socket;
  private BufferedReader reader;
  private PrintWriter writer;
  private WebProcess parent;

  public ServerClient(WebProcess p, Socket s) {
    socket = s;
    parent = p;
    try {
      if (s != null) reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
      else reader = new BufferedReader(new InputStreamReader(System.in));
      if (s!= null) writer = new PrintWriter(s.getOutputStream(), true);
      else writer = new PrintWriter(System.out, true);
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
    start();
  }

  public void clearInBuffer() {
    try {
      while (reader.ready()) reader.readLine();
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
  }

  public String readNextLine() {
    try {
      return reader.readLine() + "\r\n";
    } 
    catch(IOException e) {
      e.printStackTrace();
    }
    return null;
  }

  public byte[] readData(int length) {
    byte[] db = new byte[length];
    int i = 0;
    try {

      while (i++ > 0) {
        db[i] = (byte) reader.read();
      }
    }
    catch(IOException e) {
      e.printStackTrace();
    }
    return db;
  }

  public void send(String s) {
    writer.write(s);
  }

  public void send(byte[] data) {
    writer.write(new String(data));
  }

  public void sendLine(String s) {
    send(s + "\r\n");
  }

  public void sendLine(byte[] s) {
    send(new String(s) + "\r\n");
  }

  public void sendAnswer(String data) {
    sendLine("HTTP/1.0 200 OK");
    sendLine("Content-Type: text/plain");
    sendLine("");
    sendLine(data);
  }

  public void close() {
    try {
      interrupt(); // Interrupt the reader to read --> join would hang, because reader blocks

      writer.close();
      reader.close();
      socket.close();
      parent.clients.remove(this);
    } 
    catch(Exception e) {
    }
  }

  public void run() {
    try {
      while (true) {
        parent.onReceive(this, reader.readLine() + "\r\n");
      }
    } 
    catch(IOException e) {
    }
  }
}

public class WebProcess extends Thread {

  public static final int PORT = 5415;

  private ServerSocket server;
  private ArrayList<ServerClient> clients = new ArrayList<ServerClient>();
  private String defaultIndex;
  private ReceiveEventHandler receiveHandler;

  public WebProcess(String defaultIndex, ReceiveEventHandler evtHandler) {
    this.defaultIndex = defaultIndex;
    receiveHandler = evtHandler;
    start(); // Autostart
  }

  public void run() {
    try {
      server = new ServerSocket(PORT);

      while (true) {
        clients.add(new ServerClient(this, server.accept()));
      }
    } 
    catch(IOException e) {
      e.printStackTrace();
      println(e);
    }
  }

  public void onReceive(ServerClient s, String message) {
    //TODO do something when we receive something...
    if (message.startsWith("GET")) { // Handle web-requests
      String path = message.substring(4).split(" ")[0];

      if (path.contains("?")) path = path.split("\\?")[0];

      if (path.equalsIgnoreCase("/")) path = defaultIndex;
      else if (path.startsWith("/")) path = path.substring(1);

      path = "web/" + path;

      println("GET --> " + path);

      String[] lines = loadStrings(path); // Load file at that path

      if (lines == null) {
        s.sendLine("HTTP/1.1 404 NOT_FOUND");
        s.close();
        return;
      }

      s.sendLine("HTTP/1.0 200 OK");
      s.sendLine("Content-Type: text/html");
      s.sendLine("\r\n");
      // s.sendLine("<html><button>Click me</button></html>");
      for (String data : lines) {
        s.sendLine(data);
      }

      s.close();
    } else if (message.startsWith("POST")) {
      // print(message);
      int length = 0;
      String l = s.readNextLine();
      while (!l.replace("\r", "").replace("\n", "").equals("")) {
        if (l.startsWith("Content-Length: ")) length = Integer.parseInt(l.substring(16).replace("\r\n", ""));
        l = s.readNextLine();
      }

      String data = s.readNextLine();
      while (data.length() < length) data += s.readNextLine();

      if (receiveHandler.onConnect(s, data.substring(0, data.length() - 2))) s.close();
    } else receiveHandler.onReceive(s, message);
  }
}