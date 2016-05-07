#ifndef __LIBSCCMN_HEARTBEAT_H__
#define __LIBSCCMN_HEARTBEAT_H__

struct heartbeat_watcher;

typedef void (* heartbeat_cb)(struct ev_loop * loop, struct heartbeat_watcher * watcher, ev_tstamp now);

struct heartbeat_watcher
{
	struct heartbeat_watcher * next;
	struct heartbeat_watcher * prev;

	heartbeat_cb cb;
	void * data;
};

struct heartbeat
{
	struct heartbeat_watcher * first_watcher;
	struct heartbeat_watcher * last_watcher;

	ev_timer timer_w;
	ev_tstamp last_beat;
};

void heartbeat_init(struct heartbeat * , ev_tstamp repeat);

void heartbeat_start(struct ev_loop * loop, struct heartbeat *);
void heartbeat_stop(struct ev_loop * loop, struct heartbeat *);

void heartbeat_add(struct heartbeat *, struct heartbeat_watcher * watcher, heartbeat_cb cb);
void heartbeat_remove(struct heartbeat *, struct heartbeat_watcher * watcher);

#endif //__LIBSCCMN_HEARTBEAT_H__
