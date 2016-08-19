'''
Created on May 23, 2013

@author: Tyto Software Pvt Ltd
'''
import Utils
import time
import traceback
import os
import json
from robot.libraries import BuiltIn
class SahiRobotBridge:
    
    logDebugMessages = False
    global sessionId 
    global host
    host = "localhost"
    global port
    port = "9999"
    global browserType 
    global scriptExecutionTimeout 
    scriptExecutionTimeout = 60
    global opened 
    opened = False
    __version__ = '0.1'
    __all__ = ['open_browser', 'close_browser','load_script','execute_function','execute_sahi_step', 'json_decode', 'json_encode']

    def __init__(self, sahiHost, sahiPort):
      self.host = sahiHost
      self.port = sahiPort
      self.sessionId = self.setSessionId()
    
    def setSessionId(self):
        return Utils.generateId()
    
    def getSessionId(self):
        return self.sessionId
    
    def open_browser(self, browser , startUrl):
        global browserType
        browserType = browser
        url = "http://localhost:9999/_s_/dyn/Driver_launchPreconfiguredBrowser?" + "sahisid=" + self.sessionId + "&browserType=" + browserType + "&startUrl="+ Utils.encode(startUrl)
        Utils.readUrl(url)
        self.opened = self.waitForBrowserReady()
        if self.opened:
            return self.opened
        else:
            err = "Browser was not launched. Please check your test script and make sure Sahi is running."
            raise Exception(err)
    
    def isBrowserReady(self):
        url = "http://" + host + ":" + port + "/_s_/dyn/Driver_isReady?sahisid=" + self.sessionId
        isReady = Utils.readUrl(url)
        return("true" == str(isReady))
    
    def waitForBrowserReady(self):
        i= 0
        while i < 500:
            i = i + 1
            isReady = self.isBrowserReady()
            if isReady:
                return True
            else:
                try:
                    time.sleep(.1)
                except:
                    traceback.print_exc()
        return False
    
    def close_browser(self):
        self.killBrowser()
            
    def load_script(self, scriptPath):
        scriptsDir = os.path.split(scriptPath)[0]
        scriptsRelativeFilePath = os.path.split(scriptPath)[1]
        if not self.opened:
            print "load script{0} failed. Call 'open browser' before executing the script".format(scriptsRelativeFilePath)
            return False
        url = "http://" + host + ":" + port + "/_s_/dyn/Player_setScriptFile?" + "sahisid=" + self.sessionId + "&browserType=" + browserType + "&dir=" + Utils.encode(scriptsDir) + "&file=" + Utils.encode(scriptsRelativeFilePath)
        try:
            Utils.readUrl(url)
            Utils.readUrl("http://" + host + ":" + port + "/_s_/dyn/SessionState_setVar?name=sahi_paused&value=0&sahisid=" + self.sessionId)
            success = self.waitForScriptComplete()
            if success:
                return success
            else:
                 err = "Script load failed for {0}.".format(scriptsRelativeFilePath )
                 raise Exception(err)
            
        except:
            err = "Script load failed for {0}.".format(scriptsRelativeFilePath )
            raise Exception(err)
        
    def json_decode(self, s):
        return json.loads(s)
    
    def json_encode(self, s):
        return json.dumps(s)
            
    def execute_function( self, fName, fParams ):
        callerP = Utils.encode(fParams)
        callerF = Utils.encode(fName)
        caller = callerF + "(" +callerP +")"  
        url  = "http://" + host + ":" + port + "/_s_/dyn/Driver_executeInRhino?" + "sahisid=" + self.sessionId + "&js=" + caller
        content = Utils.readUrl(url)
        s = content.split("__SAHIDELIMITER__", 1)
        noError = json.loads(s[0])
        complete = self.waitForFunctionComplete()
        success = noError and complete 
        if success:
            return s[1]
        else:
            func = fName + "(" +fParams +")"
            err = "function execution failed for {0}.".format(func)
            raise Exception(err)
    def waitForFunctionComplete(self):
        sleepInterval = 2
        timeout = 0
        while (timeout < scriptExecutionTimeout):
            complete = self.isScriptComplete()
            if complete:
                return complete
            try:
                time.sleep(sleepInterval)
            except:
                traceback.print_exc()
                
            timeout += sleepInterval
        return False
    
    def waitForScriptComplete(self):
        sleepInterval = 2
        timeout = 0
        while (timeout < scriptExecutionTimeout):
            complete = self.isScriptComplete()
            if complete:
                hasErrors = self.scriptHasErrors()
                return not hasErrors
            try:
                time.sleep(sleepInterval)
            except:
                traceback.print_exc()
                
            timeout += sleepInterval
        return False
            
        
    def isScriptComplete(self):
        url = "http://" + host + ":" + port + "/_s_/dyn/Driver_isPlaying?sahisid=" + self.sessionId
        isPlaying = Utils.readUrl(url)
        return isPlaying == "0"
    
    def scriptHasErrors(self):
            url = "http://" + host + ":" + port + "/_s_/dyn/Player_hasErrors?sahisid=" + self.sessionId
            hasErrors = str(Utils.readUrl(url))
            return hasErrors == "true"
    
    def killBrowser(self):
        if not self.opened:
            err = "No open browser found" 
            raise Exception(err)
        else:
            url = "http://" + host + ":" + port + "/_s_/dyn/Driver_kill?sahisid=" + self.sessionId
            Utils.readUrl(url)
    
    def execute_sahi_step(self, step):
        url  = "http://" + host + ":" + port + "/_s_/dyn/Driver_executeInRhino?" + "sahisid=" + self.sessionId + "&js=" + step
        content = Utils.readUrl(url)
        s = content.split("__SAHIDELIMITER__", 1)
        noError = json.loads(s[0])
        complete = self.waitForFunctionComplete()
        success = noError and complete 
        if success:
            return s[1]
        else:
            err = "step execution failed for {0}.".format(step)
            raise Exception(err)