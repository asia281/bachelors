#ifndef VALIDATE_FLAGS_H
#define VALIDATE_FLAGS_H

#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#include "request.h"

struct server_options{
    bool got_file;
    time_t timeout;
    int32_t port;
    char *file;
};

typedef struct server_options server_options;

bool validate(server_options *my_opts, request *r) {
    my_opts = {false, 5, 2022, ""};
    char ch;
    while ( (ch = getopt(argc, argv, "f:p:t:")) != EOF ) {
        switch (ch) {
        case 'f':
            my_opts.file = optarg;
            my_opts.got_file = true;
            break;
        case 'p':
            my_opts.port = atoi(optarg);
            break;
        case 't':
            my_opts.timeout = atoi(optarg);
            break;
        default:
            // zla flaga podana
            wrong_flags();
            break;
        }
    }
    if (!my_opts.got_file || my_opts.timeout <= 0 || my_opts.timeout > 86400) return false;
    if (my_opts.port <= 0 || my_opts.port > 65535) return false;
    r->timeout = my_opts->timeout;
    return true;
}


#endif //VALIDATE_FLAGS_H
