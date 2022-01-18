setlocal enabledelayedexpansion
cls

REM Build main file

64tass.exe -a QWAKSNES.asm -b -X -o qwakSNES.sfc --no-caret-diag --dump-labels -l "qwakSNES.tass" -L "qwakSNES.list" --verbose-list --line-numbers
if %ERRORLEVEL% NEQ 0 goto :maintassfail

REM boot MESEN
REM TODO ???
goto :end

:maintassfail
echo "ERROR : assembly of main file failed"
goto :end

:end



