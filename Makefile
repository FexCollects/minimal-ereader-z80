all: minimal.raw

minimal.o: minimal.asm 
	./rgbasm -o $@ $<
minimal.gbc: minimal.o
	./rgblink -o $@ $<
minimal.z80: minimal.gbc
	python3 ./stripgbc.py $< $@
minimal.vpk: minimal.z80
	./nevpk -c -i $< -o $@
minimal.raw: minimal.vpk
	./nedcmake -i $< -o $@ -type 1 -region 1

clean:
	rm -f *.o *.gbc *.z80 *.vpk *.raw
