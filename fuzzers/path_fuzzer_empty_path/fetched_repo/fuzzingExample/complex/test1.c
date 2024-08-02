#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

void common1(short *s);
void common2(short *s);
void common3(short *s);

int main(int argc, char *argv[])
{
        char s[30];

        FILE *f = fopen(argv[1], "rb");
        if(!f)
                return 0;

        int ret = fread(s, 1, 24, f);
        if(ret < 24)
                return 1;

        assert(ret == 24);
        common1((short *)s);
        common2((short *)(s + 8));
        common3((short *)(s + 16));
        fclose(f);

        return 0;
}




