@echo off
set title=NeRF
title %title%

set dir=data\nerf

echo 1) New Project
echo 2) Render Scene
echo 3) Load Snapshop
choice /c 123 /n /m Choice: 
echo.

if errorlevel 3 goto snap
if errorlevel 2 goto render
if errorlevel 1 goto new


:snap
title %title% - Load Snapshot

set /p snap=Snapshot path (*.msgpack): 

build\testbed.exe --snapshot=%snap% -m nerf

title %title - Finished
pause
exit

:render
title %title% - Render Scene

set /p project=Project folder name: 
if not exist %dir%\%project% (exit)
if %project% == "" (exit)

echo.
set /p seconds=Seconds: 
set /p fps=FPS: 
set /p width=Res Width: 
set /p height=Res Height: 
echo.

call conda activate ngp

python scripts/render.py --scene %dir%\%project% --n_seconds %seconds% --fps %fps% --render_name %project% --width %width% --height %height%
rename %project%_test.mp4 %project%_render.mp4

title %title - Finished
pause
exit


:new
title %title% - New Project

set path=%path%;%cd%\COLMAP

set /p project=Project folder name: 
if not exist %dir%\%project%\%dir%\%project% (exit)
if %project% == "" (exit)

choice /n /c yn /m "Generate transforms? (y/n): "
echo.
if errorlevel 2 goto run

call conda activate ngp
python scripts\colmap2nerf.py --colmap_matcher exhaustive --run_colmap --aabb_scale 16 --images %dir%\%project%\%dir%\%project%

timeout 1
powershell -command "$dir = '%dir%\%project%\%dir%\%project%'; $dir = './' + $dir.replace('\', '\\\\') + '/'; (Get-Content transforms.json) -replace $dir, ('./' + '%dir%\%project%'.replace('\', '\\') + '/') | Out-File -encoding ASCII transforms.json;

del colmap.db
rmdir /s /q colmap_sparse
rmdir /s /q colmap_text
move transforms.json %dir%\%project%

:run
build\testbed.exe --scene %dir%\%project%

title %title - Finished
pause
exit
