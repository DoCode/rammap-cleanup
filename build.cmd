@if not defined _echo @echo off
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& """%~dpn0.ps1""" %*"
exit /b %ERRORLEVEL%