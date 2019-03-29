#include "euron.h"
#include <assert.h>
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <inttypes.h>

#define N_TESTS 4
#define N 2

uint64_t get_value(uint64_t n) {
    assert(n < N);
    return n + 1;
}

void put_value(uint64_t n, uint64_t v) {
    assert(n < N);
    assert(v == n + 4);
}

typedef struct euron_args {
    uint64_t id;
    char *prog;
} euron_args;

typedef struct Test {
    uint64_t id;
    char *prog;
    uint64_t expected;
} Test;

const Test tests[N_TESTS][N] = {
        {
                {0, "91S",                                      0},
                {1, "00S",                                      9},
        },
        {
                {0, "4n+1n-+4n+1n-+SCS",                        5},
                {1, "4n+1n-+4n+1n-+SCS",                        4}
        },
        {
                {0, "4n+1n-+S",                                 5},
                {1, "4n+1n-+S",                                 4}
        },
        {
                {0, "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC", 112},
                {1, "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC", 56}
        }
};

void *thread_function(void *data) {

    euron_args args = *((euron_args *) data);
    free(data);

    fprintf(stderr, "[euron] id: %" PRIu64 ", prog: %s\n", args.id, args.prog);

    pthread_exit((void *) euron(args.id, args.prog));
}

int main() {

    pthread_t thread[N];

    void *ret;

    //branch tests, one thread
    assert(euron(N - 1, "21-+6-B") == 0);
    assert(euron(N - 1, "15B00002") == 1);
    assert(euron(N - 1, "12ED+E1-+75+-BC") == 4);
    assert(euron(0, "01234n+P56789E-+D+*G*1n-+C2*2ED+E1-+75+-BC") == 112);
    assert(euron(1, "01234n+P56789E-+D+*G*1n-+C7-7-++2ED+E1-+75+-BC") == 56);


//     synchronize tests, two threads
    for (int j = 0; j < N_TESTS; j++) {
        fprintf(stderr, "[main] test N %d\n", j);

        for (int i = 0; i < N; i++) {

            euron_args *arg = malloc(sizeof(euron_args)); // zadeklarowanie pamieci
            arg->id = tests[j][i].id;
            arg->prog = tests[j][i].prog;

            if (pthread_create(&(thread[i]), NULL, thread_function, arg) != 0) {
                fprintf(stderr, "pthread_create\n");
            }
        }

        for (int i = 0; i < N; i++) {
            if (pthread_join(thread[i], &ret) != 0) {
                fprintf(stderr, "pthread_join\n");
                exit(1);
            }
            fprintf(stderr, "[main] result for euron %d is %" PRIu64 "\n", i, (uint64_t) ret);
            assert((uint64_t) ret == tests[j][i].expected);
        }
        fprintf(stderr, "\n");
    }
    return 0;
}