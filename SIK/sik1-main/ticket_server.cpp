#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <iostream>
#include <vector>
#include <queue>
#include <sys/stat.h>
#include <stdarg.h>

// Set `errno` to 0 and evaluate `x`. If `errno` changed, describe it and exit.
#define CHECK_ERRNO(x)                                                             \
    do {                                                                           \
        errno = 0;                                                                 \
        (void) (x);                                                                \
        PRINT_ERRNO();                                                             \
    } while (0)

// Print an error message and exit with an error.
inline static void fatal(const char *fmt, ...) {
    va_list fmt_args;

    fprintf(stderr, "Error: ");
    va_start(fmt_args, fmt);
    vfprintf(stderr, fmt, fmt_args);
    va_end(fmt_args);
    fprintf(stderr, "\n");
    exit(EXIT_FAILURE);
}

namespace server_functions {
// Evaluate `x`: if false, print an error message and exit with an error.
#define ENSURE(x)                                                         \
    do {                                                                  \
        bool result = (x);                                                \
        if (!result) {                                                    \
            fprintf(stderr, "Error: %s was false in %s at %s:%d\n",       \
                #x, __func__, __FILE__, __LINE__);                        \
            exit(EXIT_FAILURE);                                           \
        }                                                                 \
    } while (0)

    // Check if errno is non-zero, and if so, print an error message and exit with an error.
#define PRINT_ERRNO()                                                  \
    do {                                                               \
        if (errno != 0) {                                              \
            fprintf(stderr, "Error: errno %d in %s at %s:%d\n%s\n",    \
              errno, __func__, __FILE__, __LINE__, strerror(errno));   \
            exit(EXIT_FAILURE);                                        \
        }                                                              \
    } while (0)

    int bind_socket(uint16_t port) {
        int socket_fd = socket(AF_INET, SOCK_DGRAM, 0); // creating IPv4 UDP socket
        ENSURE(socket_fd > 0);
        struct sockaddr_in server_address;
        server_address.sin_family = AF_INET; // IPv4
        server_address.sin_addr.s_addr = htonl(INADDR_ANY); // listening on all interfaces
        server_address.sin_port = htons(port);
        // bind the socket to a concrete address
        CHECK_ERRNO(bind(socket_fd, (struct sockaddr *) &server_address,
                            (socklen_t) sizeof(server_address)));

        return socket_fd;
    }


    size_t read_message(int socket_fd, struct sockaddr_in *client_address, char *buffer, size_t max_length) {
        socklen_t address_length = (socklen_t) sizeof(*client_address);
        errno = 0;
        ssize_t len = recvfrom(socket_fd, buffer, max_length, 0,
                            (struct sockaddr *) client_address, &address_length);

        if (len < 0) {
            PRINT_ERRNO();
        }
        return (size_t) len;
    }

    void send_message(int socket_fd, const struct sockaddr_in *client_address, const char *message, size_t length) {
        socklen_t address_length = (socklen_t) sizeof(*client_address);
        ssize_t sent_length = sendto(socket_fd, message, length, 0,
                                    (struct sockaddr *) client_address, address_length);

        ENSURE(sent_length == (ssize_t) length);
    }
}

#define RESERVATION_BASE 1000*1000
#define BUFFER_SIZE 65507
#define DIV 256 

std::vector < uint16_t > tickets;
std::vector < uint16_t > tickets_reserved;
char buffer[BUFFER_SIZE];
size_t events_size;
uint32_t reservation_cnt = RESERVATION_BASE;
char buffer_events[BUFFER_SIZE + 100];

void int_to_oct(uint32_t num, char *buf) {
    for (int8_t i = 3; i >= 0; i--) {
        buf[i] = num % DIV;
        num /= DIV;
    }
}

namespace parse_file {
    size_t scan_file(FILE *file) {
        fseek(file, 0L, SEEK_END);
        size_t sz = ftell(file);
        rewind(file);
        return sz;
    }


