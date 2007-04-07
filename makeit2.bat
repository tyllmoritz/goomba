arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/cache.c -o obj/cache.o
arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/main.c -o obj/main.o
arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/minilzo.107/minilzo.c -o obj/minilzo.o
arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/rumble.c -o obj/rumble.o
arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/sram.c -o obj/sram.o
arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/ui.c -o obj/ui.o

rem arm-eabi-gcc -mthumb-interwork -fomit-frame-pointer -Wall -O2 -mthumb -c src/c/boot.c -o obj/boot.o
pause
