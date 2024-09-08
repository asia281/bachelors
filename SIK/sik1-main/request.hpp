#ifndef REQUEST_H
#define REQUEST_H

#include <iostream>
#include <vector>
#include "common.hpp"
using std::vector;

typedef struct request {
    int socket_fd;
    bool got;       // czy bylo zapytanie
    char type;
    uint16_t ticket_count;
    char byte_tc[2];
    uint32_t id;
    char byte_id[4];
    time_t timeout;
    char cookie[48];
} request;

#define BUFFER_SIZE 65507

vector < uint16_t > tickets;
vector < uint16_t > tickets_reserved;
char buffer[BUFFER_SIZE];
size_t events_size;
uint32_t reservation_cnt;
char buffer_events[BUFFER_SIZE + 100];


uint32_t oct4_to_int(char * buffer) {
    return static_cast<int>(static_cast<unsigned char>(buffer[0]) << 24 |
        static_cast<unsigned char>(buffer[1]) << 16 | 
        static_cast<unsigned char>(buffer[2]) << 8 | 
        static_cast<unsigned char>(buffer[3]));
}

uint16_t oct2_to_int(char * buffer) {
    return static_cast<int>(static_cast<unsigned char>(buffer[0]) << 8 |
        static_cast<unsigned char>(buffer[1]));
}

void copy(char *dest, char *source, uint16_t len) {
    for (uint16_t i = 0; i < len; i++) {
        dest[i] = source[i];
    }
}

void process_request(request *r) {
    r->type = buffer[0];
    switch (r->type) {
        case 1:
            return;
        case 3:
            copy(r->byte_id, buffer + 1, 4);
            r->id = oct4_to_int(buffer+1);
            copy(r->byte_tc, buffer + 5, 2);
            r->ticket_count = oct2_to_int(buffer+1+4);
            return;
        default:
            copy(r->byte_id, buffer + 1, 4);
            r->id = oct4_to_int(buffer+1);
            copy(r->cookie, buffer + 1 + 4, 48);
            return;
    }
}


void get_packet(request *r, struct sockaddr_in *client_address) {
    memset(buffer, 0, sizeof(buffer));
    size_t read_length = read_message(r->socket_fd, client_address, buffer, sizeof(buffer));
    
    if (read_length <= 0) {
        r->got = false;
        return;
    }

    r->got = true;
    process_request(r);
}

#endif //REQUEST_H
