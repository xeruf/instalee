@echo off
Powershell Start -Verb runAs powershell -ArgumentList '-ExecutionPolicy Bypass -NoExit Set-Location %cd%; .\instalee\i.ps1'