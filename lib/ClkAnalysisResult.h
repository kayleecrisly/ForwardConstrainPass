#ifndef CLKANALYSISRESULT_H
#define CLKANALYSISRESULT_H

#include <string>
#include <vector>
#include <cstdint>

namespace clk_analysis {

struct APBRegisterMapping {
  std::string signalName;
  std::string registerName;
  uint32_t address;
  uint32_t bitWidth;
  bool isWritable = true;
  bool isReadable = true;
  bool isW1C = false;
};

struct AddressConflict {
  uint32_t address;
  std::vector<std::string> registerNames;
};

struct CombinationalAssignment {
  unsigned bitWidth = 0;
  std::string targetSignal;
  std::string expression;
};

} // namespace clk_analysis

#endif
