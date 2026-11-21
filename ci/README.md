Native package builds use the explicit platform inventory and pinned flake inputs.
Selected completed public build outputs and their runtime closures are exported to
a separate publisher job, including reusable dependencies after a later failure.
Handy's native workflows set an 8 GiB uncompressed limit for both export and
import through the legacy ATTIC_MAX_CLOSURE_MIB setting. Oversize transfers fail
rather than dropping selected outputs.

Trusted owning-repository default-branch jobs read the shared private Niks3 cache
with read-only OIDC. Separate publisher jobs use GitHub OIDC for Niks3 writes;
application builds receive no writer credential. Pull requests receive no private
reader and never publish. Enable DAVE_FORK_CI_ENABLED and NIKS3_PUSH_ENABLED in
repository settings; ATTIC_PUSH_ENABLED remains a compatibility gate. Never
commit credentials.
