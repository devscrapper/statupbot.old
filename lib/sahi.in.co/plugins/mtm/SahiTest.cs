using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using NUnit.Framework;

//change namespace to your own solution
namespace SahiMTMIntegrator
{
    [TestFixture]
    public class SahiTest
    {
        private static String sahiHost = "localhost";
        private static String sahiPort = "9999";
        private static String browserType = "chrome+ie+firefox";
        private static String userDataScriptsFolder = "D:/sahi/sahi_pro_g/userdata/scripts/demo/plugins/"; //change this to your own directory
        
        [Test]
        public void test()
        {
            String scriptPath = userDataScriptsFolder + "test_demo.sah";
            Sahi sahiHelper = new Sahi(sahiHost, sahiPort);
            Boolean s = sahiHelper.executeInParallel("http://sahitest.com/demo", browserType, scriptPath);
            Console.WriteLine(s);
        }
        
      
    }
}
