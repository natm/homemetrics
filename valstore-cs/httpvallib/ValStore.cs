using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace httpval
{
	/// <summary>
	/// Description of ValStore.
	/// </summary>
	public class ValStore
	{
		private List<string> mIntKeys;
		private Dictionary<string,DateTime> mExpiries;
		private Dictionary<string,DateTime> mAdded;
		private Dictionary<string,DateTime> mUpdated;
		private Dictionary<string,long> mUpdates;
		private Dictionary<string,long> mRetrieved;
		private Dictionary<string,string> mValues;
		private Dictionary<string,string> mKeys;
		private Dictionary<string,string> mAddedSource;
		private Dictionary<string,string> mUpdatedSource;
		
		const int DefaultExpirySecs = 900;
		
		public ValStore()
		{
			mIntKeys = new List<string>();
			mAdded = new Dictionary<string, DateTime>();
			mExpiries = new Dictionary<string, DateTime>();
			mUpdated = new Dictionary<string, DateTime>();
			mUpdates = new Dictionary<string, long>();
			mRetrieved = new Dictionary<string, long>();
			mValues = new Dictionary<string, string>();
			mKeys = new Dictionary<string, string>();
			mAddedSource = new Dictionary<string, string>();
			mUpdatedSource = new Dictionary<string, string>();
		}
		
		public void AddValue(string type, string format, string key, string val, string source)
		{
			Worker.Instance.RequestsAdd++;
			string ik = FormatIntKey(type,format,key);
			DateTime expires = DateTime.Now + new TimeSpan(0,0,DefaultExpirySecs);
			string act = "";
			if (mIntKeys.Contains(ik))
			{
				// exists, update existing value and update expiry
				mValues[ik] = val;
				mExpiries[ik] = expires;
				mUpdates[ik]++;
				mUpdated[ik] = DateTime.Now;
				mUpdatedSource[ik] = source;
				act = "Updated";
				Worker.Instance.RequestsAddUpdate++;
			} else {
				// new
				mIntKeys.Add(ik);
				mValues.Add(ik,val);
				mExpiries.Add(ik,expires);
				mAdded.Add(ik,DateTime.Now);
				mUpdated.Add(ik,DateTime.Now);
				mKeys.Add(ik,key);
				mUpdates.Add(ik,0);
				mRetrieved.Add(ik,0);
				mAddedSource.Add(ik,source);
				mUpdatedSource.Add(ik,source);
				act = "Added";
				Worker.Instance.RequestsAddNew++;
			}
			Console.WriteLine("{2} {0} expires {1}",ik,expires,act);
		}
		
		
		public string GetValue(string key, string defaultval)
		{
			Worker.Instance.RequestsGet++;
			switch (key) {
				case "internal_requestsget":
					return Worker.Instance.RequestsGet.ToString();
				case "internal_requestsadd":
					return Worker.Instance.RequestsAdd.ToString();
				case "internal_requestsaddnew":
					return Worker.Instance.RequestsAddNew.ToString();
				case "internal_requestsaddupdate":
					return Worker.Instance.RequestsAddUpdate.ToString();
				case "internal_values":
					return Worker.Instance.Values.mKeys.Count.ToString();
				default:
					
					break;
			}
			if (mKeys.ContainsValue(key))
			{
				foreach (string k in mKeys.Keys)
				{
					if (mKeys[k] == key)
					{
						mRetrieved[k]++;
						return mValues[k];
					}
				}
			}
			return defaultval;

		}
		
		public string DumpValues()
		{
			StringBuilder s = new StringBuilder();
			s.AppendLine("<html><head><title>valstore</title></head><body>");
			s.AppendLine("<table border='1'>");
			s.AppendLine("<tr><th>added by</th><th>intkey</th><th>key</th><th>added</th><th>updated</th><th>expires</th><th>value</th><th>update</th><th>retrieved</th>");
			s.AppendLine("</tr>");
			List<string> sorted = new List<string>(mIntKeys);
			sorted.Sort();
			foreach (string intkey in sorted)
			{
				TimeSpan tupd = DateTime.Now - mUpdated[intkey];
				TimeSpan texp = mExpiries[intkey] - DateTime.Now;
				string added = "";
				if (mAdded[intkey].ToShortDateString() == DateTime.Now.ToShortDateString()) {
					added = mAdded[intkey].ToShortTimeString();
				} else {
					added = mAdded[intkey].ToString();
				}
				s.AppendLine("<tr>");
				s.AppendFormat("<td>{0}</td>",mAddedSource[intkey]);
				s.AppendFormat("<td>{0}</td>",intkey);
				s.AppendFormat("<td>{0}</td>",mKeys[intkey]);
				s.AppendFormat("<td>{0}</td>",added);
				s.AppendFormat("<td>{0:0}s</td>",tupd.TotalSeconds);
				s.AppendFormat("<td>{0:0}s</td>",texp.TotalSeconds);
				s.AppendFormat("<td>{0}</td>",mValues[intkey]);
				s.AppendFormat("<td>{0}</td>",mUpdates[intkey]);
				s.AppendFormat("<td>{0}</td>",mRetrieved[intkey]);
				s.AppendLine("</tr>");
			}
			s.AppendLine("</table></body></html>");
			return s.ToString();
		}
		
		public string DumpValuesJson()
		{
			StringBuilder sb = new StringBuilder();
			sb.AppendLine("{ \"data\": [");
			for (int i = 0; i < mIntKeys.Count; i++) {
				string key = mIntKeys[i];
				//sb.AppendFormat("{ \"key\":\"{0}\", \"value\":\"{1}\" }",mKeys[key],mValues[key]);
				sb.Append("{ \"key\":\"");
				sb.Append(mKeys[key]);
				sb.Append("\", \"value\":\"");
				sb.Append(mValues[key]);
				sb.Append("\" }");
				if (i < mIntKeys.Count - 1) {
					sb.Append(",");
				}
				sb.AppendLine();
			}
			sb.AppendLine("] }");
			return sb.ToString();
		
		}
		
		public void HouseKeeping()
		{
			List<string> keys = new List<string>(mIntKeys);
			int removed = 0;
			foreach (string intkey in keys)
			{
				if (mExpiries[intkey] < DateTime.Now)
				{
					mAdded.Remove(intkey);
					mExpiries.Remove(intkey);
					mValues.Remove(intkey);
					mKeys.Remove(intkey);
					mIntKeys.Remove(intkey);
					mUpdated.Remove(intkey);
					mUpdates.Remove(intkey);
					mRetrieved.Remove(intkey);
					mAddedSource.Remove(intkey);
					mUpdatedSource.Remove(intkey);
					removed++;
				}
			}
			if (removed > 0)
			{
				Console.WriteLine("Removed {0} keys",removed);
			}
		}
		
		private string FormatIntKey(string type, string format, string key)
		{
			return type + ":" + format + ":" + key;
		}
		
		public int Count {
			get { return mValues.Count; }
		}
	}
}
