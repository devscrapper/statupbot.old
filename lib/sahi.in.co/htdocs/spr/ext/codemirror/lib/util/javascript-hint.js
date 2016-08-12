(function () {
  function forEach(arr, f) {
    for (var i = 0, e = arr.length; i < e; ++i) f(arr[i]);
  }
  
  function arrayContains(arr, item) {
    if (!Array.prototype.indexOf) {
      var i = arr.length;
      while (i--) {
        if (arr[i] === item) {
          return true;
        }
      }
      return false;
    }
    return arr.indexOf(item) != -1;
  }

  function scriptHint(editor, keywords, getToken) {
    // Find the token at the cursor
    var cur = editor.getCursor(), token = getToken(editor, cur), tprop = token;
    // If it's not a 'word-style' token, ignore the token.
		if (!/^[\w$_]*$/.test(token.string)) {
      token = tprop = {start: cur.ch, end: cur.ch, string: "", state: token.state,
                       className: token.string == "." ? "property" : null};
    }
    // If it is a property, find out what it is a property of.
    while (tprop.className == "property") {
      tprop = getToken(editor, {line: cur.line, ch: tprop.start});
      if (tprop.string != ".") return;
      tprop = getToken(editor, {line: cur.line, ch: tprop.start});
      if (tprop.string == ')') {
        var level = 1;
        do {
          tprop = getToken(editor, {line: cur.line, ch: tprop.start});
          switch (tprop.string) {
          case ')': level++; break;
          case '(': level--; break;
          default: break;
          }
        } while (level > 0)
        tprop = getToken(editor, {line: cur.line, ch: tprop.start});
				if (tprop.className == 'variable')
					tprop.className = 'function';
				else return; // no clue
      }
      if (!context) var context = [];
      context.push(tprop);
    }
    return {list: getCompletions(token, context, keywords),
            from: {line: cur.line, ch: token.start},
            to: {line: cur.line, ch: token.end}};
  }

  CodeMirror.javascriptHint = function(editor) {
    return scriptHint(editor, javascriptKeywords,
                      function (e, cur) {return e.getTokenAt(cur);});
  }

  function getCoffeeScriptToken(editor, cur) {
  // This getToken, it is for coffeescript, imitates the behavior of
  // getTokenAt method in javascript.js, that is, returning "property"
  // type and treat "." as indepenent token.
    var token = editor.getTokenAt(cur);
    if (cur.ch == token.start + 1 && token.string.charAt(0) == '.') {
      token.end = token.start;
      token.string = '.';
      token.className = "property";
    }
    else if (/^\.[\w$_]*$/.test(token.string)) {
      token.className = "property";
      token.start++;
      token.string = token.string.replace(/\./, '');
    }
    return token;
  }

  CodeMirror.coffeescriptHint = function(editor) {
    return scriptHint(editor, coffeescriptKeywords, getCoffeeScriptToken);
  }

  CodeMirror.sahiHint = function(editor) {
    return scriptHint(editor, sahiKeywords, function (e, cur) {return e.getTokenAt(cur);});
  }  
  
  var stringProps = ("charAt charCodeAt indexOf lastIndexOf substring substr slice trim trimLeft trimRight " +
                     "toUpperCase toLowerCase split concat match replace search").split(" ");
  var arrayProps = ("length concat join splice push pop shift unshift slice reverse sort indexOf " +
                    "lastIndexOf every some filter forEach map reduce reduceRight ").split(" ");
  var funcProps = "prototype apply call bind".split(" ");
  var javascriptKeywordsStr = "break case catch continue debugger default delete do else false finally for function " +
  "if in instanceof new null return switch throw true try typeof var void while with";
  var javascriptKeywords = javascriptKeywordsStr.split(" ");
  var sahiNormalFunctions = "_accessor _button _checkbox _image _imageSubmitButton _link _password _radio _select _submit _textarea _textbox _hidden _event _cell _table _byId _row _div _span _spandiv _option _reset _file _get _byText _byClassName _label _listItem _list _parentNode _parentCell _parentRow _parentTable _in _near _rte _iframe _tableHeader _heading1 _heading2 _heading3 _heading4 _heading5 _heading6 _hidden _area _map _italic _bold _emphasis _strong _preformatted _code _blockquote _xy _under _above _aboveOrUnder _leftOf _rightOf _leftOrRightOf _byXPath _bySeleniumLocator  _getValue _getAttribute _containsText _containsHTML _getText _getCellText _getSelectedText _lastAlert _lastPrompt _lastConfirm _style _cookie _position _rteHTML _rteText _isVisible _contains _title _exists _extract  _isIE _isIE9 _isFF _isFF3 _isFF4 _isChrome _isSafari _isOpera _isHTMLUnit  _fetch _random _savedRandom _getGlobal _getDB _getQC _readFile _readURL _print _printCalled _lastDownloadedFileName _scriptName _logException _logExceptionAsFailure _stopOnError _continueOnError _scriptPath _re _readCSVFile _writeFile _writeToFile _deleteFile _suiteInfo _writeCSVFile _areEqualArrays _userDataDir _setRecovery _removeRecovery _sessionInfo _renameFile _runUnitTests _fail _dataDrive _condition _setSpeed _selectWindow _selectDomain _userDataPath _evalOnRhino _scriptStatus _flex _stackTrace _dynamicInclude _execute _prompt _confirm _resolvePath _datebox _datetimebox _datetimelocalbox _emailbox _monthbox _numberbox _telephonebox _rangebox _searchbox _timebox _urlbox _weekbox _count _collect _canvas _f _abbr _setHttpHeader _addHttpHeader _removeHttpHeader _resetHttpHeader _testcase _takeSnapShot _activeElement _readExcelFile _dList _dTerm _dDesc _compareImages _getExcel _setFlexReadyCondition _paragraph _sendHTMLResponseAfterFileDownload _applet";
  var sahiSchedulerFunctions = "_alert _assertEqual _assertEqualArrays _assertNotEqual _assertNotNull _assertNull _assertTrue _assert _assertNotTrue _assertFalse _assertExists _assertNotExists _callServer _click _clickLinkByAccessor _dragDrop _resetSavedRandom _setSelected _setValue _simulateEvent _call _eval _setGlobal _wait _popup _domain _highlight _log _navigateTo _callServer _doubleClick _rightClick _addMock _removeMock _expectConfirm _setFile _expectPrompt _debug _debugToErr _debugToFile _mouseOver _keyPress _focus _keyDown _keyUp _mockImage _assertContainsText _enableKeepAlive _disableKeepAlive _dragDropXY _deleteCookie _createCookie _clearPrintCalled _saveDownloadedAs _clearLastDownloadedFileName _rteWrite _type _check _uncheck _blur _removeFocus _clearLastAlert _clearLastPrompt _clearLastConfirm _closeWindow _assertNotContainsText _simulateMouseEvent _simulateMouseEventXY _mouseDown _mouseUp _setStrictVisibilityCheck _takeSnapShots _assertSnapShot";
  var sahiKeywords = (javascriptKeywordsStr + " " + sahiNormalFunctions + " " + sahiSchedulerFunctions).split(" "); 
  
  var coffeescriptKeywords = ("and break catch class continue delete do else extends false finally for " +
                  "if in instanceof isnt new no not null of off on or return switch then throw true try typeof until void while with yes").split(" ");

  function getCompletions(token, context, keywords) {
    var found = [], start = token.string;
    function maybeAdd(str) {
      if (str.indexOf(start) == 0 && !arrayContains(found, str)) found.push(str);
    }
    function gatherCompletions(obj) {
      if (typeof obj == "string") forEach(stringProps, maybeAdd);
      else if (obj instanceof Array) forEach(arrayProps, maybeAdd);
      else if (obj instanceof Function) forEach(funcProps, maybeAdd);
      for (var name in obj) maybeAdd(name);
    }

    if (context) {
      // If this is a property, see if it belongs to some object we can
      // find in the current environment.
      var obj = context.pop(), base;
      if (obj.className == "variable")
        base = window[obj.string];
      else if (obj.className == "string")
        base = "";
      else if (obj.className == "atom")
        base = 1;
      else if (obj.className == "function") {
        if (window.jQuery != null && (obj.string == '$' || obj.string == 'jQuery') &&
            (typeof window.jQuery == 'function'))
          base = window.jQuery();
        else if (window._ != null && (obj.string == '_') && (typeof window._ == 'function'))
          base = window._();
      }
      while (base != null && context.length)
        base = base[context.pop().string];
      if (base != null) gatherCompletions(base);
    }
    else {
      // If not, just look in the window object and any local scope
      // (reading into JS mode internals to get at the local variables)
      for (var v = token.state.localVars; v; v = v.next) maybeAdd(v.name);
      gatherCompletions(window);
      forEach(keywords, maybeAdd);
    }
    return found;
  }
})();
