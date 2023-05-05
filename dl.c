#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>
#include <unistd.h>

int main(int argc, char **argv) {
    void *handle;
    int (*cosine)(void);
    char *error;

    while (1) {

    handle = dlopen ("./hello_lib.so", RTLD_LAZY);
    if (!handle) {
        fputs (dlerror(), stderr);
        exit(1);
    }

    cosine = dlsym(handle, "plugin");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    (*cosine)();
    dlclose(handle);
    sleep(1);  
    }

}

