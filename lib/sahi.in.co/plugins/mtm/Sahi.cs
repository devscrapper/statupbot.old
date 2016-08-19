using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace SahiMTMIntegrator
{
    public class Sahi
    {
        private String host = "localhost";
        private String port = "9999";

        public Sahi()
        {
        }
        public Sahi(String host, String port)
        {
            this.host = host;
            this.port = port;
        }

        public Boolean executeInParallel(String baseUrl, String browserType, String scriptPath)
        {
            Boolean result = executeSingle(baseUrl, browserType, "false", scriptPath, "5", "html", scriptPath);
            return result;
        }

        public Boolean executeSingle(String baseUrl, String browserTypes, String useSingleSession, String scriptPath, String threads, String logInfo, String suitePath)
        {
            String[] split = browserTypes.Split('+');
            BrowserRunner[] browserRunners = new BrowserRunner[split.Length];
            StringBuilder result = new StringBuilder();
            for (int i = 0; i < split.Length; i++)
            {
                string browserType = split[i];
                browserRunners[i] = new BrowserRunner(host, port, baseUrl, browserType, useSingleSession, scriptPath, threads, logInfo);
                browserRunners[i].Start();
            }
            Boolean passed = true;

            for (int i = 0; i < browserRunners.Length; i++)
            {
                browserRunners[i].join();
                result.Append("\n").Append(split[i]).Append(":").Append(browserRunners[i].getStatus());
                if (!"SUCCESS".Equals(browserRunners[i].getStatus()))
                {
                    passed = false;
                }
            }
            Console.WriteLine("result = " + result);
            Console.WriteLine("passed = " + passed);

            if (!passed)
            {
                throw new Exception(result.ToString());
            }
            return passed;
        }

        public String getStatus(String userDefinedId)
        {
            String status;
            int retries = 0;
            while (true)
            {
                try
                {
                    Thread.Sleep(1000);
                }
                catch (ThreadInterruptedException e)
                {
                    Console.WriteLine(e.StackTrace);
                }
                status = getSuiteStatus(userDefinedId);
                if ("SUCCESS".Equals(status) || "FAILURE".Equals(status))
                {
                    break;
                }
                else if ("RETRY".Equals(status))
                {
                    if (retries++ == 10)
                    {
                        status = "FAILURE";
                        break;
                    }
                }
            }
            return status;
        }

        public String getSuiteStatus(String userDefinedId)
        {
            return Utils.readURL("http://" + host + ":" + port + "/_s_/dyn/SahiEndPoint_status?userDefinedId=" + userDefinedId);
        }

        public void cleanup(String userDefinedId)
        {
            Utils.readURL("http://" + host + ":" + port + "/_s_/dyn/SahiEndPoint_cleanup?userDefinedId=" + userDefinedId);
        }


        class BrowserRunner
        {
            private String host;
            private String port;
            private String baseUrl;
            private String browserType;
            private String useSingleSession;
            private String scriptPath;
            private String threads;
            private String logInfo;
            private Thread _thread;
            private String status;

            public void Start() { _thread.Start(); }
            public BrowserRunner(String host, String port, String baseUrl, String browserType, String useSingleSession, String scriptPath, String threads, String logInfo)
            {
                _thread = new Thread(new ThreadStart(this.run));
                this.host = host;
                this.port = port;
                this.baseUrl = baseUrl;
                this.browserType = browserType;
                this.useSingleSession = useSingleSession;
                this.scriptPath = scriptPath;
                this.threads = threads;
                this.logInfo = logInfo;
            }


            public void run()
            {
                String userDefinedId = Utils.generateId();

                String url = "http://" + host + ":" + port + "/_s_/dyn/SahiEndPoint_run?a=a" +
                        "&suite=" + Utils.encode(scriptPath) +
                        "&browserType=" + browserType +
                        "&baseURL=" + Utils.encode(baseUrl) +
                        "&threads=" + threads +
                        "&isSingleSessionS=" + Utils.encode(useSingleSession) +
                        "&logsInfo=" + Utils.encode(logInfo) +
                        "&userDefinedId=" + userDefinedId;
                Utils.readURL(url);

                status = new Sahi().getStatus(userDefinedId);
            }

            public String getStatus()
            {
                return status;
            }


            internal void join()
            {
                _thread.Join();
            }
        }
    }
}
