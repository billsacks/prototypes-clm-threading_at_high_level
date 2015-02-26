all: prototype

%.o : %.F90
	gfortran -c -Wall -fcheck=all -fopenmp $< -o $@

prototype: decompMod.o TemperatureType.o IrrigationMod.o clm_instMod.o clm_driver.o
	gfortran -Wall -fcheck=all -fopenmp -o prototype $^

clean:
	rm -f *.mod *.o prototype

TemperatureType.o: decompMod.o
IrrigationMod.o: TemperatureType.o decompMod.o
clm_instMod.o: IrrigationMod.o TemperatureType.o decompMod.o
clm_driver.o: clm_instMod.o decompMod.o
