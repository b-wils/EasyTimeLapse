################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL := cmd.exe
RM := rm -rf

USER_OBJS :=

LIBS := 
PROJ := 

O_SRCS := 
C_SRCS := 
S_SRCS := 
S_UPPER_SRCS := 
OBJ_SRCS := 
ASM_SRCS := 
PREPROCESSING_SRCS := 
OBJS := 
OBJS_AS_ARGS := 
C_DEPS := 
C_DEPS_AS_ARGS := 
EXECUTABLES := 
OUTPUT_FILE_PATH :=
OUTPUT_FILE_PATH_AS_ARGS :=
AVR_APP_PATH :=$$$AVR_APP_PATH$$$
QUOTE := "
ADDITIONAL_DEPENDENCIES:=
OUTPUT_FILE_DEP:=

# Every subdirectory with source files must be described here
SUBDIRS :=  \
../Arduino


# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS +=  \
../Arduino/HardwareSerial.cpp \
../Arduino/new.cpp \
../Arduino/Print.cpp \
../Arduino/Stream.cpp \
../Arduino/WMath.cpp \
../Arduino/WString.cpp \
../ETL_V1.cpp \
../SoftModem.cpp \
../Arduino/wiring_digital.c \
../Arduino/wiring.c \
../Utils.cpp \
../Arduino/WInterrupts.c \
../Arduino/wiring_analog.c \
../crc.c


PREPROCESSING_SRCS += 


ASM_SRCS += 


OBJS +=  \
Arduino/HardwareSerial.o \
Arduino/new.o \
Arduino/Print.o \
Arduino/Stream.o \
Arduino/WMath.o \
Arduino/WString.o \
ETL_V1.o \
SoftModem.o \
Arduino/wiring_digital.o \
Arduino/wiring.o \
Utils.o \
Arduino/WInterrupts.o \
Arduino/wiring_analog.o \
crc.o


OBJS_AS_ARGS +=  \
Arduino/HardwareSerial.o \
Arduino/new.o \
Arduino/Print.o \
Arduino/Stream.o \
Arduino/WMath.o \
Arduino/WString.o \
ETL_V1.o \
SoftModem.o \
Arduino/wiring_digital.o \
Arduino/wiring.o \
Utils.o \
Arduino/WInterrupts.o \
Arduino/wiring_analog.o \
crc.o


C_DEPS +=  \
Arduino/HardwareSerial.d \
Arduino/new.d \
Arduino/Print.d \
Arduino/Stream.d \
Arduino/WMath.d \
Arduino/WString.d \
ETL_V1.d \
SoftModem.d \
Arduino/wiring_digital.d \
Arduino/wiring.d \
Utils.d \
Arduino/WInterrupts.d \
Arduino/wiring_analog.d \
crc.d


C_DEPS_AS_ARGS +=  \
Arduino/HardwareSerial.d \
Arduino/new.d \
Arduino/Print.d \
Arduino/Stream.d \
Arduino/WMath.d \
Arduino/WString.d \
ETL_V1.d \
SoftModem.d \
Arduino/wiring_digital.d \
Arduino/wiring.d \
Utils.d \
Arduino/WInterrupts.d \
Arduino/wiring_analog.d \
crc.d


OUTPUT_FILE_PATH +=ETL_V1.elf

OUTPUT_FILE_PATH_AS_ARGS +=ETL_V1.elf

ADDITIONAL_DEPENDENCIES:=

OUTPUT_FILE_DEP:= ./makedep.mk

# AVR32/GNU C Compiler





























Arduino/%.o: ../Arduino/%.c
	@echo Building file: $<
	@echo Invoking: AVR8/GNU C++ Compiler
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-gcc.exe$(QUOTE)  -funsigned-char -funsigned-bitfields -O0 -ffunction-sections -fpack-struct -fshort-enums -Wall -c -std=gnu99 -MD -MP -MF "$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -mmcu=atmega328p  -o"$@" "$<" 
	@echo Finished building: $<

Arduino/%.o: ../Arduino/%.cpp
	@echo Building file: $<
	@echo Invoking: AVR8/GNU C++ Compiler
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-g++.exe$(QUOTE) -funsigned-char -funsigned-bitfields -Os -fdata-sections -ffunction-sections -fpack-struct -fshort-enums -g2 -Wall -c -MD -MP -MF "$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -mmcu=atmega328p   -o"$@" "$<" 
	@echo Finished building: $<

./%.o: .././%.c
	@echo Building file: $<
	@echo Invoking: AVR8/GNU C++ Compiler
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-gcc.exe$(QUOTE)  -funsigned-char -funsigned-bitfields -O0 -ffunction-sections -fpack-struct -fshort-enums -Wall -c -std=gnu99 -MD -MP -MF "$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -mmcu=atmega328p  -o"$@" "$<" 
	@echo Finished building: $<

./%.o: .././%.cpp
	@echo Building file: $<
	@echo Invoking: AVR8/GNU C++ Compiler
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-g++.exe$(QUOTE) -funsigned-char -funsigned-bitfields -Os -fdata-sections -ffunction-sections -fpack-struct -fshort-enums -g2 -Wall -c -MD -MP -MF "$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"  -mmcu=atmega328p   -o"$@" "$<" 
	@echo Finished building: $<



# AVR32/GNU Preprocessing Assembler



# AVR32/GNU Assembler




ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: $(OUTPUT_FILE_PATH) $(ADDITIONAL_DEPENDENCIES)

$(OUTPUT_FILE_PATH): $(OBJS) $(USER_OBJS) $(OUTPUT_FILE_DEP)
	@echo Building target: $@
	@echo Invoking: AVR8/GNU C++ Linker
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-g++.exe$(QUOTE) -o$(OUTPUT_FILE_PATH_AS_ARGS) $(OBJS_AS_ARGS) $(USER_OBJS) $(LIBS) -Wl,-Map="ETL_V1.map" -Wl,--start-group -Wl,-lm  -Wl,--end-group -Wl,--gc-sections -mrelax -Wl,--defsym=__stack=0x800 -Wl,-lm  -mmcu=atmega328p  
	@echo Finished building target: $@
	"C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-objcopy.exe" -O ihex -R .eeprom -R .fuse -R .lock -R .signature  "ETL_V1.elf" "ETL_V1.hex"
	"C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-objcopy.exe" -j .eeprom  --set-section-flags=.eeprom=alloc,load --change-section-lma .eeprom=0  --no-change-warnings -O ihex "ETL_V1.elf" "ETL_V1.eep" || exit 0
	"C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-objdump.exe" -h -S "ETL_V1.elf" > "ETL_V1.lss"
	"C:\Program Files (x86)\Atmel\Atmel Studio 6.0\extensions\Atmel\AVRGCC\3.3.2.31\AVRToolchain\bin\avr-size.exe" -C --mcu=atmega328p  "ETL_V1.elf"
	




# Other Targets
clean:
	-$(RM) $(OBJS_AS_ARGS)$(C_DEPS_AS_ARGS) $(EXECUTABLES) 
	rm -rf "ETL_V1.hex" "ETL_V1.lss" "ETL_V1.eep" "ETL_V1.map"
	