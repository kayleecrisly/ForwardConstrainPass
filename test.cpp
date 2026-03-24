#include "mlir/Pass/Pass.h"
#define GEN_PASS_DECL_FORWARDCONSTRAIN
#define GEN_PASS_DEF_FORWARDCONSTRAIN
#include "build/Passes.h.inc"
namespace {
struct ForwardConstrainPass : public impl::ForwardConstrainBase<ForwardConstrainPass> {};
}
std::unique_ptr<mlir::Pass> createForwardConstrainPass() { return std::make_unique<ForwardConstrainPass>(); }
int main() {}
