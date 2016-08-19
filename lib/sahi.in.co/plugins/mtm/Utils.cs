using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;

//change namespace to your own solution
namespace SahiMTMIntegrator
{
    class Utils
    {
        public static String getUUID()
        {
            return System.Guid.NewGuid().ToString().Replace('-', '0');
        }

        public static String generateId()
        {
            return "sahi_" + getUUID();
        }
        public static String encode(String s)
        {
            if (s == null) return null;
            try
            {
                return Uri.EscapeDataString(s);
            }
            catch (ApplicationException)
            {
                return s;
            }
        }

        internal static String readURL(string url)
        {
            HttpWebRequest myHttpWebRequest = (HttpWebRequest)WebRequest.Create(url);
            HttpWebResponse myHttpWebResponse = (HttpWebResponse)myHttpWebRequest.GetResponse();
            Stream receiveStream = myHttpWebResponse.GetResponseStream();
            Encoding encode = System.Text.Encoding.GetEncoding("utf-8");
            StreamReader readStream = new StreamReader(receiveStream, encode);
            Char[] read = new Char[256];
            int count = readStream.Read(read, 0, 256);
            String output = "";
            while (count > 0)
            {
                String str = new String(read, 0, count);
                output += str;
                count = readStream.Read(read, 0, 256);
            }
            readStream.Close(); 
            myHttpWebResponse.Close();
            return output;
        }
    }
}
