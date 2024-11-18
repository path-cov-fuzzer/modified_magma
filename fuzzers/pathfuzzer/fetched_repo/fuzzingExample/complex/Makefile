# ------------------ original Makefile start -------------

all: complex test2 test3

complex: common1.o common2.o common3.o test1.o
	$(CC) $(CFLAGS) $^ -o $@

test2: test2.o
	$(CC) $(CFLAGS) $^ -o $@

test3: test3.o
	$(CC) $(CFLAGS) $^ -o $@

# 模式规则，定义如何从 .c 文件生成 .o 文件
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf *.o test2 test3 complex *.so *.txt *.bin ./convert ./complex_cmplog ./output_dir 

# ------------------ original Makefile end   -------------


