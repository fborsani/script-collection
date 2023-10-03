@echo off
title Editor
color a
cls
echo.
echo Creates a file in the current directory
echo To save press CTRL+Z or F6 then Enter
echo To close the editor press CTRL+C
echo To retrieve text from a file run cmdBat FILE and press CTRL+V after specifying the filename
echo To append strings to a file run cmdBat FILE, set the destination file as FILE press ENTER followed by CTRL+V
if [%1]==[] goto edit
type "%1"| clip
:edit
echo.
echo 
set /p name=Destination file:
copy con %name%
if exist %name% copy %name% + con
exit