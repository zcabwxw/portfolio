DEP_CC:=gcc  -I. -nostdinc  -std=gnu99 -m32 -ffunction-sections -ffreestanding -fno-omit-frame-pointer -Wall -Wno-format -Wno-unused -Werror -gdwarf-2 -fno-stack-protector -MD -MF .deps/.d -MP  _  -Os --gc-sections 
DEP_PREFER_GCC:=
