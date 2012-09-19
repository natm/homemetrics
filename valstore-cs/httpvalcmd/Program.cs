using System;
using httpval;

namespace httpvalcmd
{
	class Program
	{
		public static void Main(string[] args)
		{
			Console.WriteLine("Hello World!");
			
			Worker.Instance.Start(80,81);
			
			while(true)
			{
				
			}
		}
	}
}