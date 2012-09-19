using System;
using System.Text;
using System.Net.Sockets;
using System.Threading;
using System.Net;

namespace httpval
{

	public class ValTcpService
	{
		private TcpListener tcpListener;
	    private Thread listenThread;
	
	    public ValTcpService(int port)
	    {
	      this.tcpListener = new TcpListener(IPAddress.Any, port);
	      this.listenThread = new Thread(new ThreadStart(ListenForClients));
	      this.listenThread.Start();
	    }
	    
		private void ListenForClients()
		{
		  this.tcpListener.Start();
		
		  while (true)
		  {
		    //blocks until a client has connected to the server
		    TcpClient client = this.tcpListener.AcceptTcpClient();
		
		    Thread clientThread = new Thread(new ParameterizedThreadStart(HandleClientComm));
   			 clientThread.Start(client);
		  }
		}
		
		private void HandleClientComm(object client)
		{
		  TcpClient tcpClient = (TcpClient)client;
		  NetworkStream clientStream = tcpClient.GetStream();
		
		  byte[] message = new byte[4096];
		  int bytesRead;
		
		  IPEndPoint ipend = (IPEndPoint)tcpClient.Client.RemoteEndPoint;
		  string source = ipend.Address.ToString();
		  while (true)
		  {
		    bytesRead = 0;
		
		    try
		    {
		      //blocks until a client sends a message
		      bytesRead = clientStream.Read(message, 0, 4096);
		    }
		    catch
		    {
		      //a socket error has occured
		      break;
		    }
		
		    if (bytesRead == 0)
		    {
		      //the client has disconnected from the server
		      break;
		    }
		
		    //message has successfully been received
		    ASCIIEncoding encoder = new ASCIIEncoding();
		    string msg = encoder.GetString(message, 0, bytesRead);
		    
		    if (msg.Contains("cmd:add")) {
		    	foreach (string line in msg.Split('\n'))
		    	{
		    		string l = line;
		    		if (l.EndsWith("\r"))
		    		{
		    			l = l.Substring(0,l.Length-1);
		    		}
		    		if (l.StartsWith("data:")) {
		    			string[] p = l.Split(':');
		    			if (p.Length == 5)
		    			{
		    				Worker.Instance.Values.AddValue(p[1],p[2],p[3],p[4],source);
		    			}
		    		}
		    	}
		    	
		    }
		    
		  }
		
		  tcpClient.Close();
		}
	}
}
