using Kayak;
using Kayak.Framework;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;

namespace httpval
{
	/// <summary>
	/// Description of Worker.
	/// </summary>
	public class Worker
	{
			private static Worker mInstance;
			private ValStore mValstore;
			private long mRequestsAdd;
			private long mRequestsGet;
			private long mRequestsAddNew;
			private long mRequestsAddUpdate;
			private bool mStarted;
			private int mPortHttp;
			private int mPortTcp;
			
			public static Worker Instance
			{
				get {
					if (mInstance == null)
					{
						mInstance = new Worker();
					}
					return mInstance;
				}
			}	
			
			private Worker()
			{
				mValstore = new ValStore();
				mRequestsGet = 0;
				mRequestsAdd = 0;
				mRequestsAddNew = 0;
				mRequestsAddUpdate = 0;
			}
			
			public void Start(int PortHTTP,int PortTCP)
			{
				if (mStarted) {
					return;
				}
				mStarted = true;
				mPortHttp = PortHTTP;
				mPortTcp = PortTCP;
				
				// HTTP
				KayakServer server = new KayakServer();
				server.UseFramework();
				server.Start(new IPEndPoint(IPAddress.Any,mPortHttp));
				
				// TCP
				ValTcpService ts = new ValTcpService(mPortTcp);
			
				DoLoop();
			}
		
				
		private void DoLoop()
		{
			while(true)
			{
				System.Threading.Thread.Sleep(360 * 1000);
				Values.HouseKeeping();
			}
		}
		
		public ValStore Values {
			get { return mValstore; }
			set { mValstore = value; }
		}
		
		public long RequestsAdd {
			get { return mRequestsAdd; }
			set { mRequestsAdd = value; }
		}
		
		public long RequestsAddNew {
			get { return mRequestsAddNew; }
			set { mRequestsAddNew = value; }
		}
		
		public long RequestsAddUpdate {
			get { return mRequestsAddUpdate; }
			set { mRequestsAddUpdate = value; }
		}
		
		public long RequestsGet {
			get { return mRequestsGet; }
			set { mRequestsGet = value; }
		}
	}
}
