#ifndef PARSE_FILE_H
#define PARSE_FILE_H

#include "request.hpp"
#define DIV 256 

size_t scan_file(FILE *file) {
  fseek(file, 0L, SEEK_END);
  size_t sz = ftell(file);
  rewind(file);
  return sz;
}

void int_to_oct(int num, char *buf) {
    for (int i = 3; i >= 0; i--) {
        buf[i] = num % DIV;
        num /= DIV;
    }
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

        for (size_t j = 0; j < read_amount; j++) {
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
    if (events_size > BUFFER_SIZE) events_size = BUFFER_SIZE-1;
    fclose(file);

}


#endif //PARSE_FILE_H
