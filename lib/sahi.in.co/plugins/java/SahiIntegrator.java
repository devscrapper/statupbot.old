package net.sf.sahi.client;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import net.sf.sahi.util.Utils;

public class SahiIntegrator {

	private String host = "localhost";
    private String port = "9999";
    
    public SahiIntegrator()
    {
    }

    public SahiIntegrator(String host, String port)
    {
        this.host = host;
        this.port = port;
    }
    
    public boolean executeInParallel(String baseUrl, String browserType, String scriptPath) throws Exception
    {
        boolean result = executeSingle(baseUrl, browserType, "false", scriptPath, "5", "html", scriptPath);
        return result;
    }

	private boolean executeSingle(String baseUrl, String browserType, String useSingleSession, String scriptPath, String threads, String logInfo, String suitePath) throws Exception {
		
		String sessionId = Utils.generateId();
        
        String url = "http://localhost:9999/_s_/dyn/Suite_startInParallel?a=a" +
                "&port=9999" +
                "&useSingleSession=" + Utils.encode(useSingleSession) +
                "&browserPath=null" +
                "&host=localhost" +
                "&test=" + Utils.encode(scriptPath) +
                "&sahisid=" + Utils.encode(sessionId) +
                "&suiteId=" + Utils.encode(sessionId) +
                "&threads=" + Utils.encode(threads) +
                "&logsInfo=" + Utils.encode(logInfo) +
                "&suitePath=" + Utils.encode(suitePath) +
                "&isSingleSessionS=" + Utils.encode(useSingleSession) +
                "&baseURL=" + Utils.encode(baseUrl) +
                "&browserType=" + Utils.encode(browserType);
        Utils.readURL(url); 
        return getResult(sessionId, browserType);        
		
	}

	private boolean getResult(String sessionId, String browserType) throws Exception {
		String[] split = browserType.split("\\+");
		HashMap<String, String[]> statuses = new HashMap<String, String[]>();
		for (int i = 0; i < split.length; i++)
        {
            String browserSingle = split[i];
            String[] status = getStatus(sessionId, browserSingle);
            statuses.put(browserSingle, status);
        }
        String result = "";
        Boolean passed = true;
        Iterator<Entry<String, String[]>> it = statuses.entrySet().iterator();
        while(it.hasNext()) {
        	Map.Entry pairs = (Map.Entry)it.next();
        	String[] value = (String[])pairs.getValue();
			result += "\n" + pairs.getKey() + ": " + value.toString();
            if (value[0] == "FAILURE") passed = false;
        }
        if (!passed)
        {
            throw new Exception(result);
        }
        return passed;
	}
	
	private String[] getStatus(String sessionId, String browserSingle) {
		String[] status;
        String message;
        int retries = 0;
        while (true)
        {
            try {
				Thread.sleep(2000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
            message = getSuiteStatus(sessionId, browserSingle);
            status = message.split(":");
            if ("SUCCESS".equals(status[0]) || "FAILURE".equals(status[0]))
            {
                break;
            }
            else if ("RETRY".equals(status[0]))
            {
                if (retries++ == 10)
                {
                    status[0] = "FAILURE";
                    break;
                }
            }
        }
        return status;
	}

	private String getSuiteStatus(String sessionId, String browserSingle) {
		byte[] status;
        String urlStr;
        String statusStr;
        
        try
        {
            urlStr = "http://" + host + ":" + port + "/_s_/dyn/Suite_getAllStatus?sahisid=" + Utils.encode(sessionId) + "&browserType=" + browserSingle;
            status = Utils.readURL(urlStr);
            statusStr = new String(status);
        }
        catch (Exception e)
        {
        	e.printStackTrace();
        	System.out.println("Exception while connecting to Sahi proxy to check status. Retrying ...");
        	statusStr = "RETRY";
        }
		
		return statusStr;
	}
}
