package Axi_Bridge_fsm;
  typedef enum logic [1:0] {  
    bridge_IDLE = 2'b00,
    bridge_READ,
    bridge_WRITE,
    bridge_WAIT
  } bridge_fsm;
endpackage