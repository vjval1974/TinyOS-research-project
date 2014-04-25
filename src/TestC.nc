
#define CC2420_DEF_RFPOWER 2
#define MAX_TABLE_SIZE 10
//#define DYMO_MONITORING 
//#include "RssiToSerial.h"

configuration TestC {

}

implementation {
  components TestM, DymoNetworkC;
  components MainC, LedsC, new TimerMilliC();
  components CC2420ActiveMessageC, ActiveMessageC;
  components new AMSenderC(6) as BeaconSenderC;
  components new AMReceiverC(6) as BeaconReceiverC;

  TestM.Boot  -> MainC;
  TestM.Leds  -> LedsC;
  TestM.Timer -> TimerMilliC;
  TestM.SplitControl -> DymoNetworkC;
  TestM.Packet       -> DymoNetworkC;
  TestM.MHPacket     -> DymoNetworkC;
  TestM.Receive      -> DymoNetworkC.Receive[1];
  TestM.Intercept    -> DymoNetworkC.Intercept[1];
  TestM.MHSend       -> DymoNetworkC.MHSend[1];
  
  TestM -> CC2420ActiveMessageC.CC2420Packet;
  TestM.RReceive -> ActiveMessageC.Snoop[1];
  TestM.MHControl -> DymoNetworkC;

// This section can be put in it's own module and run independently.
 	TestM.BeaconPacket -> BeaconSenderC;
	TestM.AMBeaconPacket -> BeaconSenderC;
	TestM.AMBeaconSend -> BeaconSenderC;
	TestM.AMBeaconControl -> ActiveMessageC;
    TestM.BeaconReceive -> BeaconReceiverC;
  	
  
#ifdef DYMO_MONITORING
  TestM.DymoMonitor -> DymoNetworkC;
#endif
}
