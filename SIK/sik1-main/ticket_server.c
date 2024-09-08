#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

#include "err.h"
#include "common.h"
#include "validate_flags.h"
#include "parse_file.h"
#include "request.h"
#include "response.h"

request *r;
server_options opts;

int main(int argc, char *argv[]) {
     = validate(r);

    FILE *file = fopen(opts.file, "r");
    printf("Opened file\n");

    uint16_t port = read_port(opts.port);
    printf("Listening on port %u\n", port);

    r->socket_fd = bind_socket(port);

    do {
        r = get_packet(socket_fd);
        response(r, file);
    } while (r->got);

    fclose(file);
    printf("finished exchange\n");

    CHECK_ERRNO(close(socket_fd));
}