package net.sf.sahi.client;

import junit.framework.TestCase;

public class SahiIntegratorTest extends TestCase {
	
	private static final long serialVersionUID = 2640926868458612899L;
	
	private static String sahiHost = "localhost";
    private static String sahiPort = "9999";
    private static String browserType = "chrome+ie+firefox";
    private static String userDataScriptsFolder = "D:/sahi/sahi_pro_g/userdata/scripts/demo/plugins/";
	
	 public void testLaunch(){
	    	
	     
     	String scriptPath = userDataScriptsFolder + "test_demo.sah";
     	SahiIntegrator sahiHelper = new SahiIntegrator(sahiHost, sahiPort);
         try {
				sahiHelper.executeInParallel("http://sahitest.com/demo", browserType, scriptPath);
			} catch (Exception e) {
				e.printStackTrace();
			}
	 }

}
