@if not defined _echo @echo off
rmdir /S /Q _build
exit /b %ERRORLEVEL%