    void create_events_response(char *fp) {
        FILE *file = fopen(fp, "r");
        if (file == NULL) fatal("file");
        size_t file_size = scan_file(file);
        memset(buffer_events, 0, sizeof(buffer_events));
        buffer_events[0] = 2;
        char line[BUFFER_SIZE];
        bool line_type = 0;
        uint16_t cnt = 0, last_size_pos = 7;

        events_size = 8;

        for (size_t i = 0; i < file_size; i += BUFFER_SIZE) {
            memset(line, 0, BUFFER_SIZE);
            size_t read_amount = fread(line, 1, BUFFER_SIZE, file);

            for (uint32_t j = 0; j < read_amount; j++) {
                if (line[j] == '\n') {
                    if (line_type) {
                        tickets.push_back(cnt);
                        cnt = 0;
                        tickets_reserved.push_back(0);
                    }
                    else if (events_size < BUFFER_SIZE + 7) {
                        buffer_events[last_size_pos] = events_size - last_size_pos - 1;
                        int_to_oct(1 + tickets.size(), buffer_events + events_size);
                        last_size_pos += buffer_events[last_size_pos] + 7;
                        events_size += 7;
                    }
                    line_type ^= 1;
                }
                else if (line_type) {
                    cnt *= 10;
                    cnt += line[j] - '0';
                }
                else if (events_size < BUFFER_SIZE + 7) {
                    buffer_events[events_size] = line[j];
                    events_size++;
                }
            }
            events_size -= 7;
            
        }
        if (events_size > BUFFER_SIZE) events_size = BUFFER_SIZE - 1;
        fclose(file);
    }
}

typedef struct request {
    int socket_fd;
    bool got;
    char type;
    uint16_t tc;
    char byte_tc[2];
    uint32_t id;
    char byte_id[4];
    time_t timeout;
    char cookie[48];
} request;

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
            r->tc = oct2_to_int(buffer+1+4);
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
    size_t read_length = server_functions::read_message(r->socket_fd, client_address, buffer, sizeof(buffer));
    if (read_length <= 0) {
        r->got = false;
        return;
    }
    r->got = true;
    process_request(r);
}

namespace response {

    typedef struct tickets_reservation {
        std::string cookie;
        uint32_t tc;
        int32_t first_ticket_id;
    } tickets_reservation;

    std::vector < tickets_reservation > cookies;

    typedef struct reservation {
        time_t time;
        uint32_t tc;
        uint32_t res_id;
        uint32_t event_id;
    } reservation;

    std::queue < reservation > expiration;

    void gen_cookie(uint16_t pos, uint16_t seed, uint16_t tc) {
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
        copy(buffer + 1, r->byte_id, 4);
        server_functions::send_message(r->socket_fd, client_address, buffer, 5);
    }

    void response_events(request *r, struct sockaddr_in *client_address) {
        uint32_t i = 5, j = 0;
        while (i < events_size && i + buffer_events[i+2] + 3 < BUFFER_SIZE) {
            buffer_events[i] = tickets[j] / DIV;
            buffer_events[i+1] = tickets[j] % DIV;
            j++;
            i += buffer_events[i+2] + 7;
        }
        server_functions::send_message(r->socket_fd, client_address, buffer_events, i-4);
    }

    void response_reservation(request *r, struct sockaddr_in *client_address) {
        if (r->tc == 0 || r->id >= tickets.size() || 
            tickets[r->id] < r->tc || BUFFER_SIZE < 7 + 7*r->tc) {
            bad_request(r, client_address);
            return;
        }
        tickets[r->id] -= r->tc;
        tickets_reserved[r->id] += r->tc;
        gen_cookie(11, reservation_cnt, r->tc);
        int_to_oct(reservation_cnt, buffer + 1);
        buffer[0] = 4;
        copy(buffer + 5, r->byte_id, 4);
        copy(buffer + 9, r->byte_tc, 2);
        time_t expiration_time = time(0);
        expiration_time += (time_t)r->timeout;
        reservation res = {expiration_time, r->tc, reservation_cnt, r->id};
        expiration.push(res);
        reservation_cnt++;

        for (uint8_t i = 8; i > 0; i--) {
            buffer[58 + i] = static_cast<unsigned char> (expiration_time % DIV);
            expiration_time /= DIV;
        }
        server_functions::send_message(r->socket_fd, client_address, buffer, 67);
    }

