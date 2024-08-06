#include <stdlib.h>

// crash when s[] = abcd**!! or **cdef!!
void common1(short *s) {
        if(s[0] == 0x6261) // ab
                s[2] = 0x6665; // ef

        if(s[1] == 0x6463) // cd
                if(((int *)s)[1] == 0x21216665) // ef!!
                        abort();
}

