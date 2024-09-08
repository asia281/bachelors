#ifndef RESPONSE_H
#define RESPONSE_H

#include <time.h>
#include <string>
#include <queue>
#include "request.hpp"

#define DIV 256 

#define RESERVATION_BASE 1000*1000

typedef struct tickets_reservation {
    std::string cookie;
    int tc;
    int first_ticket_id;
} tickets_reservation;

std::vector < tickets_reservation > cookies;

typedef struct reservation {
    time_t time;
    uint16_t tc;
    uint32_t res_id;
    uint32_t event_id;
} reservation;

std::queue < reservation > expiration;

void gen_cookie(uint16_t pos, int seed, int tc) {
    srand(seed);
    std::string c = "";

    for (uint8_t i = 0; i < 48; i++) {
        buffer[pos + i] = rand() % 94 + 33;
        c += buffer[pos + i];
    }
    cookies.push_back({c, tc, -1});
}


void bad_request(request *r, struct sockaddr_in *client_address) {
    buffer[0] = 255;
    copy (buffer + 1, r->byte_id, 4);
    send_message(r->socket_fd, client_address, buffer, 5);
}

void response_events(request *r, struct sockaddr_in *client_address) {
    size_t i = 5, j = 0;
    while (i < events_size) {
        buffer_events[i] = tickets[j] / DIV;
        buffer_events[i+1] = tickets[j] % DIV;
        j++;
        i += buffer_events[i+2] + 7;
    }
    
    send_message(r->socket_fd, client_address, buffer_events, events_size);
}

void response_reservation(request *r, struct sockaddr_in *client_address) {
    if (r->ticket_count == 0 || r->id >= tickets.size() || tickets[r->id] < r->ticket_count || BUFFER_SIZE < 7 + 7*r->ticket_count) {
        bad_request(r, client_address);
        return;
    }
    tickets[r->id] -= r->ticket_count;
    tickets_reserved[r->id] += r->ticket_count;
    int res_num = reservation_cnt;
    gen_cookie(11, res_num, r->ticket_count);
    for (int i = 4; i > 0; i--) {
        buffer[i] = res_num % DIV;
        res_num /= DIV;
    }
    buffer[0] = 4;
    reservation_cnt++;
    copy(buffer + 5, r->byte_id, 4);
    copy(buffer + 9, r->byte_tc, 2);
    time_t expiration_time = time(0);
    expiration_time += (time_t)r->timeout;
    std::cout << reservation_cnt-1 << " " << expiration_time << "exp\n";
    reservation res = {expiration_time, r->ticket_count, reservation_cnt-1, r->id};
    expiration.push(res);


    for (int i = 8; i > 0; i--) {
        buffer[58 + i] = static_cast<unsigned char> (expiration_time % DIV);
        expiration_time /= DIV;
    }
    send_message(r->socket_fd, client_address, buffer, 67);
}

int ticket_counter = 0;

void response_tickets(request *r, struct sockaddr_in *client_address) {
    if (7 + 7*r->ticket_count > BUFFER_SIZE) return bad_request(r, client_address);
    std::cout << cookies.size() << " " << r->id << "rid\n";
    if (cookies.size() < r->id - RESERVATION_BASE) return bad_request(r, client_address); 
    std::cout << "nana";
    tickets_reservation data = cookies[r->id - RESERVATION_BASE];
    if (data.cookie == "" || data.cookie != r->cookie) return bad_request(r, client_address);
    std::cout << "lala";
    buffer[0] = 6;
    copy (buffer + 1, r->byte_id, 4);
    copy (buffer + 5, r->byte_tc, 2);
    int zakres = 'Z' - 'A';

    int first_ticket_id = data.first_ticket_id;
    if (first_ticket_id == -1) {
        first_ticket_id = ticket_counter;
        ticket_counter += data.tc;
    }

    for (size_t i = 0; i < data.tc; i++) {
        int ticket_id = first_ticket_id + i;
        for (size_t j = 0; j < 7; j++) {
            buffer[7 + j + i*7] = ticket_id % zakres + 'A';
            ticket_id /= zakres;
        }
    }
    cookies[r->id - RESERVATION_BASE].first_ticket_id = first_ticket_id;
    std::cout <<  "tickets" << std::endl;
    send_message(r->socket_fd, client_address, buffer, 7 + 7*r->ticket_count);

}

void response(request *r, struct sockaddr_in *client_address) {
    time_t now = (time_t)time(0);

    while (!expiration.empty() && expiration.front().time < now ) {
        reservation res = expiration.front();
        if (cookies[res.res_id - RESERVATION_BASE].first_ticket_id == -1) {
            tickets[res.event_id] += res.tc;
            tickets_reserved[res.event_id] -= res.tc;
            cookies[res.res_id - RESERVATION_BASE].cookie = "";
        }
        expiration.pop();

    }

    memset(buffer, 0, sizeof(buffer));
    switch (r->type) {
    case 1:
        response_events(r, client_address);
        break;
    case 3:
        response_reservation(r, client_address);
        break;
    case 5:
        response_tickets(r, client_address);
        break;
    }
}


#endif //RESPONSE_H
