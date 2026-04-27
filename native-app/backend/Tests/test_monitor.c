#include "../Sources/Core/process_monitor.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    system_process_t self_proc;
    int self_result = get_process_info(getpid(), &self_proc);
    assert(self_result == 0);
    assert(self_proc.pid == getpid());
    assert(self_proc.start_time_epoch_ms > 0);

    system_process_t *processes = NULL;
    int count = 0;
    int all_result = get_all_processes(&processes, &count);
    assert(all_result == 0);
    assert(count >= 0);

    if (count > 0) {
        int found_self = 0;
        for (int i = 0; i < count; i++) {
            if (processes[i].pid == getpid()) {
                found_self = 1;
                assert(processes[i].start_time_epoch_ms > 0);
                break;
            }
        }
        assert(found_self == 1);
    }

    free(processes);
    printf("Monitor tests passed.\n");
    return 0;
}
