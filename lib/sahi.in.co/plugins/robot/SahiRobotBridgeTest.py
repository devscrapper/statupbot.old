import unittest
from SahiRobotBridge import SahiRobotBridge
import time
import re

class SahiRobotBridgeTest(unittest.TestCase):
       
    global host 
    global port 
    
    def setUp(self):
        self.host = "localhost"
        self.port = "9999"
        
    def testOpenBrowser(self):
        helper = SahiRobotBridge(self.host , self.port)
        try:
            helper.open_browser("chrome", "http://sahitest.com/demo")
            time.sleep(3)
        except Exception, e:
            self.assertEquals(str(e), "Browser was not launched. Please check your test script and make sure Sahi is running.", "Browser launch error was expected.")
        finally:
            helper.close_browser()
        
    
    def testFunctionNotFound(self):
        
        helper = SahiRobotBridge(self.host , self.port)
        helper.open_browser("chrome", "http://sahitest.com/demo")
        helper.load_script("D:/sahi/sahi_pro_g/userdata/scripts/demo/robot_sample.sah")
        try:
            helper.execute_function("login_not", '"test","secret"')
        except Exception, e:
            self.assertEquals(str(e), 'function execution failed for login_not("test","secret").', "wrong error message")
            
        finally:
            helper.close_browser()
   
    def testExecuteFunction(self):
        helper = SahiRobotBridge(self.host , self.port)
        try:
            helper.open_browser("chrome", "http://sahitest.com/demo")
            helper.load_script("D:/sahi/sahi_pro_g/userdata/scripts/demo/robot_sample.sah")
            helper.execute_function("login", '"test","secret"')
        except Exception, e:
            self.assertEquals(str(e), 'function execution failed for login("test","secret").', "wrong error message")
        finally:
            helper.close_browser()
        
    
    def testLoadAvailableScript(self):
        helper = SahiRobotBridge(self.host , self.port)
        try:
            helper.open_browser("chrome", "http://sahitest.com/demo")
            helper.load_script("D:/sahi/sahi_pro_g/userdata/scripts/demo/robot_sample.sah")
        except Exception, e:
            self.assertEqual(str(e), "script loading failed for robot_sample.sah", "wrong error message")
        finally:
            helper.close_browser()
        
    def testLoadUnavailableScript(self):
        helper = SahiRobotBridge(self.host , self.port)
        try:
            helper.open_browser("chrome", "http://sahitest.com/demo")
            helper.load_script("D:/sahi/sahi_pro_g/userdata/scripts/demo/robot_sample_not.sah")
        except Exception, e:
            self.assertEqual(str(e), "Script load failed for robot_sample_not.sah.")
        finally:
            helper.close_browser()
    
    def testFunctionFail(self):
        helper = SahiRobotBridge(self.host , self.port)
        try:
            helper.open_browser("chrome", "http://sahitest.com/demo")
            helper.load_script("D:/sahi/sahi_pro_g/userdata/scripts/demo/robot_sample_fail.sah")
            helper.execute_function("login", '"test","secret"')
        except Exception, e:
            self.assertEquals(str(e), 'function execution failed for login("test","secret").', "wrong error message")
        finally:
            helper.close_browser()