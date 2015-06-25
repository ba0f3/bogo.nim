#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

#ifdef _WIN32
#define LIB_BOGO "../libbogo.dll"
#elif __APPLE__
#define LIB_BOGO "../libbogo.dylib"
#else
#define LIB_BOGO "../libbogo.so"
#endif
int cmdCount() {
  return 0;
}
  
char* cmdLine() {
  return "";
}


int main() {
  void *handle;
  char* (*processSequence)(const char*, const bool);
  char* (*test)(const char*);
  
  handle = dlopen(LIB_BOGO, RTLD_LAZY);
  
  if (!handle) {
    printf("Unable to open library: %s\n", dlerror());
    return 1;
  }
  //*(void **)(&processSequence) = dlsym(handle, "processSequenceVni");
  processSequence = dlsym(handle, "processSequenceVni");
  test = dlsym(handle, "test");

  printf("%s\n", processSequence("To6i la2 ngươi2 Vie6t5 Nam que6", 1));
  //printf("%s\n", test("To6i la2 ngươi2 Vie6t5 Nam que6"));

  dlclose(handle);
  return 0;  
}
  
