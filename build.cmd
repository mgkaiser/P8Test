java -jar c:\prog8\prog8compiler-9.7-all.jar -sourcelines -target cx16 -srcdirs src;src2;inc main.p8
copy main.prg C:\x16-Drive\drive\p8test.prg

java -jar c:\prog8\prog8compiler-9.7-all.jar -sourcelines -target cx16 -srcdirs src;src2;inc extprog.p8
copy extprog.prg C:\x16-Drive\drive\extprog.prg

rem java -jar c:\prog8\prog8compiler-9.7-all.jar -sourcelines -target cx16 -srcdirs src;src2;inc extprog2.p8
rem copy extprog2.prg C:\x16-Drive\drive\extprog2.prg

rem cd C:\x16emu_win64-r46\
rem call x16emu.cmd
rem cd C:\Users\mgkai\src\p8Test