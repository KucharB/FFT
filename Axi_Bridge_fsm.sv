package Axi_Bridge_fsm;
  typedef enum logic [3:0] {  
    bridge_IDLE = 4'b000,
    bridge_ADDR_WRITE,
    bridge_DATA_WRITE,
    bridge_WRITE_RESPONSE,
    bridge_WAIT,
    bridge_ADDR_READ,
    bridge_DATA_READ,
    bridge_READ_LAST
  } bridge_fsm;
endpackage