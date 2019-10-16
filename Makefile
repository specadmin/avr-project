mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

PROJECT_NAME := $(CURRENT_DIR)
SOURCES := main.cpp lib/avr-misc/avr-misc.cpp lib/avr-debug/debug.cpp
MCU := atmega88p
ADAPTER := usbasp

OUTPUT_DIR=bin
CC=avr-g++
CFLAGS=-O -Wextra -Wall -x c++
LD_FLAGS=-nodefaultlibs
HEADERS=/usr/lib/avr/include
MORE_HEADERS=include lib
DEFINES=__AVR_ATmega88PA__ F_CPU=16000000UL


LIBS=c gcc $(MCU)
INCLUDES=$(foreach dir,$(HEADERS),-I$(dir)) $(foreach dir,$(MORE_HEADERS),-I$(dir))
DEFS=$(foreach def,$(DEFINES),-D$(def))
LD_LIBS=$(foreach lib,$(LIBS),-l$(lib))
OBJECTS=$(SOURCES:.cpp=.o)
OUTPUT_FILENAME=$(OUTPUT_DIR)/$(PROJECT_NAME).elf
MAP_FILE=$(OUTPUT_DIR)/$(PROJECT_NAME).map
ASM_FILE=$(OUTPUT_DIR)/$(PROJECT_NAME).asm
HEX_FILE=$(OUTPUT_DIR)/$(PROJECT_NAME).hex
DUMP_FILE=$(OUTPUT_DIR)/$(PROJECT_NAME).dump

all: before $(OBJECTS) $(OUTPUT_FILENAME) after

%.o: %.cpp
	$(CC) -c $(CFLAGS) $(INCLUDES) $(DEFS) $< -o $@

$(OUTPUT_FILENAME): $(OBJECTS)
	$(CC) -o $(OUTPUT_FILENAME) $(OBJECTS) $(LD_FLAGS) -mmcu=$(MCU) $(LD_LIBS) -Wl,-Map=$(MAP_FILE)

before:
	rm -f $(MAP_FILE)
	rm -f $(HEX_FILE)
	rm -f $(ASM_FILE)
	rm -f $(DUMP_FILE)

after: $(OUTPUT_FILENAME)
	avr-objdump -dS $(OUTPUT_FILENAME) > $(ASM_FILE) 
	avr-strip --strip-debug -R .comment $(OUTPUT_FILENAME)
	avr-objcopy -R .eeprom -R .fuse -R .lock -R .signature -O ihex $(OUTPUT_FILENAME) $(HEX_FILE)
	avr-objdump -xC $(OUTPUT_FILENAME) > $(DUMP_FILE)
	grep -m1 ".text  " $(MAP_FILE) > $(OUTPUT_DIR)/.text
	grep -A 35 "00000000" $(ASM_FILE) >> $(OUTPUT_DIR)/.text
	grep "F .text" $(DUMP_FILE) | sort >> $(OUTPUT_DIR)/.text
	avr-size -dBt --common `find . -name '*.o'`
	avr-size -C --mcu=$(MCU) -d $(OUTPUT_FILENAME)
	mv $(OUTPUT_DIR)/.text $(MAP_FILE)
	rm -f $(OUTPUT_FILENAME) $(DUMP_FILE)
	
.PHONY clean:
	rm -rf $(OBJECTS) 
	rm -f `find . -name '*.ii'`
	rm -f `find . -name '*.s'`

install: $(HEX_FILE)
	avrdude -p $(MCU) -c $(ADAPTER) -V -U flash:w:$(HEX_FILE)
