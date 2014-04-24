#ifndef RSSIMESSAGE_H
#define RSSIMESSAGE_H



typedef nx_struct RssiMsg {
	nx_uint16_t nodeid;
	nx_uint16_t seq;
	nx_uint16_t rssi;
	nx_uint32_t TEST;
} RssiMsg;


enum {
  AM_RSSIMSG = 9,
};
#endif /* RSSIMESSAGE_H */
