#ifndef __LIBSCCMN_SOCK_EST_H__
#define __LIBSCCMN_SOCK_EST_H__

struct established_socket;

struct established_socket_cb
{
	size_t (*read_advise)(struct established_socket *, struct frame * frame);

	// True as a return value means, that the frame has been handed over to upstream protocol
	bool (*read)(struct ev_loop * loop, struct established_socket *, struct frame * frame);
};

struct established_socket
{
	// Input
	struct ev_io read_watcher;
	struct frame * read_frame;

	// Output
	struct ev_io write_watcher;

	// Common fields
	int ai_family;
	int ai_socktype;
	int ai_protocol;

	struct sockaddr_storage ai_addr;
	socklen_t ai_addrlen;

	struct frame_pool * frame_pool;

	struct established_socket_cb * cbs;

	// Custom data field
	void * data;
};

bool established_socket_init(struct established_socket *, struct established_socket_cb * cbs, struct frame_pool * frame_pool, struct listening_socket * listening_socket, int fd, const struct sockaddr * peer_addr, socklen_t peer_addr_len);

bool established_socket_read_start(struct ev_loop * loop, struct established_socket *);
bool established_socket_read_stop(struct ev_loop * loop, struct established_socket *);

bool established_socket_shutdown(struct established_socket *);

#endif // __LIBSCCMN_SOCK_EST_H__