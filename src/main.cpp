
#include <iostream>

extern "C" {
  #include "bridge.h"
}


int main() {
  std::cout << "Invoking OBJC" << std::endl;
  return ApplicationMain(); // AppDelegate.m
}


