package nome;
simple src{
	parameters:
		volatile double ds@unit(s);
	gates:
		output o;
}
simple coda{
	parameters:
		int c;
		volatile double dc@unit(s);
	gates:
		input i
		output o;
}
simple dst{
	gates:
		input i;
}
network fifol{
	submodules:
		src:src{parameters: ds=exponential(3s);}
		coda:coda{parameters: dx=trunconormal(4s,2s);c=10}
		dst:dst;
	connections:
		src.o->coda.i;
		coda.o->dst.i;
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
#include "stdio.h"
#include "omnetpp.h"
class src: public cSimpleModule{
	private:
		cMessage +event;
		cMessage *m;
		simtime_t d;
		long numSentS;
	public:
		src();
		virtual ~src();
	protected:
		virtual void initialize();
		virtual void handleMessage(cMessage *msg);
		virtual void finish();
};
Define_Module(src);
src::src(){
	event=m=NULL;
	numSentS=0
}
src::~src(){
	cancelAndDelete(m);
	cancelAndDelete(event);
}

void src::initialize(){
	event= new cMessage("event");
	d=par("ds");
	scheduleAt(simTime()+d,event);
}
void src::handleMessage(cMessage *msg){
	if(msg==event){
		m=new cMessage("messaggio");
		send(m,"o");
		d=par("ds")
		numSentS++;
		scheduleAt(simTime()+d,e);
	}
}

void src:: finish(){
	recordScalar("numero inviati:" numSentS);
}

class coda: public cSimpleModule{
	private:
		cMessage +event;
		cMessage *m;
		simtime_t d;
		cQueue q;
		int capacita;
		long numSentC;
		long numReceivedC;
		long numDeletedC;
	public:
		coda();
		virtual ~coda();
	protected:
		virtual void initialize();
		virtual void handleMessage(cMessage *msg);
		virtual void finish();
};
Define_Module(coda);
coda::coda(){
	numeSentC=numDeletedC=numReceivedC=0;
	event=m=NULL;
	capacita=par("c");
	
}

coda::~coda(){
	cancelAndDelete(m);
	cancelAndDelete(event);
}

void coda::initialize(){
	q.setName("CODA");
}

void coda::handleMessage(cMessage *msg){
	if(msg==event){
		if(!q.empty()){
			m=check_and_cast<cMessage*> (q.pop());
			send(m,"o");
			numeSentC++;
			event=new cMessage("event");
			d=par("dc");
			scheduleAt(simTime()+d,event);
		}else
			canceEvent(event);
	}else{
		if(q.length()<capacita){
				q.insert(msg);
				event=new cMessage("event");
				d=par("dc");
				scheduleAt(simTime()+d,event);
				numReceivedC++;
				
		}else{
			delete msg;
			numDeletedC++;
		}
		
		
	}
	
}

void coda::finish(){
	recordScalar("numero Eliminati:"numDeletedC);
	recordScalar("numero ricevutii:"numReceivedC);
	recordScalar("numero inviati:"numSentC);
}
class dst: public cSimpleModule{
	protected:
		virtual void initialize();
		virtual void handleMessage(cMessage *msg);
		virtual void finish();
	private:
		long numReceivedD;
};
Define_Module(dst);

void dst::initialize{
	numReceivedD=0;
}
void dst::handleMessage(cMessage *msg){
	delete m;
	numReceivedD++;
}
void dst:: finish(){
	recordScalar("numero ricevuti:" numReceivedD);
}
