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

//int cmdCount() {return 0;}
//char* cmdLine() {return "";}

void *handle;
char* (*processSequenceVni)(const char*, const bool);
char* (*processSequenceTelex)(const char*, const bool, const bool, const bool);


int main() {   
  handle = dlopen(LIB_BOGO, RTLD_LAZY);
  if (!handle) {
    printf("Unable to open library: %s\n", dlerror());
    return 1;
  }
  processSequenceVni = dlsym(handle, "processSequenceVni");
  processSequenceTelex = dlsym(handle, "processSequenceTelex");

  printf("Telex: %s\n", processSequenceTelex("Tooi laf nguoiwf Vieetj Nam", 1, 1, 1));
  printf("VNI: %s\n", processSequenceVni("To6i la2 ngươi2 Vie6t5 Nam", 1));
  
  dlclose(handle);
  return 0;  
}
  
