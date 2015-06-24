#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int cmdCount() {
  return 0;
}
  
char* cmdLine() {
  return "";
}

int main() {
  void *handle;
  char* (*processSequence)(const char*, const bool);
  
  handle = dlopen("../libbogo.so", RTLD_LAZY);
  
  if (!handle) {
    printf("Unable to open library: %s\n", dlerror());
    return 1;
  }
  //*(void **)(&processSequence) = dlsym(handle, "processSequenceVni");
  processSequence = dlsym(handle, "processSequenceVni");

  //printf("%s\n", processSequence("To6i la2 nguo*i2 Vie65t Nam", 1));
  printf("%s\n", processSequence("To6i la2 Vie65t", 1));

  dlclose(handle);
  return 0;  
}
  
