#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

// crash when s[] = abcd**!! or **cdef!!
void vul(short *s) {
	if(s[0] == 0x6261) // ab
		s[2] = 0x6665; // ef

	if(s[1] == 0x6463) // cd
		if(((int *)s)[1] == 0x21216665) // ef!!
			abort();
}

int main(int argc, char *argv[])
{
	char s[10];

	FILE *f = fopen(argv[1], "rb");
	if(!f)
		return 0;

	int ret = fread(s, 1, 8, f);
	if(ret < 8)
		return 1;
	
	assert(ret == 8);
	vul((short *)s);
	fclose(f);

	return 0;
}

