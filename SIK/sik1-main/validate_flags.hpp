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
#include <string>

#include "request.hpp"

struct server_options{
    bool got_file;
    bool got_time;
    bool got_port;
    time_t timeout;
    int port;
    char *file;
};

typedef struct server_options server_options;


#endif //VALIDATE_FLAGS_H
