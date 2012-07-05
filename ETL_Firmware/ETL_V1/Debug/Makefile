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
LIB_AS_ARGS :=
OUTPUT_FILE_PATH :=
OUTPUT_FILE_PATH_AS_ARGS :=
HEX_FLASH_FILE_PATH :=
HEX_FLASH_FILE_PATH_AS_ARGS :=
HEX_EEPROM_FILE_PATH :=
HEX_EEPROM_FILE_PATH_AS_ARGS :=
LSS_FILE_PATH :=
LSS_FILE_PATH_AS_ARGS :=
MAP_FILE_PATH :=
MAP_FILE_PATH_AS_ARGS :=
AVR_APP_PATH :=C:/Program Files (x86)/Atmel/AVR Studio 5.0/AVR ToolChain/bin/
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
Arduino/WInterrupts.d \
Arduino/wiring_analog.d \
crc.d


OUTPUT_FILE_PATH +=ETL_V1.elf

OUTPUT_FILE_PATH_AS_ARGS +=ETL_V1.elf

HEX_FLASH_FILE_PATH +=ETL_V1.hex

HEX_FLASH_FILE_PATH_AS_ARGS +=ETL_V1.hex

HEX_EEPROM_FILE_PATH +=ETL_V1.eep

HEX_EEPROM_FILE_PATH_AS_ARGS +=ETL_V1.eep

LSS_FILE_PATH +=ETL_V1.lss

LSS_FILE_PATH_AS_ARGS +=ETL_V1.lss

MAP_FILE_PATH =ETL_V1.map

MAP_FILE_PATH_AS_ARGS =ETL_V1.map

LIB_AS_ARGS +=libETL_V1.a

ADDITIONAL_DEPENDENCIES:= $(HEX_FLASH_FILE_PATH) $(LSS_FILE_PATH) $(HEX_EEPROM_FILE_PATH) size

OUTPUT_FILE_DEP:= ./makedep.mk

# AVR/GNU C Compiler











Arduino/%.o: ../Arduino/%.c
	@echo Building file: $<
	@echo Invoking: AVR/GNU C Compiler
	$(QUOTE)$(AVR_APP_PATH)avr-gcc.exe$(QUOTE) -funsigned-char -funsigned-bitfields -O0 -fpack-struct -fshort-enums -g2 -Wall -c -std=gnu99  -mmcu=atmega328p   -MD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<

Arduino/%.o: ../Arduino/%.cpp
	@echo Building file: $<
	@echo Invoking: AVR/GNU CPP Compiler
	$(QUOTE)$(AVR_APP_PATH)avr-g++.exe$(QUOTE) -funsigned-char -funsigned-bitfields -O0 -fdata-sections -ffunction-sections -fpack-struct -fshort-enums -g2 -Wall -c  -mmcu=atmega328p   -MD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<

./%.o: .././%.c
	@echo Building file: $<
	@echo Invoking: AVR/GNU C Compiler
	$(QUOTE)$(AVR_APP_PATH)avr-gcc.exe$(QUOTE) -funsigned-char -funsigned-bitfields -O0 -fpack-struct -fshort-enums -g2 -Wall -c -std=gnu99  -mmcu=atmega328p   -MD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<

./%.o: .././%.cpp
	@echo Building file: $<
	@echo Invoking: AVR/GNU CPP Compiler
	$(QUOTE)$(AVR_APP_PATH)avr-g++.exe$(QUOTE) -funsigned-char -funsigned-bitfields -O0 -fdata-sections -ffunction-sections -fpack-struct -fshort-enums -g2 -Wall -c  -mmcu=atmega328p   -MD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<



# AVR/GNU Assembler




ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: $(OUTPUT_FILE_PATH) $(ADDITIONAL_DEPENDENCIES)

# AVR/GNU C/C++ Linker
$(OUTPUT_FILE_PATH): $(OBJS) $(USER_OBJS) $(OUTPUT_FILE_DEP)
	@echo Building target: $@
	@echo Invoking: AVR/GNU C/C++ Linker
	$(QUOTE)$(AVR_APP_PATH)avr-g++.exe$(QUOTE) -Wl,--gc-sections -mrelax -mmcu=atmega328p  -Wl,-Map=$(MAP_FILE_PATH_AS_ARGS) -o$(OUTPUT_FILE_PATH_AS_ARGS) $(OBJS_AS_ARGS) $(USER_OBJS) $(LIBS) -Wl,-lm
	@echo Finished building target: $@



$(HEX_FLASH_FILE_PATH): $(OUTPUT_FILE_PATH)
	$(QUOTE)$(AVR_APP_PATH)avr-objcopy.exe$(QUOTE) -O ihex -R .eeprom -R .fuse -R .lock -R .signature  $(QUOTE)$<$(QUOTE) $(QUOTE)$@$(QUOTE)

$(HEX_EEPROM_FILE_PATH): $(OUTPUT_FILE_PATH)
	-$(QUOTE)$(AVR_APP_PATH)avr-objcopy.exe$(QUOTE) -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma .eeprom=0 --no-change-warnings -O ihex $(QUOTE)$<$(QUOTE) $(QUOTE)$@$(QUOTE) || exit 0

$(LSS_FILE_PATH): $(OUTPUT_FILE_PATH)
	$(QUOTE)$(AVR_APP_PATH)avr-objdump.exe$(QUOTE) -h -S $(QUOTE)$<$(QUOTE) > $(QUOTE)$@$(QUOTE)

size: $(OUTPUT_FILE_PATH)
	@$(QUOTE)$(AVR_APP_PATH)avr-size.exe$(QUOTE) -C --mcu=atmega328p $(OUTPUT_FILE_PATH_AS_ARGS)

# Other Targets
clean:
	-$(RM) $(OBJS_AS_ARGS)$(C_DEPS_AS_ARGS) $(EXECUTABLES) $(LIB_AS_ARGS) $(HEX_FLASH_FILE_PATH_AS_ARGS) $(HEX_EEPROM_FILE_PATH_AS_ARGS) $(LSS_FILE_PATH_AS_ARGS) $(MAP_FILE_PATH_AS_ARGS)

