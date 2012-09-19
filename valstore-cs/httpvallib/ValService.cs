using System;
using System.IO;
using System.Net;
using System.Text;
using Kayak;
using Kayak.Framework;
using Owin;

namespace httpval
{
	public class ValService : KayakService
	{
		[Path("/")]
		public void Root()
		{
			Response.Write("<html><head></head><body><h3>value store</h3>");
			int v = Worker.Instance.Values.Count;
			if (v == 0) {
				Response.Write("<p>empty</p>");
			} else {
				Response.Write("<p>");
				Response.Write(v);
				Response.Write(" items</p>");
			}
			Response.Write("<a href='/debug'>/debug</a>");
			Response.Write("</body></html>");
		}
		
		[Path("/add")]
		public void Add()
		{
			if (Request["type"] == null)
			{
				Response.Write("fail: type missing");
				return;
			}
			if (Request["type"] == "")
			{
				Response.Write("fail: type empty");
				return;
			}
			if (Request["format"] == null)
			{
				Response.Write("fail: format missing");
				return;
			}
			if (Request["format"] == "")
			{
				Response.Write("fail: format empty");
				return;
			}
			if (Request["key"] == null)
			{
				Response.Write("fail: key missing");
				return;
			}
			if (Request["key"] == "")
			{
				Response.Write("fail: key empty");
				return;
			}

			string type = Request.QueryString["type"];
			string format = Request["format"];
			string key = Request["key"];
			string source = "http";

			string val = "";
			if (Request["value"] != null)
			{
				val = Request["value"];
			}

			Worker.Instance.Values.AddValue(type,format,key,val,source);
			Response.Write("ok");
		}
		
		[Path("/get")]
		public void Get()
		{
			if (Request["key"] == null)
			{
				Response.Write("fail: key missing");
				return;
			}
			if (Request["key"] == "")
			{
				Response.Write("fail: key empty");
				return;
			}

			string key = Request["key"];
			string val = Worker.Instance.Values.GetValue(key,"");
			Response.Write(val);
		}
		
		[Path("/getcached")]
		public void GetCached()
		{
			if (Request["key"] == null)
			{
				Response.Write("fail: key missing");
				return;
			}
			if (Request["key"] == "")
			{
				Response.Write("fail: key empty");
				return;
			}
			if (Request["type"] == null)
			{
				Response.Write("fail: type missing");
				return;
			}
			if (Request["type"] == "")
			{
				Response.Write("fail: type empty");
				return;
			}
			string key = Request["key"];
			string val = Worker.Instance.Values.GetValue(key,"");
			Response.Write(val);
			//Response.Write(DateTime.Now.ToString());
		}
		
		[Path("/debug")]
		public void Debug()
		{
			string d = Worker.Instance.Values.DumpValues();
			
			Response.Write(d);
		}
		
		[Path("/json")]
		public void Json()
		{
			string d = Worker.Instance.Values.DumpValuesJson();
			Response.Write(d);
		
		}
	}
}
