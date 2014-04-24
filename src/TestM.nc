#include "routing_table.h"
#include "rssimessage.h"


module TestM {
  
  uses {
    interface Boot;
    interface Leds;
    interface SplitControl;
    interface AMPacket as MHPacket;
    interface Packet;
    interface Receive;
    interface Intercept;
    interface AMSend as MHSend;
    interface Timer<TMilli>;
    interface CC2420Packet;
   	interface MHControl;
   	interface Receive as RReceive;
  }
  
  uses {
	  //Radio interface
	  interface Packet as BeaconPacket;
	  interface AMSend as AMBeaconSend;
	  interface AMPacket as AMBeaconPacket;
	  interface SplitControl as AMBeaconControl;
 
	  interface Receive as BeaconReceive;
	  //	uses interface Intercept; // added by me
 
	
  }
  
  
#ifdef DYMO_MONITORING
  uses interface DymoMonitor;
#endif
}

implementation {

  enum {
    ORIGIN = 1,
    TARGET = 3,
	NODE_X = 2, //AM_BROADCAST_ADDR,
  };
  uint8_t flag = 0; 
  uint8_t dest = TARGET;
  uint16_t rssi = 0;
  message_t pkt; 
  message_t bpkt; //beacon packet
  uint16_t seq_number = 1;
  uint8_t busy = FALSE; 
 // uint16_t pl;
	    
  
  		  
uint16_t getRssi(message_t *msg){
		return (uint16_t) call CC2420Packet.getRssi(msg);
	}


  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0Toggle();
    if (val & 0x02)
      call Leds.led1Toggle();
    if (val & 0x04)
      call Leds.led2Toggle();
  }

  task void stop(){
    call SplitControl.stop();
	call AMBeaconControl.stop();
  }

  event void Boot.booted(){
    call SplitControl.start();
    call AMBeaconControl.start();

  }

  event void SplitControl.startDone(error_t e){
    if(call MHPacket.address() == ORIGIN){
      call Timer.startPeriodic(256);
    }
  }

  event void Timer.fired(){ // time to send a message
	  // if (!busy){
	  //
	  
	  error_t error;
	  // 
	 
	  // 

	  //error = call MHSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RssiMsg));
	  if (flag == 0)
	  {
		uint16_t * pl = (uint16_t *)(call Packet.getPayload(&pkt, 2));   
		*pl = 0x1978; 	
		  error = call MHSend.send(TARGET, &pkt, sizeof(*pl));
		  if (error == SUCCESS)
		  {
			  busy = TRUE;
		  }
		  flag = 1;
	  }
	  else 
	  {
	  	
	  RssiMsg * rssipkt = (RssiMsg *)(call BeaconPacket.getPayload(&bpkt, sizeof(RssiMsg)));
	 	rssipkt->seq = seq_number++; // the sequence number of this transmission.
		 rssipkt->nodeid = 0x3333; // put the destination node id in the packet. 
		  error = call AMBeaconSend.send(AM_BROADCAST_ADDR, &bpkt, sizeof(RssiMsg));
		  if (error == SUCCESS)
		  {
			  busy = TRUE;
			  call Leds.led1Toggle();	
		  }
		  flag = 0;
	  }
	
	  //	  }
 
  }

  event void MHSend.sendDone(message_t * msg, error_t e){
	  if((e == SUCCESS) && (msg == &pkt) && (call MHPacket.address() == ORIGIN)){
		  // Message sent
		//  setLeds(1); //toggle led 1. 
	  } else if (e == FAIL) {
		  // Message sending failed
		//  setLeds(2); // toggle led 2 
	  } else {
		  // something went wrong.
		//  setLeds(4);
	  }
	  if (msg == &pkt){
		  busy = FALSE;
	  }
  }
 
  event message_t * Receive.receive(message_t * msg, void * payload, uint8_t len){
    if(call MHPacket.address() == TARGET){
      // The message was for this node...! 
      setLeds(1);
    } 
    else {
      dbg("messages", "What is this message?\n");
      
      //setLeds(1);
    }
     
    return msg;
  }

  event bool Intercept.forward(message_t * msg, void * payload, uint8_t len){	
	// forward this message, its not for me. 
	
    setLeds(2); // set the the second (green) led and fwd the message. 
    return TRUE;
  }

  event void SplitControl.stopDone(error_t e){}

#ifdef DYMO_MONITORING

  event void DymoMonitor.msgReceived(message_t * msg){
    dbg("messages", "Dymo msg received.\n");
  }

  event void DymoMonitor.msgSent(message_t * msg){
    dbg("messages", "Dymo msg sent.\n");
  }

  event void DymoMonitor.routeDiscovered(uint32_t delay, addr_t target){
    dbg("messages", "Route for %u discovered in %lu milliseconds.\n", target, delay);
  }

#endif


	event void MHControl.sendFailed(message_t *msg, uint8_t why){
		// TODO Auto-generated method stub
	}

	event void MHControl.msgReceived(message_t *msg){
		//call Leds.led0Toggle();
		
	}

	event message_t * RReceive.receive(message_t *msg, void *payload, uint8_t len){
	//	call Leds.led0Toggle();
	call Leds.led1Toggle();
	//	call Leds.led2Toggle();
		
		return msg;
	}

	event void AMBeaconSend.sendDone(message_t *msg, error_t e){
	
		if((e == SUCCESS) && (msg == &bpkt)){
			// Message sent
			 setLeds(2); //toggle led 1. 
		} else if (e == FAIL) {
			// Message sending failed
			//  setLeds(2); // toggle led 2 
		} else {
			// something went wrong.
			//  setLeds(4);
		}

	}

	event void AMBeaconControl.startDone(error_t error){
		
		if (error != SUCCESS){
			call AMBeaconControl.start();
		}
		
	}

	event void AMBeaconControl.stopDone(error_t error){
	
	}

	event message_t * BeaconReceive.receive(message_t *msg, void *payload, uint8_t len){
		//if (len == sizeof(RssiMsg)){
		// TODO Auto-generated method stub
		setLeds(4);
//	}
		return msg;
	}
}
