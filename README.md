AXI State Machine
Overview
This repository contains a SystemVerilog implementation of an AXI state machine that interfaces with a SPI bus. The module handles AXI read and write transactions based on SPI inputs and manages the state transitions for proper data communication.

File Description
axi_state_machine.sv: SystemVerilog file containing the implementation of the AXI state machine.
Features
Interfaces with AXI and SPI buses.
Handles AXI write and read transactions.
Uses state machines for AXI and SPI communication management.
Supports asynchronous reset for both AXI and SPI domains.
Contains internal registers for data and address storage.
Inputs and Outputs
Inputs
AXI_ACLK: System clock signal for the AXI interface.
AXI_ARESETN: Active low asynchronous reset signal for the AXI interface.
CLK_50MHZ: 50 MHz clock signal for the SPI interface.
RESET: Active low asynchronous reset signal for the SPI interface.
AXI_AWREADY: Indicates that the slave is ready to accept an address and control information.
AXI_WREADY: Indicates that the slave is ready to accept write data.
AXI_BRESP: Write response from the slave.
AXI_BVALID: Indicates that a valid write response is available.
AXI_ARREADY: Indicates that the slave is ready to accept a read address and control information.
AXI_RDATA: Read data from the slave.
AXI_RRESP: Read response from the slave.
AXI_RVALID: Indicates that the read data is valid.
MOSI: Master Out Slave In signal from the SPI interface.
SCLK: Serial clock signal from the SPI interface.
CS: Chip select signal from the SPI interface.
Outputs
AXI_AWADDR: Write address for AXI.
AXI_AWPROT: Write protection type.
AXI_AWVALID: Indicates that the address and control information are valid.
AXI_WDATA: Write data for AXI.
AXI_WSTRB: Write strobe.
AXI_WVALID: Indicates that the write data is valid.
AXI_BREADY: Indicates that the master is ready to accept the write response.
AXI_ARADDR: Read address for AXI.
AXI_ARPROT: Read protection type.
AXI_ARVALID: Indicates that the read address and control information are valid.
AXI_RREADY: Indicates that the master is ready to accept the read data.
MISO: Master In Slave Out signal for the SPI interface.
Internal Signals and Registers
Internal Signals
axi_done: Indicates the completion of an AXI transaction.
state_write: State variable for the AXI write state machine.
start_axi_write: Signal to start an AXI write transaction.
start_axi_read: Signal to start an AXI read transaction.
awvalid, wvalid, arvalid, rready, bready: Control signals for AXI transactions.
awaddr, wdata, araddr: Address and data registers for AXI transactions.
read_data: Data read from the AXI slave.
SPI Specific Signals
MISO_i: Internal MISO signal.
DATA_REG_i, ADDR_REG_i: Internal registers for data and address storage.
cycle, state: State and cycle counters for SPI communication.
input_reg, output_reg: Registers for storing input and output data for SPI transactions.
rec_input_reg, can_reg_address: Registers for received input data and address.
sclk_low_sync, sclk_low_sync1, sclk_low: Synchronization signals for SCLK.
address_index, data_index: Index counters for data and address bits.
sclk_pos_edge, sclk_neg_edge: Edge detection signals for SCLK.
h_count, l_count, delay_counter: Counters for timing and delay management.
sclk_high, channel_count, temp: Additional control and temporary signals.
sync0_MOSI, sync1_MOSI, sync0_SCLK, sync1_SCLK, sync0_CS, sync1_CS: Synchronization signals for MOSI, SCLK, and CS.
posedge_MOSI, posedge_CS, posedge_SCLK: Edge detection signals for MOSI, CS, and SCLK.
spi_done: Indicates the completion of an SPI transaction.
ADDRESS_TO_BE_READ: Address to be read during AXI read transactions.
State Machines
AXI Write State Machine
Idle State (3'd0): Initializes the write address and data, sets the control signals for AXI write transaction, and moves to the next state.
Wait for Write Completion (3'd1): Waits for AXI slave to accept the write address and data. Once the slave responds, the state machine moves to the next state.
Completion State (3'd2): Resets the state machine to the idle state for the next transaction.
SPI State Machine
Idle State (6'd0): Initializes the SPI transaction and waits for the chip select (CS) signal.
Wait for Chip Select (6'd1): Waits for the CS signal to go low, indicating the start of a SPI transaction.
Receive Address (6'd2): Receives the address bits from MOSI.
Address Handling (6'd3): Determines if the received address is for a read or write operation.
Receive Data (6'd4): Receives data bits from MOSI for a write operation.
Read Data (6'd5): Reads data from internal registers based on the received address.
Transmit Data (6'd6): Transmits data bits to MISO for a read operation.
Completion State (6'd7): Completes the SPI transaction and resets the state machine to the idle state.
Summary
The axi_state_machine module is designed to interface with both AXI and SPI buses, handling read and write transactions through state machines. The module uses a combination of internal registers and signals to manage data communication and ensures proper synchronization between different clock domains.

For detailed signal waveforms and timing diagrams, refer to the implementation details in the axi_state_machine.sv file.
