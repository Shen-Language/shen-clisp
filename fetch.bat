del .\kernel /q /s /f
PowerShell.exe -Command "Invoke-WebRequest -Uri https://github.com/Shen-Language/shen-sources/releases/download/shen-20.0/ShenOSKernel-20.0.zip -OutFile .\ShenOSKernel-20.0.zip"
PowerShell.exe -Command "Expand-Archive .\ShenOSKernel-20.0.zip -DestinationPath ."
ren ShenOSKernel-20.0 kernel
del ShenOSKernel-20.0.zip /q /f
