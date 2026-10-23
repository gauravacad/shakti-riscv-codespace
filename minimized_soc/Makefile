# ==============================================================================
# Makefile for Shakti E-Class SoC with Boot Logo on VSD Squadron FM
# ==============================================================================

PROJ = soc_top
PCF = VSDSquadronFM.pcf
DEVICE = up5k
PACKAGE = sg48
BOARD_FREQ = 12

SRCS = rtl/soc_top.v \
       rtl/mkeclass_axi4lite.v \
       rtl/mkriscv.v \
       rtl/mkstage1.v \
       rtl/mkstage2.v \
       rtl/mkstage3.v \
       rtl/mkalu.v \
       rtl/mkcsr.v \
       rtl/mkcsrfile.v \
       rtl/module_*.v \
       rtl/RegFile.v \
       rtl/FIFO*.v \
       rtl/SizedFIFO.v \
       rtl/Counter.v \
       rtl/bram_boot.v \
       rtl/spram_128kb.v \
       rtl/axi4lite_interconnect.v \
       rtl/simpleuart.v

all: build

# 1. Build Firmware (re-generates rtl/firmware.hex)
fw:
	$(MAKE) -C firmware

# 2. Synthesize with Yosys
$(PROJ).json: $(SRCS) rtl/firmware.hex
	yosys -DCPU_FREQ=$(BOARD_FREQ) -p "verilog_defaults -push; verilog_defaults -add -DSYNTHESIS; synth_ice40 -top $(PROJ) -json $@" $(SRCS)

# 3. Place & Route with NextPNR (displays exact LUT utilization)
$(PROJ).asc: $(PROJ).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(PROJ).json --pcf $(PCF) --asc $@ --timing-allow-fail

# 4. Generate Bitstream with Icepack (-s flag for coldboot mode)
$(PROJ).bin: $(PROJ).asc
	icepack -s $< $@
	@echo "=========================================================="
	@echo "SUCCESS: Hardware Bitstream Generated: $@"
	@echo "=========================================================="

build: $(PROJ).bin

# 5. Flash to SPI Flash on VSD Squadron FM
flash: $(PROJ).bin
	sudo iceprog $<

# 6. 1-Click Upload C App via Python (Fast, Reliable, Auto-Terminal)
upload:
	python3 upload.py user_app/app.bin /dev/ttyUSB1

# 7. Serial Terminal @ 115200 Baud (FPGA UART is on /dev/ttyUSB1)
terminal:
	sudo picocom -b 115200 /dev/ttyUSB1 --send-cmd "sx -vv"

terminal-9600:
	sudo picocom -b 9600 /dev/ttyUSB1 --send-cmd "sx -vv"

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin sim_soc *.vcd

.PHONY: all fw build flash clean terminal