    uint32_t ticket_counter = 0;

    void response_tickets(request *r, struct sockaddr_in *client_address) {
        if (cookies.size() < r->id - RESERVATION_BASE) 
            return bad_request(r, client_address); 

        tickets_reservation data = cookies[r->id - RESERVATION_BASE];
        if (data.tc > 9357 || data.cookie == "" || data.cookie != r->cookie) 
            return bad_request(r, client_address);

        buffer[0] = 6;
        copy (buffer + 1, r->byte_id, 4);
        buffer[5] = data.tc / DIV;
        buffer[6] = data.tc % DIV;
        uint8_t range = 'Z' - 'A' + '9' - '0' + 1;

        int first_ticket_id = data.first_ticket_id;
        if (first_ticket_id == -1) {
            first_ticket_id = ticket_counter;
            ticket_counter += data.tc;
        }

        for (size_t i = 0; i < data.tc; i++) {
            int ticket_id = first_ticket_id + i;
            for (size_t j = 0; j < 7; j++) {
                buffer[7 + j + i*7] = ticket_id % range + '0';
                if (buffer[7 + j + i*7] > '9') buffer[7 + j + i*7] -= '9' - 'A';
                ticket_id /= range;
            }
        }
        cookies[r->id - RESERVATION_BASE].first_ticket_id = first_ticket_id;
        server_functions::send_message(r->socket_fd, client_address, buffer, 7 + 7*data.tc);
    }

    void get_response(request *r, struct sockaddr_in *client_address) {
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

}
namespace parse_flags {
    void exit_program(std::string message) {
        message.append("\n");
        printf("Usage: {argv[0]} -f <path to events file> "
            "[-p <port>] [-t <timeout>]\n");
        fprintf(stderr, "%s", message.c_str());
        exit(1);
    }

    void check_file_path(char *path) {
        struct stat buffer{};
        if (stat(path, &buffer) != 0) {
            exit_program("incorrect file path");
        }
    }

    void check_port(char *port_str, int *port_ptr) {
        size_t port = strtoul(port_str, nullptr, 10);
        if (port <= 0 || port > UINT16_MAX) {
            exit_program("incorrect port");
        }
        *port_ptr = (int) port;
    }

    void check_timeout(char *timeout_str, int *timeout_ptr) {
        size_t timeout = strtoul(timeout_str, nullptr, 10);
        if (timeout < 1 || timeout > 86400) {
            exit_program("incorrect timeout");
        }
        *timeout_ptr = (int) timeout;
    }

    void check_parameters(int argc, char *argv[], int *port_ptr, int *timeout_ptr,
                        int *file_index) {
        if ( argc % 2 == 0)
            exit_program("incorrect number of arguments");

        bool got_file = false;
        for (uint8_t i = 1; i < argc; i += 2) {
            if (strcmp(argv[i], "-f") == 0) {
                got_file = true;
                check_file_path(argv[i + 1]);
                *file_index = (i + 1);

            } else if (strcmp(argv[i], "-p") == 0) {
                check_port(argv[i + 1], port_ptr);

            } else if (strcmp(argv[i], "-t") == 0) {
                check_timeout(argv[i + 1], timeout_ptr);

            } else {
                exit_program("incorrect flag given");
            }
        }
        if (!got_file) exit_program("file path not given");
    }
}

int main(int argc, char *argv[]) {
    int port = 2022, timeout = 5;
	int file_index;

	parse_flags::check_parameters(argc, argv, &port, &timeout, &file_index);
    request *r = (request*)malloc(sizeof(request));
    r->timeout = timeout;

    parse_file::create_events_response(argv[file_index]);

    printf("Listening on port %u\n", port);

    r->socket_fd =  server_functions::bind_socket(port);

    do {
        struct sockaddr_in client_address;
        get_packet(r, &client_address);
        response::get_response(r, &client_address);
    } while (r->got);

    printf("Finished exchange\n");
    CHECK_ERRNO(close(r->socket_fd));
}