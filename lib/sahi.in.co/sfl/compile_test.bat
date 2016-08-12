@ECHO OFF
if "%3"=="" goto ERROR
echo ant compile_test -Dfile=%1 -Dextension=%2 -Dversion=%3
ant compile_test -Dfile=%1 -Dextension=%2 -Dversion=%3
goto :EOF
:ERROR
echo Usage: compile_test.bat fileName fileExtension
echo Example 1: compile_test.bat sample mxml 3
echo Example 2: compile_test.bat sampleAs as 4
