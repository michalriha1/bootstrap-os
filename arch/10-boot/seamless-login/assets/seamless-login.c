/*
 * seamless-login - Plymouth to display manager transition helper
 *
 * This program deactivates Plymouth's boot splash to allow a seamless
 * visual transition to the display manager (e.g., GDM, SDDM).
 *
 * Usage: Called by the display manager service before starting.
 */

#include <unistd.h>
#include <sys/wait.h>

static int run_command(const char *cmd, char *const argv[]) {
    pid_t pid = fork();
    if (pid == -1) {
        return -1;
    }
    if (pid == 0) {
        execvp(cmd, argv);
        _exit(127);
    }
    int status;
    waitpid(pid, &status, 0);
    return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

int main(void) {
    /* Deactivate Plymouth splash for seamless handoff to display manager */
    char *argv[] = {"plymouth", "deactivate", NULL};
    int ret = run_command("plymouth", argv);

    if (ret != 0) {
        /* Plymouth may not be running, which is fine */
        return 0;
    }

    return 0;
}
