#ifndef RESPONSE_H
#define RESPONSE_H

#include <time.h>
#include "request.h"
#include "common.h"

void bad_request(request *r) {
    send_message(r->socket_fd, r->client_address, );
}

void response_events(request *r, FILE *file) {

}

void response_reservation(request *r) {
    time_t expiration_time = r->timeout + time;
}

void response_tickets(request *r) {

}

void response(request *r, FILE *file) {
    switch (r->type) {
    case 1:
        response_events(r, file);
        break;
    case 3:
        response_reservation(r);
    case 5:
        response_tickets(r);
    }
}

char *generate_ticket() {

}

#endif //RESPONSE_H
