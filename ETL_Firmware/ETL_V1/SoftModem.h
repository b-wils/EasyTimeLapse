#ifndef SoftModem_h
#define SoftModem_h

// #define SOFT_MODEM_BAUD_RATE   (5)
// #define SOFT_MODEM_LOW_FREQ    (882)
// #define SOFT_MODEM_HIGH_FREQ   (1764)
// #define SOFT_MODEM_MAX_RX_BUFF (32)

#define SOFT_MODEM_BAUD_RATE   (500)
#define SOFT_MODEM_LOW_FREQ    (2000)
#define SOFT_MODEM_HIGH_FREQ   (4000)
#define SOFT_MODEM_MAX_RX_BUFF (64)

// #define SOFT_MODEM_BAUD_RATE   (315)
// #define SOFT_MODEM_LOW_FREQ    (1575)
// #define SOFT_MODEM_HIGH_FREQ   (3150)
// #define SOFT_MODEM_MAX_RX_BUFF (8)

// #define SOFT_MODEM_BAUD_RATE   (630)
// #define SOFT_MODEM_LOW_FREQ    (3150)
// #define SOFT_MODEM_HIGH_FREQ   (6300)
// #define SOFT_MODEM_MAX_RX_BUFF (16)

//#define SOFT_MODEM_BAUD_RATE   (600)
//#define SOFT_MODEM_LOW_FREQ    (2666)
//#define SOFT_MODEM_HIGH_FREQ   (4000)
//#define SOFT_MODEM_MAX_RX_BUFF (16)

// #define SOFT_MODEM_BAUD_RATE   (1225)
// #define SOFT_MODEM_LOW_FREQ    (4900)
// #define SOFT_MODEM_HIGH_FREQ   (7350)
// #define SOFT_MODEM_MAX_RX_BUFF (32)

//#define SOFT_MODEM_BAUD_RATE   (2450)
//#define SOFT_MODEM_LOW_FREQ    (7350)
//#define SOFT_MODEM_HIGH_FREQ   (14700)
//#define SOFT_MODEM_MAX_RX_BUFF (32)

//  Brief carrier tone before each transmission
//  1 start bit (LOW)
//  8 data bits, LSB first
//  1 stop bit (HIGH)
//  1 push bit (HIGH)

#define SOFT_MODEM_MAX_WRITE_BUFFER (32)

#include <inttypes.h>
#include <avr/io.h>

//#define SOFT_MODEM_DEBUG       (1)

class SoftModem
{
private:
	volatile uint8_t *_txPortReg;
	uint8_t _txPortMask;
	uint8_t _lastTCNT;
	uint8_t _lastDiff;
	uint8_t _recvStat;
	uint8_t _recvBits;
	uint8_t _recvBufferHead;
	uint8_t _recvBufferTail;
	uint8_t _recvBuffer[SOFT_MODEM_MAX_RX_BUFF];
	uint8_t _sendBufferHead;
	uint8_t _sendBufferTail;
	uint8_t _sendBuffer[SOFT_MODEM_MAX_WRITE_BUFFER];
	uint16_t _lowCount;  // TODO upped this to 16bit values to deal with overflow
	uint16_t _highCount; // Do deeper investigation between depth and modem settings
	void modulate(uint8_t b);
public:
	SoftModem();
	~SoftModem();
	void begin(void);
	void end(void);
	uint8_t available(void);
	int read(void);
	#if defined(ARDUINO) && ARDUINO >= 100
	size_t write(uint8_t data);
	//size_t writeBytes(uint8_t *data, uint16_t length);
	#else
	void write(uint8_t data);
	void writeBytes(uint8_t *data, uint16_t length);
	void fillBuffer(uint8_t *data, uint16_t length);
	void flushBuffer(uint16_t bytes);
	#endif
	void demodulate(void);
	void recv(void);
	static SoftModem *activeObject;
	uint16_t anaISRCnt;
	uint16_t timer2ISRCnt;
	uint16_t lowNoiseCnt;
	uint16_t midNoiseCnt;
	uint16_t highNoiseCnt;
	uint32_t lowSignalCnt;
	uint32_t highSignalCnt;
	void printDebugInfo(short resetCounts);
	void resetSignalCounts();
#if SOFT_MODEM_DEBUG
	void handleAnalogComp(bool high);
	void demodulateTest(void);
	uint8_t _errs;
	uint16_t _ints;
	uint8_t errs;
	uint16_t ints;
#endif
};

#endif
