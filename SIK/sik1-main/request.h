#ifndef REQUEST_H
#define REQUEST_H

#include <stdint.h>

typedef struct request {
    int socket_fd;
    const struct sockaddr_in *client_address;
    bool got;       // czy bylo zapytanie
    int8_t type;
    int16_t ticket_count;
    int32_t id;
    time_t timeout;

    char *cookie;

} request;


#define BUFFER_SIZE 1000

char buffer[BUFFER_SIZE];

void get_packet(request *r) {
    size_t read_length = read_message(r->socket_fd, &(r->client_address), buffer, sizeof(buffer));
    
    if (read_length <= 0) {
        r->got = false;
        return;
    }

    r->got = true;

    // process -- get message_id

    char* client_ip = inet_ntoa(client_address.sin_addr);

    uint16_t client_port = ntohs(client_address.sin_port);
    printf("received %zd bytes from client %s:%u: '%.*s'\n", read_length, client_ip, client_port,
               (int) read_length, buffer); // note: we specify the length of the printed string

}


#endif //REQUEST_H
